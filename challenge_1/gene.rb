
class Gene

  attr_accessor :gene_id
  attr_accessor :gene_name
  attr_accessor :mutant_phenotype
  attr_accessor :genes_linked

  @@genes = []

  def initialize(params = {})
    # best initialization lesson 2
    gene_code = params.fetch(:gene_id, 'default')
    # solution of one exercise lesson 2
    gene_match = Regexp.new(/A[Tt]\d[Gg]\d\d\d\d\d/)
    if gene_match.match(gene_code)
      @gene_id = gene_code
    else
      warn 'This gene id is not valid'
      abort
    end
    @gene_name = params.fetch(:gene_name, 'default')
    @mutant_phenotype = params.fetch(:mutant_phenotype, 'default')
    @genes_linked = {}
    @@genes << self


  end

  def self.all_genes
    @@genes
  end

  def self.find_gene(any_id)
    @@genes.each do |gene|
      if gene.gene_id == any_id
        return gene
      end
    end
  end

  def add_linked_gene(gene, test)
    @genes_linked[gene] = test
  end
end

