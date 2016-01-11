X = c();
Y = c();
pi_v = c(0.1, 0.2, 0.7);
var = 0.5;
den = 0;

U = runif(100,0,1)

for( i in 1:100 ){
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

for( j in 1:100 ){
	for( i in 1:3){
		
		num = dnorm( Y[j] - i, 0, var, FALSE)*pi_v[i];  
		den = 0;
		for( a in 1:3 ){
			den = den + dnorm( Y[j] - a, 0, var, FALSE)*pi_v[a];
		}
		pi_v[i] = num/den;
	}
}

EX = 1*pi_v[1] + 2*pi_v[2] + 3*pi_v[3];

print(EX);
  
