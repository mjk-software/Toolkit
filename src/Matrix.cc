/*
* Matrix.cc
* Author: Mateusz Kaleta
*/

#include<fstream>
#include<iostream>
#include<iomanip>
#include <cassert>
#include <random>
#include <sys/time.h>

#include "Matrix.h"

Matrix::Matrix(const Matrix &other): n(other.n), m(other.m), array(new double[other.n*other.m]){
  for(int i=0; i<n; i++)
    for(int j=0; j<m; j++)
      array[m*i+j] = other.array[m*i+j];
}

Matrix::Matrix(std::string filepath){
  std::string n_str;
  std::string m_str;
  std::string row;
  std::ifstream file;
  file.open(filepath);
  if (file.is_open()){
    file >> n_str >> m_str;
    n = std::stoi(n_str);
    m = std::stoi(m_str);
    array = new double[n*m];
    int i=0;
    while(file >> row){
      array[i] = std::stod(row);
      ++i;
    }
    file.close();
  }
  else{
    std::cerr << "Failed to open matrix file" << std::endl;
  }
}

Matrix::Matrix(int x, int y): n(x), m(y), array(new double[x*y]){
    for(int i=0; i<x; i++){
      for(int j=0; j<y; j++){
        array[i*y+j] = 0.0;
      }
    }
}

Matrix::Matrix(int x, int y, int range): n(x), m(y), array(new double[x*y]){

    for(int i=0; i<x; i++){
      for(int j=0; j<y; j++){
        array[i*y+j] = rand()%range;
      }
    }
}

Matrix::~Matrix(){
  delete [] array;
}

std::ostream &operator<<(std::ostream &out, const Matrix &M){
  out << "[ \n";
  for (int i=0; i<M.n; i++){
    for (int j=0; j<M.m; j++){
      out << std::setprecision(3) << M.array[i*M.m+j] << "\t";
    }
    out << std::endl;
  }
  out << "]";
  return out;
}

void Matrix::operator=(const Matrix &other){
  delete [] array;
  n = other.n;
  m = other.m;
  array = new double[n*m];
  for (int i=0; i<n;i++)
    for (int j=0; j<m; j++)
      array[i*m+j] = other.array[i*m+j];
}

void Matrix::operator=(const int a){
  // Make diagonal matrix
  assert(n == m && "This assignement works only for diagonal matrices");
  for (int i=0; i<n;i++)
    for (int j=0; j<m; j++){
      array[i*m+j] = 0;
      if (i==j) array[i*m+j] = a;
    }
}
