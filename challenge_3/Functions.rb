require 'rest-client'
require 'bio'
require '../challenge_2/Rest_client'
require 'set'
require 'csv'
require '../challenge 3/indexes'

def load_gene_data(file)
  gene_list = []
  gene_data = File.open(file, 'r')
  gene_data.each_line do |gene_id|
    gene_id.delete!("\n")
    gene_list << gene_id
  end
  gene_data.close
  gene_list
end

def retrieve_sequences(gene_id)
  url_sequences = "http://www.ebi.ac.uk/Tools/dbfetch/dbfetch?db=ensemblgenomesgene&format=embl&id=#{gene_id}"
  response = retrieve(url_sequences)
  bio = Bio::EMBL.new(response)
  sequence = bio.to_biosequence
  sequence
end

def report_maker(set, filename)
  f =  File.new(filename, "w")
  f.write "These are the genes without CTTCTT region found it:\n"
  set.each do |gene_id|
    f.write "#{gene_id}\n"
  end
  f.write "Total: #{set.length}"
  f.close
end

def create_my_features(coordinates, sequence, gene_id)
  exon_features = []
  coordinates.each do |key, value|
    my_features = Bio::Feature.new("#{$fw_region.upcase}", "#{key[0]}..#{key[1]}")
    my_features.append(Bio::Feature::Qualifier.new('strand', value[1]))
    my_features.append(Bio::Feature::Qualifier.new('exon', value[0]))
    my_features.append(Bio::Feature::Qualifier.new('nucleotide region', "#{$fw_region.upcase}"))
    CSV.open("gene_features.gff", 'a',col_sep: "\t", headers: true) do |tsv|
      tsv << [gene_id, 'region_CTTCTT', 'exon', key[0], key[1], '.', value[1], '.', "ID= #{value[0]}"]
      exon_features << my_features
    end
  end
  sequence.features.concat(exon_features)
    puts 'The new features are added to the bio-objects'
    puts 'Writing to my GFF'
end

def create_my_chromosome_features (coordinates,  sequence, gene_id)

  chrom = sequence.primary_accession.split(":")
  chromosome = [chrom[2], chrom[3], chrom[4]]
  # examples AC   chromosome:TAIR10:5:22038165:22039568:1
  coordinates.each do |key, value|
    begin_chr= chromosome[1].to_i + key[0]
    end_chr= chromosome[1].to_i + key[1]
    #write GFF file to avoid double iteration
     # write it here to avoid double iteration
    CSV.open("chromosome_features.gff", 'a',col_sep: "\t", headers: true) do |tsv|
      tsv << ["Chr#{chromosome[0]}", 'region_CTTCTT', "exon#{value[0]}", begin_chr, end_chr, '.', value[1], '.', "ID=gene_id#{gene_id}"]
    end
  end
  puts 'Retrieving features of chromosome'
  puts 'Writing to my other GFF'
end

def exon_scanner (sequence)
  coordinates = {}
    # https://www.javatpoint.com/ruby-variables
    $fw_region = 'cttctt'
    # in the reverse strand the complementary region is gaagaa and the inverse is aagaag
    $re_region = 'aagaag'
    length = sequence.length
    fw_coordinates = sequence.indices /#{$fw_region}/
    re_coordinates = sequence.reverse_complement.indices /#{$re_region}/
    features = sequence.features
    features.each do |feature|
      id_search = Regexp.new(/[Aa][Tt]\d[Gg]\d\d\d\d\d.\d.exon\d/)
      if feature.feature == 'exon'
        id = feature.qualifiers[0].value
        exon_id = id[id_search] #re.search is in python
        exon_position = feature.position
        if exon_position =~ /complement/ # first gene id I tried AT4g02770 is in reverse strand, this start by complement
          coordinate = feature.position.match(/[0-9]+\.\.[0-9]+/).to_s.split("..")
          coordinates_exon = []

          coordinate.each do |coord|
            coordinates_exon.insert(0, length - coord.to_i)
          end

          strand = '-'
          re_coordinates.each do |starting|

            ending = starting + $re_region.length - 1

            if (starting >= coordinates_exon[0]) && (starting <= coordinates_exon[1]) && (ending >= coordinates_exon[0]) && (ending <= coordinates_exon[1])

              exon_end = length - ending
              exon_start = length - starting
              coordinates[[exon_end, exon_start]] = [exon_id, strand]
            end

          end

        else # forward strand
          coordinate_exon = exon_position.split("..")
          strand = '+'
          fw_coordinates.each do |starting|
            ending = starting + $fw_region.length - 1
            if (starting >= coordinate_exon[0].to_i) && (starting <= coordinate_exon[1].to_i) && (ending >= coordinate_exon[0].to_i) && (ending <= coordinate_exon[1].to_i)
              coordinates[[starting, ending]] = [exon_id, strand]
            end
          end
        end
      end
    end
  puts 'searching for region CTTCTT and adding coordinates to features'
  return coordinates
end





