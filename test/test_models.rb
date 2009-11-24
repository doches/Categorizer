require 'lib/Models'
require 'test/unit'

class TestModels < Test::Unit::TestCase
  def test_labels
    map = {
      "McraeLsaAutoclass" => "Bayesian",
      "McraeLdaAutoclass" => "Bayesian",
      "DepspaceAutoclass" => "Bayesian",
      "McraeMcraeCw" => "Graph",
      "McraeMcraeClutoRb" => "Top-Down",
      "LsaBaseline" => "Oracle",
      "McraeMcraeBaseline" => "Oracle"
    }
    map.each_pair do |klass,label|
      assert_equal label,Models.class_to_label(klass)
    end
  end

  def test_space_labels
    map = {
      "McraeLsaAutoclass" => "Lsa",
      "McraeLdaAutoclass" => "Lda",
      "DepspaceAutoclass" => "Depspace",
      "McraeMcraeClutoRb" => "Mcrae",
      "LsaBaseline" => "Lsa",
      "McraeMcraeCw" => "Mcrae"
    }
    map.each_pair do |klass,label|
      assert_equal label,Models.class_to_label(klass,true)
    end
  end
end
