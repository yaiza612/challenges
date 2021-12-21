require './auxiliar_functions.rb'
require 'bio'
require 'json'

organism1 = 'organism_TAIR10_cds_20101214_updated_aa.fa'
organism2 = 'organism_pep.fa'

# flatfasta

organism1_flatfasta = flatfasta(organism1)
organism2_flatfasta = flatfasta(organism2)

# we want just protein fasta files:

organism1_type = type(organism1_flatfasta)
organism2_type = type(organism2_flatfasta)

if organism1_type == "nucl"
  organism1_fasta = na2aa(organism1_flatfasta)
else
  organism1_fasta = organism1_flatfasta.instance_variable_get(:@stream).instance_variable_get(:@path)
end

if organism2_type == "nucl"
  organism2_fasta = na2aa(organism2_flatfasta)
else
  organism2_fasta = organism2_flatfasta.instance_variable_get(:@stream).instance_variable_get(:@path)
end

organism1_database = database_maker(organism1_flatfasta, organism1_fasta)
organism2_database = database_maker(organism2_flatfasta, organism2_fasta)


most_likely_orthologues = {}
puts 'Getting ready for the party'
besthit = best_hit(organism1_fasta, organism2_flatfasta)
organism1_flatfasta.each_entry do |entry| # check the id
  puts 'searching orthologues'
  next unless  besthit.value?(entry.entry_id)
  pair_hits = do_blast(organism2_fasta, entry)
  if besthit[pair_hits] == entry.entry_id
    most_likely_orthologues[pair_hits]=entry.entry_id
  end
end

# write report and json with orthologues to have something more easy to work appart from the report

# json
json = JSON.generate(most_likely_orthologues)
File.open('Orthologues.json', "w+") do |f|
  f.write(json)
end

# report
File.open('Orthologues.txt', "w+") do |file|
  file.write 'Pairs of most likely orthologues'
  file.write 'between the following organisms:'
  file.write([organism1[0..-4], organism2[0..-4]].join("\t"))
  file.write("\n")
  most_likely_orthologues.each do |i,j|
    file.write([i, j].join("\t"))
    file.write("\n")
    end
end


puts 'report written'
puts 'we are ready'
