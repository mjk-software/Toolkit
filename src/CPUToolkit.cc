/*
* CPUToolkit.h
* Author: Mateusz Kaleta
*/

#include "CPUToolkit.h"
#include "Matrix.h"

CPUToolkit::CPUToolkit(){

}

CPUToolkit::~CPUToolkit(){

}

Matrix CPUToolkit::add(Matrix A, Matrix B){
  int A_n = A.getN();
  int A_m = A.getM();
  int B_n = B.getN();
  int B_m = B.getM();
  if ( (A_n != B_n) || (A_m != B_m) ){
    throw "Matrix dimensions do not match!";
  }
  Matrix C(A_n, A_m);
  double *a = A.getArrayPointer();
  double *b = B.getArrayPointer();
  double *c = C.getArrayPointer();
  for(int i=0;i<A_n;i++){
    for(int j=0;j<A_m;j++){
      c[i*A_m+j] = a[i*A_m+j] + b[i*A_m+j];
    }
  }
  return C;
}

Matrix CPUToolkit::subtract(Matrix A, Matrix B){
  int A_n = A.getN();
  int A_m = A.getM();
  int B_n = B.getN();
  int B_m = B.getM();
  if ( (A_n != B_n) || (A_m != B_m) ){
    throw "Matrix dimensions do not match!";
  }
  Matrix C(A_n, A_m);
  double *a = A.getArrayPointer();
  double *b = B.getArrayPointer();
  double *c = C.getArrayPointer();
  for(int i=0;i<A_n;i++){
    for(int j=0;j<A_m;j++){
      c[i*A_m+j] = a[i*A_m+j] - b[i*A_m+j];
    }
  }
  return C;
}

Matrix CPUToolkit::multiply(Matrix A, Matrix B){
  int A_n = A.getN();
  int A_m = A.getM();
  int B_n = B.getN();
  int B_m = B.getM();
  if ( A_m != B_n ){
    throw "Matrix dimensions do not match!";
  }
  Matrix C(A_n, B_m);
  double *a = A.getArrayPointer();
  double *b = B.getArrayPointer();
  double *c = C.getArrayPointer();
  double dotproduct = 0;
  for(int i=0;i<A_n;i++){
    for(int j=0;j<B_m;j++){
      dotproduct = 0;
      for (int k=0;k<A_m;k++){
        dotproduct += a[i*A_m+k] * b[k*B_m+j];
      }
      c[i*A_m+j] = dotproduct;
    }
  }
  return C;
}

Matrix CPUToolkit::findInverse(Matrix A){
  int A_n = A.getN();
  int A_m = A.getM();
  if ( A_n != A_m ){
    throw "Inverse matrix is undefined for non-square matrices!";
  }
  Matrix Id(A_n,A_n);
  Id = 1;
  double *a = A.getArrayPointer();
  double *id = Id.getArrayPointer();
  double eps = 1e-6;

  for(int j=0; j<A_n; j++){
    // adding rows
    if ( a[j*A_n+j] == 0.0 ){
      for(int k=j+1; k<A_n; k++){
        if ( a[k*A_n+j] != 0.0){
          for(int i=0; i<A_n; i++){
            a[j*A_n+i] += a[k*A_n+i];
            id[j*A_n+i] += id[k*A_n+i];
          }
          break;
        }
      }
    }
    // normalising rows
    for(int i=0; i<A_n; i++){
      if (i != j){
        id[j*A_n+i] /= a[j*A_n+j];
        a[j*A_n+i] /= a[j*A_n+j];
      }
    }

    id[j*A_n+j] /= a[j*A_n+j];

    // subtract
    for(int i=0; i<A_n; i++){
      for(int k=0; k<A_n; k++){
        if (k != j){
          id[k*A_n+i] -= id[j*A_n+i]*a[k*A_n+j];
          if( i != j)
          a[k*A_n+i] -= a[j*A_n+i]*a[k*A_n+j];
        }
      }
    }
  }

  return Id;
}
