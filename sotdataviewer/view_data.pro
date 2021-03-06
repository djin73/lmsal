

;Enter dates/times in the form 'DD-Mon-YYYYTHH:MM:SS' or 'YY/MM/DD, HH:MM:SS.SSS'
;G Band 2048 x 1024 (for some reason 1024 x 512 returns no results)
;mode = G band 4305
;Example: view_data, '09-Dec-2013T11:30:00', '10-Dec-2013T15:00:00', 'G band 4305', 1024, 512
pro view_data, t0, t1, mode, naxis1, naxis2
  ssw_path, /sot
  set_logenv, 'SOT_DATA', '/Volumes/data1/hinode/sot/data'

  ; replace spaces with *'s
  WHILE (((I = STRPOS(mode, ' '))) NE -1) DO STRPUT, mode, '*', I

  sot_cat, t0, t1, cat, files, /level1
  modes = sot_umodes(cat, mcount=mc, info=info)
  print, 'MODES: '
  prstr, modes
  
  ; HCR for time range for inst. (SOT~SOTFG, use SOTSP for SP)
  sothcr=ssw_hcr_query(ssw_hcr_make_query(t0,t1,instrument='SOT',/all_select))
  help,sothcr & info=get_infox(sothcr,'starttime,stoptime,goal,planners,xcen,ycen',/more,/number)


  for i = 0, N_elements(sothcr)-1 do begin
     cat = []
     files = []

     ; hcr/obs -> catalog+file list
     sot_cat, sothcr[i].starttime, sothcr[i].stoptime, cat, files, /level1 ,search_array=['wave='+mode,'naxis1='+strtrim(naxis1,2),'naxis2='+strtrim(naxis2,2)]
     if files eq !NULL then continue
     help,cat,files & print, 'SOTHCR SEQUENCE ', strtrim(i, 2) &info=get_infox(sothcr[i],'starttime,stoptime,goal,planners,xcen,ycen',/more,/number) & more,[files[0:1],'...etc...',last_nelem(files,2)]

     
     
     read_sot, files, index, data

     origdata = data
     ;implement option for viewing original data

     
                               

      ;co-registration
      ;look at xcen and  ycen and shift to match first frame
     for j = 1, N_elements(index) - 1 do begin
        xshift = (index[j].xcen - index[0].xcen) / index[j].cdelt1
        yshift = (index[j].ycen - index[0].ycen) / index[j].cdelt2
;        help, xshift, yshift
        xshift = long(xshift+0.5) ;round to nearest integer
        yshift = long(yshift+0.5)
;        help, xshift, yshift

        if j eq (N_elements(index)-1) then begin
           data = [ [[data[*, *, 0:(j-1)]]], [[shift(data[*,*,j], xshift, yshift)]] ]
        endif else begin
           data = [ [[data[*, *, 0:(j-1)]]], [[shift(data[*,*,j], xshift, yshift)]], [[data[*,*, (j+1):((size(data))[3]-1)]]] ]
        endelse
        
        
     endfor
     print, 'CO-REGISTRATION FOR SEQUENCE ', strtrim(i, 2), ' COMPLETE.'
     

     vidtitle = 'SEQUENCE '+strtrim(i, 2) + ':   ' +sothcr[i].goal+ '   '+ sothcr[i].starttime + ' to ' + sothcr[i].stoptime
     vidtitle2 = vidtitle + ' (NO CO-REGISTRATION)'
     
     movie_player, data, files, index, title=vidtitle, xsize=naxis1, ysize=naxis2
;     movie_player, origdata, files, index, title=vidtitle2, xsize = naxis1, ysize = naxis2
     

     save = ''
     read, save, prompt='Record and save changes to FITS headers? [y/n]'
     if save eq 'n' then begin
       
     endif else begin
        mwritefits, index, origdata, outfile=files, outdir='/Users/jin/Desktop/testpath'
     endelse
     
     a = ''
     read, a, prompt='PRESS ENTER TO CONTINUE TO NEXT SEQUENCE: '
     
  endfor
  print, 'ALL SEQUENCES HAVE BEEN SEARCHED OR VIEWED.'
  
end

;files = strarray of fits file names
;data = data cube
;filename = name of file to save stuff to
;newfile = 'y' or 'n'
function shift_tool, files, data, index, shiftframe, filename, newfile

  orig = data
  shiftframe = uint(shiftframe)
  startframe = shiftframe-1
  movie, bytscl(data[*,*,[startframe:shiftframe]]), 1
  print, 'NOW SHIFTING: IMAGE ', strtrim(shiftframe, 2)

  yshift = 0
  xshift = 0
  levelvec = [0.1 * max(data), 0.2 * max(data), 0.7 * max(data), 0.85 * max(data)]

  contour, data[*,*,startframe], LEVELS = levelvec, /OVERPLOT

  ; Scale image intensities:
  image = BYTSCL(data[*,*,shiftframe])
  CONTOUR, data[*,*,startframe], LEVELS = levelvec, $
           XSTYLE = 1, YSTYLE = 1, /NODATA
  

