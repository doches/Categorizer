require 'progressbar'
require 'lib/Oracle'
require 'lib/Models'

mcrae = ARGV.include?("--mcrae")
ARGV.reject! { |x| x == "--mcrae" }

model = Models.load(ARGV[0].to_sym)
exemplars = mcrae ? Oracle.mcrae_exemplars() : Oracle.exemplars()
labels = mcrae ? Oracle.mcrae_categories() : Oracle.categories

progress = ProgressBar.new("Naming",exemplars.size)
out = File.open("results/naming/"+Models.output_path(ARGV[0].to_sym),"w")
exemplars.each do |exemplar|
  if exemplar.word =~ /^[a-zA-Z0-9]+$/ and model.query(exemplar.word)
  
    ranks = labels.map { |label| [label,model.similarity(exemplar.word,label)] }
    begin
      ranks = ranks.sort { |a,b| b[1] <=> a[1] }
    rescue
      p ranks
      raise $!
    end

    out.print "#{exemplar.word} (#{exemplar.category}): "
    out.puts ranks.map { |x| "#{x[0]} (#{x[1]})"}.join("  ")
    out.flush()
#    print "#{exemplar.word} (#{exemplar.category}): "
#    puts ranks.map { |x| "#{x[0]} (#{x[1]})"}.join("  ")
  else
    #STDERR.puts "Skipping #{exemplar.word}"
  end
  progress.inc
end
progress.finish
out.close
