n = 100000;

U = runif(n,0,1);

for( i in 1:n){
	X[i] = exp(-U[i]^2);
}

total = 0; 
for( i in 1:n ){
	total = total + X[i];
}

integral = total/n;
print(integral);
