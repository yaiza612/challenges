require './Interaction_network'
require 'json'

gene_file = ARGV
#gene_file = 'tiny.txt'
if ARGV.length != 1 #https://code-mven.com/argv-the-command-line-arguments-in-ruby
warn 'Lacking arguments'
puts 'To run the program: ruby main.rb gene_file'
abort
end

a = Interaction_network.new({:gene_file => gene_file})
puts "Looking at the genes of file #{gene_file}"
a.find_networks(a.genes, 0, {})
a.write_report

puts 'We are ready!'
