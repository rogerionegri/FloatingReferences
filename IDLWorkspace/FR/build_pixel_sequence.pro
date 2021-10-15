FUNCTION BUILD_PIXEL_SEQUENCE, Img

Dim = GET_DIMENSIONS(Img)
NB = Dim[0]   &   NC = Dim[1]   &   NL = Dim[2]
Seg = LONARR(NC,NL)

pos = 0L
FOR i = 0L, NC-1 DO BEGIN
   FOR j = 0L, NL-1 DO BEGIN
      Seg[i,j] = pos
      pos++
   ENDFOR
ENDFOR

Return, Seg
END