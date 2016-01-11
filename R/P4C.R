n = 10000

U = runif(n,0,1)

# F(x) = (x^2 + x)/2 
# F(y) = xy/(x+0.5) + y^2/(2x+1)
#Using inverse transform method:

X = -0.5 + sqrt(1+8*U)/2

#simulate Y for a value of X 
Y = -1+sqrt(1^2+2*U*1+U)

#histogram shows the frequency of each bin out of the n values in 
#the array
a = hist(Y, xlim = c(0,1), breaks = 300 )

#Need the frequency of each bin 
b = a$counts	

#divide the frequency by the number of values to get a probability
b = b/n

#calculate the cumulative sum 
sum = cumsum( b )

#now we plot the x midpoints and the cumulative sum
plot( x=a$mids , y=sum, xlab = "x", type = "l", ylab = "CDF" )



