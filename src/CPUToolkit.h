/*
* CPUToolkit.h
* Author: Mateusz Kaleta
*/

#pragma once

#include "Toolkit.h"
#include "Matrix.h"

class CPUToolkit: public Toolkit {
public:
  explicit CPUToolkit();
  virtual ~CPUToolkit();
  Matrix add(Matrix A, Matrix B);
  Matrix subtract(Matrix A, Matrix B);
  Matrix multiply(Matrix A, Matrix B);
  Matrix findInverse(Matrix A);
};
