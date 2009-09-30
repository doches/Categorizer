require 'lib/LdaModel'
require 'lib/Label'

class LdaLabelBalprecModel < LdaModel
  include Label
  
  def initialize
    super
    
    init_label(:balprec)
  end
end
