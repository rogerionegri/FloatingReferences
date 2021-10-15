FUNCTION REBUILD_SEGM_CLUSTERS, structRegs, Segm

segmInd = Segm*0
segmIndLin = Segm*0

RegIndex = Segm[UNIQ(Segm, SORT(Segm))]

n = N_ELEMENTS(structRegs)
FOR i = 0L, n-1 DO BEGIN
  ;IF RegIndex[i] GE 0 THEN BEGIN
    pos = WHERE(Segm EQ RegIndex[i])
    segmInd[pos] = structRegs[i].ind
  ;ENDIF 
ENDFOR

;Return, segmInd

b = sort(segmInd)
c = uniq(segmInd[b])
d = segmInd[b[c]]

ind = 0
n = N_ELEMENTS(d)-1
FOR i = d[0], d[n] DO BEGIN
   pos = WHERE(segmInd EQ i)
   IF pos[0] NE -1 THEN BEGIN
      segmIndLin[pos] = ind
      ind++
   ENDIF
ENDFOR

Return, {imageClustersLin: segmIndLin, imageClusters: segmInd, indexClusters: d, structRegsInd: structRegs[*].ind}
END