@BocaLib.pro
@asf_support_functions.pro
@kitter_illingworth.pro
@otsu_threshold.pro
@assess_chandet_report.pro

PRO ASF_MAIN

   ;PATH_T1 and _T2 are the images paths (tif files)
   PATH_T1 = './dataset/Images/image1.tif'
   PATH_T2 = './dataset/Images/image2.tif'
  
   ;PATH_ROI is the path for txt-like file containing references samples to assess the change detection results
   ;Such file must the ENVI's ASCII Roi format only with "ROI Location - 1dAddress" option   
   PATH_ROI = './dataset/Samples/ChangeNonChange_RefSamples.txt'

   ;Atts1 allows select a band/attribute from images at PATH_T1 and PATH_T2
   ;The first band is indexed by 0 
   Atts1 = [0,1,2] ;The first three bands of PATH_T1 (and indirectly PATH_T2) will be considered in the following steps 
   Atts2 = Atts1

   ;Output text file with several assessment measures (Accuracy ; Precision ; Recall ; F1-Score ; Kappa ; VarianceKappa ; TP ; TN ; FP ; FN ; MCC; time(sec.))
   PATH_REPORT = './outputPath/Report.txt'
  
   ;Output path which contains the resullting change detection maps
   PATH_RESULT = './outputPath/'


  PREFIX = 'ASF__' ;Just a filename prefix (usefull for organization purposes)

  ;Atts1 allows select a band/attribute from images at PATH_T1 and PATH_T2
  ;The first band is indexed by 0
  Atts1 = [0,1,2] ;The first three bands of PATH_T1 (and indirectly PATH_T2) will be considered in the following steps
  Atts2 = Atts1

  ;Thresholding type: 1 - Otsu; 2 - Kittler-Illingworth; 3 - K-Means based approach
  tresType = 2
  ;Rule for histogram binsize choice: 0 - Freedman-Diaconis' rule; 1- Scott's rule [used for tresType 0 or 1]
  rule = 1
  ;Number of open-close iterations
  iters = 2
  ;----------------------------------------------

  parNames = ['tresType', 'rule', 'iterations']
  PUT_HEADER, PATH_REPORT, parNames

  t1 = SYSTIME(/seconds) ;initial instant  
  
  ;Images reading and magnitude computing
  img1 = OPEN_IMAGE(PATH_T1, Atts1)
  img2 = OPEN_IMAGE(PATH_T2, Atts2)
  difImage = FUNC_CVA(img1,img2)
  difImage = difImage.Magnitude

  ;ASF's core process
  FOR i = 1, iters DO BEGIN
    Structure = SE_SHAPE(2*i+1, 'disk')
    Img = MORPHO_BOCA(difImage, Structure, 'dilate')
    Img = MORPHO_BOCA(difImage, Structure, 'erode')
  ENDFOR

  ;Thresholding and mapping generating stages
  CASE tresType OF
    1: BEGIN
      ;tresholding
      thres = OTSU_THRESHOLD(Img,rule)
      ;color map
      mapChange = UNSUPERVISED_COLOR_CLASSIFICATION(otsu) ;<-- struct {Index: __, Classification: __, RuleImage: __}
    END
    2: BEGIN
      ;tresholding
      thres = KIW_THRESHOLD(Img,rule) 
      ;color map
      mapChange = UNSUPERVISED_COLOR_CLASSIFICATION(kiw) ;<-- struct {Index: __, Classification: __, RuleImage: __}
    END
  ENDCASE
  
  time = SYSTIME(/seconds) - t1 ;total runtime  

  ASSESS_CHANDET_REPORT, PATH_REPORT, thres, PATH_ROI, [STRTRIM(STRING(tresType),1),STRTRIM(STRING(rule),1),STRTRIM(STRING(iters),1)], time

  WRITE_TIFF, PATH_RESULT + PREFIX + 'tresType-rule = ' + STRTRIM(STRING(tresType),1) +' - '+ STRTRIM(STRING(rule),1) + '_binMap.tif', thres
  WRITE_TIFF, PATH_RESULT + PREFIX + 'tresType-rule = ' + STRTRIM(STRING(tresType),1) +' - '+ STRTRIM(STRING(rule),1) + '_classMap.tif', mapChange

  Print, 'End of process...'
END