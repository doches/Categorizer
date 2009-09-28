require 'lib/cosine'

class Array
  # Compute set intersection between two arrays
  def intersection(other)
    self.reject { |x| not other.include?(x) }
  end
  
  def sum
    self.inject(0) { |s,i| s += i }
  end
  
  alias intersect intersection
  
  def max
    max = nil
    self.each { |element| max = element if (max.nil? or element > max) }
    return max
  end
  
  def normalize
    sum = self.inject(0) { |s,i| s += i }
    self.map { |i| i/sum.to_f }
  end
  
  def normalize!
    self.normalize.each_with_index { |v,i| self[i] = v }
  end
end

class Concept < Array
  def initialize(array = [])
    if array
      array.each { |i| self.push i }
    end
  end

  def quality_properties(threshold = 0)
    properties = {}
    self.each_with_index { |value,index| properties[index] = value if value > threshold }
    return properties
  end
  
  def quality_properties_mean
    self.quality_properties(self.mean)
  end
  
  def mean
    self.inject(0) { |s,i| s += i.to_i}/self.size.to_f
  end
  
  def Concept.degree_help(c_i, c_j)
    p_a = c_i.quality_properties_mean.keys.intersect( c_j.quality_properties.keys )
    num = p_a.map { |i| c_i[i] }.sum
    
    p_b = c_i.quality_properties_mean.keys
    den = p_b.map { |i| c_i[i] }.sum
    num/den.to_f
  end
  
  def Concept.degree(a,b)
    Concept.degree_help(b,a)
  end
  
  @@l1 = 0.5
  @@l2 = 0.4
  @@alpha = 2.0
  @@t1 = 0.0
  @@t2 = 0.0
  def Concept.dominance_parameters=(params)
    l1,l2,alpha,t1,t2 = *params
    @@l1 = l1
    @@l2 = l2
    @@alpha = alpha
    @@t1 = t1
    @@t2 = t2
  end
  
  def Concept.dominance_parameters
    [@@l1,@@l2,@@alpha,@@t1,@@t2]
  end
  
  def dominate(c2)
    Concept.dominate(self,c2)
  end
  
  Debug = false
  # Do weighting of c_2 as dominated by c_1
  def Concept.dominate(c1,c2)
    c1 = c1.dup
    c2 = c2.dup
    puts if Debug
    p c1,c2 if Debug
    # Step 1: Re-weight c_1 and c_2 to assign higher weights to properties in c_1
    [ [@@l1, c1], [@@l2, c2] ].each do |pair|
      max = pair[1].max
      pair[1].map! do |weight| 
        pair[0] + ((pair[0] * weight)/max)
      end
    end
    puts "Step 1:" if Debug
    p c1,c2 if Debug
    # Step 2: Strengthen the weights of shared quality properties by multiplier alpha
    c1.quality_properties(@@t1).keys.intersect( c2.quality_properties(@@t2).keys ).each do |index|
      c1[index] *= @@alpha
      c2[index] *= @@alpha
    end
    puts "Step 2:" if Debug
    p c1,c2 if Debug
    # Step 3: Compute property weights in the composition
    composed = []
    c1.each_with_index { |w_1,i| composed[i] = w_1 + c2[i] }
    puts "Step 3:" if Debug
    p composed if Debug
    # Step 4: Normalize composed vector
    composed.normalize!
    puts "Step 4:" if Debug
    p composed if Debug
    return composed
  end
  
  # Degree to which concept is included within this one
  def degree_includes(concept)
    Concept.degree_help(concept,self)
  end
  
  def degree_included(concept)
    concept.degree_includes(self)
  end
  
  alias qp quality_properties
  alias qp_u quality_properties_mean
  
  # Other metrics
  def entails(other,metric)
  	case metric
  		when :degree
  			return degree_includes(other)
  		when :lin
  			return lin(other)
  		when :weedsprec
  			return weeds(other)
  		when :balprec
  			return balprec(other)
  		when :balapinc
  			return balapinc(other)
  		when :cosine
  		  return cosine(self,other)
  	end
  end
  
  def lin(b)
  	qp_a = self.quality_properties
  	qp_b = b.quality_properties
  	
  	numerator = qp_a.keys.reject { |index| not qp_b[index] }.map { |index| qp_a[index] + qp_b[index] }.inject(0) { |s,x| s += x }
  	denominator = qp_a.values.inject(0) { |s,x| s += x } + qp_b.values.inject(0) { |s,x| s += x }

  	return numerator.to_f / denominator
  end
  
  def weeds(b)
  	qp_a = self.quality_properties
  	qp_b = b.quality_properties
  	
  	numerator = qp_a.keys.reject { |index| not qp_b[index] }.map { |index| qp_a[index] }.inject(0) { |s,x| s += x }
  	denominator = qp_a.values.inject(0) { |s,x| s += x }
  	
  	res = numerator.to_f / denominator
  	return res
	end
	
	def balprec(b)
		return (lin(b) * weeds(b))**0.5
	end
	
	def balapinc(b)
		# Make rel(f)
		rel = []
		b.each_with_index { |x,i| rel[i] = (x == 0.0) ? 0 : 1-(i/(b.size+1.0)) }
		# Make P(r)
		p_r = []
		self.each_with_index do |x,i|
			p_r[i] = self[0..i].reject { |x| x == 0.0 }.size/i.to_f
			p_r[i] = 0 if p_r[i].nan?
		end
		apinc = (1...b.size).map { |r| p_r[r] * rel[r] }.inject(0) { |s,x| s += x } / self.reject { |x| x == 0.0 }.size.to_f
		
		return (lin(b) * apinc)**0.5
	end
end
