/*
 File:            discrete_fourier_transform.h
 Purpose:         Contains prototypes for a fast discrete Fourier
                  transformation based on code available at:
                  http://paulbourke.net/miscellaneous/dft/
 */


#ifndef DISCRETE_FOURIER_TRANSFORM_H
#define DISCRETE_FOURIER_TRANSFORM_H

/* Function prototype */
void fft(short int dir,long m,double x[],double y[]);

#endif