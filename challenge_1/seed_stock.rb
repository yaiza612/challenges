require 'date'

# Create an object stock and return current stock
class Stock
  attr_accessor :seed_stock, :mutant_gene_id, :last_planted, :storage, :grams_remaining

  @@stocks = []

  # @param [seed_stock, mutant_gene_id, last_planted, storage, grams_remaining] params
  def initialize(params = {})
    @seed_stock = params.fetch(:seed_stock, 'default')
    @mutant_gene_id = params.fetch(:mutant_gene_id, 'default')
    unless @mutant_gene_id.is_a? Gene
      warn 'mutant_gene_id should be content the corresponding gene object'
      abort
    end
    @last_planted = params.fetch(:last_planted, 'default')
    @storage = params.fetch(:storage, 'default')
    @grams_remaining = params.fetch(:grams_remaining, 'default')
    @grams_remaining = @grams_remaining.to_i unless @grams_remaining.is_a? Integer

    @@stocks << self
  end

  def self.all_stocks
    @@stocks
  end

  def to_a
    [seed_stock, mutant_gene_id.gene_id, last_planted, storage, grams_remaining]
  end

  def self.find_stock(any_id)
    @@stocks.each do |stock|
      if stock.seed_stock == any_id
        return stock
        end
    end
  end

  def plant(num)
    @grams_remaining -= num
    unless @grams_remaining.positive?
      @grams_remaining = 0
      warn "Hey! You need more stock of #{@seed_stock} (locus #{@mutant_gene_id.gene_id})"
    end
    current_date = DateTime.now.strftime('%-d/%-m/%Y')
    @last_planted = current_date
  end
end
