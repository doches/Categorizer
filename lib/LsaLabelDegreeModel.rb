require 'lib/LsaModel'
require 'lib/Label'

class LsaLabelDegreeModel < LsaModel
  include Label
  
  def initialize
    super
    
    init_label(:degree)
  end
end
