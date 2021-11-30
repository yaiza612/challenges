require '../challenge 3/Functions'

gene_file = ARGV

if ARGV.length != 1 #https://code-mven.com/argv-the-command-line-arguments-in-ruby
warn 'Lacking arguments'
puts 'To run the program: ruby main.rb file'
abort
end

genes = load_gene_data(gene_file)
coordinates_all_genes = []
genes_without_region = Set.new
File.new('chromosome_features.gff', "w")
File.new('gene_features.gff', "w")
genes.each do |gene_id|
  sequence= retrieve_sequences(gene_id)
  coordinates = exon_scanner(sequence)
  if coordinates.empty?
    genes_without_region << gene_id
  else
    coordinates_all_genes << coordinates # just to check that everything is ok here
    create_my_features(coordinates, sequence, gene_id)
    create_my_chromosome_features(coordinates, sequence, gene_id)
    puts 'still getting ready for the party'
  end
end

report_maker(genes_without_region, filename='genes_whithout_cttctt.txt')
puts 'report written'
puts 'we are ready'

