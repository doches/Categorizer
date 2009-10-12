require 'lib/DepspaceModel'
require 'lib/Label'

class DepspaceLabelDegreeModel < DepspaceModel
  include Label
  
  def initialize
    super
    
    init_label(:degree)
  end
end
