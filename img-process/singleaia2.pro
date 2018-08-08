@/sanhome/zoe/split.pro
@/sanhome/zoe/fns.pro
;for aia images


pro correct_image, listfilename, fitsfilename
a = listfilename
fn= fitsfilename
ssw_path, /sot
loadct, 1
TVLCT, r, g, b, /get

;fn='net/solarsan/Volumes/mars/hinode/sot/level0//2011/02/12//FG/H0600//FG20150316_060444.0.fits'
;fn = 'net/solarsan/Volumes/mars/sdo/AIA/lev1p5//2017/09/06/H1100//AIA20170906_115558_0171.fits'

e = 'AIA' + a + 'a_corrected'
	read_sdo,fn,idata,xdata
	print,e
        wrt_fits,e,struct2fitshead(idata),fix(xdata) ;end
close,1
end ;proc

pro display_image, listfilename, fitsfilename, scale1, scale2, colortable
a = listfilename
c = scale1
d = scale2
j = colortable
fn= fitsfilename
e = 'AIA' + a + 'a_corrected'
loadct, j
tvlct, r, g, b, /get
gamma_ct, 1.0
print,e
xdata2=rfits2(e)
split,bytscl(xdata2,c,d),r,g,b,big
;	big=big(*,0:1727,0:1023)
tv,big,/true
image = e + '.jpg'
print, image
write_jpeg,image,big,/true


end                             ;proc

pro do_everything
                                ;to make a video from .list files
                                ; you need file name, scale numbers,and framerate
                                ;run do_everything
  filename = ''
  fitsfilename = ''
  scale1 = ''
  scale2 = ''
  colortable = ''
  read, filename, prompt='Enter final file name: '
  read, fitsfilename, prompt='Enter fits file name: '
  read, scale1, prompt='Enter scale number 1: '
read, scale2, prompt='Enter scale number 2: '
read, colortable, prompt='Enter color table (0-74): '
;CORRECT IMAGE
correct_image, filename, fitsfilename
  
;DISPLAY IMAGE
display_image, filename, fitsfilename, scale1, scale2, colortable

end

