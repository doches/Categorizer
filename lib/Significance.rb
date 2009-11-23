require 'lib/Regress'
require 'lib/Report'
require 'vendor/statistics2'

# Provides mechanisms for testing the significance of various results.
module Significance
  # Implements a simple chi squared test with 2 degrees of freedom. 
  # You probably don't want to use this directly; instead, use the
  # handier wrappers in #naming_test and #generation_test
  #
  # Note: #chi_squared doesn't compute the p-value, only the sum of the
  # chi squares. Use Significance#chi_p for that!
  def Significance.chi_squared(a_correct,a_total,b_correct,b_total)
    
    # Observed values
    a_wrong = a_total - a_correct.to_f
    b_wrong = b_total - b_correct.to_f
    correct_total = a_correct + b_correct.to_f
    wrong_total = a_wrong + b_wrong.to_f
    total = a_total + b_total.to_f
    
    # Expected values
    a_correct_expected = (a_total * correct_total)/total
    b_correct_expected = (b_total * correct_total)/total
    a_wrong_expected = (a_total * wrong_total)/total
    b_wrong_expected = (b_total * wrong_total)/total
    
    
    # Chis
    chis = []
    chis.push( ((a_correct_expected - a_correct)**2)/a_correct_expected )
    chis.push( ((b_correct_expected - b_correct)**2)/b_correct_expected )
    chis.push( ((a_wrong_expected - a_wrong)**2)/a_wrong_expected )
    chis.push( ((b_wrong_expected - b_wrong)**2)/b_wrong_expected )
    chi_total = chis.inject(0) { |s,x| s += x }
    
    return chi_total
  end
  
  # For a given sum of chi-squares (see Significance#chi_squared) and a p-value,
  # determine whether the chi-squared test is significant (p-value defaults to 0.05, degrees of freedom defaults to 2).
  def Significance.chi_p(chi,p=0.05,df=2)
    return chi > Statistics2.pchi2X_(df,1-p)
  end
  
  # Determine whether the difference between two NamingData objects is significant at the given p-value
  def Significance.naming_test(a,b,p=0.05)
    chi = Significance.chi_squared(a.value * a.results.size,a.results.size,b.value * b.results.size,b.results.size)
    return Significance.chi_p(chi,p,2)
  end
  
  # Determine whether the difference between two GenerationData objects is significant at the give p-value
  #
  # NOT IMPLEMENTED
  def Significance.generation_test(a,b,p=0.05)
    #chi = Significance.chi_squared(a.overlap*
    raise "not implemented"
  end
  
  # Determine whether the difference between two TypicalityData objects is significant at the given p-value
  def Significance.typicality_test(a,b,p=0.05)
    return Regress.diff_sig(a.regress,b.regress) < p
  end
end
