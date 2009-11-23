require 'test/unit'
require 'lib/Report'

class TestRegress < Test::Unit::TestCase
  def setup
  
  end
  
  def test_typicality_create
    typicality = Report::TypicalityData.new("results/typicality/LsaBaseline.report")
    p typicality.correlation
  end
end
