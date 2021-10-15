FUNCTION GKC4CD_MODULE, img1, img2, epsilon, alpha

;-------------------------------------------------------
;  PATH_T1 = 'time 1'
;  PATH_T2 = 'time 2';
;
;  Atts = attributes...
;
;  alpham = S.A. cooling factor
;-------------------------------------------------------

  C = 2   ;<<<fixed (change-non change)
  m = 2.0 ;<<<adjusted by Simulated Annealing
  rho = FLTARR(C)   &   rho[*] = 1.0 ;<<<adjusted by Simulated Annealing
  percent = 0.0025 ;<<<fixed?
  seed = 123456L   ;<<<fixed!
  ;-------------------------------------------------------

  img1 = DARK_SUBTRACTION(img1)
  img2 = DARK_SUBTRACTION(img2)

  difImage = FUNC_CVA(img1,img2)
  difImage = difImage.Magnitude

  ;filtragem pela media...
  Structure = SE_SHAPE(3, 'disk')
  avgDifImage = MORPHO_BOCA(difImage, Structure, 'average')

  ;two-band image adopted by the method
  imageGKC = FLTARR(2,N_ELEMENTS(difImage[*,0]),N_ELEMENTS(difImage[0,*]))
  imageGKC[0,*,*] = difImage   &   imageGKC[1,*,*] = avgDifImage

  ;Processo com SA aqui...
  parsSA = SIMULATED_ANNEALING_GKC(imageGKC, C, epsilon, percent*0.25, alpha, seed)
  resGKC = GKC(imageGKC, C, parsSA.Pars[0], parsSA.Pars[1:2], epsilon, percent)

  changeRef1 = MEAN(resGKC.Centroids[*,0])  ;MEAN(resGKC.Rule[0,*,*])
  changeRef2 = MEAN(resGKC.Centroids[*,1])  ;MEAN(resGKC.Rule[1,*,*])

  IF changeRef1 LE changeRef2 THEN ChangeMap = resGKC.Index ELSE BEGIN
    posChange = WHERE(resGKC.Index EQ 0)
    posNonChange = WHERE(resGKC.Index EQ 1)
    ChangeMap = resGKC.Index
    ChangeMap[posChange] = 1   &   ChangeMap[posNonChange] = 0
  ENDELSE

  ;color map
  ClaImage = UNSUPERVISED_COLOR_CLASSIFICATION(ChangeMap)
  
  Return, {Index: ChangeMap, Classification: ClaImage, RuleImage: resGKC.Rule}
END