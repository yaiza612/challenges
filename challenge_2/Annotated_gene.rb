require '../challenge_1/gene'
require 'rest_client'
require 'json'
require './Rest_client'

class Annotated_Gene < Gene
  attr_accessor :kegg
  attr_accessor :go

  def initialize(params = {})
    super
    @kegg= params.fetch(:kegg, {})
    @go= params.fetch(:go, {})
  end


  def annotation

    url_kegg= URI("http://togows.org/entry/kegg-genes/ath:#{self.gene_id}/pathways.json")
    url_go = URI("http://togows.org/entry/ebi-uniprot/#{self.gene_id}/dr.json")

    response_KEGG = retrieve(url_kegg)
    response_GO = retrieve(url_go)

    data_KEGG = JSON.parse(response_KEGG.body)[0]
    data_GO = JSON.parse(response_GO.body)[0]


    unless data_KEGG.nil?
      data_KEGG.each do |keeg_id, pathway_name|
        self.kegg[keeg_id] = pathway_name
      end
    end

    #dataGo return a hash with key Go for GO ontology and inside we have an array, one of the elements of the array
    # have the information of the biological process, and we only want that one
    unless data_GO["GO"].nil?
      data_GO["GO"].each do |element|
        if element[1] =~ /^P:/
          self.go[element[0]] = element[1].sub(/P:/, "")
        end
      end
    end
  end
end












