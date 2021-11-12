require './Annotated_gene'
require 'mitab'
require './Rest_client'
require './Protein'
require 'set'

class Interaction_network
  attr_accessor :genes, :proteins

  def initialize(params = {})
    @genes = {}
    @proteins = {}
    gene_file = params.fetch(:gene_file)
    load_gene_data(gene_file)
  end

  def load_gene_data(file)
    gene_list = []
    gene_data = File.open(file, "r")
    gene_data.each_line do |gene_id|
      gene_id.delete!("\n")
      gene_list << gene_id
    end
    gene_data.close
    gene_list.each do |gene_id|
      gene = Annotated_Gene.new(:gene_id => gene_id)
      gene.annotation
      @genes[gene_id] = gene
    end
  end


  def descendants(active_genes)
    new_genes = {}
    active_genes.each_value do |gene|
      gene_id = gene.gene_id
      id = gene_id.capitalize
      url_interactions = URI("http://www.ebi.ac.uk/Tools/webservices/psicquic/intact/webservices/current/search/interactor/#{id}?format=tab25")
      response_intact = retrieve(url_interactions)
      data_intact = Mitab::MitabParser.new(response_intact)
      nodes = data_intact.nodes
      associations = data_intact.links
      nodes.each_value do |value|
        unless value.nil? || value.empty? # check that we have retrieved the information
          nodes.delete_if{|key, value| value[:taxonomy][0] != 'taxid:3702(arath)'} # check that all are arabidopsis thaliana
          value[:uniprot].each do |hash|
            regex_expression = Regexp.new(/^[Aa][Tt]\d[Gg]\d\d\d\d\d\(locus name\)$/)
            if hash[:value].match(regex_expression)
              locus_name = hash[:value][0,9]
              locus_name[1]='T'
            else
              next
            end
            gene_name = value[:geneName].fetch(0) unless value[:geneName].empty? || value[:geneName].nil?
            uni_prot_id = value[:id] unless value[:id].empty? || value[:id].nil?
            intact_id = value[:altIds][0][:value] unless value[:altIds].empty? || value[:altIds].nil?
            if locus_name == gene_id
              gene.gene_name = gene_name
              protein = Protein.new(:gene_id => gene)
              protein.uni_prot_id = uni_prot_id
              protein.intact_id = intact_id
              @proteins[uni_prot_id] = protein
            else
              unless locus_name.nil? || locus_name.empty?
                new_gene = Annotated_Gene.new(:gene_id => locus_name, :gene_name => gene_name)
                new_gene.annotation
                new_genes[locus_name] = new_gene
                new_protein = Protein.new(:gene_id => new_gene)
                new_protein.uni_prot_id = uni_prot_id
                new_protein.intact_id = intact_id
                @proteins[uni_prot_id] = new_protein
              end
            end
          end
        end
      end
      associations.each do |association|
        unless association.nil? || association.empty?
          interactor_a = association[:source]
          interactor_b = association[:target]
          if interactor_a == interactor_b
            next
          else
            method = association[:detMethods][0][:value]
            author = association[:firstAuthor][0]
            unless association[:publications].nil? || association[:publications].empty?
              unless association[:publications][1].nil? || association[:publications][1].empty?
                unless association[:publications][1][:score].nil? || association[:publications][1][:score].empty?
                  pubmed_id = association[:publications][1][:score]
                end
              end
            end
            type_link = association[:intTypes][0][:value]
            miscore = association[:scores][0][:score]
            info_link = {method: method, author: author, pubmed_id: pubmed_id, type_link: type_link, miscore: miscore}
            unless @proteins[interactor_a].nil?
              @proteins[interactor_a].links << {interactor: interactor_b, info: info_link}
            end
          end
        end
      end
    end
    new_genes
  end

  def find_networks(old_front, depth, marked_as_expanded)
    puts "Take a coffe in the meantime"
    wave_front = descendants(old_front)
    marked_as_expanded = marked_as_expanded.merge(old_front)
    marked_as_expanded.each_key{|key| wave_front.delete(key)}
    if depth == 0
      wave_front.merge(old_front)
      wave_front
    else
      networks = find_networks(wave_front, depth - 1, marked_as_expanded)
      @genes.merge(networks)
      @genes.merge(marked_as_expanded)
    end
  end


  def write_report(filename= 'Report.txt')
    f = File.new(filename, "w")
    f.write "\r" + "Detailed report of iteraction networks found in genes \n"
    f.write "######################################################## \n"
    n = 1
    @proteins.each_value do |protein|
      f.write "Network #{n} \n"
      f.write "################### \n"
      f.write "################### \n"
      n += 1
      f.write "#{protein.gene_id.gene_id} \n"
      f.write "Information of the gene: \n"
      unless protein.gene_id.kegg.empty?
        f.write "KEGG annotations for all the genes in the network: \n"
        protein.gene_id.kegg.each do |kegg_id, kegg_pathway|
          f.write "ID: #{kegg_id}, pathway name: #{kegg_pathway}\n"
        end
      end
      unless protein.gene_id.go.empty?
        f.write "GO annotations for all the genes in the network: \n"
        protein.gene_id.go.each do |hash|
          hash.each do |go_id, go_process|
            f.write "ID: #{go_id}, process: #{go_process}\n"
          end
        end
      end
      f.write "that codify  #{protein.uni_prot_id} interact with: \n"
      unless protein.links.empty? || protein.links.nil?
        protein.links.each do |object_protein| # object protein is every hash of the list found in protein_links
          unless object_protein[:interactor].nil? || object_protein[:interactor].empty?
            object = Protein.find_protein(object_protein[:interactor]) #with the protein_id we can find the protein object that allow us to find out the gene_id
            if object.is_a? Protein #the function find protein sometimes return an array instead if the id is not found (really weird)
              info = object_protein[:info] unless object_protein[:info].empty? || object_protein[:info].nil?
              f.write "#{object.gene_id.gene_id} that codify #{object.uni_prot_id} with: \n"
              f.write "INFO OF THE ASSOCIATION \n"
              # info_link = {method: method, author: author, pubmed_id: pubmed_id, type_link: type_link, miscore: miscore}
              f.write "Discover by #{info[:method]}, by #{info[:author]}, you can found it in pubmed with id: #{info[:pubmed_id]} \n"
              f.write "Is a #{info[:type_link]}, with confidence level represented by miscore : #{info[:miscore]} \n"
            else
              next
            end
          end
        end
      end
    end
    f.close
    puts 'Report written'
  end
end





