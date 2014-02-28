/*
 File:            tide_analyzer.h
 Purpose:         Contains prototypes
 */


#ifndef TIDE_ANALYZER_H
#define TIDE_ANALYZER_H

/* Insert function prototypes here */
FILE * open_file (FILE * file_pointer, char * fileName, char * mode );
void process_file( double array_to_populate[], FILE * pointer_to_data_file );

#endif