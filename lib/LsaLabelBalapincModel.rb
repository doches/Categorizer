require 'lib/LsaModel'
require 'lib/Label'

class LsaLabelBalapincModel < LsaModel
  include Label
  
  def initialize
    super
    
    init_label(:balapinc)
  end
end
