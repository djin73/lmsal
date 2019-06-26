@/sanhome/zoe/split.pro
@/sanhome/zoe/fns.pro
;for aia images

pro correct_image, listfilename
  a = listfilename
fn= ' '
ssw_path, /sot
loadct, 1
TVLCT, r, g, b, /get

;fn='net/solarsan/Volumes/mars/hinode/sot/level0//2011/02/12//FG/H0600//FG20150316_060444.0.fits'
fn = 'net/solarsan/Volumes/mars/sdo/AIA/lev1p5//2017/09/06/H1100//AIA20170906_115558_0171.fits'
openr,1,a+'.list'
endIn = file_lines(a+'.list') - 1
fileLines = file_lines(a+'.list')
fileLinesAsString = strtrim(fileLines, 2)
e = 'AIA' + a + 'a_corrected####'
TIC
for i=0, endIn do begin
	readf,1,fn
	read_sdo,fn,idata,xdata
	fno=fns(e+'.fits',i)
	print,fno
        wrt_fits,fno,struct2fitshead(idata),fix(xdata)
        percent = (float(i+1)/(endIn+1))*100
        print, 'CORRECT_IMAGE: ', strtrim(string(percent),1)," percent complete"
   TOC
;end
endfor
close,1
end ;proc


pro display_image, listfilename, skip, scale1, scale2, ctable, odd_even
a = listfilename
s = skip
oe = odd_even
remainder = -1
if oe eq 'even' then remainder = 0
if oe eq 'odd' then remainder = 1
c = scale1
d = scale2
j = ctable
fn= ' '

openr,1,a+'.list'
endIn = file_lines(a+'.list') - 1
fileLines = file_lines(a+'.list')
fileLinesAsString = strtrim(fileLines, 2)
TIC
for i=0, endIn do begin
   e = 'AIA' + a + 'a_corrected####'
   fn=fns(e+'.fits',i)
   if i mod 2 eq remainder then continue
   percent = ''
   if remainder eq -1 then begin
      percent = (float(i+1)/(endIn+1))*100
   endif else begin
      curIndex = (i + remainder + 1) / 2
      percent = (float(curIndex)/((endIn + 1 + remainder)/2))*100
   endelse

   loadct, j
   tvlct, r, g, b, /get
   gamma_ct, 1.0
   print,fn
	xdata2=rfits2(fn)
	split,bytscl(xdata2,c,d),r,g,b,big
;	big=big(*,0:1727,0:1023)
	tv,big,/true
        fn2=fns(e+'.jpg', i)
        write_jpeg,fn2,big,/true
        print, 'DISPLAY_IMAGE: ', strtrim(string(percent),1)," percent complete"
        TOC
     end
end                             ;proc

pro video, listfilename, skip, framerate, oe
a = listfilename
sk = skip
odd_even = oe
remainder = -1
if odd_even eq 'even' then remainder = 0
if odd_even eq 'odd' then remainder = 1
z = framerate
fn= ' '

e = 'AIA' + a + 'a_corrected####'
print, e
image = e + '.jpg'
print, image
for i=remainder+1, remainder+1 do begin
   fn = fns(image,i)
   read_jpeg, fn, brian
   s = size(brian)
   print, s[2]
   print, s[3]
   endIn = file_lines(a+'.list')
end

compile_opt idl2

video_file = a + '.mov'
print, video_file

video = IDLffVideoWrite(video_file, Format = 'mov')

stream = video.AddVideoStream (s[2],s[3],z)
files = File_Search(image, count = endIn)
endIn = file_lines(a+'.list')
print, endIn
for i=0,endIn-1 do begin
   if i eq 105 then continue ;bad frame
   if i mod 2 eq remainder then continue
   fn = fns(image,i)
   print, fn
   read_jpeg,fn, g
   nick = g
   void = video.Put(stream,nick)
endfor
video.Cleanup

end	;proc



pro do_everything
                                ;to make a video from .list files
                                ; you need file name, scale numbers,and framerate
                                ;run do_everything
  
;READ INPUTS
listfilename = ''
read, listfilename, prompt='Enter File Name (without .list): '
skip = ''
read, skip, prompt= 'Skip every other image? (y/n): '
odd_even = ''
if skip eq 'y' then read, odd_even, prompt = 'Skip evens (images 0000, 0002, etc.) or odds (images 0001, 0003, etc.)? (even/odd): '
remainder = ''
if odd_even eq 'even' then remainder = 0
if odd_even eq 'odd' then remainder = 1
c = ''
d = ''
read, c, prompt='Enter scale number 1: '
read, d, prompt='Enter scale number 2: '
j = ''
read, j, prompt='Enter color table (0-74): '
z =''
read, z, prompt= 'Enter framerate: '

;CORRECT IMAGE
correct_image, listfilename

;DISPLAY IMAGE
if skip eq 'y' then begin
   display_image, listfilename, skip, c, d, j, odd_even
endif else begin
   display_image, listfilename, skip, c, d, j, 'N/A'
endelse
  
;CREATE VIDEO
if skip eq 'y' then begin
   video, listfilename, skip, z, odd_even
endif else begin
   video, listfilename, skip, z, 'N/A'
endelse

end	;proc

