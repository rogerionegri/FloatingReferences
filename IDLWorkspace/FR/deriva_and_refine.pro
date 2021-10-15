FUNCTION DERIVA_AND_REFINE, x, y

n = N_ELEMENTS(x)

dy = y*0.0
FOR i = 0, n-2 DO dy[i] = y[i+1] - y[i]

posGE = WHERE(abs(dy) ge STDDEV(dy))
posLT = WHERE(abs(dy) lt STDDEV(dy))

newX = x[posGE]
newY = y[posGE]

sel = 4
FOR i = 0, N_ELEMENTS(posLT)-1 DO BEGIN
   IF (i MOD sel) EQ 0 THEN BEGIN
      newX = [newX , x[posLT[i]]]
      newY = [newY , y[posLT[i]]]
   ENDIF
ENDFOR

sor = SORT(newX)
newX = newX[sor]
newY = newY[sor]

Return, {X: newX, Y: newY}
END