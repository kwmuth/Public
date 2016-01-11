n = 100000

U1 = runif(n,0,0.5)
U2 = runif(n,0,1)

Z1 = (-0.5)+(0.5)*(2*U1)^(1/2)
Z2 = (0.5)-(0.5)*(1-2*U1)^(1/2)

for( i in 1:n ){
	
	if( U2[i] < 0.5 ){
		PDF[i] = Z1[i]
	}
	else{
		PDF[i] = Z2[i]
	}
}

a = hist(PDF, xlim = c(0,1), breaks = 300 )

#Need the frequency of each bin 
b = a$counts	

#divide the frequency by the number of values to get a probability
b = b/n

#calculate the cumulative sum 
sum = cumsum( b )

#now we plot the x midpoints and the cumulative sum
plot( x=a$mids , y=sum, xlab = "x", ylab = "CDF", type = "l" )

