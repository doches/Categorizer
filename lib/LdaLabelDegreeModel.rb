require 'lib/LdaModel'
require 'lib/Label'

class LdaLabelDegreeModel < LdaModel
  include Label
  
  def initialize
    super
    
    init_label(:degree)
  end
end
