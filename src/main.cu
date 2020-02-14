/*
* main.cu
* Author: Mateusz Kaleta
*/

#include<iostream>
#include <sys/time.h>

#include "Matrix.h"
#include "Toolkit.h"
#include "CPUToolkit.h"
#include "GPUToolkit.h"

double cpuTime() {
  struct timeval clock;
  gettimeofday(&clock, NULL);
  return ((double)clock.tv_sec + (double)clock.tv_usec *1.e-6);
}

void evaluatePerformance(std::string operation, Toolkit *T, int N,
int matrix_size[], double time[]){
  int range = 10;
  double elapsed_time = 0;
  for(int i=0; i<N; i++){
    if (operation=="add"){
      Matrix A(matrix_size[i], matrix_size[i], range);
      Matrix B(matrix_size[i], matrix_size[i], range);
      elapsed_time = cpuTime();
      Matrix C = T->add(A,B);
      elapsed_time = cpuTime() - elapsed_time;
    }
    if (operation=="subtract"){
      Matrix A(matrix_size[i], matrix_size[i], range);
      Matrix B(matrix_size[i], matrix_size[i], range);
      elapsed_time = cpuTime();
      Matrix C = T->subtract(A,B);
      elapsed_time = cpuTime() - elapsed_time;
    }
    if (operation=="multiply"){
      Matrix A(matrix_size[i], matrix_size[i], range);
      Matrix B(matrix_size[i], matrix_size[i], range);
      elapsed_time = cpuTime();
      Matrix C = T->multiply(A,B);
      elapsed_time = cpuTime() - elapsed_time;
    }
    if (operation=="inverse"){
      Matrix A(matrix_size[i], matrix_size[i], range);
      elapsed_time = cpuTime();
      Matrix C = T->findInverse(A);
      elapsed_time = cpuTime() - elapsed_time;
    }
    time[i] = elapsed_time;
  }
}


int main(int argc, char** argv){
  srand(time(NULL));

  if (argc !=4){
	    std::cerr << "Wrong input parameters. Usage: " << argv[0] << " [gpu|cpu] \
  [add|subtract|multiply|inverse] [normal|performance]" << std::endl;
	    return 1;
  }
  std::string architecture = argv[1];
  std::string operation = argv[2];
  std::string type = argv[3];

  if (  !(architecture == "gpu" || architecture == "cpu")
     || !(operation == "add" || operation == "subtract" || operation == "multiply" || operation == "inverse")
     || !(type == "normal" || type == "performance")
  ){
    std::cerr << "Wrong input parameters. Usage: " << argv[0] << " [gpu|cpu] \
  [add|subtract|multiply|inverse] [normal|performance]" << std::endl;
    return 1;
  }

  Toolkit *T;

  if(architecture == "cpu"){
    T = new CPUToolkit();
    std::cout << "Used architecture: cpu" << std::endl;
  }
  else if (architecture == "gpu"){
    T = new GPUToolkit();
    std::cout << "Used architecture: gpu" << std::endl;
  }
  if (type == "performance"){
    int N = 25;
    int matrix_size[N];
    for (int idx=0; idx<N;idx++) matrix_size[idx] = 4*(idx+1);
    double time[N];
    evaluatePerformance(operation, T, N, matrix_size, time);
    std::cout << "Performed operation: " << operation << std::endl;
    for (int i=0; i<N;i++){
      std::cout << "Matrix size : " << matrix_size[i] << ", " << "time: " << time[i] << " s" << std::endl;
    }
  }
  // two operand operations
  else if (operation == "add" || operation == "subtract" || operation == "multiply"){
    std::string A_path = "./A.txt";
    std::string B_path = "./B.txt";
    // Read matrices from text files
    Matrix A(A_path);
    Matrix B(B_path);
    std::cout << "\nMatrix A: " << A << std::endl;
    std::cout << "\nMatrix B: " << B << std::endl;
    if (operation=="add"){
      Matrix C = T->add(A, B);
      std::cout << "\nMatrix A+B: " << C << std::endl;
    }
    if (operation=="subtract"){
      Matrix C = T->subtract(A, B);
      std::cout << "\nMatrix A-B: " << C << std::endl;
    }
    if (operation=="multiply"){
      Matrix C = T->multiply(A, B);
      std::cout << "\nMatrix A*B: " << C << std::endl;
    }
  }
  // one operand operations
  else if (operation == "inverse"){
    std::string A_path = "./A.txt";
    // Read one matrix from text file
    Matrix A(A_path);
    std::cout << "\nMatrix A: " << A << std::endl;
    Matrix C = T->findInverse(A);
    std::cout << "\nA^(-1): " << C << std::endl;
  }
  delete T;
}
