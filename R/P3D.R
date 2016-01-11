X = c();
Y = c();
XK = c();
n = 10000;

var = 0.1;

U = runif(n,0,1)

for( i in 1:n ){
	if( U[i] < 0.1 ){
		X[i] = 1;
	}
	else if( U[i] < 0.3 ){
		X[i] = 2;
	}
	else{
		X[i] = 3;
	}

	Y[i] = X[i] + rnorm(1,0,var);
}



for( j in 1:n ){
	min = 10^10;
	for( i in 1:3 ){
		if( (Y[j] - i)^2 < min ){
			min = (Y[j] - i)^2;
			min_i = i;
		}
	}
	XK[j] = min_i; 
}
print(XK);
total = 0;

for( j in 1:n ){
	total = total + XK[j];
}
 
print( total/n );

  
