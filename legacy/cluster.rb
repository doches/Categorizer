require 'net/ssh'
require 'progressbar'

debug = ARGV.include?("-d") or ARGV.include?("--debug")
stream = ARGV.include?("-s") or ARGV.include?("--stream")

machines = Cluster[:machines]
jobs = Cluster[:jobs]

joblist = {}
machines.reject! { |machine| machine =~ /^#.*/ }
machines.each { |ip| joblist[ip.to_sym] = [] }
jobs.each_with_index do |job,index|
  joblist[machines[index % machines.size].to_sym].push job
end
machine_index = jobs.size

# Print commands and exit
if Cluster[:test]
  joblist.each_pair do |ip,list|
    if list.size > 0
      puts ip
      list.each { |cmd| puts cmd }
      print "\n"
    end
  end
  exit(0)
end
progress = ProgressBar.new("Farming",jobs.size) if not debug
output = []
threads = []
machines.each do |ip|
  threads << Thread.new(ip) do |ip|
    begin
      STDERR.puts "Forking thread for #{ip}" if debug
      Net::SSH.start(ip.to_s,"s0897549",:password => "d()ches42",:timeout => 2) do |session|
        while not jobs.empty?
          STDERR.puts "Jobs remaining: #{jobs.size} (#{ip})" if debug
          res = session.exec!(jobs.shift)
          if stream
            STDOUT.puts res
          else
            output.push res 
          end
          progress.inc if not debug
        end
      end
    rescue
      STDERR.puts "#{ip} not responding" if debug
    end
  end
end

threads.each { |t| t.join }
progress.finish if not debug
print output.join("") if not stream
