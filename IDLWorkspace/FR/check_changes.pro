FUNCTION CHECK_CHANGES, distBlocks, pos, fx, segmBlock, ind, A, B

warnImage = segmBlock*0L ;<<< imagem que vai denotar os possiveis locais de mudança
warnImageDist = segmBlock*0D ;<<< imagem que vai denotar os possiveis locais de mudança

RegIndex = segmBlock[UNIQ(segmBlock, SORT(segmBlock))]

;zona de alarme de mudanca...
listOutcast = -1L
FOR j = 0L, N_ELEMENTS(pos)-1 DO BEGIN
   IF ( ( distBlocks[j] LT MIN(fx.X[A:B]) ) OR ( distBlocks[j] GT MAX(fx.X[A:B]) ) ) THEN BEGIN
      listOutcast = [listOutcast , pos[j]]
      
      ;blockpos = WHERE(segmBlock EQ pos[j])
      blockpos = WHERE(segmBlock EQ RegIndex[pos[j]])
      
      warnImage[blockpos] = ind
      
      warnImageDist[blockpos] = distBlocks[j]
   ENDIF
ENDFOR

Return, {warnImage: warnImage, warnImageDist: warnImageDist}
END



;##########################################
FUNCTION CHECK_CHANGES_V2, distBlocks, pos, fx, segmBlock, A, B

warnImage = segmBlock*0L
RegIndex = segmBlock[UNIQ(segmBlock, SORT(segmBlock))]

;zona de alarme de mudanca...
FOR j = 0L, N_ELEMENTS(pos)-1 DO BEGIN
  IF ( ( distBlocks[j] LT MIN(fx.X[A:B]) ) OR ( distBlocks[j] GT MAX(fx.X[A:B]) ) ) THEN BEGIN
    ;IF RegIndex[pos[j]] GE 0 THEN BEGIN
      blockpos = WHERE(segmBlock EQ RegIndex[pos[j]])
      warnImage[blockpos] = 1
    ;ENDIF
  ENDIF
ENDFOR

Return, warnImage
END


;##########################################
FUNCTION CHECK_CHANGES_V3, distBlocks, pos, fx, segmBlock, A, B

  warnImage = segmBlock*0D
  RegIndex = segmBlock[UNIQ(segmBlock, SORT(segmBlock))]

  ;zona de alarme de mudanca...
  FOR j = 0L, N_ELEMENTS(pos)-1 DO BEGIN
    IF ( ( distBlocks[j] LT MIN(fx.X[A:B]) ) OR ( distBlocks[j] GT MAX(fx.X[A:B]) ) ) THEN BEGIN
      ;IF RegIndex[pos[j]] GE 0 THEN BEGIN
      blockpos = WHERE(segmBlock EQ RegIndex[pos[j]])
      ;warnImage[blockpos] = 1
      warnImage[blockpos] = MAX(fx.X[A:B]) - MIN(fx.X[A:B])
      ;ENDIF
    ENDIF
  ENDFOR

  Return, warnImage
END


;##########################################
FUNCTION CHECK_CHANGES_V4, distBlocks, pos, segmBlock, ref

  warnImage = segmBlock*0D
  RegIndex = segmBlock[UNIQ(segmBlock, SORT(segmBlock))]

  ;zona de alarme de mudanca...
  FOR j = 0L, N_ELEMENTS(pos)-1 DO BEGIN
    distRef = abs(distBlocks[j] - ref)
    blockpos = WHERE(segmBlock EQ RegIndex[pos[j]])
    warnImage[blockpos] = distRef
  ENDFOR

  Return, warnImage
END