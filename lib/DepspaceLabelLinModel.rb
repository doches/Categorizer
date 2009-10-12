require 'lib/DepspaceModel'
require 'lib/Label'

class DepspaceLabelLinModel < DepspaceModel
  include Label
  
  def initialize
    super
    
    init_label(:lin)
  end
end
