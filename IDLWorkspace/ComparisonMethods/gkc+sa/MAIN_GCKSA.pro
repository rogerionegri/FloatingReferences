@BocaLib.pro
@gkc4cd_module.pro
@dark_subtraction.pro
@asf_support_functions.pro
@gkc_support_functions.pro
@simulated_annealing_gkc.pro
@gkc.pro
@assess_chandet_report.pro


PRO MAIN_GCKSA

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
   
  PREFIX = 'GKC+SA__' ;Just a filename prefix (usefull for organization purposes)
  
  ;Parameters
  epsilon = 0.0001 ;SA convergence
  alpha = 0.5      ;SA cooling factor
  ;----------------------------------------------

  img1 = OPEN_IMAGE(PATH_T1, Atts1)
  img2 = OPEN_IMAGE(PATH_T2, Atts2)

  parNames = ['epsilon', 'alpha']
  PUT_HEADER, PATH_REPORT, parNames
  
  t1 = SYSTIME(/seconds)
  Res = gkc4cd_module(img1, img2, epsilon, alpha)
  time = SYSTIME(/seconds) - t1

  ASSESS_CHANDET_REPORT, PATH_REPORT, Res.Index, PATH_ROI, [STRTRIM(STRING(epsilon),1),STRTRIM(STRING(alpha),1)], time

  WRITE_TIFF, PATH_RESULT + PREFIX + 'epsilon-alpha = ' + STRTRIM(STRING(epsilon),1) +' - '+ STRTRIM(STRING(alpha),1) + '_binMap.tif', Res.Index
  WRITE_TIFF, PATH_RESULT + PREFIX + 'epsilon-alpha = ' + STRTRIM(STRING(epsilon),1) +' - '+ STRTRIM(STRING(alpha),1) + '_classMap.tif', Res.Classification
  
  Print, 'End of process...'
END