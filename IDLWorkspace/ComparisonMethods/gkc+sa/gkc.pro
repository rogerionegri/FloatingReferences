FUNCTION GKC, Image, C, m, rho, epsilon, percent

Dims = GET_DIMENSIONS(Image)

Z = GET_ALL_DATA(Image)

;V = INIT_CLUSTERS(Z,C)
V = INIT_CLUSTERS_SPREADER(Z, C, percent)

U = INIT_PERTINENCE_MATRX(V,Z)

F = DBLARR(C,Dims[0],Dims[0])
FQ = DBLARR(Dims[0],Dims[0]) ;auxiliar

N = N_ELEMENTS(Z[0,*])
iter = 0L
;WHILE 1 DO BEGIN
WHILE iter LE 1000 DO BEGIN

   ;Compute the cluster prototypes
   FOR i = 0L, (C-1) DO BEGIN
      sumNum = DBLARR(N_ELEMENTS(Z[*,0]))*0.0D
      sumDen = 0.0D
      FOR k = 0L, (N-1) DO BEGIN
         sumNum[*] += U[i,k]^m * Z[*,k]
         sumDen += U[i,k]^m
      ENDFOR
      V[*,i] = sumNum/sumDen
   ENDFOR


   ;Compute the covariance matrices
   F[*] = 0
   FOR i = 0L, (C-1) DO BEGIN
      sumDen = 0.0D
      FQ[*] = 0
      FOR k = 0L, (N-1) DO BEGIN
         sub = Z[*,k] - V[*,i]
         FQ[*,*] += U[i,k]^m * (sub # TRANSPOSE(sub))
         sumDen += U[i,k]^m
      ENDFOR
      F[i,*,*] = FQ[*,*]/sumDen
   ENDFOR


   ;Compute the distances
   d = U*0.0D
   FOR i = 0L, (C-1) DO BEGIN
      FQ[*,*] = F[i,*,*] 
      PROD = rho[i] * DETERM(FQ)^(1.0/Dims[0]) * INVERT(FQ)
      FOR k = 0L, (N-1) DO BEGIN
         sub = Z[*,k] - V[*,i]
         d[i,k] = TRANSPOSE(sub) # PROD # sub
      ENDFOR
   ENDFOR


   ;Update partition matrices
   oldU = U   &   U[*] *= 0.0
   FOR i = 0L, (C-1) DO BEGIN
      FOR k = 0L, (N-1) DO BEGIN
         Den = (d[i,k]/d[*,k])^(1.0/(m-1.0))
         U[i,k] = 1.0/TOTAL(Den)
      ENDFOR
   ENDFOR


   ;convergence?
   deltaU = mean(ABS(U - oldU))

   IF MAX(deltaU) LE epsilon THEN BREAK
   
   print, 'deltaU: ',  MAX(deltaU)
   
   iter++
ENDWHILE

xieBeni = XIE_BENI_GKC(V,U,Z,d)

rule = VECTOR_TO_RULEIMAGE(TRANSPOSE(U), Dims[1], Dims[2])
index = UNSUPERVISED_CLASSIFICATION_INDEX(rule)
color = UNSUPERVISED_FUZZY_CLASSIFICATION(rule,0)

Return, {Index: index, Rule: rule, Classification: color, XieBeni: xieBeni, centroids: V}
END




