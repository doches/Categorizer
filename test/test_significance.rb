require 'test/unit'
require 'lib/Significance'
require 'lib/Report'

class TestSignificance < Test::Unit::TestCase
  def test_chi
    chi = Significance.chi_squared(175,200,125,250)
    assert_in_delta 70.42,chi,0.5
  end
  
  def test_chi_p
    chi = Significance.chi_squared(175,200,125,250)
    assert_equal true,Significance.chi_p(chi,0.05)
    assert_equal true,Significance.chi_p(chi,0.01)
  end
  
  def test_naming
    a = Report::NamingData.new("results/naming/McraeMcraeBaseline.report")
    b = Report::NamingData.new("results/naming/McraeDepspaceCw.report")
    
    # This isn't the best test, because I'm not sure that these two are sig. different --
    # but they look like they ought to be, and identical samples should not be.
    assert_equal true,Significance.naming_test(a,b)
    assert_equal false,Significance.naming_test(a,a)
    assert_equal false,Significance.naming_test(b,b)
  end
  
  def test_typicality
    a = Report::TypicalityData.new("results/typicality/McraeLsaBaseline.report")
    b = Report::TypicalityData.new("results/typicality/McraeLsaClutoAgglo.report")
    assert_equal true,Significance.typicality_test(a,b)
    assert_equal false,Significance.typicality_test(a,a)
    assert_equal false,Significance.typicality_test(b,b)
  end

  def test_generation
    a = Report::GenerationData.new("results/generation/McraeLsaBaseline.report",true)
    b = Report::GenerationData.new("results/generation/McraeLsaAutoclass.report",true)
    assert_equal true,Significance.generation_test(a,b)
    assert_equal false,Significance.generation_test(a,a)
    assert_equal false,Significance.generation_test(b,b)
  end
end
