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

def magnitude_e(v)
  begin
    return Math.sqrt(dot_product_e(v,v))
  rescue
    return 0
  end
end

def cosine(v1,v2)
  return dot_product_e(v1,v2) / (magnitude_e(v1) * magnitude_e(v2))
end
