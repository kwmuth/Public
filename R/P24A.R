Q1 = 1;
Q2 = 2;
Q3 = 3;

X = c();
A = matrix(c(0.3, 0.3, 0.4, 0.1, 0.9, 0.0, 0.1, 0.1, 0.8), 3, 3, TRUE);

count_1 = 0;
count_2 = 0;
count_3 = 0;

count_11 = 0; 
count_12 = 0; 
count_13 = 0; 
count_21 = 0;
count_22 = 0; 
count_23 = 0; 
count_31 = 0; 
count_32 = 0;
count_33 = 0;

n = 100000;

U = runif(1,0,1);

X[1] = Q2
if( U <= 0.1 ){
	X[1] = Q1
}

U2 = runif(n,0,1)

for( i in 2:n ){
	if( X[i-1] == Q1 ){
		if( U2[i] <= 0.3 ){
			X[i] = Q1
		}
		else if( U2[i] <= 0.6 ){
			X[i] = Q2
		}
		else{
			X[i] = Q3
		}
	}
	else if( X[i-1] == Q2 ){
		if( U2[i] <= 0.1 ){
			X[i] = Q1
		}
		else{
			X[i] = Q2
		} 
	}
	else{
		if( U2[i] <= 0.1 ){
			X[i] = Q1
		}
		else if( U2[i] <= 0.2 ){
			X[i] = Q2
		}
		else{
			X[i] = Q3
		}
	}
}

#count how many times the chain spends in each state
for( i in 1:n ){
	if( X[i] == Q1 ){
		count_1 = count_1 + 1;
	}
	if( X[i] == Q2 ){
		count_2 = count_2 + 1;
	}
	if( X[i] == Q3 ){
		count_3 = count_3 + 1;
	}
}

#count how many times the chain transitions from one state to another
for( i in 2:n ){
	if( X[i-1] == Q1 && X[i] == Q1 ){
		count_11 = count_11 + 1;
	}
	if( X[i-1] == Q1 && X[i] == Q2 ){
		count_12 = count_12 + 1;
	}
	if( X[i-1] == Q1 && X[i] == Q3 ){
		count_13 = count_13 + 1;
	}
	if( X[i-1] == Q2 && X[i] == Q1 ){
		count_21 = count_21 + 1;
	}
	if( X[i-1] == Q2 && X[i] == Q2 ){
		count_22 = count_22 + 1;
	}
	if( X[i-1] == Q2 && X[i] == Q3 ){
		count_23 = count_23 + 1;
	}
	if( X[i-1] == Q3 && X[i] == Q1 ){
		count_31 = count_31 + 1;
	}
	if( X[i-1] == Q3 && X[i] == Q2 ){
		count_32 = count_32 + 1;
	}
	if( X[i-1] == Q3 && X[i] == Q3 ){
		count_33 = count_33 + 1;
	}
}

#calculate the transition probabilities using the counts we found above
prob_11 = count_11/count_1;
prob_12 = count_12/count_1;
prob_13 = count_13/count_1;

prob_21 = count_21/count_2;
prob_22 = count_22/count_2;
prob_23 = count_23/count_2;

prob_31 = count_31/count_3;
prob_32 = count_32/count_3;
prob_33 = count_33/count_3;


B = matrix(c(prob_11, prob_12, prob_13, prob_21, prob_22, prob_23, prob_31, prob_32, prob_33), 3, 3, TRUE);
print(B);

#percentage of time spent in each state
print(count_1/n);
print(count_2/n);
print(count_3/n);

#pi infinity 
r = eigen(t(A), only.values = FALSE); 
pi_inf = r$vectors[,1];
sum_pi = (pi_inf[1] + pi_inf[2] + pi_inf[3])
pi_inf[1] = pi_inf[1]/sum_pi;
pi_inf[2] = pi_inf[2]/sum_pi;
pi_inf[3] = pi_inf[3]/sum_pi;
print(pi_inf);

