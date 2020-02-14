/*
* GPUToolkit.h
* Author: Mateusz Kaleta
*/


#include "GPUToolkit.h"
#include "Matrix.h"

#define BLOCK_SIZE 16


__global__ void find_pivots(double *d_a, double *d_id, int n, int row){
  int col = blockIdx.x * blockDim.x + threadIdx.x;
  double eps = 1e-6;
  if(col < n){
    if ( abs(d_a[row*n+row]) < eps)
    for(int k=row+1; k<n; k++){
      if ( abs(d_a[k*n+row]) < eps){
        d_a[row*n+col] += d_a[k*n+col];
        d_id[row*n+col] += d_id[k*n+col];
        break;
      }
    }
  }
}

__global__ void normalize_row(double *d_a, double *d_id, int n, int row){
  int col = blockIdx.x * blockDim.x + threadIdx.x;
  if (col < n){
    if (row !=col){
      d_id[row*n+col] /= d_a[row*n+row];
      d_a[row*n+col] /= d_a[row*n+row];
    }
    else{
      d_id[row*n+col] /= d_a[row*n+row];
    }
  }
}

__global__ void reduce_row(double *d_1, double *d_2, int n, int current_row, bool reduce_id){
  int col = blockIdx.x * blockDim.x + threadIdx.x;
  int row = blockIdx.y * blockDim.y + threadIdx.y;
  if( col<n && row< n){
    if (row != current_row){
      if (col != current_row || reduce_id){
        d_1[row*n+col] -= d_1[current_row*n+col]*d_2[row*n+current_row];
      }
    }
  }
}

__global__ void add_kernel(double *d_a, double *d_b, double *d_c, int n, int m){
  int col = blockIdx.x * blockDim.x + threadIdx.x;
  int row = blockIdx.y * blockDim.y + threadIdx.y;
  if( col < m && row < n){
    d_c[row + m*col] = d_a[row + m*col] + d_b[row + m*col];
  }
}

__global__ void subtract_kernel(double *d_a, double *d_b, double *d_c, int n, int m){
  int col = blockIdx.x * blockDim.x + threadIdx.x;
  int row = blockIdx.y * blockDim.y + threadIdx.y;
  if( col < m && row < n){
    d_c[row + m*col] = d_a[row + m*col] - d_b[row + m*col];
  }
}

__global__ void multiply_kernel(double *d_a, double *d_b, double *d_c, int m, int n, int k){
  int row = blockIdx.y * blockDim.y + threadIdx.y;
  int col = blockIdx.x * blockDim.x + threadIdx.x;
  float tmp = 0;
  if(row < m && col < k){
    for(int i = 0; i < n; i++){
      tmp += d_a[row * m + i] * d_b[i * k + col];
    }
    d_c[row * k + col] = tmp;
  }
}

GPUToolkit::GPUToolkit(){

}

GPUToolkit::~GPUToolkit(){

}

Matrix GPUToolkit::add(Matrix A, Matrix B){
  int A_n  = A.getN();
  int A_m  = A.getM();
  int B_n  = B.getN();
  int B_m  = B.getM();
  if ( A_n != B_n || A_m != B_m ){
    throw "How am I supposed to add a physicist to a humanist?!";
  }
  Matrix C(A_n, A_m);
  double *h_a = A.getArrayPointer();
  double *h_b = B.getArrayPointer();
  double *h_c = C.getArrayPointer();
  // Allocate memory space on the device
  double *d_a;
  double *d_b;
  double *d_c;
  cudaMalloc((void **)&d_a, A_n*A_m*sizeof(double));
  cudaMalloc((void **)&d_b, A_n*A_m*sizeof(double));
  cudaMalloc((void **)&d_c, A_n*A_m*sizeof(double));
  // copy matrices from host to device memory
  cudaMemcpy(d_a, h_a, A_n*A_m*sizeof(double), cudaMemcpyHostToDevice);
  cudaMemcpy(d_b, h_b, A_n*A_m*sizeof(double), cudaMemcpyHostToDevice);
  cudaMemcpy(d_c, h_c, A_n*A_m*sizeof(double), cudaMemcpyHostToDevice);
  // set grid
  dim3 dimBlock2(BLOCK_SIZE, BLOCK_SIZE);
  dim3 dimGrid2( (A_n+dimBlock2.x-1)/dimBlock2.x,(A_n+dimBlock2.y-1)/dimBlock2.y );
  // launch kernel
  add_kernel <<<dimGrid2, dimBlock2>>> (d_a, d_b, d_c, A_n, A_m);
  // copy result to host
  cudaMemcpy(h_c, d_c, A_n*A_m*sizeof(double), cudaMemcpyDeviceToHost);

  cudaFree(d_a);
	cudaFree(d_b);
	cudaFree(d_c);

  return C;
}

