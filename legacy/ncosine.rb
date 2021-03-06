require 'narray'

# From http://blade.nagaokaut.ac.jp/cgi-bin/scat.rb/ruby/ruby-talk/277157
def dot_product_e l1, l2
  begin
    sum = 0
    for i in 0...l1.size
        sum += l1[i] * l2[i]
    end
    return sum
  rescue TypeError
    return sum
  end
end

def dot_product_n(a,b)
  dot = a*b
  if dot < 0
#    raise "Integer overflow in dot_product_n"
    return dot_product_e(a,b)
  else
    return dot
  end
end

def magnitude_e(v)
  return Math.sqrt(dot_product_n(v,v))
end

def cosine(v1,v2)
  return dot_product_n(v1,v2) / (magnitude_e(v1) * magnitude_e(v2))
end

def cosine_safe(v1,v2)
  v1 = NVector.to_na(v1) if not v1.is_a? NVector
  v2 = NVector.to_na(v2) if not v2.is_a? NVector
  return cosine(v1,v2)
end
