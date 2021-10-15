FUNCTION AHD_STOCH_CLUSTERS_4PIX, Img, segmBlock, ParRegs, minElem, distType


  structRegs = REPLICATE( {parReg: PTR_NEW(), ind: -1L}, N_ELEMENTS(ParRegs) )
  structRegs[*].parReg = ParRegs
  structRegs[*].ind = 0

  cardElemSet = N_ELEMENTS(ParRegs)

  ListInd = [-1,0]
  indexSet = 0
  WHILE N_ELEMENTS(ListInd) NE 1 DO BEGIN
    print, ListInd

    current = ListInd[N_ELEMENTS(ListInd)-1]
    ListInd = ListInd[0:N_ELEMENTS(ListInd)-2] ;remove para analise

    pos = WHERE(structRegs[*].ind EQ current)
    ;condSplit = SPLIT_CONDITION_V2(structRegs[pos],minElem*cardElemSet)

    ;IF condSplit THEN BEGIN

    posLR = KMEANS_STOCH_BINARY(structRegs[pos].parReg, distType)
    posL = *posLR[0].pos
    posR = *posLR[1].pos
    diamL = posLR[0].diam
    diamR = posLR[1].diam

    print, 'L>> ', n_elements(posL), '  diam: ', diamL
    print, 'R>> ', n_elements(posR), '  diam: ', diamR

    ;IF (posL[0] NE -1) AND (diamL GT diamThreshold) THEN BEGIN
    IF N_ELEMENTS(posL) GT (minElem*cardElemSet) THEN BEGIN
      indexSet++
      ListInd = [ListInd , indexSet]
      structRegs[pos[posL]].ind = indexSet
    ENDIF

    ;IF (posR[0] NE -1) AND (diamR GT diamThreshold) THEN BEGIN
    IF N_ELEMENTS(posR) GT (minElem*cardElemSet) THEN BEGIN
      indexSet++
      ListInd = [ListInd , indexSet]
      structRegs[pos[posR]].ind = indexSet
    ENDIF

    ;ENDIF

  ENDWHILE

 
  ahdClusters = rebuild_segm_clusters(structRegs,segmBlock)
  ;ahdClusters = REBUILD_PIXEL_CLUSTERS(structRegs, Img)

  Return, ahdClusters
END