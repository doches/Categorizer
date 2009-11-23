class String
  # Split this string by intercapped characters, returning an array of (capitalized) words.
  # 
  # Example:
  #   "ComplexClassName".split_intercapped => ['Complex','Class','Name']
  def split_intercapped
    pieces = []
    
    if self.size <= 1
      pieces.push self
      return pieces
    end
    
    prev = 0
    for i in (1..self.size-1)
      if self[i].chr =~ /[A-Z]/
        pieces.push self[prev..i-1]
        prev = i
      end
    end
    pieces.push self[prev..self.size]
    return pieces
  end
end
