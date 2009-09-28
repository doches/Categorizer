def euclidean(a,b)
  a.zip(b).map { |x| (x[1]-x[0])**2 }.inject(0) { |s,x| s += x } ** 0.5
end

if __FILE__ == $0
  a = [1,2]
  b = [3,4]
  p euclidean(a,b),2.828
  a = [1,2,3]
  b = [4,5,6]
  p euclidean(a,b),5.196
end
