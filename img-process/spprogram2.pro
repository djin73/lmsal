@/sanhome/zoe/split.pro

pro make_image
  filename = ''
  read, filename, prompt='Enter file name: '
  ct = ''
  read, ct, prompt='Enter color table (0-74): '
  a = ''
  read, a, prompt = 'Continuum, Longitudinal, Transverse, Velocity? (0-3): '
  while (a ne 0) and (a ne 1) and (a ne 2) and (a ne 3) do begin
     print, 'Error: Must enter an integer from 0 to 3.'
     read, a, prompt = 'Continuum, Longitudinal, Transverse, Velocity? (0-3): '
  endwhile
  scale1 = ''
  scale2 = ''
  if (a ne 0) then begin
     read, scale1, prompt='Enter scale number 1: '
     read, scale2, prompt='Enter scale number 2: '
  endif

  type = ''
  case a of
     '0': type = 'conti'
     '1': type = 'longi'
     '2': type = 'trans'
     '3': type = 'veloc'
  endcase
  
  stks=sotsp_stks2struct(filename)
  sotsp_stks2index,filename,index,data
  sotsp_getdata,filename,/level
  if (a eq 0) then begin
     scale1 = min(stks.conti)
     scale2 = max(stks.conti)
  endif
  tvscl,data(*,*,a)
  loadct, ct
  tvlct,r,g,b,/get
  split,bytscl(data(*,*,a),scale1,scale2),r,g,b,big
  write_jpeg, "SP" + filename + type + ".jpg",big,/true

end
