require 'lib/LdaModel'
require 'lib/Label'

class LdaLabelCosineModel < LdaModel
  include Label
  
  def initialize
    super
    
    init_label(:cosine)
  end
end