Matrix GPUToolkit::subtract(Matrix A, Matrix B){
  int A_n  = A.getN();
  int A_m  = A.getM();
  int B_n  = B.getN();
  int B_m  = B.getM();
  if ( A_n != B_n || A_m != B_m ){
    throw "How am I supposed to subtract a humanist from a physicist?!";
  }
  Matrix C(A_n, A_m);
  double *h_a = A.getArrayPointer();
  double *h_b = B.getArrayPointer();
  double *h_c = C.getArrayPointer();
  // Allocate memory space on the device
  double *d_a;
  double *d_b;
  double *d_c;
  cudaMalloc((void **)&d_a, A_n*A_m*sizeof(double));
  cudaMalloc((void **)&d_b, A_n*A_m*sizeof(double));
  cudaMalloc((void **)&d_c, A_n*A_m*sizeof(double));
  // copy matrices from host to device memory
  cudaMemcpy(d_a, h_a, A_n*A_m*sizeof(double), cudaMemcpyHostToDevice);
  cudaMemcpy(d_b, h_b, A_n*A_m*sizeof(double), cudaMemcpyHostToDevice);
  cudaMemcpy(d_c, h_c, A_n*A_m*sizeof(double), cudaMemcpyHostToDevice);
  // set grid
  dim3 dimBlock2(BLOCK_SIZE, BLOCK_SIZE);
  dim3 dimGrid2( (A_n+dimBlock2.x-1)/dimBlock2.x,(A_n+dimBlock2.y-1)/dimBlock2.y );
  // launch kernel
  subtract_kernel <<<dimGrid2, dimBlock2>>> (d_a, d_b, d_c, A_n, A_m);
  // copy result to host
  cudaMemcpy(h_c, d_c, A_n*A_m*sizeof(double), cudaMemcpyDeviceToHost);
  // be a hero and clean after yourself!
  cudaFree(d_a);
	cudaFree(d_b);
	cudaFree(d_c);

  return C;
}

Matrix GPUToolkit::multiply(Matrix A, Matrix B){
  int A_n  = A.getN();
  int A_m  = A.getM();
  int B_n  = B.getN();
  int B_m  = B.getM();
  if ( A_m != B_n ){
    throw "Matrix multiplication is defined only for matrices with the same inner dimensions!";
  }
  Matrix C(A_n, B_m);
  double *h_a = A.getArrayPointer();
  double *h_b = B.getArrayPointer();
  double *h_c = C.getArrayPointer();
  // Allocate memory space on the device
  double *d_a;
  double *d_b;
  double *d_c;
  cudaMalloc((void **)&d_a, A_n*A_m*sizeof(double));
  cudaMalloc((void **)&d_b, A_n*A_m*sizeof(double));
  cudaMalloc((void **)&d_c, A_n*A_m*sizeof(double));
  // copy matrices from host to device memory
  cudaMemcpy(d_a, h_a, A_n*A_m*sizeof(double), cudaMemcpyHostToDevice);
  cudaMemcpy(d_b, h_b, A_m*B_n*sizeof(double), cudaMemcpyHostToDevice);
  cudaMemcpy(d_c, h_c, A_n*B_m*sizeof(double), cudaMemcpyHostToDevice);
  // set grid
  dim3 dimBlock2(BLOCK_SIZE, BLOCK_SIZE);
  dim3 dimGrid2( (A_n+dimBlock2.x-1)/dimBlock2.x,(A_n+dimBlock2.y-1)/dimBlock2.y );
  // launch kernel
  multiply_kernel <<<dimGrid2, dimBlock2>>> (d_a, d_b, d_c, A_n, A_m, B_m);
  // copy result to host
  cudaMemcpy(h_c, d_c, A_n*A_m*sizeof(double), cudaMemcpyDeviceToHost);
  // be a hero and clean after yourself!
  cudaFree(d_a);
  cudaFree(d_b);
  cudaFree(d_c);

  return C;
}

Matrix GPUToolkit::findInverse(Matrix A){
  int A_n = A.getN();
  int A_m = A.getM();
  if ( A_n != A_m ){
    throw "Inverse matrix is undefined for non-square matrices!";
  }
  Matrix Id(A_n,A_n);
  Id = 1;
  double *h_a = A.getArrayPointer();
  double *h_id = Id.getArrayPointer();

  // Allocate memory space on the device
  double *d_a;
  double *d_id;
  cudaMalloc((void **)&d_a, A_n*A_n*sizeof(double));
  cudaMalloc((void **)&d_id, A_n*A_n*sizeof(double));

  // copy matrices from host to device memory
  cudaMemcpy(d_a, h_a, A_n*A_n*sizeof(double), cudaMemcpyHostToDevice);
  cudaMemcpy(d_id, h_id, A_n*A_n*sizeof(double), cudaMemcpyHostToDevice);

  // iterate over matrix rows
  for(int row=0; row<A_n; row++){
    //set dimensions
    dim3 dimBlock(BLOCK_SIZE*BLOCK_SIZE, 1);
    dim3 dimGrid( (A_n+dimBlock.x-1)/dimBlock.x,1);
    find_pivots <<< dimGrid, dimBlock>>> (d_a, d_id, A_n, row);
    normalize_row <<< dimGrid, dimBlock>>> (d_a, d_id, A_n, row);
    // change grid dimensions; row reduction can be done at once on 2D grid
    dim3 dimBlock2(BLOCK_SIZE, BLOCK_SIZE);
    dim3 dimGrid2( (A_n+dimBlock2.x-1)/dimBlock2.x,(A_n+dimBlock2.y-1)/dimBlock2.y );
    reduce_row <<<dimGrid2, dimBlock2>>> (d_id, d_a, A_n, row, true);
    reduce_row <<<dimGrid2, dimBlock2>>> (d_a, d_a, A_n, row, false);
  }
  cudaMemcpy(h_a, d_a, A_n*A_n*sizeof(double), cudaMemcpyDeviceToHost);
  cudaMemcpy(h_id, d_id, A_n*A_n*sizeof(double), cudaMemcpyDeviceToHost);

  // be a hero and clean after yourself!
  cudaFree(d_a);
	cudaFree(d_id);
  return Id;
}
