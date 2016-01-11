Q1 = 1;
Q2 = 2;
Q3 = 3;
X = c();
n = 1000;

#Create a regular transition matrix - 3 states
A = matrix(c(0.3, 0.3, 0.4, 0.2, 0.1, 0.7, 0.5, 0.2, 0.3), 3, 3, TRUE);

#calculate pi(infinity)
r = eigen(t(A), only.values = FALSE); 

pi_inf = r$vectors[,1];
sum_pi = (pi_inf[1] + pi_inf[2] + pi_inf[3])
pi_inf[1] = pi_inf[1]/sum_pi;
pi_inf[2] = pi_inf[2]/sum_pi;
pi_inf[3] = pi_inf[3]/sum_pi;

print(pi_inf);

# Initial conditions P(Q1) = 0.1, P(Q2) = 0.3, P(Q3) = 0.6

U = runif(1,0,1);

if( U <= 0.1 ){
	X[1] = Q1;
}

if( U > 0.1 && U <= 0.4 ){
	X[1] = Q2;
}

if( U > 0.4 ){
	X[1] = Q3;
}

U2 = runif(n,0,1);

for( i in 2:n ){
	if( X[i-1] == Q1 ){
		if( U2[i] <= 0.3 ){
			X[i] = Q1;
		}
		else if( U2[i] <= 0.6 ){
			X[i] = Q2;
		}
		else{
			X[i] = Q3;
		}
	}
	else if( X[i-1] == Q2 ){
		if( U2[i] <= 0.2 ){
			X[i] = Q1
		}
		else if( U2[i] <= 0.3 ){
			X[i] = Q2
		} 
		else{
			X[i] = Q3;
		}
	}
	else{
		if( U2[i] <= 0.5 ){
			X[i] = Q1
		}
		else if( U2[i] <= 0.7 ){
			X[i] = Q2
		}
		else{
			X[i] = Q3
		}
	}
}

total = 0;
for( i in 1:n ){
	total = total + X[i];
}

#Left half of equation
LLN = total/n;
print(LLN);

#Right half of equation
RS = 1*pi_inf[1] + 2*pi_inf[2] + 3*pi_inf[3];

print(RS);

#These two values end up being the same. In this case they 
#both equaled ~2
 



