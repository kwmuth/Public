func = function(){

n = 100000
U = runif( n, 0, 1 )
U2 = runif( n, 0, 1 )
PDF = c()

Z1 = U
Z2 = U^(1/3)
Z3 = U^(1/5)

for( i in 1:n ){
	
	if( U2[i] < 1/3 ){
		PDF[i] = Z1[i]
	}
	else if( U2[i] < 2/3 ){
		PDF[i] = Z2[i]
	}
	else{
		PDF[i] = Z3[i]
	}
}

#histogram shows the frequency of each bin out of the 50 000 values in 
#the array

a = hist( PDF, xlim = c(0,1), breaks = 300 )

#Need the frequency of each bin 
b = a$counts	

#divide the frequency by the number of values to get a probability
b = b/n

#calculate the cumulative sum 
sum = cumsum( b )

#now we plot the x midpoints and the cumulative sum
plot( x=a$mids , y=sum, type = "l", xlab = "x", ylab = "CDF" )

}






