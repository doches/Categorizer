require 'lib/DepspaceModel'
require 'lib/Label'

class DepspaceLabelBalapincModel < DepspaceModel
  include Label
  
  def initialize
    super
    
    init_label(:balapinc)
  end
end
