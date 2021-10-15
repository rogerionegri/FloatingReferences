FUNCTION COMPUTE_PARAMETERS, Image, TReg, PntROIs

Dim = SIZE(Image,/DIMENSION)
NB = Dim[0]   &   NC = Dim[1]   &   NL = Dim[2]

ParRegs = PTRARR(N_ELEMENTS(PntROIs))

FOR i = 0, N_ELEMENTS(TReg)-1 DO BEGIN
   
   Regs = *TReg[i] ;regioes de uma dada classe i
   
   Pars = PTRARR(N_ELEMENTS(Regs))
   ;Pars = REPLICATE( {Mu: [0], Sigma: [0], InvSigma: [0]}, N_ELEMENTS(Regs)) 
   
   FOR j = 0, N_ELEMENTS(Regs)-1 DO BEGIN
      Lex = *Regs[j] ;posicoes dos pixels q compoe a regiao
      
      Samples = FLTARR(NB)
      FOR k = 0, N_ELEMENTS(Lex)-1 DO BEGIN
         lin = FIX(Lex[k]/NC)
         col = FIX(Lex[k] MOD NC)
         Samples = [ [Samples] , [Image[*,col,lin]] ]
      ENDFOR
      Samples = Samples[*,1:N_ELEMENTS(Samples[0,*])-1]
      
      ;calcular os parametros...
      MeanVec = MEAN_VECTOR(Samples)
      SigMatrix = COVARIANCE_MATRIX(Samples)
      InvSigma = INVERT(SigMatrix, Status, /DOUBLE)
      
      IF Status THEN BEGIN
         
         WHILE Status DO BEGIN
            print, 'Opa! Matriz singular... (compute parameters)', i
            SigMatrix += RANDOMU(SYSTIME(/SECONDS),N_ELEMENTS(SigMatrix[*,0]), N_ELEMENTS(SigMatrix[0,*]))
            InvSigma = INVERT(SigMatrix, Status, /DOUBLE)
         ENDWHILE          
            
      ENDIF
      
      ;armazenar os parametros calculados
      ;Pars[j].Mu = MeanVec
      ;Pars[j].Sigma = SigMatrix
      ;Pars[j].InvSigma = InvSigma
      Pars[j] = PTR_NEW({Mu: MeanVec, Sigma: SigMatrix, InvSigma: InvSigma})
      
      PTR_FREE, Regs[j] ;desaloca o vetor de posicoes da regiao j, classe i 
   ENDFOR
   
   ParRegs[i] = PTR_NEW(Pars)
   
   PTR_FREE, TReg[i] ;desaloca a classe i
ENDFOR

Return, ParRegs
END







;#################################
FUNCTION COMPUTE_REGION_PARAMETERS, Image, TReg, PntROIs

Dim = SIZE(Image,/DIMENSION)
NB = Dim[0]   &   NC = Dim[1]   &   NL = Dim[2]

ParRegs = [PTR_NEW()]

FOR i = 0, N_ELEMENTS(TReg)-1 DO BEGIN
   
   Regs = *TReg[i] ;regioes de uma dada classe i 
   
   FOR j = 0, N_ELEMENTS(Regs)-1 DO BEGIN
      Lex = *Regs[j] ;posicoes dos pixels q compoe a regiao
      
      Samples = FLTARR(NB)
      FOR k = 0, N_ELEMENTS(Lex)-1 DO BEGIN
         lin = FIX(Lex[k]/NC)
         col = FIX(Lex[k] MOD NC)
         Samples = [ [Samples] , [Image[*,col,lin]] ]
      ENDFOR
      Samples = Samples[*,1:N_ELEMENTS(Samples[0,*])-1]
      
      ;calcular os parametros...
      MeanVec = MEAN_VECTOR(Samples)
      SigMatrix = COVARIANCE_MATRIX(Samples)
      InvSigma = INVERT(SigMatrix, Status, /DOUBLE)
      
      IF Status THEN BEGIN
         
         WHILE Status DO BEGIN
            print, 'Opa! Matriz singular... (compute parameters)', i
            SigMatrix += RANDOMU(SYSTIME(/SECONDS),N_ELEMENTS(SigMatrix[*,0]), N_ELEMENTS(SigMatrix[0,*]))
            InvSigma = INVERT(SigMatrix, Status, /DOUBLE)
         ENDWHILE          
            
      ENDIF
      
      Pars = PTR_NEW({Mu: MeanVec, Sigma: SigMatrix, InvSigma: InvSigma})
      
      PTR_FREE, Regs[j] ;desaloca o vetor de posicoes da regiao j, classe i
      
      ParRegs = [ParRegs, Pars] 
   ENDFOR   
   
   PTR_FREE, TReg[i] ;desaloca a classe i
ENDFOR

Return, ParRegs[1:*]
END







;#################################
FUNCTION MEAN_VECTOR, Samples

MeanVec = Samples[*,0]*1.0D

FOR i = 0, N_ELEMENTS(Samples[*,0])-1 DO $
   MeanVec[i] = TOTAL(Samples[i,*])/DOUBLE(N_ELEMENTS(Samples[0,*]))

Return, MeanVec
END



;#################################
FUNCTION COVARIANCE_MATRIX, Samples

MeanVec = Samples[*,0]
FOR i = 0L, N_ELEMENTS(Samples[*,0])-1 DO $
   MeanVec[i] = TOTAL(Samples[i,*])/DOUBLE(N_ELEMENTS(Samples[0,*]))
   
SigMatrix = DBLARR(N_ELEMENTS(Samples[*,0]),N_ELEMENTS(Samples[*,0]))

