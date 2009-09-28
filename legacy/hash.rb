class Hash
  def sort
    pairs = []
    self.each_pair { |k,v| pairs.push([( (v.nan? or v.infinite?) ? 0.0 : v),k]) }
    begin
      return pairs.sort { |a,b| a[0] <=> b[0] }.map { |x| [x[1],x[0]] }
    rescue
      p self
      raise $!
    end
  end
end