; Get size of plot window in device pixels.
  PX = !X.WINDOW * !D.X_VSIZE
  PY = !Y.WINDOW * !D.Y_VSIZE
  print, PX
  print, PY
; Desired size of image in pixels.
  SX = PX[1] - PX[0] + 1	
  SY = PY[1] - PY[0] + 1
  print, SX
  print, SY
  
  TVSCL, CONGRID(image, SX, SY), PX[0], PY[0]
  
  
  REPEAT BEGIN
     a = get_kbrd(/KEY_NAME)
     
     case a of
        'DOWN': begin
           if shiftframe eq (N_elements(files) - 1) then begin
              data = [ [[data[*, *, 0:startframe]]], [[shift(data[*,*,shiftframe], 0, -1)]] ]
           endif else begin
              data = [ [[data[*, *, 0:startframe]]], [[shift(data[*,*,shiftframe], 0, -1)]], [[data[*,*, (startframe+2):((size(data))[3]-1)]]] ]
           endelse
          
           yshift--
        end
        'UP': begin
           if shiftframe eq (N_elements(files) - 1) then begin
              data = [ [[data[*, *, 0:startframe]]], [[shift(data[*,*,shiftframe], 0, 1)]] ]
           endif else begin
              data = [ [[data[*, *, 0:startframe]]], [[shift(data[*,*,shiftframe], 0, 1)]], [[data[*,*, (startframe+2):((size(data))[3]-1)]]] ]
           endelse
           
           yshift++
        end
        'LEFT': begin
           if shiftframe eq (N_elements(files) - 1) then begin
              data = [ [[data[*, *, 0:startframe]]], [[shift(data[*,*,shiftframe], -1, 0)]] ]
           endif else begin
              data = [ [[data[*, *, 0:startframe]]], [[shift(data[*,*,shiftframe], -1, 0)]], [[data[*,*, (startframe+2):((size(data))[3]-1)]]] ]
           endelse
           
           xshift--
        end
        'RIGHT': begin
           if shiftframe eq (N_elements(files) - 1) then begin
              data = [ [[data[*, *, 0:startframe]]], [[shift(data[*,*,shiftframe], 1, 0)]] ]
           endif else begin
              data = [ [[data[*, *, 0:startframe]]], [[shift(data[*,*,shiftframe], 1, 0)]], [[data[*,*, (startframe+2):((size(data))[3]-1)]]] ]
           endelse
           
           xshift++
        end

        ;play movie
        'p': movie, bytscl(data[*,*,[startframe:shiftframe]]), 1

        else: begin
        end
        
     endcase

     if (a eq 'DOWN') or (a eq 'UP') or (a eq 'LEFT') or (a eq 'RIGHT') then begin
        print, ''
        print, 'SHIFTED FRAME ',strtrim(shiftframe, 2), ' ',a,' 1 PIXEL'
        print, 'CURRENT SHIFT: (', strtrim(xshift,2), ', ', strtrim(yshift,2), ')'
        print, 'USE ARROWS TO KEEP SHIFTING, TYPE P TO PLAY MOVIE, TYPE Q TO QUIT'
     end


; Display the image with its lower-left corner at
; the origin of the plot window and with its size
; scaled to fit the plot window.
     image = BYTSCL(data[*,*,shiftframe])
     TVSCL, CONGRID(image, SX, SY), PX[0], PY[0]
     CONTOUR, data[*,*,startframe], LEVELS = levelvec, XSTYLE = 1, YSTYLE = 1, /OVERPLOT
     
  ;   exit upon entering 'q'
  ENDREP UNTIL a EQ 'q'
  print, ''
  save = ''  

  ;print final shift details
  print, 'FINAL SHIFT APPLIED:'
  print, 'xshift: ', xshift
  print, 'yshift: ', yshift
  print, 'applied to frame ', strtrim(shiftframe, 2)
  print, 'Filename: ', files[shiftframe]
  print, ''

  help, index
  print, index.xcen
  print, index.ycen
  
  read, save, prompt='Record and save changes to FITS header? [y/n]: '


  if save eq 'y' then begin
     ; save to file
     if newfile eq 'y' then begin
        ;open new file for writing
        openw, 1, filename, /APPEND
     endif else begin
        ;open existing file
        openu, 1, filename, /APPEND
     endelse
     
     str = files[shiftframe]

     
     index[shiftframe].xcen = index[shiftframe].xcen + xshift*index[shiftframe].cdelt1
     index[shiftframe].ycen = index[shiftframe].ycen + yshift*index[shiftframe].cdelt2

     
     printf, 1, systime(), ' ', strmid(str, str.lastindexof('/')+1,str.strlen()-str.lastindexof('/')),' xshift:', strtrim(xshift, 2),' yshift:', strtrim(yshift, 2)
;     printf, 1, ''
     close, 1
     print, 'SHIFT RECORDED TO FILE: ', filename
     return, data
  endif else begin
     return, orig
  endelse
  
  
  
end
