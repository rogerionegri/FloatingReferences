FUNCTION DARK_SUBTRACTION, Image

Dims = GET_DIMENSIONS(Image)
corImage = Image

FOR i = 0, Dims[0]-1 DO corImage[i,*,*] = (Image[i,*,*] - MIN(Image[i,*,*])) 

Return, corImage
END