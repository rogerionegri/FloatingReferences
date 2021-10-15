FUNCTION CVA_MODULE, PATH_T1, PATH_T2, Atts1, Atts2, tresType, rule

  img1 = OPEN_IMAGE(PATH_T1, Atts1)
  img2 = OPEN_IMAGE(PATH_T2, Atts2)
  difImage = FUNC_CVA(img1,img2)


   CASE tresType OF
      1: BEGIN
         ;tresholding
         otsu = OTSU_THRESHOLD(difImage.magnitude,rule)
         ;color map
         ClaImage = UNSUPERVISED_COLOR_CLASSIFICATION(otsu)
         Return, {Index: otsu, Classification: ClaImage, RuleImage: difImage}
      END

      2: BEGIN
         ;tresholding
         kiw = KIW_THRESHOLD(difImage.magnitude,rule)
         ;color map
         ClaImage = UNSUPERVISED_COLOR_CLASSIFICATION(kiw)
         Return, {Index: kiw, Classification: ClaImage, RuleImage: difImage}
      END
   ENDCASE

END