require 'test/unit'
require 'lib/Regress'

class TestRegress < Test::Unit::TestCase
  def setup
    @data = [ [0,0],
              [1,0],
              [1,1],
              [2,2]
            ]
  end
  
  def test_format_input
    txt = <<TXT
0	0
1	0
1	1
2	2
TXT
    assert_equal txt.strip,Regress.format_input(@data),"Malformed string output from Regress.format_input, string:\n\"#{Regress.format_input(@data)}\"\n\tshould have been:\n\"#{txt.strip}\""
  end
  
  def test_cleanup
  	Regress.cleanup = true
  	regress = Regress.new(@data)
  	assert(!File.exists?(Regress.temporary_file), "#{Regress.temporary_file} should not still exist (cleanup enabled)")
  end
  
  def test_no_cleanup
  	Regress.cleanup = false
  	regress = Regress.new(@data)
  	assert_equal false,Regress.cleanup?,"Regress.cleanup=false has no effect"
  	assert File.exists?(Regress.temporary_file), "#{Regress.temporary_file} should still exist with cleanup disabled..."
  	`rm #{Regress.temporary_file}`
  	Regress.cleanup=true
  end
  
  def test_change_tempfile
  	Regress.cleanup = false
  	orig_file = Regress.temporary_file
  	Regress.temporary_file = ".test_temp_file~"
  	assert_equal ".test_temp_file~",Regress.temporary_file,"Regress.temporary_file = \"#{Regress.temporary_file}\" after modification to \".test_temp_file~\""
  	regress = Regress.new(@data)
  	assert File.exists?(".test_temp_file~"), "Modified tempfile doesn't exist!"
  	`rm .test_temp_file~`
  	Regress.temporary_file = orig_file
  	Regress.cleanup = true
  end
  
  def test_init_array_num
    regress = nil
    assert_nothing_raised { regress = Regress.new(@data) }
    assert_equal 0.8528,regress.r,"r check failed"
  end
  
  def test_init_array_strings
    regress = nil
    fout = File.open(Regress.temporary_file,"w")
    fout.puts Regress.format_input(@data)
    fout.close
    output = `cat #{Regress.temporary_file} | regress`.split("\n")
    `rm #{Regress.temporary_file}`
    assert_nothing_raised { regress= Regress.new(output) }
    assert_equal 0.8528,regress.r,"r check failed"
  end
  
  def test_init_filename_data
    regress = nil
    fout = File.open(Regress.temporary_file,"w")
    fout.puts Regress.format_input(@data)
    fout.close
    assert_nothing_raised { regress= Regress.new(Regress.temporary_file) }
    assert_equal 0.8528,regress.r,"r check failed"
    `rm #{Regress.temporary_file}`
  end
  
  def test_init_filename_report
    regress = nil
    fout = File.open(Regress.temporary_file,"w")
    fout.puts Regress.format_input(@data)
    fout.close
    filename = ".test.regress"
    output = `cat #{Regress.temporary_file} | regress > #{filename}`
    `rm #{Regress.temporary_file}`
    assert File.exists?(filename),"Attempt to create regression output file failed"
    assert_nothing_raised { regress= Regress.new(filename) }
    assert_equal 0.8528,regress.r,"r check failed"
    `rm #{filename}`
  end
  
  def test_nums
  	regress = Regress.new(@data)
  	assert_equal 2, regress.num_variables, "num_variables"
  	assert_equal @data.size, regress.num_cases, "num_cases"
  end
  
  def test_stats
    regress = Regress.new(@data)
  	assert_equal 0.0, regress.min, "Min"
  	assert_equal 2.0, regress.max, "Max"
  	assert_equal 4.0, regress.sum, "Sum"
  	assert_equal 1.0, regress.mean, "Mean"
  	assert_equal 0.8165, regress.stddev, "SD"
  end
  
  def test_eq
    regress = Regress.new(@data)
    assert_equal 0.7273,regress.slope,"Slope"
    assert_equal 0.454545,regress.intercept,"Intercept"
  end
  
  def test_sig
    regress = Regress.new(@data)
    assert_equal 0.8528,regress.r,"r"
    assert_equal 0.7273,regress.r_squared,"r_squared"
    assert_equal 0.5222,regress.se_est,"se_est"
    assert_equal 5.3333,regress.f,"f"
    assert_equal 0.1472,regress.prob,"prob"
  end
  
  def test_diffsig
    a = [ [0,0], [1,0], [2,1], [3,3], [4,1] ]
    b = [ [0,0], [1,0], [2,1], [3,3], [4,2] ]
    5.times { a.push [2,0]; b.push [0,2] }
    ra = Regress.new(a)
    rb = Regress.new(b)
    assert_in_delta 0.487,Regress.diff_sig(ra,rb),0.001
  end
  
  def test_convert_to_ranks
    data = [ [:a,0.8],[:b,1.2],[:c,1.2],[:d,2.3],[:e,18]]
    ranks = Regress.convert_to_ranks(data)
    assert_equal ranks[:b],ranks[:c],"Items with the same score should have the same rank"
    assert_operator ranks[:a], :<, ranks[:b]
    assert_operator ranks[:a], :<, ranks[:d]
  end
  
  def test_pearson
    a = [ [:a,0.8],[:b,1.2],[:c,1.2],[:d,2.3],[:e,18]]
    b = [ [:b,0.7],[:a,1.1],[:c,2.3],[:d,2.3],[:e,18]]
    data = a.map { |pair| [pair[1],b.reject { |m| m[0] != pair[0]}[0][1]] }
    p Regress.new(data).r
    p Regress.pearson(a,b)
  end
end
