FUNCTION MAX_CUT_DOIDO_V2, Img

   ;bs = (max(Img)-min(Img))*0.001
   FreedmanDiaconis = 2*IQR(Img)*(N_ELEMENTS(Img)^(-1.0/3.0))
   h = HISTOGRAM(Img, locations = x, binsize = FreedmanDiaconis)

   ;sor = SORT(Img)
   ;t = TOTAL(Img)
   ;At = max(h)*(x[N-1] - x[0])
   
   N = N_ELEMENTS(x)
   vecObj = DBLARR(N)
   FOR cut = 1, (N-2) DO BEGIN
      areaLeft = TOTAL(h[0:cut])
      rectLeft = (x[cut] - x[0]) * max(h[0:cut])
      
      areaRight = TOTAL(h[cut:(N-1)])
      rectRight = (x[N-1] - x[cut]) * max(h[cut:(N-1)])
      
      vecObj[cut] = ((areaLeft*areaRight)*(areaLeft + areaRight))/((rectLeft*rectRight)*(rectLeft+rectRight))
   ENDFOR

   pos = where(vecObj eq max(vecObj))
   
;   window, 1
;   plot, x, vecObj
;   oplot, [x[pos],x[pos]], [0,max(h)], color = 600000L
;   
;   window, 2
;   plot, x, h
;   oplot, [x[pos],x[pos]], [0,max(h)], color = 600000L
;   
;   window, 3
;   tvscl, (Img GT x[pos[0]])
   

   Return, (Img GT x[pos[0]])
END