require 'lib/LdaModel'
require 'lib/Label'

class LdaLabelBalapincModel < LdaModel
  include Label
  
  def initialize
    super
    
    init_label(:balapinc)
  end
end
