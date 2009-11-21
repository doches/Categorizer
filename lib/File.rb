def save_in(filename,&blk)
  fout = File.open(filename,"w")
  blk.call(fout)
  fout.close
end
