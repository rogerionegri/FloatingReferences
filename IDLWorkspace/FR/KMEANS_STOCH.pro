FUNCTION KMEANS_STOCH, ParRegs, Centroids, distType, Segm, Image, path

;Parameters
MaxIter = 100L

ClaRegs = LONARR(N_ELEMENTS(ParRegs)) ;ja é a classificação!

;Define the centroids (random choice)
CentSEGs = GET_CENTROIDS_LIST(ParRegs,Centroids)
CentDist = DBLARR(Centroids)

;inicialização supondo que os centroides foram calculados por qnt igual de regiões...
CentQnt = DBLARR(Centroids) + LONG(N_ELEMENTS(ParRegs)/Centroids) 

iters = 0L
Convergence = 0
resetCent = *ParRegs[0]
   resetCent.Mu = resetCent.Mu*0
   resetCent.Sigma = resetCent.Sigma*0
   resetCent.InvSigma = resetCent.InvSigma*0
         
WHILE ~Convergence DO BEGIN

   FOR i = 0L, N_ELEMENTS(ParRegs)-1 DO BEGIN
      ParI = *ParRegs[i]
      FOR j = 0, Centroids-1 DO BEGIN
         ParJ = *CentSEGs[j]
         CASE distType OF       
            0: CentDist[j] = BHATTACHARYYA(ParI.Mu, ParJ.Mu, ParI.Sigma, ParJ.Sigma) 
            1: CentDist[j] = 2*(1-exp(-1 * BHATTACHARYYA(ParI.Mu, ParJ.Mu, ParI.Sigma, ParJ.Sigma)))
         ENDCASE   
      ENDFOR
   
      MinDist = WHERE(CentDist EQ MIN(CentDist))
      ClaRegs[i] = MinDist[0] ;melhorar esse critério, caso haja empate...
   ENDFOR

   ;Centroid update
   OldCents = CentSEGs
   OldCentQnt = CentQnt
   FOR j = 0, Centroids-1 DO BEGIN
      pos = WHERE(ClaRegs EQ j)
      CentQnt[j] = N_ELEMENTS(pos)
      
      ;reinializa o centroide... pois nenhum elemento foi associado a ele...
      if pos[0] eq -1 then begin
         pos = LONG(RANDOMU(SYSTIME(/SECONDS),1)*10000*j+iters) MOD (N_ELEMENTS(ClaRegs) + 1)
         print, 'forced reinitialization on centroid', j
      endif
      
      CentSum = resetCent ;just initailize
      FOR k = 0, N_ELEMENTS(pos)-1 DO BEGIN
         Aux = *ParRegs[pos[k]]
         CentSum.Mu += Aux.Mu
         CentSum.Sigma += Aux.Sigma
         CentSum.InvSigma += Aux.InvSigma
      ENDFOR
      CentSum.Mu /= DOUBLE(N_ELEMENTS(pos))
      CentSum.Sigma /= DOUBLE(N_ELEMENTS(pos))
      CentSum.InvSigma /= DOUBLE(N_ELEMENTS(pos))
      
      CentSEGs[j] = PTR_NEW(CentSum)
   ENDFOR

   ;Convergence? (diference on updated centroids)
   Convergence = STOCH_CONVERGENCE(OldCents,CentSEGs,OldCentQnt,CentQnt, distType)   
   
   ;Max iterations
   IF iters GE MaxIter THEN Convergence = 1
   
   Print, 'Iteration: ', iters

iters++
ENDWHILE

;gerar imagens com
dim = GET_DIMENSIONS(Image)
ClaTeste = Segm*0 -1
FOR i = 0, Centroids-1 DO BEGIN
   pos = WHERE(ClaRegs EQ i)
   IF pos[0] NE -1 THEN BEGIN
      FOR j = 0, N_ELEMENTS(pos)-1 DO BEGIN
         posSeg = WHERE(Segm EQ pos[j])
         ClaTeste[posSeg] = i
      ENDFOR
   ENDIF
   
   posNull = WHERE(ClaTeste NE i)
   tempImage = Image*0
   tempBand = FLTARR(dim[1],dim[2])*0
   FOR ba = 0, dim[0]-1 DO BEGIN
      tempBand[*,*] = Image[ba,*,*]
      tempBand[posNull] = 0
      tempImage[ba,*,*] = tempBand[*,*]
   ENDFOR
   path_img = path+'_'+STRTRIM(STRING(i),1)+'.tiff'
   WRITE_TIFF, path_img, tempImage
ENDFOR


stop
Return, 0
END




;##################################
FUNCTION GET_CENTROIDS_LIST, ParRegs, Centroids

CentSEGs = PTRARR(Centroids)
Rand = LONG((RANDOMU(SYSTIME(/SECONDS) MOD 10000,Centroids) * 1e9) MOD (N_ELEMENTS(ParRegs)+1))
CentSEGs = ParRegs[Rand]

Return, CentSEGs
END


;##################################
FUNCTION STOCH_CONVERGENCE, OldCents, CentSEGs, OldCentQnt, CentQnt, distType;, ENL

Aux = *OldCents[0] 
;nb = N_ELEMENTS(Aux[0,*])
nb = N_ELEMENTS(Aux.Mu)

GL = DOUBLE(nb^2.0)
significance = 0.00001

;Por enquanto, só para bathacharrya...
FOR j = 0, N_ELEMENTS(OldCents)-1 DO BEGIN
   ParI = *OldCents[j]
   ParJ = *CentSEGs[j]

   CASE distType OF
      0: d = BHATTACHARYYA(ParI.Mu, ParJ.Mu, ParI.Sigma, ParJ.Sigma) 
      1: d = 2*(1-exp(-1 * BHATTACHARYYA(ParI.Mu, ParJ.Mu, ParI.Sigma, ParJ.Sigma)))
      2: d = HELLINGER(ParI.Mu, ParJ.Mu, ParI.Sigma, ParJ.Sigma)
   ENDCASE
   
   ;s = 8*[(OldCentQnt[j]*CentQnt[j])/(OldCentQnt[j]+CentQnt[j])]*d  ;<<<<<<<pq esse colchete???
   s = 8*((OldCentQnt[j]*CentQnt[j])/(OldCentQnt[j]+CentQnt[j]))*d
   pv = CHISQR_PDF(s, GL)
   P_VAL = 1.0-pv
   
   ;se P_VAL < significance, os centroides são diferentes, logo, não convergiu!
   IF P_VAL LE significance THEN Return, 0
ENDFOR

Return, 1
END