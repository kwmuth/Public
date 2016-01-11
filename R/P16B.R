func = function(){

#number of random variables we want to generate
n = 50000

#number of power we want to go up to
v = 5

#make a matrix with random variables of different distributions 
#in each row
Z1 = matrix(nrow = v, ncol = n )

PDF = c()

U = runif( n, 0, 1 )
U2 = runif( n, 0, 1 )

#populate each row of matrix with random variables with the different
#distributions

for( i in 1:v ){
	Z1[i, ] = U^(1/i)
}

#now we can populate the PDF variable. I assumed that each random variable
#has equal probability. This is the same inverse transform method used in 
#other questions
 
for( i in 1:n ){
	for( j in 1:v ){
		if( U2[i] < (v-j+1)/v ){
			PDF[i] = Z1[j, i]
		}
	}
}


#histogram shows the frequency of each bin out of the n values in 
#the array
a = hist( PDF, xlim = c(0,1), breaks = 300 )

#Need the frequency of each bin 
b = a$counts	

#divide the frequency by the number of values to get a probability
b = b/50000

#calculate the cumulative sum 
sum = cumsum( b )

#now we plot the x midpoints and the cumulative sum
plot( x=a$mids , y=sum, type = "l", xlab = "x", ylab = "CDF" )

}







