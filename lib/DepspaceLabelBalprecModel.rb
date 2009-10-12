require 'lib/DepspaceModel'
require 'lib/Label'

class DepspaceLabelBalprecModel < DepspaceModel
  include Label
  
  def initialize
    super
    
    init_label(:balprec)
  end
end
