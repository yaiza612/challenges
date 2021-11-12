
class Protein

  attr_accessor :uni_prot_id 
  attr_accessor :intact_id
  attr_accessor :gene_id
  attr_accessor :links

  @@proteins = []


  def initialize (params = {})
    @gene_id = params.fetch(:gene_id, 'default')
    @uni_prot_id = params.fetch(:uni_prot_id, 'default')
    @intact_id = params.fetch(:intact_id, 'default')
    @links = params.fetch(:links, [])
    @@proteins << self
  end

  def self.id
    @gene_id
  end

  def self.all_proteins
    @@proteins
  end

  def self.find_protein(any_id)
    @@proteins.each do |protein|
      if protein.uni_prot_id == any_id
        return protein
      end
    end
  end

end
