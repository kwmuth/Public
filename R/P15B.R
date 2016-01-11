n = 100000
Z1 = c()
Z2 = c()

PDF = c()

U = runif( n, 0, 1)
U2 = runif( n, 0, 1 )

Z1 = (-0.5)+sqrt(0.25+2*U)

a = hist(Z1, xlim = c(0,1), breaks = 300 )
b = a$counts
b = b/n

sum = cumsum( b )

plot( x=a$mids , y=sum, xlab = "x", type = 'l', ylab = "CDF" )