SampleMu = Samples
FOR i = 0L, N_ELEMENTS(Samples[0,*])-1 DO SampleMu[*,i] = Samples[*,i] - MeanVec[*]
FOR i = 0L, N_ELEMENTS(Samples[0,*])-1 DO SigMatrix += SampleMu[*,i]##(SampleMu[*,i])

SigMatrix = SigMatrix/DOUBLE(N_ELEMENTS(Samples[0,*]))

Return, SigMatrix
END


FUNCTION COMPUTE_PARAMETERS_ROI, Image, PntROIs

Dim = SIZE(Image,/DIMENSION)
NB = Dim[0]   &   NC = Dim[1]   &   NL = Dim[2]

ParRegs = PTRARR(N_ELEMENTS(PntROIs))

FOR i = 0, N_ELEMENTS(PntROIs)-1 DO BEGIN
   
   Roi = *PntROIs[i]
   Lex = Roi.RoiLex
   Samples = DBLARR(NB)
   FOR k = 0L, N_ELEMENTS(Lex)-1 DO BEGIN
      lin = LONG(Lex[k]/NC)
      col = LONG(Lex[k] MOD NC)
      Samples = [ [Samples] , [Image[*,col,lin]] ]
   ENDFOR
   Samples = Samples[*,1:N_ELEMENTS(Samples[0,*])-1]
      
   ;calcular os parametros...
   MeanVec = MEAN_VECTOR(Samples)
   SigMatrix = COVARIANCE_MATRIX(Samples)
   InvSigma = INVERT(SigMatrix, Status, /DOUBLE)
      
   IF Status THEN print, 'Opa! Matriz singular... (comp param rois)', i
      
   ;armazenar os parametros calculados
   Pars = {Mu: MeanVec, Sigma: SigMatrix, InvSigma: InvSigma}      
   ParRegs[i] = PTR_NEW(Pars)
   
ENDFOR

Return, ParRegs
END




;;Adicionado...
;FUNCTION BHATTACHARYYA, MuX, MuY, SigmaX, SigmaY
;;###########################################
;
;;Distancia de Bhattacharyya, simplificada para distribuição gaussiana multivariada
;
;P = (SigmaX + SigmaY)/2.0
;
;DetP = DETERM(P,/CHECK)
;DetX = DETERM(SigmaX,/CHECK)
;DetY = DETERM(SigmaY,/CHECK)
;
;IF ~FINITE(DetP/SQRT(DetX*DetY)) THEN Return, 10L^10 $
;ELSE D = (1/8.0)*TRANSPOSE(MuX - MuY)#INVERT(P)#(MuX - MuY) + 0.5*ALOG(DetP/SQRT(DetX*DetY))
;
;Return, D
;END


;Adicionado...
FUNCTION BHATTACHARYYA, MuX, MuY, SigmaX, SigmaY
;###########################################

;Distancia de Bhattacharyya, simplificada para distribuição gaussiana multivariada
P = (SigmaX + SigmaY)/2.0
D = (1/8.0)*TRANSPOSE(MuX - MuY)#INVERT(P)#(MuX - MuY) + $
    0.5*ALOG(DETERM(P, /check, /double)/SQRT(DETERM(SigmaX, /check, /double)*DETERM(SigmaY, /check, /double)))
    
Return, D
END




;Adicionado...
FUNCTION HELLINGER, MuX, MuY, SigmaX, SigmaY
  ;###########################################

  ;Distancia de Hellinger, simplificada para distribuição gaussiana multivariada
  
  P = 0.5*(SigmaX + SigmaY)
  A = DETERM(SigmaX, /check, /double)^0.25 * DETERM(SigmaY, /check, /double)^0.25
  B = DETERM( P , /check, /double)^0.5
  D = -0.125 * TRANSPOSE(MuX - MuY)#INVERT(P)#(MuX - MuY)

  H = 1.0 - ( (A/B) * EXP(D) )

  Return, H
END




;Adicionado...
FUNCTION KULLBACK_LEIBLER, Mu0, Mu1, Sigma0, Sigma1
  ;###########################################

  ;Distancia de Kullback-Leibler para distribuição gaussiana multivariada
  
  invSigma0 = INVERT(Sigma0)
  invSigma1 = INVERT(Sigma1)
  k = N_ELEMENTS(Mu0)
  detSigma0 = DETERM(Sigma0, /check, /double)
  detSigma1 = DETERM(Sigma1, /check, /double)
  
  D01 = 0.5 * ( TRACE(invSigma1 # Sigma0) + TRANSPOSE(Mu1 - Mu0) # invSigma1 # (Mu1 - Mu0) - k + ALOG(detSigma1/detSigma0) ) 
  D10 = 0.5 * ( TRACE(invSigma0 # Sigma1) + TRANSPOSE(Mu0 - Mu1) # invSigma0 # (Mu0 - Mu1) - k + ALOG(detSigma0/detSigma1) )
  
  ;cabrito tosco....
  if ~finite(d01) then d01 = randomu(seed,1)
  if ~finite(d10) then d10 = randomu(seed,1)
  
  D = 0.5*(D01 + D10)

  Return, D
END



;Adicionado...
FUNCTION BOCA_NORMA, Mu0, Mu1, Sigma0, Sigma1
  ;###########################################
  
  ;experimentacao

  invSigma0 = INVERT(Sigma0)
  invSigma1 = INVERT(Sigma1)
  k = N_ELEMENTS(Mu0)
  
  AA =  TOTAL(ABS(TRANSPOSE(Mu1 - Mu0) # invSigma1 # (Mu1 - Mu0)))
  
  BB = invSigma0#Sigma1
  CC = invSigma1#Sigma0
  DD = TOTAL(ABS( BB + CC - 2*IDENTITY(k) ))
  
  Return, (AA + DD)
END