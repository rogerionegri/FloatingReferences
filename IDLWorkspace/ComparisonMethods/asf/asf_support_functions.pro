FUNCTION ASF_SUPPORT_FUNCTIONS
   ;caller...
END


;################################################
FUNCTION SE_SHAPE, diam, shapeType

  disk = INTARR(diam,diam)
  center = [diam/2,diam/2]

  IF shapeType EQ 'disk' THEN disk[*] = 1

  IF shapeType EQ 'diamond' THEN BEGIN
    FOR i = 0, (diam-1) DO BEGIN
      FOR j = 0, (diam-1) DO BEGIN
        IF NORM([i,j] - center) LE diam/2 THEN disk[i,j] = 1
      ENDFOR
    ENDFOR
  ENDIF

  Return, disk
END

;################################################
FUNCTION MORPHO_BOCA, Image, SE, opType

  diam = SIZE(SE,/Dimensions)   &   diam = diam[0]
  Dims = SIZE(Image,/Dimensions)
  neigh = MAKE_ARRAY(diam*diam, TYPE = SIZE(Image,/TYPE))
  resImage = Image*0.0

  FOR i = 0, Dims[0]-1 DO BEGIN
    FOR j = 0, Dims[1]-1 DO BEGIN
      count = 0L
      neigh[*] *= 0
      FOR k = -(diam/2), +(diam/2) DO BEGIN
        FOR l = -(diam/2), +(diam/2) DO BEGIN

          IF ((i+k) GE 0) AND ((i+k) LT Dims[0]) AND ((j+l) GE 0) AND ((j+l) LT Dims[1]) THEN BEGIN
            IF SE[k+(diam/2) , l+(diam/2)] NE 0 THEN BEGIN
              neigh[count] = Image[i+k,j+l]
              count++
            ENDIF
          ENDIF

        ENDFOR
      ENDFOR

      IF (opType EQ 'dilate') THEN resImage[i,j] = MAX(neigh[0:count-1])
      IF (opType EQ 'erode') THEN resImage[i,j] = MIN(neigh[0:count-1])
      IF (opType EQ 'average') THEN resImage[i,j] = MEAN(neigh[0:count-1])

    ENDFOR
  ENDFOR

  Return, resImage
END
