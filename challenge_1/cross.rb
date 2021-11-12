
#require 'statistics2'

class Cross
  attr_accessor :parent1  
  attr_accessor :parent2  
  attr_accessor :f2_wild
  attr_accessor :f2_p1
  attr_accessor :f2_p2
  attr_accessor :f2_p1p2
  attr_accessor :chisquare_dist_df3
  attr_accessor :pvalue

  @@crosses = []

  def initialize(params = {})
    @parent1 = params.fetch(:parent1, 0.00)
    unless @parent1.is_a? Gene
      warn 'parent1 should content the corresponding gene object'
      abort
    end
    @parent2 = params.fetch(:parent2, 0.00)
    unless @parent2.is_a? Gene
      warn 'parent2 should content the corresponding gene object'
      abort
    end
    @f2_p1 = params.fetch(:f2_p1, 0.00)
    @f2_p1 = @f2_p1.to_f
    @f2_p2 = params.fetch(:f2_p2, 0.00)
    @f2_p2 = @f2_p2.to_f
    @f2_wild = params.fetch(:f2_wild, 0.00)
    @f2_wild = @f2_wild.to_f
    @f2_p1p2 = params.fetch(:f2_p1p2, 0.00)
    @f2_p1p2 = @f2_p1p2.to_f
    @chi_square = chi_square

    @@crosses << self
  end

  def all_crosses
    @@crosses
  end

  def chi_square
    total = f2_wild + f2_p1 + f2_p2+ f2_p1p2
    # Mendel's independent segregation law: 9:3:3:1
    #expected
    d = total * 9/16
    h1 = total * 3/16
    h2 = total * 3/16
    r = total * 1/16
    pr_chitest = ((f2_wild-d)**2/d)  + ((f2_p1-h1)**2/h1) + ((f2_p2-h2)**2/h2) + ((f2_p1p2-r)**2/r)
    #pr = Statistics2.pchi2_x(pr_chitest, 3)
    # I wanted to implement this using the gem statistics2 but give me the same values all the time
    # not matter what you put no mather the degrees of freedom neither
    # 3 degrees of freedom
    critic_value = 7.8147
    if pr_chitest > critic_value
      @parent1.add_linked_gene(@parent2, pr_chitest)
      @parent2.add_linked_gene(@parent1, pr_chitest)
      STDERR.puts "chi square of #{pr_chitest} for #{parent1.gene_name} and #{parent2.gene_name}"
    end
  end
end
