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
/// Complex LU Decomposition with partial row pivoting (P * A = L * U).
pub struct ComplexLuDecomposition {
  n : Int
  lu_mat : ComplexMatrix
  pivots : Array[Int]
  sign : Int
} derive(Eq, Debug)

///|
/// Computes the complex LU decomposition of square matrix A with partial row pivoting.
pub fn ComplexLuDecomposition::decompose(
  mat : ComplexMatrix,
) -> ComplexLuDecomposition {
  let n = mat.num_rows()
  let lu = mat.copy()
  let pivots = Array::make(n, 0)
  for i in 0..<n {
    pivots[i] = i
  }
  let mut sign = 1

  for col in 0..<n {
    // Find pivot row with maximum magnitude
    let mut max_mag = lu.get(col, col).abs()
    let mut max_row = col
    for row in (col + 1)..<n {
      let mag = lu.get(row, col).abs()
      if mag > max_mag {
        max_mag = mag
        max_row = row
      }
    }

    if max_row != col {
      lu.swap_rows(col, max_row)
      let tmp_p = pivots[col]
      pivots[col] = pivots[max_row]
      pivots[max_row] = tmp_p
      sign = -sign
    }

    let diag = lu.get(col, col)
    if diag.abs() > 1.0e-14 {
      let inv_diag = diag.recip()
      for row in (col + 1)..<n {
        let mult = lu.get(row, col).mul(inv_diag)
        lu.set(row, col, mult)
        for c in (col + 1)..<n {
          let old_val = lu.get(row, c)
          let subt = mult.mul(lu.get(col, c))
          lu.set(row, c, old_val.sub(subt))
        }
      }
    }
  }

  { n, lu_mat: lu, pivots, sign }
}

///|
/// Solves linear system A * x = b using LU decomposition.
pub fn ComplexLuDecomposition::solve(
  self : ComplexLuDecomposition,
  b : ComplexVector,
) -> ComplexVector {
  let n = self.n
  let y = ComplexVector::zeros(n)

  // Forward substitution: L * y = P * b
  for i in 0..<n {
    let p_idx = self.pivots[i]
    let mut sum = b.get(p_idx)
    for j in 0..<i {
      let mult = self.lu_mat.get(i, j).mul(y.get(j))
      sum = sum.sub(mult)
    }
    y.set(i, sum)
  }

  // Backward substitution: U * x = y
  let x = ComplexVector::zeros(n)
  for i = n - 1; i >= 0; i = i - 1 {
    let mut sum = y.get(i)
    for j in (i + 1)..<n {
      let mult = self.lu_mat.get(i, j).mul(x.get(j))
      sum = sum.sub(mult)
    }
    let diag = self.lu_mat.get(i, i)
    let sol_val = if diag.abs() > 1.0e-15 {
      sum.div(diag)
    } else {
      Complex::zero()
    }
    x.set(i, sol_val)
  }

  x
}

///|
/// Computes the complex determinant of matrix from LU decomposition.
pub fn ComplexLuDecomposition::det(self : ComplexLuDecomposition) -> Complex {
  let mut d = if self.sign == 1 {
    Complex::one()
  } else {
    Complex::new(-1.0, 0.0)
  }
  for i in 0..<self.n {
    d = d.mul(self.lu_mat.get(i, i))
  }
  d
}

///|
/// Direct Gaussian elimination solver for ComplexMatrix linear system A * x = b.
pub fn complex_gaussian_solve(
  a : ComplexMatrix,
  b : ComplexVector,
) -> ComplexVector {
  let lu = ComplexLuDecomposition::decompose(a)
  lu.solve(b)
}

///|
/// Inverts a complex square matrix using LU factorization.
pub fn complex_matrix_inverse(mat : ComplexMatrix) -> ComplexMatrix {
  let n = mat.num_rows()
  let lu = ComplexLuDecomposition::decompose(mat)
  let inv = ComplexMatrix::zeros(n, n)

  for col in 0..<n {
    let e = ComplexVector::zeros(n)
    e.set(col, Complex::one())
    let col_sol = lu.solve(e)
    for row in 0..<n {
      inv.set(row, col, col_sol.get(row))
    }
  }

  inv
}

///|
/// Computes complex condition number using ratio of max and min diagonal elements in LU.
pub fn complex_matrix_cond_estimate(mat : ComplexMatrix) -> Double {
  let lu = ComplexLuDecomposition::decompose(mat)
  let mut max_diag = 0.0
  let mut min_diag = 1.0e30
  for i in 0..<lu.n {
    let mag = lu.lu_mat.get(i, i).abs()
    if mag > max_diag {
      max_diag = mag
    }
    if mag < min_diag && mag > 1.0e-15 {
      min_diag = mag
    }
  }
  if min_diag == 0.0 {
    1.0e15
  } else {
    max_diag / min_diag
  }
}
