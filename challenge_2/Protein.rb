
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
    @links = params.fetch(:links, {})
    @@proteins << self
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


  def interaction
    unless self.links.empty? || self.links.nil?
      interactions = []
      self.links.each do |key, value|
        interactor = key
        unless value.nil? || value.empty?
          info = value
          author = info[:author] unless info[:author].nil?
          method = info[:method] unless info[:method].nil?
          pubmed = info[:pubmed_id] unless info[:pubmed_id].nil?
          type = info[:type_link] unless  info[:type_link].nil?
          miscore = info[:miscore] unless info[:miscore].nil?
        end
        interactions << [interactor, author, method , pubmed, type, miscore]
      end
    end
    return interactions
  end

end


