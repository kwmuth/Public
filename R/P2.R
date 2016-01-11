A = matrix(c(1/6, 1/6, 1/6, 1/6, 1/6, 1/6, 0, 0, 1/2, 0, 1/2, 0, 
			1, 0, 0, 0, 0, 0, 0, 1/2, 0, 0, 1/2, 0, 0, 0, 0, 
			1, 0, 0, 0, 0, 1, 0, 0, 0), 6, 6, TRUE);

B = matrix(1/6, 6, 6, TRUE);
print(A);
print(B);

M = 0.85 * A + 0.15 *  B;

r = eigen(t(M), only.values = FALSE); 

pi_inf = r$vectors[,1];
sum_pi = (pi_inf[1] + pi_inf[2] + pi_inf[3] + pi_inf[4] + pi_inf[5] + pi_inf[6])
pi_inf[1] = pi_inf[1]/sum_pi;
pi_inf[2] = pi_inf[2]/sum_pi;
pi_inf[3] = pi_inf[3]/sum_pi;
pi_inf[4] = pi_inf[4]/sum_pi;
pi_inf[5] = pi_inf[5]/sum_pi;
pi_inf[6] = pi_inf[6]/sum_pi;

print(pi_inf);
