# Get package for computing integrals in various distributions.
require 'vendor/statistics2'

# A flexible interpreter for the 'regress' tool. Parses regression test output
# into a more easily-accessed form, and provides some additional statistical 
# tools for analyzing the results.
#
# Currently, Regress only knows how to handle regression tests between two 
# variables. Additional variables (> 2) may work, but it hasn't been tested.
class Regress
  attr_reader :num_variables,:num_cases,:min,:max,:sum,:mean,:stddev,:slope,:intercept,:r,:r_squared,:se_est,:f,:prob

  # Helper method to format array-style input into something 'regress' will
  # merrily accept.
  def Regress.format_input(array)
    return array.map { |pair| pair.join("\t") }.join("\n")
  end
  
  # File path used for temporary files. Creating a Regress interpreter with an
  # array-of-arrays requires saving to a tempfile. Defaults to ".regress.tmp~"
  @@temporary_file = ".regress.tmp~"
  # Get path to temporary file
  def Regress.temporary_file
    return @@temporary_file
  end
  # Change path/filename Regress uses for temporary data files
  def Regress.temporary_file=(file)
    @@temporary_file = file
  end
  
  # Clean up temporary files? A tidy default says "yes!"
  @@cleanup = true
  # Test whether Regress cleans up temporary files. Defaults to true
  def Regress.cleanup?
    @@cleanup
  end
  # Chaneg whether Regress cleans up temporary files.
  def Regress.cleanup=(enabled)
    @@cleanup = enabled
  end

  # Create a new Regress interpreter. 'data' can be one of the following types:
  #
  # [filename]  If the filename ends with '.regress' the file is loaded as-is 
  #             and parsed as regress output. All other filenames are first run
  #             through 'regress' before processing.
  #
  # [array]     If data is an array of strings it is treated as regress output,
  #             otherwise it is dumped to a tempfile (Regress.temporary_file) 
  #             via Regress.format_input and run through 'regress'.
  def initialize(data)
    array_data = nil
    
    if data.is_a?(Array)
      if data[0].is_a?(String)
        array_data = data.map { |x| x.strip }
      else
        tmpfile = File.open(Regress.temporary_file,"w")
        tmpfile.puts Regress.format_input(data)
        tmpfile.close
        array_data = `cat #{Regress.temporary_file} | regress`.split("\n").map { |x| x.strip }
        `rm #{Regress.temporary_file}` if Regress.cleanup? # Delete temporary files if cleanup is on.
      end
    elsif data.is_a?(String)
      if not File.exists?(data)
        raise "File \"#{data}\" does not exist! (Regress.new)"
      end
      if data =~ /\.regress$/
        array_data = IO.readlines(data).map { |x| x.strip }
      else
        array_data = `cat #{data} | regress`.split("\n").map { |x| x.strip }
      end
    else
      raise "Regress needs either a string or an array of strings for processing."
    end
    
    process(array_data)
  end
  
  # Test whether the difference between two correlation coefficients is 
  # significant. From http://www.fon.hum.uva.nl/Service/Statistics/Two_Correlations.html
  # 
  # r1 and r2 should be Regress objects
  def Regress.diff_sig(r1,r2)
    z_a = 0.5 * Math.log( (1.0+r1.r) / (1-r1.r) )
    z_b = 0.5 * Math.log( (1.0+r2.r) / (1-r2.r) )
    z = (z_a - z_b) / Math.sqrt(1.0/(r1.num_cases-3) + 1.0/(r2.num_cases-3))
    return Statistics2.normalx__x(z)
  end
  
  private
  
  # Process regress output in the form of an array of strings (one line per 
  # string). Exceedingly ugly method...
  def process(array)
    # "Analysis for ..."
    words = array.shift.split(" ")
    @num_cases = words[2].to_i
    @num_variables = words[5].to_i
    # headers
    array.shift
    # Basic stats
    @min = array.shift.split(" ")[1].to_f
    @max = array.shift.split(" ")[1].to_f
    @sum = array.shift.split(" ")[1].to_f
    @mean= array.shift.split(" ")[1].to_f
    @stddev = array.shift.split(" ")[1].to_f
    # Ignore correlation matrix (for now)
    6.times { array.shift }
    # Regression equation
    array.shift #header
    eq = array.shift.split(" ")
    @slope = eq[2].to_f
    @intercept = eq[5].to_f
    array.shift # blank line
    # "Significance test..."
    array.shift #header
    array.shift #colheader
    vars = array.shift.split(" ")
    @r = vars[0].to_f
    @r_squared = vars[1].to_f
    @se_est = vars[2].to_f
    @f = vars[3].to_f
    @prob = vars[4].to_f
  end
end
