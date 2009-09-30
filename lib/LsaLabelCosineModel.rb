require 'lib/LsaModel'
require 'lib/Label'

class LsaLabelCosineModel < LsaModel
  include Label
  
  def initialize
    super
    
    init_label(:cosine)
  end
end
