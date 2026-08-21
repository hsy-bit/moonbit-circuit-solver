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
/// Symbolic polynomial matrix in Laplace variable s: A(s) where each entry is a Polynomial.
pub struct PolyMatrix {
  rows : Int
  cols : Int
  data : Array[Polynomial]
} derive(Eq, Debug)

///|
/// Creates a new PolyMatrix filled with zero polynomial.
pub fn PolyMatrix::zeros(rows : Int, cols : Int) -> PolyMatrix {
  let total = rows * cols
  let data = Array::make(total, Polynomial::constant(0.0))
  { rows, cols, data }
}

///|
/// Gets polynomial entry at (r, c).
pub fn PolyMatrix::get(self : PolyMatrix, r : Int, c : Int) -> Polynomial {
  if r >= 0 && r < self.rows && c >= 0 && c < self.cols {
    self.data[r * self.cols + c]
  } else {
    Polynomial::constant(0.0)
  }
}

///|
/// Sets polynomial entry at (r, c).
pub fn PolyMatrix::set(
  self : PolyMatrix,
  r : Int,
  c : Int,
  val : Polynomial,
) -> Unit {
  if r >= 0 && r < self.rows && c >= 0 && c < self.cols {
    self.data[r * self.cols + c] = val
  }
}

///|
/// Adds a polynomial to entry at (r, c).
pub fn PolyMatrix::add_to_entry(
  self : PolyMatrix,
  r : Int,
  c : Int,
  poly : Polynomial,
) -> Unit {
  let curr = self.get(r, c)
  self.set(r, c, curr.add(poly))
}

///|
/// Computes exact symbolic determinant of square PolyMatrix using cofactor expansion.
pub fn PolyMatrix::determinant(self : PolyMatrix) -> Polynomial {
  let n = self.rows
  if n == 0 {
    return Polynomial::constant(1.0)
  }
  if n == 1 {
    return self.get(0, 0)
  }
  if n == 2 {
    let a = self.get(0, 0)
    let b = self.get(0, 1)
    let c = self.get(1, 0)
    let d = self.get(1, 1)
    return a.mul(d).sub(b.mul(c))
  }
  if n == 3 {
    let a11 = self.get(0, 0)
    let a12 = self.get(0, 1)
    let a13 = self.get(0, 2)
    let a21 = self.get(1, 0)
    let a22 = self.get(1, 1)
    let a23 = self.get(1, 2)
    let a31 = self.get(2, 0)
    let a32 = self.get(2, 1)
    let a33 = self.get(2, 2)

    let term1 = a11.mul(a22.mul(a33).sub(a23.mul(a32)))
    let term2 = a12.mul(a21.mul(a33).sub(a23.mul(a31)))
    let term3 = a13.mul(a21.mul(a32).sub(a22.mul(a31)))

    return term1.sub(term2).add(term3)
  }

  // Recursive cofactor expansion along row 0
  let mut det = Polynomial::constant(0.0)
  let mut sign = 1.0

  for j = 0; j < n; j = j + 1 {
    let a_0j = self.get(0, j)
    if a_0j.degree() >= 0 {
      // Build minor matrix
      let minor = PolyMatrix::zeros(n - 1, n - 1)
      for r = 1; r < n; r = r + 1 {
        let mut col_dest = 0
        for c = 0; c < n; c = c + 1 {
          if c != j {
            minor.set(r - 1, col_dest, self.get(r, c))
            col_dest = col_dest + 1
          }
        }
      }

      let minor_det = minor.determinant()
      let term = a_0j.mul(minor_det).scale(sign)
      det = det.add(term)
    }
    sign = -sign
  }

  det
}

///|
/// Solves exact symbolic transfer function H(s) = V_out(s) / V_in(s) using Cramer's rule.
pub fn solve_symbolic_transfer_function(
  mna_poly : PolyMatrix,
  rhs_poly : Array[Polynomial],
  target_var_idx : Int,
) -> TransferFunction {
  let delta = mna_poly.determinant()

  let n = mna_poly.rows
  let modified_mat = PolyMatrix::zeros(n, n)

  for r = 0; r < n; r = r + 1 {
    for c = 0; c < n; c = c + 1 {
      if c == target_var_idx {
        modified_mat.set(r, c, rhs_poly[r])
      } else {
        modified_mat.set(r, c, mna_poly.get(r, c))
      }
    }
  }

  let delta_k = modified_mat.determinant()
  TransferFunction::new(delta_k, delta)
}
