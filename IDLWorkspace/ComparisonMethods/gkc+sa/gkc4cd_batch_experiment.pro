@BocaLib.pro
@cva.pro
@func_cva.pro
@asf_support_functions.pro
@simulated_annealing_gkc.pro
@dark_subtraction.pro
@gkc_support_functions.pro
@gkc4cd_module.pro
@assess_chandet_report.pro


PRO GKC4CD_BATCH_EXPERIMENT

  ;FIXED ELEMENTS--------------------------------
  PATH_T1 = '/home/rogerio/SharedVirtualBox/Exp.ChangeDetection/Tapajos/L5_1988_recorte_SBSR_TesseledCap.tif'
  PATH_T2 = '/home/rogerio/SharedVirtualBox/Exp.ChangeDetection/Tapajos/L5_1999_recorte_SBSR_TasseledCap.tif'
  Atts = [0,1,2]
  
  PATH_ROI = '/home/rogerio/SharedVirtualBox/Exp.ChangeDetection/Tapajos/amostrasChangeNonChange.txt'
  PATH_REPORT = '/home/rogerio/Desktop/resGKC/testesGKC/REPORT_GKC.txt'
  PATH_OUTPUT = '/home/rogerio/Desktop/resGKC/testesGKC/'
  PREFIX = 'GKC4CD__'
  ;----------------------------------------------

  alphaGrid = INDGEN(11)*0.1 + 8.0 ; alpha in 0.8,...,0.9
  parNames = ['alpha']

  PUT_HEADER, PATH_REPORT, parNames
  FOR i = 0, N_ELEMENTS(alphaGrid)-1 DO BEGIN
    alpha = alphaGrid[i]
    t1 = SYSTIME(/seconds)
    Res = GKC4CD_MODULE(PATH_T1, PATH_T2, Atts, alpha)
    time = SYSTIME(/seconds) - t1

    ASSESS_CHANDET_REPORT, PATH_REPORT, Res.Index, PATH_ROI, [STRTRIM(STRING(alpha),1)], time

    WRITE_TIFF, PATH_OUTPUT + PREFIX + STRTRIM(STRING(alpha),1) + '_binMap.tif', Res.Index
    WRITE_TIFF, PATH_OUTPUT + PREFIX + STRTRIM(STRING(alpha),1) + '_classMap.tif', Res.Classification
  ENDFOR

  print, '...fim!'
END