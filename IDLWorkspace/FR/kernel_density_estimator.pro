FUNCTION KERNEL_DENSITY_ESTIMATOR, x, h, rangeOutput, step

h = ( (4.0*STDDEV(x)^5)/(3.0*N_ELEMENTS(x)) )^(1/5.0) ;>>>>regra de Silverman

outX = DBLARR( (rangeOutput[1] - rangeOutput[0])/step )
fx = DBLARR( (rangeOutput[1] - rangeOutput[0])/step )

n = N_ELEMENTS(x)
nox = N_ELEMENTS(outX)
FOR i = 0L, (nox-1) DO BEGIN
  
  outX[i] = rangeOutput[0] + i*step   &   xAct = outX[i]   ;>>>estrateigia para diminuir tempo comp. 
  sum = 0.0D
  FOR j = 0L, (n-1) DO $
    sum += ( 1.0/SQRT(2*!DPI) * EXP(-0.5D * ( (xAct - x[j])/h )^2 ) )  ;>>>expressao do kernel
  
  fx[i] = (1.0/n)*sum
  
ENDFOR
;fx = (1.0/n)*fx

Return, {x: outX, y: fx}
END