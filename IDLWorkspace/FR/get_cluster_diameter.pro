FUNCTION GET_CLUSTER_DIAMETER, ParReg, Centroid, distType

N = N_ELEMENTS(ParReg)
diam = -1.0D
FOR i = 0L, (N-1) DO BEGIN
   
   ParI = *ParReg[i]
   CASE distType OF    
      0: dst = BHATTACHARYYA(ParI.Mu, Centroid.Mu, ParI.Sigma, Centroid.Sigma)
      1: dst = 2*(1-exp(-1 * BHATTACHARYYA(ParI.Mu, Centroid.Mu, ParI.Sigma, Centroid.Sigma)))
      2: dst = HELLINGER(ParI.Mu, Centroid.Mu, ParI.Sigma, Centroid.Sigma)
      3: dst = NORM(ParI.Mu - Centroid.Mu)
      4: dst = KULLBACK_LEIBLER(ParI.Mu, Centroid.Mu, ParI.Sigma, Centroid.Sigma)
      5: dst = BOCA_NORMA(ParI.Mu, Centroid.Mu, ParI.Sigma, Centroid.Sigma)
   ENDCASE
   
   IF dst GT diam THEN diam = dst
ENDFOR

Return, diam
END