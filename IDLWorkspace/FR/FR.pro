FUNCTION FR, Img1, Img2, params 

  ;------------------------------------------------------------
  WinX = 2*params.NeighRadius + 1
  WinY = WinX 

  ;AHD--------------------------
  minElem = params.minElements
  distType = 3

  ;KDE e Inter.Conf.-------------
  stepPercent = 0.1
  ;------------------------------------------------------------

  Dims = GET_DIMENSIONS(Img1)
  warnImage = DBLARR(Dims[1],Dims[2])

  t0 = systime(/seconds)
  ParRegs1 = GET_NEIGH_PARS(Img1, WinX, WinY)
  t1 = systime(/seconds)
  print, 'time...', t1-t0
  ParRegs2 = GET_NEIGH_PARS(Img2, WinX, WinY)
  t2 = systime(/seconds)
  print, 'time...', t2-t1

  segmBlock = BUILD_PIXEL_SEQUENCE(Img1)
  clusts = AHD_STOCH_CLUSTERS_4PIX(Img1, segmBlock, ParRegs1, minElem, distType)

  ;geração das curvas de distancias para cada grupo entre img1 e img2
  FOR i = MIN(clusts.indexClusters), MAX(clusts.indexClusters) DO BEGIN
    pos = WHERE(clusts.structRegsInd EQ i) ;equivalencia lexicografica

    IF pos[0] NE -1 THEN BEGIN
      distBlocks = DBLARR(N_ELEMENTS(pos))
      FOR j = 0L, N_ELEMENTS(pos)-1 DO BEGIN
        ParI = *ParRegs1[pos[j]]
        ParJ = *ParRegs2[pos[j]]
        distBlocks[j] = NORM(ParI.Mu - ParJ.Mu)
        if ~finite(distBlocks[j]) then distBlocks[j] = -1   ;<<< teste (coloca fora da area que eh usada pela fx)
      ENDFOR

      origfx = KERNEL_DENSITY_ESTIMATOR(distBlocks, h, [0.0, max(distBlocks)], (max(distBlocks) - 0.0)*(1/100.0)*stepPercent)
      fx = DERIVA_AND_REFINE(origFx.X,origFx.Y)
      ss = SEARCH_SOL(fx.X, fx.Y)

      vA = 0.1
      margA = 0.01 ;>>> infA = vA-margA   &   supA = vA+margA
      infA = (vA-margA)   &   supA = (vA+margA)
      
      fs = FIND_SOL_V2(ss, infA, supA)

      A = [fs.px]   &   B = [fs.py]

      refTemp = (fx.X[B] + fx.X[A])*0.5 ;>>> media do centro do intervalo de referencia!
      
      Warn = CHECK_CHANGES_V4(distBlocks, pos, segmBlock, refTemp)
      
      warnImage += Warn
    ENDIF

  ENDFOR

  doido = MAX_CUT_DOIDO_V2(warnImage)

  ;color map
  ClaImageDoido = UNSUPERVISED_COLOR_CLASSIFICATION(doido)

  ;>>>>adiconado -- 12/12/18
  PTR_FREE, ParRegs1[*], ParRegs2[*]
  HEAP_GC, /verbose

  Return, {Index: doido, Classification: ClaImageDoido, RuleImage: warnImage}
END