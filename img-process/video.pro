@/sanhome/zoe/split.pro
@/sanhome/zoe/fns.pro

pro make_video
  a = ''
  d = ''
  name = ''
  endIn = ''
  read, a, prompt='Enter final file name (without .mp4): '
  read, d, prompt='Enter framerate in fps: '
  read, name, prompt='Enter format of .jpg image names (before the ####): '
  read, endIn, prompt='Enter number of frames: '
  print, endIn
e = name + '####'
for i=0, 0 do begin
   image = e + '.jpg'
   fn = fns(image,i)
   print, fn
   read_jpeg, fn, brian
   s = size(brian)
   print, s[2]
   print, s[3]
end

compile_opt idl2

video_file = a + '.mp4'
print, video_file

video = IDLffVideoWrite(video_file, Format = 'mp4')
print, 'test'
stream = video.AddVideoStream(s[2],s[3],d)
for i=0, endIn - 1 do begin
   fn = fns(e+ '.jpg',i)
   print, fn
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
