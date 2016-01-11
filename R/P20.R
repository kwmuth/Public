n = 10000
X = c()
U = runif(n,0,1)

#Using inverse transform method:
for( i in 1:n ){
	if( U[i] <= 0.1 ){
		X[i] = 0 
	}
	else{
		X[i] = 1
	}
}
print(X)
x = c(0.1, 0.2, 0.3, 0.4, 0.5, 0.6, 0.7, 0.8, 0.9, 1)
y = c(0.8304, 1.1304, 1.284, 1.34, 1.356, 1.3352, 1.276, 1.1192, 0.7848, 
		0.0424 )

plot(x, y, type="l") 




