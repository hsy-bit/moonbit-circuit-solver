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
/// Dense 2D Complex Matrix for multi-frequency AC simulation, S-parameter conversions, and RF networks.
pub struct ComplexMatrix {
  rows : Int
  cols : Int
  data : Array[Complex]
} derive(Eq, Debug)

///|
/// Creates a new complex matrix of size rows x cols filled with initial val.
pub fn ComplexMatrix::make(
  rows : Int,
  cols : Int,
  val : Complex,
) -> ComplexMatrix {
  let size = rows * cols
  let data = Array::make(size, val)
  { rows, cols, data }
}

///|
/// Creates a new zero complex matrix of size rows x cols.
pub fn ComplexMatrix::zeros(rows : Int, cols : Int) -> ComplexMatrix {
  ComplexMatrix::make(rows, cols, Complex::zero())
}

///|
/// Creates an identity complex matrix of size n x n.
pub fn ComplexMatrix::identity(n : Int) -> ComplexMatrix {
  let mat = ComplexMatrix::zeros(n, n)
  for i in 0..<n {
    mat.set(i, i, Complex::one())
  }
  mat
}

///|
/// Gets number of rows.
pub fn ComplexMatrix::num_rows(self : ComplexMatrix) -> Int {
  self.rows
}

///|
/// Gets number of columns.
pub fn ComplexMatrix::num_cols(self : ComplexMatrix) -> Int {
  self.cols
}

///|
/// Gets matrix element at row r and column c (0-indexed).
pub fn ComplexMatrix::get(self : ComplexMatrix, r : Int, c : Int) -> Complex {
  if r >= 0 && r < self.rows && c >= 0 && c < self.cols {
    self.data[r * self.cols + c]
  } else {
    Complex::zero()
  }
}

///|
/// Sets matrix element at row r and column c (0-indexed).
pub fn ComplexMatrix::set(
  self : ComplexMatrix,
  r : Int,
  c : Int,
  val : Complex,
) -> Unit {
  if r >= 0 && r < self.rows && c >= 0 && c < self.cols {
    self.data[r * self.cols + c] = val
  }
}

///|
/// Adds val to existing element at (r, c).
pub fn ComplexMatrix::add_to_element(
  self : ComplexMatrix,
  r : Int,
  c : Int,
  val : Complex,
) -> Unit {
  if r >= 0 && r < self.rows && c >= 0 && c < self.cols {
    let current = self.get(r, c)
    self.set(r, c, current.add(val))
  }
}

///|
/// Copies the complex matrix.
pub fn ComplexMatrix::copy(self : ComplexMatrix) -> ComplexMatrix {
  let total = self.rows * self.cols
  let new_data = Array::make(total, Complex::zero())
  for i in 0..<total {
    new_data[i] = self.data[i]
  }
  { rows: self.rows, cols: self.cols, data: new_data }
}

///|
/// Computes the transpose (without complex conjugation) of matrix.
pub fn ComplexMatrix::transpose(self : ComplexMatrix) -> ComplexMatrix {
  let res = ComplexMatrix::zeros(self.cols, self.rows)
  for r in 0..<self.rows {
    for c in 0..<self.cols {
      res.set(c, r, self.get(r, c))
    }
  }
  res
}

///|
/// Computes the Hermitian conjugate transpose (A^H = conj(A^T)).
pub fn ComplexMatrix::conjugate_transpose(
  self : ComplexMatrix,
) -> ComplexMatrix {
  let res = ComplexMatrix::zeros(self.cols, self.rows)
  for r in 0..<self.rows {
    for c in 0..<self.cols {
      res.set(c, r, self.get(r, c).conj())
    }
  }
  res
}

///|
/// Multiplies matrix with a complex vector: y = A * x.
pub fn ComplexMatrix::multiply_vector(
  self : ComplexMatrix,
  x : ComplexVector,
) -> ComplexVector {
  let y = ComplexVector::zeros(self.rows)
  for r in 0..<self.rows {
    let mut sum = Complex::zero()
    for c in 0..<self.cols {
      let term = self.get(r, c).mul(x.get(c))
      sum = sum.add(term)
    }
    y.set(r, sum)
  }
  y
}

///|
/// Multiplies two complex matrices: C = A * B.
pub fn ComplexMatrix::multiply(
  self : ComplexMatrix,
  other : ComplexMatrix,
) -> ComplexMatrix {
  let res = ComplexMatrix::zeros(self.rows, other.cols)
  for r in 0..<self.rows {
    for k in 0..<self.cols {
      let a_rk = self.get(r, k)
      if a_rk.abs_sq() > 0.0 {
        for c in 0..<other.cols {
          let term = a_rk.mul(other.get(k, c))
          res.add_to_element(r, c, term)
        }
      }
    }
  }
  res
}

///|
/// Adds two complex matrices elementwise.
pub fn ComplexMatrix::add(
  self : ComplexMatrix,
  other : ComplexMatrix,
) -> ComplexMatrix {
  let res = ComplexMatrix::zeros(self.rows, self.cols)
  for r in 0..<self.rows {
    for c in 0..<self.cols {
      res.set(r, c, self.get(r, c).add(other.get(r, c)))
    }
  }
  res
}

///|
/// Scales complex matrix by a complex scalar.
pub fn ComplexMatrix::scale(
  self : ComplexMatrix,
  alpha : Complex,
) -> ComplexMatrix {
  let res = ComplexMatrix::zeros(self.rows, self.cols)
  for r in 0..<self.rows {
    for c in 0..<self.cols {
      res.set(r, c, self.get(r, c).mul(alpha))
    }
  }
  res
}

///|
/// Computes the Frobenius norm of matrix.
pub fn ComplexMatrix::norm_frobenius(self : ComplexMatrix) -> Double {
  let mut sum_sq = 0.0
  for r in 0..<self.rows {
    for c in 0..<self.cols {
      sum_sq = sum_sq + self.get(r, c).abs_sq()
    }
  }
  sum_sq.sqrt()
}

///|
/// Computes the infinity norm (max row sum).
pub fn ComplexMatrix::norm_inf(self : ComplexMatrix) -> Double {
  let mut max_row_sum = 0.0
  for r in 0..<self.rows {
    let mut row_sum = 0.0
    for c in 0..<self.cols {
      row_sum = row_sum + self.get(r, c).abs()
    }
    if row_sum > max_row_sum {
      max_row_sum = row_sum
    }
  }
  max_row_sum
}

///|
/// Swaps rows r1 and r2 in-place.
pub fn ComplexMatrix::swap_rows(
  self : ComplexMatrix,
  r1 : Int,
  r2 : Int,
) -> Unit {
  if r1 != r2 && r1 >= 0 && r1 < self.rows && r2 >= 0 && r2 < self.rows {
    for c in 0..<self.cols {
      let tmp = self.get(r1, c)
      self.set(r1, c, self.get(r2, c))
      self.set(r2, c, tmp)
    }
  }
}

///|
/// Adds a complex multiple of row src to row dest: row[dest] += alpha * row[src].
pub fn ComplexMatrix::add_row_multiple(
  self : ComplexMatrix,
  dest : Int,
  src : Int,
  alpha : Complex,
) -> Unit {
  for c in 0..<self.cols {
    let current = self.get(dest, c)
    let added = current.add(alpha.mul(self.get(src, c)))
    self.set(dest, c, added)
  }
}
