
require 'bio'

def rename(filename)
  File.rename(filename, "organism_#{filename}" )
  return "organism_#{filename}"
end

def descompress(file)
  if file.to_s.include?('.tar.zip')
    system("unzip #{file}")
    file = file.chomp('.zip') + '.fa'
  end
  return rename(file)
end

def flatfasta(filename)
  Bio::FlatFile.auto(filename)
end


def na2aa(filename)
  # No mezclemos churras con merinas
  # Both should be protein like they explain in the practices of metagenomics
  # Even if it can be done, don't going to have the same accuracy if we compare two different things
  name = filename.instance_variable_get(:@stream).instance_variable_get(:@path)
  name = name[0..-4]
  new_file = File.open("#{name}_aa.fa", 'w')
  filename.each_entry do |entry|
    protein = entry.naseq.translate # bioruby.org/doc/Tutorial.rd.html
    protein_str = protein.to_s
    protein_str = protein_str.tr("*", "") if protein_str.include?('*')
    seq = Bio::Sequence.new(protein_str)
    new_file.write seq.output_fasta(entry.definition)
    new_file.write("\n")
  end
  return new_file.to_s
  puts 'Conversion fatafile done'
end

def type(file)
  entry=Bio::Sequence.auto(file.next_entry.to_s).guess
  if entry==Bio::Sequence::NA
    type='nucl'
  elsif entry == Bio::Sequence::AA
    type='prot'
  end
  return type
end


def database_maker(file, fasta)
  type=type(file)
  system("mkdir Databases")
  system("makeblastdb -in #{fasta} -dbtype '#{type}' -out ./Databases/#{fasta.to_s}") # if type is equal nucl something is not working
  return
end


def do_blast(fasta,query)
  $e_value='-e 1e-6'
  factory=Bio::Blast.local("blastp","./Databases/#{fasta.to_s}","-F 'm S' #{$e_value}" )
  report=factory.query(query)
  # https://doi.org/10.1093/bioinformatics/btm585
  # Based on our results, the recommended parameters for the best detection of orthologs as reciprocal best hits
  # is the combination of soft filtering with a Smith–Waterman final alignment (the -F “m S” -s T options in NCBI's BLASTP).
  # These options resulted in both the highest number of orthologs and the minimal error rates.
  # However, most of the improvement can be achieved using soft filtering (-F “m S”) alone.
  return report.hits[0].definition.split("|")[0].strip unless report.hits[0].nil?
  # Other option is use .evalue and calculate the coverage of the hit like
  #  length_alignment = hit.query_end.to_f - hit.query_start.to_f
  #   length_query = (query.to_s).length.to_f
  #   coverage = length_alignment + 1 / length_query
  # Nevertheless the best results obtained are with the -F “m S” -s T options in NCBI's BLASTP as shown in the paper
end


def best_hit(fasta,queries)
  best_hit = {}
  queries.each_entry do |query|
    puts 'getting best hits'
    best_hit[query.entry_id]=do_blast(fasta,query) # add the information to the hash
  end
  return best_hit
end





