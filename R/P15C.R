X = c()
n = 100000

U = runif(n,0,1)
U2 = runif(n,0,1)

X = sqrt(-0.5*log(1-U))

a = hist(X, xlim = c(0,1), breaks = 300 )

#Need the frequency of each bin 
b = a$counts	

#divide the frequency by the number of values to get a probability
b = b/n

#calculate the cumulative sum 
sum = cumsum( b )

#now we plot the x midpoints and the cumulative sum
plot( x=a$mids , y=sum, xlab = "x", ylab = "CDF", type = 'l' )

