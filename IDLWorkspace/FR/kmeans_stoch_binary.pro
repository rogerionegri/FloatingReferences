FUNCTION KMEANS_STOCH_BINARY, ParRegs, distType

;lista = just_get_mu_list(parRegs)  ;>>>REMOVER APOS TESTES!

;Parameters
Centroids = 2
MaxIter = 1000L
Epsilon = 0.000001D

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
            2: CentDist[j] = HELLINGER(ParI.Mu, ParJ.Mu, ParI.Sigma, ParJ.Sigma)
            3: CentDist[j] = NORM(ParI.Mu - ParJ.Mu)
            4: CentDist[j] = KULLBACK_LEIBLER(ParI.Mu, ParJ.Mu, ParI.Sigma, ParJ.Sigma)
            5: CentDist[j] = BOCA_NORMA(ParI.Mu, ParJ.Mu, ParI.Sigma, ParJ.Sigma)
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
      FOR k = 0L, N_ELEMENTS(pos)-1 DO BEGIN
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
   ;Convergence = STOCH_CONVERGENCE(OldCents,CentSEGs,OldCentQnt,CentQnt, distType)   
   
   
   AA = *CentSEGs[0]
   BB = *CentSEGs[1]
   
   CC = *OldCents[0]
   DD = *OldCents[1]
   
   ;Print, 'Iteration: ', iters, ' determs ', max([DETERM(AA.Sigma) , DETERM(BB.Sigma)]), ' dif norm ', NORM(AA.mu - BB.mu)
   ;Print, 'Iteration: ', iters, ' >>> ', (NORM(AA.mu - CC.mu) + NORM(BB.mu - DD.mu))

   IF (NORM(AA.mu - CC.mu) + NORM(BB.mu - DD.mu)) LT Epsilon THEN Convergence = 1
   
   ;Max iterations
   IF iters GE MaxIter THEN Convergence = 1

iters++
ENDWHILE

posL = WHERE(ClaRegs EQ 0)
posR = WHERE(ClaRegs EQ 1)

diamL = GET_CLUSTER_DIAMETER(ParRegs[posL], *CentSEGs[0], distType)
diamR = GET_CLUSTER_DIAMETER(ParRegs[posR], *CentSEGs[1], distType)

Return, [{pos: PTR_NEW(posL), diam: diamL} , {pos: PTR_NEW(posR), diam: diamR}]
END