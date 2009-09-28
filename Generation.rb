require 'progressbar'
require 'lib/Oracle'
require 'lib/Models'

model = Models.load(ARGV[0].to_sym)
exemplars = Oracle.exemplars()
labels = Oracle.categories()

progress = ProgressBar.new("Generation",labels.size)
out = File.open("results/generation/"+Models.output_path(ARGV[0].to_sym),"w")

labels.each do |label|
  best = []
  best_ex = []
  iprogress = ProgressBar.new(label,exemplars.size)
  exemplars.each_with_index do |exemplar,i|
   if exemplar.word =~ /^[a-zA-Z0-9]+$/
    sim = model.similarity(exemplar.word,label)
    if sim and not sim.nan?
      found = false
      best.each_with_index { |x,i| found ||= (x[0] == exemplar.word ? i : false) }
      if found
        best[found][1] = sim if best[found][1] < sim
      elsif best.size < 20
        best.push [exemplar.word,sim]
      elsif sim > best[19][1]
        best.push [exemplar.word,sim]
      end
      best.sort! { |a,b| b[1] <=> a[1] }
      best = best[0..19]
    end
   end
#   STDERR.puts "#{label}: " + best[0..9].map { |x| x[0] }.join("\t") if i % 1000 == 0
   iprogress.inc
  end
  iprogress.finish
#  print "#{label}: "
#  puts best.map { |x| "#{x[0]}" }.join(", ")
  out.print "#{label}: "
  out.puts best.map { |x| "#{x[0]}" }.join(", ")
  progress.inc
end
progress.finish
out.close
