require 'main_function'

organism1 = ARGV[0]
organism2 = ARGV[1]

unless organism1 && organism2 #https://code-mven.com/argv-the-command-line-arguments-in-ruby
  warn 'Lacking arguments'
  puts 'To run the program: ruby main.rb fastafile fastafile'
  abort
end

do_assignment(organism1, organism2)

puts 'report written'
puts 'we are ready'
