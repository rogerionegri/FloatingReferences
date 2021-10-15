PRO AUX_FUNCS
   ;just a caller
END


;##########################################
FUNCTION SEARCH_SOL, X, Y
;>>>>>Talvez seja interessante abs(Y), para evitar integral negativa!!!
n = N_ELEMENTS(X)
mat = DBLARR(n,n)
I = INT_TABULATED(X,Y)

FOR a = 0, n-2 DO BEGIN
   FOR b = a+1, n-1 DO BEGIN
      mat[a,b] = INT_TABULATED(X[a:b],Y[a:b],/DOUBLE) / I  ;<<< esta divisao eh para garantir integral (no intervalo) igual a 1
   ENDFOR
ENDFOR

Return, mat
END


;##########################################
FUNCTION FIND_SOL, sols, v0, v1

p0 = where(sols GE v0)
p1 = where(sols LE v1)

s0 = sols*0   &   s0[p0] = 1
s1 = sols*0   &   s1[p1] = 1
slice = s0*s1
dis = slice*0D + N_ELEMENTS(sols[*,0])^2L

n = N_ELEMENTS(sols[*,0])
FOR a = 0, n-2 DO BEGIN
   FOR b = a+1, n-1 DO BEGIN
      IF slice[a,b] EQ 1 THEN dis[a,b] = ABS(b-a)
   ENDFOR
ENDFOR

posMin = WHERE(dis EQ MIN(dis))
posX = posMin[N_ELEMENTS(posMin)/2] MOD N_ELEMENTS(sols[*,0]) 
posY = posMin[N_ELEMENTS(posMin)/2] / N_ELEMENTS(sols[*,0])

Return, {imgDis: dis, pX: posX, py: posY}
END


;##########################################
FUNCTION FIND_SOL_V2, sols, v0, v1

p0 = where(sols GE v0)
p1 = where(sols LE v1)

s0 = sols*0   &   s0[p0] = 1
s1 = sols*0   &   s1[p1] = 1
slice = s0*s1
dis = slice*0D + N_ELEMENTS(sols[*,0])^2L

n = N_ELEMENTS(sols[*,0]) 
pos = WHERE(slice EQ 1)
np = N_ELEMENTS(pos)-1

a = pos[*] mod n
b = pos[*] / n

FOR i = 0L, np DO dis[a[i],b[i]] = abs(b[i] - a[i]) 

posMin = WHERE(dis EQ MIN(dis))
posX = posMin[N_ELEMENTS(posMin)/2] MOD N_ELEMENTS(sols[*,0]) 
posY = posMin[N_ELEMENTS(posMin)/2] / N_ELEMENTS(sols[*,0])

Return, {imgDis: dis, pX: posX, py: posY}
END




;##########################################
FUNCTION SELECT_PAIR, dists ,coords, inf, sup, opt

selected  = [-1,-1]
FOR i = 0L, N_ELEMENTS(dists)-1 DO BEGIN
   
   IF opt THEN BEGIN
      IF ((dists[i] GE inf) AND (dists[i] LE sup)) THEN selected = [[selected] , [coords[*,i]]]
   ENDIF ELSE BEGIN
      IF ((dists[i] LT inf) OR (dists[i] GE sup)) THEN selected = [[selected] , [coords[*,i]]]
   ENDELSE
   
ENDFOR

Return, selected[*,1:*]
END





;##########################################
FUNCTION BUILD_COMP_BLOCKS, Img1 , Img2, sel, wx, wy

BLOCKS = PTR_NEW('NULL')

NC = N_ELEMENTS(Img1[0,*,0])
NL = N_ELEMENTS(Img1[0,0,*])
FOR i = 0, N_ELEMENTS(sel[0,*])-1 DO BEGIN
   wind1 = Img1[*,0:wx-1,0:wy-1] * 0
   wind2 = wind1
   
   colW = 0
   FOR colSel = (-wx/2)+sel[0,i], (wx/2)+sel[0,i] DO BEGIN
      linW = 0
      FOR linSel = (-wy/2)+sel[1,i], (wy/2)+sel[1,i] DO BEGIN
         
         IF (colSel GE 0) AND (colSel LT NC) AND (linSel GE 0) AND (linSel LT NL) THEN BEGIN
            wind1[*,colW,linW] = Img1[*,colSel,linSel]
            wind2[*,colW,linW] = Img2[*,colSel,linSel]
         ENDIF
         linW++
         
      ENDFOR
      colW++
   ENDFOR

   BLOCKS = [BLOCKS, PTR_NEW({block1: wind1, block2: wind2})]
ENDFOR

Return, BLOCKS
END




;##########################################
FUNCTION BUILD_IMAGE_BLOCKS, Blocks, wx, wy, nAtts

obs = 20
slack = 5
smallSlack = 2

faixa = INTARR(nAtts, 2*obs*wx + obs*slack, obs*wy + obs*slack)

l1 = 0   &   l2 = wy-1
ini = 0
FOR i = 1, obs DO BEGIN
   bl = *Blocks[i]
   
   fin = ini + (wx-1)
   faixa[*,ini:fin,l1:l2] = bl.block1[*,*,*]
   
   ini = fin+slack
   fin = ini + (wx-1)
   faixa[*,ini:fin,l1:l2] = bl.block2[*,*,*]   
ENDFOR

Return, 0
END




;##########################################
FUNCTION BUILD_IMAGE_COMP_BLOCKS, sel, wx, wy, NC, NL

ImgBlock = INTARR(NC,NL)*0
FOR i = 0L, N_ELEMENTS(sel[0,*])-1 DO BEGIN
   FOR colSel = (-wx/2)+sel[0,i], (wx/2)+sel[0,i] DO BEGIN
      FOR linSel = (-wy/2)+sel[1,i], (wy/2)+sel[1,i] DO BEGIN
         IF (colSel GE 0) AND (colSel LT NC) AND (linSel GE 0) AND (linSel LT NL) THEN $
            ImgBlock[colSel,linSel] = 1
      ENDFOR
   ENDFOR
   ;ImgBlock[sel[0,i],sel[1,i]] = 0
ENDFOR

Return, ImgBlock
END