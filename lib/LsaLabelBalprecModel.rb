require 'lib/LsaModel'
require 'lib/Label'

class LsaLabelBalprecModel < LsaModel
  include Label
  
  def initialize
    super
    
    init_label(:balprec)
  end
end
