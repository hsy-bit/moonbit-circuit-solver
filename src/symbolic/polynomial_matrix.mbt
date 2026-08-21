// Copyright 2026 hsy-bit
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

///|
/// Represents a matrix whose elements are polynomials in s: P(s).
pub struct PolynomialMatrix {
  rows : Int
  cols : Int
  data : Array[Polynomial]
} derive(Eq, Debug)

///|
/// Creates a new m x n Polynomial Matrix initialized to zero polynomials.
pub fn PolynomialMatrix::zeros(rows : Int, cols : Int) -> PolynomialMatrix {
  let data = Array::make(rows * cols, Polynomial::constant(0.0))
  PolynomialMatrix::{ rows, cols, data }
}

///|
/// Gets the polynomial at (row, col).
pub fn PolynomialMatrix::get(
  self : PolynomialMatrix,
  row : Int,
  col : Int,
) -> Polynomial {
  self.data[row * self.cols + col]
}

///|
/// Sets the polynomial at (row, col).
pub fn PolynomialMatrix::set(
  self : PolynomialMatrix,
  row : Int,
  col : Int,
  poly : Polynomial,
) -> Unit {
  self.data[row * self.cols + col] = poly
}

///|
/// Adds two polynomial matrices of identical dimensions.
pub fn PolynomialMatrix::add(
  self : PolynomialMatrix,
  other : PolynomialMatrix,
) -> PolynomialMatrix {
  let res = PolynomialMatrix::zeros(self.rows, self.cols)
  for r in 0..<self.rows {
    for c in 0..<self.cols {
      let sum_poly = self.get(r, c).add(other.get(r, c))
      res.set(r, c, sum_poly)
    }
  }
  res
}

///|
/// Multiplies two polynomial matrices: C(s) = A(s) * B(s).
pub fn PolynomialMatrix::multiply(
  self : PolynomialMatrix,
  other : PolynomialMatrix,
) -> PolynomialMatrix {
  let res = PolynomialMatrix::zeros(self.rows, other.cols)
  for r in 0..<self.rows {
    for c in 0..<other.cols {
      let mut acc = Polynomial::constant(0.0)
      for k in 0..<self.cols {
        let prod = self.get(r, k).mul(other.get(k, c))
        acc = acc.add(prod)
      }
      res.set(r, c, acc)
    }
  }
  res
}

///|
/// Evaluates the polynomial matrix at complex frequency s = sigma + j*omega -> Complex Matrix.
pub fn PolynomialMatrix::evaluate_s(
  self : PolynomialMatrix,
  s : @linalg.Complex,
) -> @linalg.ComplexMatrix {
  let c_mat = @linalg.ComplexMatrix::zeros(self.rows, self.cols)
  for r in 0..<self.rows {
    for c in 0..<self.cols {
      let poly = self.get(r, c)
      let deg = poly.degree()
      let mut val = @linalg.Complex::zero()
      let mut s_pow = @linalg.Complex::one()

      for k = 0; k <= deg; k = k + 1 {
        let coeff = poly.coeff(k)
        val = val.add(s_pow.scale(coeff))
        s_pow = s_pow.mul(s)
      }
      c_mat.set(r, c, val)
    }
  }
  c_mat
}

///|
/// Computes determinant of 2x2 polynomial matrix.
pub fn PolynomialMatrix::determinant_2x2(self : PolynomialMatrix) -> Polynomial {
  let a = self.get(0, 0)
  let b = self.get(0, 1)
  let c = self.get(1, 0)
  let d = self.get(1, 1)

  let ad = a.mul(d)
  let bc = b.mul(c)
  ad.sub(bc)
}
