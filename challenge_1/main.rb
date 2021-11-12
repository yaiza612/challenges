require './stock_database'
#To generate the stock_database the following files are required:
#gene_file= 'gene_information.tsv'
#stock_file= 'seed_stock_data.tsv'
#cross_file= 'cross_data.tsv'
gene_file, stock_file, cross_file, new_file = ARGV

if ARGV.length != 4  #https://code-mven.com/argv-the-command-line-arguments-in-ruby
  warn 'Lacking arguments'
  puts 'To run the program: ruby main.rb gene_file stock_file cross_file new_file'
  abort

end

warn "File #{gene_file} does not exist" unless File.exist?(gene_file)
warn "File #{stock_file} does not exist" unless File.exist?(stock_file)
warn "File #{cross_file} does not exist" unless File.exist?(cross_file)
abort 'Check that you put well the name' unless File.exist?(gene_file) && File.exist?(stock_file) && File.exist?(cross_file)



stock_database = Database.new({
                          :gene_file => gene_file,
                          :stock_file => stock_file,
                          :cross_file => cross_file,
                        })


stock_database.stocks.each do |stock|
  id, s = stock
  s.plant(7)
end

stock_database.write_database(new_file)

puts 'Report of linked genes'

stock_database.genes.each do |gene|
  gene_id, g = gene
  warn 'No linked genes were found' if g.genes_linked.nil?
  g.genes_linked.each do |linked|
    linked_gene, test = linked
    puts "#{g.gene_name} is linked to #{linked_gene.gene_name}"
  end
end





