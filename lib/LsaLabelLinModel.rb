require 'lib/LsaModel'
require 'lib/Label'

class LsaLabelLinModel < LsaModel
  include Label
  
  def initialize
    super
    
    init_label(:lin)
  end
end
