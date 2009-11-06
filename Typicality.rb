require 'progressbar'
require 'lib/Oracle'
require 'lib/Models'

model = Models.load(ARGV[0].to_sym)
mcrae = ARGV.include?("--mcrae")
ARGV.reject! { |x| x == "--mcrae" }
exemplars = mcrae ? Oracle.mcrae_exemplars() : Oracle.exemplars()
labels = mcrae ? Oracle.mcrae_categories() : Oracle.categories

progress = ProgressBar.new("Typicality",exemplars.size)
counts = [0,0]
out = File.open("results/typicality/"+Models.output_path(ARGV[0].to_sym),"w")
exemplars.each do |exemplar|
  if exemplar.word =~ /^[a-zA-Z0-9]+$/ and model.query(exemplar.word)
    sim = model.similarity(exemplar.word,exemplar.category)
    if sim and not sim.nan?
      out.puts "#{exemplar.frequency}\t#{sim}"
      out.flush()
    end
    counts [0] += 1
  else
    #STDERR.puts "Skipping #{exemplar.word} (#{counts[0]}/#{counts[1]})"
  end
  progress.inc
  counts[1] += 1
end
progress.finish
out.close
