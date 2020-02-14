/*
* Matrix.h
* Author: Mateusz Kaleta
*/

#pragma once

#include<iostream>
#include<string>

class Matrix {
protected:
  double* array;
  int n;
  int m;
public:
  Matrix();
  Matrix(int x, int y);
  Matrix(int x, int y, int range);
  Matrix(const Matrix &other);
  Matrix(std::string filepath);
  virtual ~Matrix();
  int getN(){return n;}
  int getM(){return m;}
  double* getArrayPointer(){return array;}
	void operator=(const Matrix &other);
	void operator=(const int a);
  friend std::ostream &operator<<(std::ostream &out, const Matrix &M);
};
