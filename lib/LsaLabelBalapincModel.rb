require 'lib/LsaLabelModel'

class LsaLabelBalapincModel < LsaLabelModel
  def initialize
    super(:balapinc)
  end
  
  def similarity(word,label)
    super(word,label)
  end
end
