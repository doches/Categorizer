require 'lib/DepspaceModel'
require 'lib/Label'

class DepspaceLabelCosineModel < DepspaceModel
  include Label
  
  def initialize
    super
    
    init_label(:cosine)
  end
end
