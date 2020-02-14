/*
* Toolkit.h
* Author: Mateusz Kaleta
*/

#pragma once

#include "Matrix.h"

class Toolkit {
public:
  virtual Matrix add(Matrix A, Matrix B) = 0;
  virtual Matrix subtract(Matrix A, Matrix B) = 0;
  virtual Matrix multiply(Matrix A, Matrix B) = 0;
  virtual Matrix findInverse(Matrix A) = 0;
};
