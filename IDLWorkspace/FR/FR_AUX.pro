PRO FR_AUX
END


;################################
FUNCTION GET_MU_NEIGH, Image, ImgSEG, winX, winY

  Dim = SIZE(Image,/DIMENSION)
  NB = Dim[0]   &   NC = Dim[1]   &   NL = Dim[2]
  RegIndex = ImgSEG[UNIQ(ImgSEG, SORT(ImgSEG))]

  ;Vetor de estrutura usado para guardar parametros das regioes a serem classificadas
  ;VRegs = REPLICATE( {Mu: FLTARR(NB), Sigma: FLTARR(NB,NB), $
  ;                    InvSigma: FLTARR(NB,NB)} , N_ELEMENTS(RegIndex) )

  VRegs = PTRARR(N_ELEMENTS(RegIndex))

  FOR i = 0L, N_ELEMENTS(RegIndex)-1 DO BEGIN

    Index = RegIndex[i]
    Lex = WHERE(ImgSEG EQ Index)

    lin = LONG(Lex/NC)
    col = LONG(Lex MOD NC)

    Samples = GET_QUICK_NEIGH_VALS(col,lin,WinX,WinY,Dim[1],Dim[2],Image)

    ;calcular os parametros...
    MeanVec = MEAN_VECTOR(Samples)
    SigMatrix = COVARIANCE_MATRIX(Samples)

    if ~finite(MeanVec[0]) then stop

    InvSigma = INVERT(SigMatrix, Status, /DOUBLE)
    ;IF Status THEN print, 'Opa! Matriz singular... (get seg reg)'

    WHILE Status DO BEGIN
      print, 'Opa! Matriz singular... (compute parameters)', i

      auxxx = RANDOMU(SYSTIME(/SECONDS),N_ELEMENTS(SigMatrix[*,0])) * 0.01
      ;SigMatrix += RANDOMU(SYSTIME(/SECONDS),N_ELEMENTS(SigMatrix[*,0]), N_ELEMENTS(SigMatrix[0,*]))
      SigMatrix += (auxxx ## auxxx)

      InvSigma = INVERT(SigMatrix, Status, /DOUBLE)
    ENDWHILE

    VRegs[i] = PTR_NEW({Mu: MeanVec, Sigma: SigMatrix, InvSigma: InvSigma})
  ENDFOR

  Return, VRegs
END



;;#################################
;FUNCTION MEAN_VECTOR, Samples
;
;MeanVec = Samples[*,0]
;
;FOR i = 0, N_ELEMENTS(Samples[*,0])-1 DO $
;   MeanVec[i] = TOTAL(Samples[i,*])/FLOAT(N_ELEMENTS(Samples[0,*]))
;
;Return, MeanVec
;END
;



;################################
FUNCTION GET_NEIGH_PARS, Image, winX, winY

  Dim = SIZE(Image,/DIMENSION)
  NB = Dim[0]   &   NC = Dim[1]   &   NL = Dim[2]

  ;Vetor de estrutura usado para guardar parametros das regioes a serem classificadas
  ;VRegs = REPLICATE( {Mu: FLTARR(NB), Sigma: FLTARR(NB,NB)} , NC*NL )
  ;VRegs = REPLICATE( {Mu: FLTARR(NB)} , NC*NL )
  VRegs = PTRARR(NC*NL)

  pos = 0L
  FOR i = 0L, NC-1 DO BEGIN
    FOR j = 0L, NL-1 DO BEGIN

      Samples = GET_QUICK_NEIGH_VALS(i,j,WinX,WinY,NB,NC,NL,Image)

      ;calcular os parametros...
      MeanVec = MEAN_VECTOR(Samples)
      SigMatrix = COVARIANCE_MATRIX(Samples)

      if ~finite(MeanVec[0]) then stop

      invSigma = INVERT(SigMatrix, Status, /DOUBLE)

      WHILE Status DO BEGIN
        ;print, 'Opa! Matriz singular... (compute parameters)', i

        auxxx = RANDOMU(SYSTIME(/SECONDS),N_ELEMENTS(SigMatrix[*,0])) * 0.01
        ;SigMatrix += RANDOMU(SYSTIME(/SECONDS),N_ELEMENTS(SigMatrix[*,0]), N_ELEMENTS(SigMatrix[0,*]))
        SigMatrix += (auxxx ## auxxx)

        InvSigma = INVERT(SigMatrix, Status, /DOUBLE)
      ENDWHILE



      VRegs[pos] = PTR_NEW({Mu: MeanVec, Sigma: SigMatrix, InvSigma: InvSigma})
      pos++
    ENDFOR
  ENDFOR

  Return, VRegs
END





;#####################################
FUNCTION GET_QUICK_NEIGH_VALS,pi,pj,WinX,WinY,NB,NC,NL,Image

  Neighs = MAKE_ARRAY(NB,NC*NL,TYPE = SIZE(Image,/TYPE))
  count = 0
  FOR i = LONG(-WinX)/2, LONG(+WinX)/2 DO BEGIN
    FOR j = LONG(-WinY)/2, LONG(+WinY)/2 DO BEGIN
      IF ((((pi + i) GE 0) AND ((pi + i) LT NC)) AND (((pj + j) GE 0) AND ((pj + j) LT NL)) ) THEN BEGIN
        Neighs[*,count] = Image[*,pi+i,pj+j]
        count++
      ENDIF
    ENDFOR
  ENDFOR

  Return, Neighs[*,0:count-1]
END