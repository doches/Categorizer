STDIN.each_line do |line|
  puts line.strip if not line.split("\t")[1].strip.to_f == 0.0
end
