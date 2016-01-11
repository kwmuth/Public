X = c()
U = c()
n = 100000

U = runif(n,0,1)

#X is a random variable with the PDF e^x/(e-1) and CDF (e^x - 1)/(e-1)
X = log(U*(exp(1)-1)+1)

#This is the frequency of each X (for a small range of values)
a = hist(X, xlim = c(0,1), breaks = 300 )

#Need the frequency of each bin 
b = a$counts	

#divide the frequency by the number of values to get a probability
b = b/n

#calculate the cumulative sum 
sum = cumsum( b )

#now we plot the x midpoints and the cumulative sum to get the CDF
plot( x=a$mids , y=sum, xlab = "x", ylab = "CDF", type = "l" )




