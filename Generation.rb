require 'progressbar'
require 'lib/Oracle'
require 'lib/Models'

def generate_exemplars_for_category(label,out)
#  out = File.open(filepath,"w")
  best = []
  best_ex = []
  iprogress = ProgressBar.new(label,@exemplars.size)
  
  begin
  @exemplars.each_with_index do |exemplar,i|
   if exemplar.word =~ /^[a-zA-Z0-9]+$/
    sim = @model.similarity(exemplar.word,label)
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
  end
  rescue RuntimeError
    STDERR.puts "No cluster labels found, dropping category"
  end
  out.print "#{label}: "
  out.puts best.map { |x| "#{x[0]}" }.join(", ")
#  out.close
end

model_sym = ARGV[0].to_sym
#label = ARGV[1]

@model = Models.load(model_sym)
@exemplars = (ARGV.include?("--mcrae") ? Oracle.mcrae_exemplars : Oracle.exemplars)
labels = ARGV.include?("--mcrae") ? Oracle.mcrae_categories : Oracle.categories

path = "results/generation/"+Models.output_path(model_sym)
fout = File.open(path,"w")
progress = ProgressBar.new("Generating",labels.size)
labels.each do |label|
  generate_exemplars_for_category(label,fout)
  progress.inc
end
progress.finish
fout.close
