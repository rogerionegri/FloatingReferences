@BocaLib.pro
@FR_AUX.pro
@build_pixel_sequence.pro
@ahd_stoch_clusters_4pix.pro
@kernel_density_estimator.pro
@deriva_and_refine.pro
@aux_funcs.pro
@check_changes.pro
@kmeans_stoch_binary.pro
@KMEANS_STOCH.pro
@rebuild_segm_clusters.pro
@compute_parameters.pro
@get_cluster_diameter.pro
@max_cut_doido_v2.pro
@FR.pro

@assess_chandet_report.pro


PRO MAIN_FR

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
   
  PREFIX = 'FR__' ;Just a filename prefix (usefull for organization purposes)
  
  ;Parameters  
  NeighRadius = 1   ;<-- for window 3x3
  minElements = 10  ;<-- avoid too small clusters
  params = {NeighRadius: NeighRadius, minElements: minElements}
  ;----------------------------------------------

  img1 = OPEN_IMAGE(PATH_T1, Atts1)
  img2 = OPEN_IMAGE(PATH_T2, Atts2)

  parNames = ['NeighRadius', 'minElements']
  PUT_HEADER, PATH_REPORT, parNames
  
  t1 = SYSTIME(/seconds)
  Res = FR(img1, img2, params)
  time = SYSTIME(/seconds) - t1

  ASSESS_CHANDET_REPORT, PATH_REPORT, Res.Index, PATH_ROI, [STRTRIM(STRING(NeighRadius),1),STRTRIM(STRING(minElements),1)], time

  WRITE_TIFF, PATH_RESULT + PREFIX + 'NeighRadius-minElements = ' + STRTRIM(STRING(NeighRadius),1) +' - '+ STRTRIM(STRING(minElements),1) + '_binMap.tif', Res.Index
  WRITE_TIFF, PATH_RESULT + PREFIX + 'NeighRadius-minElements = ' + STRTRIM(STRING(NeighRadius),1) +' - '+ STRTRIM(STRING(minElements),1) + '_classMap.tif', Res.Classification
  
  Print, 'End of process...'
END