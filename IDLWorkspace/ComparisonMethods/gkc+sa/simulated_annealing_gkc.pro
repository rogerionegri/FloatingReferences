FUNCTION SIMULATED_ANNEALING_GKC, Image, C, epsilon, percent, alpha, seed

   ;Input: A randomly chosen configuration.
   ;Output: A globally optimum configuration.

   ;Step 1: Randomly select (initialize) a configuration (Conf current ) and set temperature T 0 to a high value; 0 denotes 0th iteration.
   parsCurrent = [1.0,1.0,1.0]  ;GENERATE_NEW_CONF([1.0,1.0,1.0], seed)
   To = 1.0
   Tf = 10D^(-5)
   iter = 0L
   T = To

   History = [parsCurrent]

   ;Step 2: Compute the cost (Cost current ) of the (Conf current ) by some procedure.
   resCurrent = GKC(Image, C, parsCurrent[0], parsCurrent[1:2], epsilon, percent)
   
   WHILE (T GT Tf) DO BEGIN
  
      ;Step 3: Perturb (Conf current ) by some rule and obtain perturbed configuration (Conf prtrbd ).
      parsPerturbed = GENERATE_NEW_CONF(parsCurrent, seed)

      ;Step 4: Compute the cost of Conf prtrbd , Cost prtrbd.
      resPerturbed = GKC(Image, C, parsPerturbed[0], parsPerturbed[1:2], epsilon, percent)

      ;Step 5: Compute deltaC = (Cost prtrbd - Cost current ).
      deltaCost = resPerturbed.XieBeni - resCurrent.XieBeni

      ;Step 6: If (Cost prtrbd <= Cost current )
      IF resPerturbed.XieBeni LT resCurrent.XieBeni THEN BEGIN
         parsCurrent = parsPerturbed
         resCurrent = resPerturbed
      ENDIF ELSE IF (EXP(-deltaCost/T) GT RANDOMU(seed,1)) THEN BEGIN
         parsCurrent = parsPerturbed
         resCurrent = resPerturbed
      ENDIF

      ;Step 7: Decrement T t slightly by some rule.
      iter++
      T = To*alpha^iter
      
      History = [[History] , [parsCurrent]]
   ENDWHILE

Return, {Pars: parsCurrent, parsHistory: History, iters: iter}
END


;------------------------------------
FUNCTION GENERATE_NEW_CONF, pars, seed

try = FLTARR(N_ELEMENTS(pars))
WHILE 1 DO BEGIN
   rand = RANDOMU(seed,N_ELEMENTS(pars))
   signal = FLOOR(RANDOMU(seed,N_ELEMENTS(pars))*10L^7) MOD 2
   try[*] = pars[*] + ((-1)^signal[*])*rand[*]
   invalid = WHERE(try LT 1)
   IF invalid[0] EQ -1 THEN BREAK
ENDWHILE

Return, try
END