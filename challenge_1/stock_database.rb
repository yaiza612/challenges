require 'csv'
require './gene'
require './seed_stock'
require './cross'


# Create the object database which load the files, and also write the new current database
class Database
  attr_accessor :genes, :stock_header, :stocks, :crosses, :crosses_header, :genes_header

  def initialize(params = {})
    @genes = {}
    @stocks = {}
    @crosses = []
    gene_file = params.fetch(:gene_file)
    stock_file = params.fetch(:stock_file)
    cross_file= params.fetch(:cross_file)
    load_genes(gene_file)
    load_stock(stock_file)
    load_crosses(cross_file)
  end

  def load_genes(file)
    gene_data = CSV.read(file, col_sep: "\t", headers: true, header_converters: :symbol, converters: :all, :encoding => 'utf-8')
    @genes_header = gene_data.headers
    abort "File #{file} passed unordered, to run the program: ruby main.rb gene_file stock_file cross_file new_file" unless @genes_header.length == 3
    gene_data.map do |gene|
      g = gene.to_hash
      id = g[:gene_id]
      @genes[id] = Gene.new(g)
    end
  end

  def load_stock(file)
    stock_data = CSV.read(file, col_sep: "\t", headers: true, header_converters: :symbol, converters: :all)
    @stock_header = stock_data.headers
    abort "File #{file} passed unordered, to run the program: ruby main.rb gene_file stock_file cross_file new_file" unless @stock_header.length == 5
    stock_data.map do |stock|
      s = stock.to_hash
      gene_object = Gene.find_gene(s[:mutant_gene_id])
      warn 'That gene is not in the database' if gene_object.nil?
      s[:mutant_gene_id] = gene_object
      id = s[:seed_stock]
      @stocks[id] = Stock.new(s)
    end

  end

  def load_crosses(file)
    crosses_data = CSV.read(file, col_sep: "\t", headers: true, header_converters: :symbol, converters: :all)
    @crosses_header = crosses_data.headers
    abort "File #{file} passed unordered, to run the program: ruby main.rb gene_file stock_file cross_file new_file" unless @crosses_header.length == 6
    crosses_data.map do |cross|
      c = cross.to_hash
      stock_object_1 = Stock.find_stock(c[:parent1])
      c[:parent1] = stock_object_1.mutant_gene_id
      stock_object_2 = Stock.find_stock(c[:parent2])
      c[:parent2] = stock_object_2.mutant_gene_id
      @crosses = Cross.new(c)
    end
  end

  def write_database(name_database)
    CSV.open(name_database, 'w',col_sep: "\t", headers: true) do |tsv|
      tsv << @stock_header
      Stock.all_stocks.each do |current_stock|
        tsv << current_stock.to_a
      end
    end
    STDOUT.puts('We are ready!')
  end

end

