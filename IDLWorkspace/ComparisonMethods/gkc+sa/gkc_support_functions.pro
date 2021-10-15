PRO GKC_SUPPORT_FUNCTIONS
;caller...
END


;---------------------------------
FUNCTION INIT_CLUSTERS, Z, C
Dims = SIZE(Z,/DIMENSIONS)
V = MAKE_ARRAY(Dims[0],C, TYPE = SIZE(Z,/TYPE))*1.0
pts = FLOOR(RANDOMU(seed,C)*10L^5) MOD Dims[1] 

FOR i = 0, (C-1) DO V[*,i] = Z[*,pts[i]]

Return, V
END


;---------------------------------
FUNCTION INIT_PERTINENCE_MATRX, V, Z

Dims = SIZE(Z,/DIMENSIONS)
C = N_ELEMENTS(V[0,*])
U = MAKE_ARRAY(C,Dims[1], TYPE = SIZE(Z,/TYPE))*1.0

FOR i = 0L, Dims[1]-1 DO BEGIN
   FOR j = 0L, (C-1) DO U[j,i] = NORM(Z[*,i] - V[*,j])
   U[*,i] /= TOTAL(U[*,i])
ENDFOR

Return, U
END


;---------------------------------
FUNCTION XIE_BENI_GKC, V, U, Z, d

N = N_ELEMENTS(U[0,*])
C = N_ELEMENTS(U[*,0])

sumXB = 0.0D
FOR i = 0L, (C-1) DO BEGIN
   FOR k = 0L, (N-1) DO sumXB += (U[i,k]^2 * d[i,k]) 
ENDFOR

val = NORM(V[*,0] - V[*,1])
FOR i = 0L, (C-2) DO BEGIN
  FOR j = i+1, (C-1) DO BEGIN
     IF NORM(V[*,i] - V[*,j]) LT val THEN val = NORM(V[*,i] - V[*,j])
  ENDFOR
ENDFOR

XB = sumXB/(N*val^2)

Return, XB
END


;---------------------------------
FUNCTION INIT_CLUSTERS_SPREADER, Z, C, percent

N = N_ELEMENTS(Z[0,*])
combs = RAND_COMBS(N,percent,C)
nCombs = N_ELEMENTS(combs[0,*])

distCombs = DBLARR(nCombs)

FOR i = 0, (nCombs-1) DO distCombs[i] = INTERNAL_SET_DIST(Z[*,combs[*,i]], C)
  
larger = WHERE(distCombs EQ MAX(distCombs))

largeComb = combs[*,larger[0]]

V = Z[*,largeComb]

Return, V
END


;---------------------------------
FUNCTION INTERNAL_SET_DIST, data, C

;val = 0.0D
lis = DBLARR((C*(C+1))/2)
count = 0
FOR i = 0, C-2 DO BEGIN
   FOR j = i+1, C-1 DO BEGIN
      ;val += NORM(data[*,i] - data[*,j])
      lis[count] = NORM(data[*,i] - data[*,j])
      count++
   ENDFOR
ENDFOR

Return, mean(lis)
END


;---------------------------------
FUNCTION RAND_COMBS, N, percent, C

qnt = FLOOR(N*percent)
combs = LONARR(C,qnt)

FOR i = 0L, (qnt-1) DO BEGIN
   pos = SORT(RANDOMU(seed,N)) 
   combs[*,i] = pos[0:C-1]
ENDFOR

Return, combs 
END



;
;;---------------------------------
;FUNCTION INIT_CLUSTERS_SPREADER, Z, C, percent
;
;  N = N_ELEMENTS(Z[0,*])
;
;  pos = FLOOR( RANDOMU(seed, FLOOR(N*percent) ) * 10L^7L ) MOD N
;
;  partZ = Z[*,pos]
;
;  partN = N_ELEMENTS(pos)
;
;  combs = COMBINATION(partN,C)
;  combs = RAND_COMBS(N,percent,C)
;
;  distCombs = DBLARR(partN)
;
;  FOR i = 0, partN-1 DO distCombs[i] = INTERNAL_SET_DIST(partZ[*,combs[i,*]], C)
;
;  larger = WHERE(distCombs EQ MAX(distCombs))
;
;  largeComb = combs[larer[0]]
;
;  V = partZ[*,largeComb]
;
;  Return, V
;END