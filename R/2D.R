x = c()
y = c()

total_x = 0
total_y = 0

time_av = 0
n = 100000

u = runif(n,0,1)

for( i in 1:n ){

	if( u[i] <= 0.2 ){
		x[i] = -3
	}
	else if( u[i] > 0.2 && u[i] <= 0.5 ){
		x[i] = -1
	}
	else if( u[i] > 0.5 && u[i] <= 0.6 ){
		x[i] = 1
	}
	else{ 
		x[i] = 3
	}
	
	y[i] = x[i]^4 + 2*x[i] + 2

	total_x = total_x + x[i]
	total_y = total_y + y[i]


}

time_av_x = total_x/n
time_av_y = total_y/n
print(paste("The time average for X is ", time_av_x, " and Y is ", time_av_y))



