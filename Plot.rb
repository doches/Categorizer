require 'lib/Graph'
require 'lib/Report'
require 'lib/Significance'

# Draws a plot of the specified model results. 
#
# Usage: Ruby Plot.rb -t <gen|typ|nam> -r <regex> -o <prefix> <options>
# Options: 
#   -s    Also print significance information
regex = Regexp.compile(ARGV[ARGV.index("-r")+1])
task = ARGV[ARGV.index("-t")+1].downcase
prefix = ARGV[ARGV.index("-o")+1]
do_sig = ARGV.include?("-s")

files = []
Dir.foreach("results/#{task}/") do |file|
  files.push File.join("results/#{task}",file) if file.gsub(".result","") =~ regex
end

paths = []
workdir = Dir.getwd
STDERR.puts "Plotting #{files.map { |x| x.split("/").pop }.join(", ")} into #{prefix}..."
graph = nil
case task
  when "naming"
    graph = Graph::NamingBarPlot.new(files,prefix)
  when "generation"
    graph = Graph::GenerationPlot.new(files,prefix)
  when "typicality"
    graph = Graph::TypicalityPlot.new(files,prefix)
  else
    raise "Unrecognized task \"#{task}\" -- should be one of \"nam\",\"gen\",\"typ\""
end
paths.push graph.render
Dir.chdir(workdir)

if ARGV.include?("-v")
  `evince #{paths[0]}`
end

# Print significance information, if requested
if do_sig
  puts "\n\tSignificance Report:"
  test = task +"_test"
  p = [0.001,0.01,0.05]
  (0..graph.data.size-1).each do |a_i|
    (0..graph.data.size-1).each do |b_i|
      a = graph.data[a_i]
      b = graph.data[b_i]
      str = a[1].split("/").pop.split(".")[0] + " > " +  b[1].split("/").pop.split(".")[0]
      found_p = nil
      p.each do |p_value|
        if Significance.send(test,a[0],b[0],p_value)
          puts "#{str} (#{p_value})"
          found_p = p_value
          break
        end
      end
      #puts "NOT SIGNIFICANT: #{str}" if found_p.nil?
    end
  end
end
