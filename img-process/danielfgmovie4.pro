@/sanhome/zoe/split.pro
@/sanhome/zoe/fns.pro

pro correct_image, listfilename
fn= ' '
ssw_path, /sot
loadct, 1
TVLCT, r, g, b, /get
a = listfilename
print, a
;fn='net/solarsan/Volumes/mars/hinode/sot/level0//2011/02/12//FG/H0600//FG20150316_060444.0.fits'
openr,1,a+'.list'
endIn = file_lines(a+'.list') - 1
b = 'FG' + a + 'a_corrected####'
print, b
for i=0, endIn do begin
	readf,1,fn
        read_sot,fn,idata,xdata
;	wait,0.5
        fg_prep, idata,xdata,idata2,xdata2, n_corr_db_good = 0
	fno=fns(b+'.fits',i)
        wrt_fits,fno,struct2fitshead(idata2),fix(xdata2)
        percent = (float(i+1)/(endIn+1))*100
        print, " "
        print, percent," PERCENT COMPLETE"
        print, " "
     end
print, "Congratulations!"
close,1
end                             ;proc

pro display_image, listfilename, scale1, scale2, colortable, contrast
a = listfilename
print,a
c = scale1
d = scale2
j = colortable
endIn = file_lines(a+'.list') - 1
for i=0, endIn do begin
   e = 'FG' + a + 'a_corrected####'
     loadct, j
     tvlct, r, g, b, /get
     gamma_ct, contrast ;1.0
     fn=fns(e+'.rig',i)
     print,fn
	xdata2=rfits2(fn)
	split,bytscl(xdata2,c,d),r,g,b,big
;	big=big(*,0:1727,0:1023)
	tv,big,/true
        fn2=fns(e+'.jpg', i)
        write_jpeg,fn2,big,/true

end
end                             ;proc


pro video, filename, framerate
a=filename
d=framerate
e = 'FG' + a + 'a_corrected####'
for i=0, 0 do begin
   image = e + '.jpg'
   fn = fns(image,i)
   read_jpeg, fn, brian
   s = size(brian)
   print, s[2]
   print, s[3]
   endIn = file_lines(a+'.list')
end

compile_opt idl2

video_file = a + '.mp4'
print, video_file

video = IDLffVideoWrite(video_file, Format = 'mp4')

stream = video.AddVideoStream (s[2],s[3],d)
files = File_Search(e+'.jpg', count = endIn)
endIn = file_lines(a+'.list')
for i=0,endIn - 1 do begin
   fn = fns(e+ '.jpg',i)
   ;print, fn
   read_jpeg,fn, g
   image = g
   void = video.Put(stream,image)
   percent = (float(i+1)/(endIn))*100
   print
   print, strtrim(string(i+1),1), "/", strtrim(string(endIn),1), " frames"
   print, strtrim(string(percent),1)," percent complete"
endfor
video.Cleanup
end                             ;proc



pro video_application_themed, filename, framerate
a=''
read, a, prompt= 'Enter file name (without .mp4): '
d=''
read, d, prompt= 'Enter framerate: '
e = 'FG' + a + 'a_corrected####'
print, "Application submitted."
wait, 1
for i=0, 0 do begin
   image = e + '.jpg'
   fn = fns(image,i)
   read_jpeg, fn, brian
   s = size(brian)
   print, s[2]
   print, s[3]
   endIn = file_lines(a+'.list')
end

compile_opt idl2

video_file = a + '.mp4'
print, video_file

video = IDLffVideoWrite(video_file, Format = 'mp4')

stream = video.AddVideoStream (s[2],s[3],d)
files = File_Search(e+'.jpg', count = endIn)
endIn = file_lines(a+'.list')
for i=0,endIn - 1 do begin
   fn = fns(e+ '.jpg',i)
   ;print, fn
   read_jpeg,fn, g
   image = g
   void = video.Put(stream,image)
   percent = (float(i+1)/(endIn))*100
   print
   print, strtrim(string(i+1),1), "/", strtrim(string(endIn),1), " applicants reviewed"
   print, strtrim(string(percent),1)," percent complete"
endfor
video.Cleanup
print
print, 'Status Update: New updates to your application were posted.'
status = ''
read, status, prompt= "Press enter to view update"
print
print, "Loading..."
decision = randomn(seed, 1, 1)
wait, 2
print
if decision ge 1 then begin
   print, "Congratulations! The admissions committee has thoroughly reviewed your application and we are delighted to offer you a place in the Class of 2022."
endif else begin
   print, "The admissions commiittee has thoroughly reviewed your application and after careful consideration, we regret to inform you that we cannot offer you a place in the Class of 2022. This year's application pool was the largest and strongest in our school's history and we simply did not have enough space for all the qualified applicants we reviewed. We know this may come as a disappointment to you and your family, but please be sure that this is not an indicator of your success. If you have any questions, please contact us through our email. We wish you the best of luck in all of your future endeavors."
endelse

print
print, "Your application ID: ", video_file
end	;proc

pro do_everything
                                ;to make a video from .list files
                                ; you need file name, scale numbers,
                                ; and framerate
                                ;run do_everything
  

a = ''
read, a, prompt='Enter File Name (without .list): '
c = ''
d = ''
read, c, prompt='Enter scale number 1: '
read, d, prompt='Enter scale number 2: '
j = ''
read, j, prompt='Enter color table (0-74): '
z =''
read, z, prompt= 'Enter framerate: '
con = ''
read, con, prompt='Enter contrast: '
fileLines = file_lines(a+'.list')
fileLinesAsString = strtrim(fileLines, 2)

;CORRECT IMAGE
correct_image, a


for i=0, 20 do begin
   print, 'DO THIS'
   print, '> ' + fileLinesAsString
   print, '> ' + a
end
;ALIGN IMAGE
spawn, "ana @alignprogram.ana"

;DISPLAY IMAGE
display_image, a, c, d, j, con

;CREATE VIDEO
;finding dimensions first
e = 'FG' + a + 'a_corrected####'
 image = e + '.jpg'
for i=0, 0 do begin
   fn = fns(image,i)
   read_jpeg, fn, brian
   s = size(brian)
   print, s[2]
   print, s[3]
   endIn = file_lines(a+'.list')
end

compile_opt idl2

video_file = a + '.mp4'
print, video_file

video = IDLffVideoWrite(video_file, Format = 'mp4')

stream = video.AddVideoStream (s[2],s[3],z)
files = File_Search(image, count = endIn)
endIn = file_lines(a+'.list')
print, endIn
for i=0,endIn-1 do begin
   fn = fns(image,i)
   print, fn
   read_jpeg,fn, g
   nick = g
   void = video.Put(stream,nick)
endfor
video.Cleanup

end	;proc
