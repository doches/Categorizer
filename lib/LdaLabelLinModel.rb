require 'lib/LdaModel'
require 'lib/Label'

class LdaLabelLinModel < LdaModel
  include Label
  
  def initialize
    super
    
    init_label(:lin)
  end
end
