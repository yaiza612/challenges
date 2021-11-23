# frozen_string_literal: true

require './Annotated_gene'
require 'mitab'
require './Rest_client'
require './Protein'
require 'set'

class Interaction_network
  attr_accessor :genes, :proteins, :original_genes

  def initialize(params = {})
    @genes = {}
    @proteins = {}
    gene_file = params.fetch(:gene_file)
    load_gene_data(gene_file)
  end

  def load_gene_data(file)
    gene_list = []
    gene_data = File.open(file, 'r')
    gene_data.each_line do |gene_id|
      gene_id.delete!("\n")
      gene_list << gene_id
    end
    gene_data.close
    gene_list.each do |gene_id|
      gene = Annotated_Gene.new(gene_id: gene_id)
      gene.annotation
      @genes[gene_id] = gene
      @original_genes = @genes
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
        next if value.nil? || value.empty? # check that we have retrieved the information

        # check that all are arabidopsis thaliana
        nodes.delete_if do |_key, value|
          value[:taxonomy][0] != 'taxid:3702(arath)'
        end
        value[:uniprot].each do |hash|
          regex_expression = Regexp.new(/^[Aa][Tt]\d[Gg]\d\d\d\d\d\(locus name\)$/)
          if hash[:value].match(regex_expression)
            locus_name = hash[:value][0, 9]
            locus_name[1] = 'T'
          else
            next
          end
          gene_name = value[:geneName].fetch(0) unless value[:geneName].empty? || value[:geneName].nil?
          uni_prot_id = value[:id] unless value[:id].empty? || value[:id].nil?
          intact_id = value[:altIds][0][:value] unless value[:altIds].empty? || value[:altIds].nil?
          if locus_name == gene_id
            gene.gene_name = gene_name
            protein = Protein.new(gene_id: gene)
            protein.uni_prot_id = uni_prot_id
            protein.intact_id = intact_id
            @proteins[uni_prot_id] = protein
          else
            unless locus_name.nil? || locus_name.empty?
              new_gene = Annotated_Gene.new(gene_id: locus_name, gene_name: gene_name)
              new_gene.annotation
              new_genes[locus_name] = new_gene
              new_protein = Protein.new(gene_id: new_gene)
              new_protein.uni_prot_id = uni_prot_id
              new_protein.intact_id = intact_id
              @proteins[uni_prot_id] = new_protein
            end
          end
        end
      end
      associations.each do |association|
        next if association.nil? || association.empty?

        interactor_a = association[:source]
        interactor_b = association[:target]
        if interactor_a == interactor_b
          next
        else
          method = association[:detMethods][0][:value]
          author = association[:firstAuthor][0]
          if !(association[:publications].nil? || association[:publications].empty?) && !(association[:publications][1].nil? || association[:publications][1].empty?) && !(association[:publications][1][:score].nil? || association[:publications][1][:score].empty?)
            pubmed_id = association[:publications][1][:score]
          end
          type_link = association[:intTypes][0][:value]
          miscore = association[:scores][0][:score]
          info_link = { method: method, author: author, pubmed_id: pubmed_id, type_link: type_link, miscore: miscore }
          unless @proteins[interactor_a].nil?
            @proteins[interactor_a].links[interactor_b] = info_link
          end
        end
      end
    end
    new_genes
  end

  def find_networks(old_front, depth, marked_as_expanded)
    puts 'Take a coffe in the meantime'
    wave_front = descendants(old_front)
    marked_as_expanded = marked_as_expanded.merge(old_front)
    marked_as_expanded.each_key { |key| wave_front.delete(key) }
    if depth.zero?
      wave_front.merge(old_front)
      wave_front
    else
      networks = find_networks(wave_front, depth - 1, marked_as_expanded)
      @genes.merge(networks)
      @genes.merge(marked_as_expanded)
    end
  end

  def write_report_for_one_protein(file, protein_id, already_written, d, special_protein)
    puts 'depth'
    puts d
    puts 'length'
    puts already_written.length
    protein = @proteins[protein_id]
    interactions = protein.interaction unless protein.nil?
    # interactions may be empty
    unless interactions.nil?
      interactions.each do |interaction|
        unless already_written.include? interaction[0] + protein_id
          unless already_written.include? protein_id + interaction[0]
          unless interaction[0] == special_protein
            file.write("The protein id #{protein_id}")
            file.write("interacts with the following proteins: \n")
            file.write(["protein_id", "author", "method", "pubmed id", "type of interaction", "confidence of interaction"].join("\t"))
            file.write("\n")
            file.write("#{(interaction).join("\t")} \n")
          # do not write a report if interaction[0] is in already_written
            already_written << interaction[0] + protein_id
            file.write("Depth of interactions = #{d} \n")
            already_written = write_report_for_one_protein(file, interaction[0], already_written, d+1, special_protein)
          end
          end
          end
      end
    end
    already_written
  end


  def write_recursive_report(filename= 'Report.txt')
    f = File.new(filename, 'w')
    f.write "\rRecursive report of iteraction networks found in genes \n"
    f.write "######################################################## \n"
    n = 1
    @proteins.each_value do |protein|
      already_written = Set.new
      f.write "\n"
      f.write "****************\n"
      f.write "Network #{n} \n"
      f.write "****************\n"
      n += 1
      f.write "Gene with id #{protein.gene_id.gene_id} \n"
      f.write "Gene from original list \n" if @original_genes[protein.gene_id.gene_id]
      unless protein.gene_id.kegg.empty?
        f.write "Information of the gene: \n"
        f.write "KEGG annotations: \n"
        protein.gene_id.kegg.each do |kegg_id, kegg_pathway|
          f.write "ID: #{kegg_id}, pathway name: #{kegg_pathway}\n"
        end
      end
      unless protein.gene_id.go.empty?
        f.write "GO annotations: \n"
        protein.gene_id.go.each do |array|
          array.each do
            f.write "ID: #{array[0]}, process: #{array[1]}\n"
          end
        end
      end
      f.write "Codify protein with id #{protein.uni_prot_id} \n"
      already_written = write_report_for_one_protein(f, protein.uni_prot_id, already_written, d=0, special_protein = protein.uni_prot_id)
      already_written << protein.uni_prot_id
    end
    f.close
  end


end







