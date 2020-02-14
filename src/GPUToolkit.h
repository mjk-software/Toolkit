/*
* GPUToolkit.h
* Author: Mateusz Kaleta
*/

#pragma once

#include "Toolkit.h"
#include "Matrix.h"

class GPUToolkit: public Toolkit {
public:
  explicit GPUToolkit();
  virtual ~GPUToolkit();
  Matrix add(Matrix A, Matrix B);
  Matrix subtract(Matrix A, Matrix B);
  Matrix multiply(Matrix A, Matrix B);
  Matrix findInverse(Matrix A);
};
