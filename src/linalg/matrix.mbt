// Linear Algebra Module - Dense Matrix Operations
// MoonBit Circuit Solver Engine

///|
/// Dense 2D matrix stored in row-major order.
pub struct Matrix {
  rows : Int
  cols : Int
  data : Array[Double]
} derive(Debug, Eq)

///|
/// Creates a new matrix of size `rows x cols` with initial value.
pub fn Matrix::make(rows : Int, cols : Int, init_val : Double) -> Matrix {
  let data = Array::make(rows * cols, init_val)
  Matrix::{ rows, cols, data }
}

///|
/// Creates a zero matrix of size `rows x cols`.
pub fn Matrix::zeros(rows : Int, cols : Int) -> Matrix {
  Matrix::make(rows, cols, 0.0)
}

///|
/// Creates an identity matrix of size `dim x dim`.
pub fn Matrix::identity(dim : Int) -> Matrix {
  let mat = Matrix::zeros(dim, dim)
  for i = 0; i < dim; i = i + 1 {
    mat.set(i, i, 1.0)
  }
  mat
}

///|
/// Gets element at (row, col).
pub fn Matrix::get(self : Matrix, row : Int, col : Int) -> Double {
  if row < 0 || row >= self.rows || col < 0 || col >= self.cols {
    abort("Matrix index out of bounds in get")
  }
  self.data[row * self.cols + col]
}

///|
/// Sets element at (row, col).
pub fn Matrix::set(self : Matrix, row : Int, col : Int, val : Double) -> Unit {
  if row < 0 || row >= self.rows || col < 0 || col >= self.cols {
    abort("Matrix index out of bounds in set")
  }
  self.data[row * self.cols + col] = val
}

///|
/// Adds value to element at (row, col) in-place.
pub fn Matrix::add_to_element(
  self : Matrix,
  row : Int,
  col : Int,
  val : Double,
) -> Unit {
  let curr = self.get(row, col)
  self.set(row, col, curr + val)
}

///|
/// Returns the number of rows.
pub fn Matrix::num_rows(self : Matrix) -> Int {
  self.rows
}

///|
/// Returns the number of columns.
pub fn Matrix::num_cols(self : Matrix) -> Int {
  self.cols
}

///|
/// Deep copy of matrix.
pub fn Matrix::copy(self : Matrix) -> Matrix {
  Matrix::{ rows: self.rows, cols: self.cols, data: self.data.copy() }
}

///|
/// Multiplies matrix by a column vector: y = A * x.
pub fn Matrix::multiply_vector(self : Matrix, x : Vector) -> Vector {
  if self.cols != x.length() {
    abort("Matrix-vector dimension mismatch")
  }
  let y = Array::make(self.rows, 0.0)
  for r = 0; r < self.rows; r = r + 1 {
    let mut sum = 0.0
    let row_offset = r * self.cols
    for c = 0; c < self.cols; c = c + 1 {
      sum = sum + self.data[row_offset + c] * x.get(c)
    }
    y[r] = sum
  }
  Vector::from_array(y)
}

///|
/// Multiplies two matrices c_mat = self * b_mat.
pub fn Matrix::multiply(self : Matrix, b_mat : Matrix) -> Matrix {
  if self.cols != b_mat.rows {
    abort("Matrix-matrix dimension mismatch")
  }
  let c_mat = Matrix::zeros(self.rows, b_mat.cols)
  for r = 0; r < self.rows; r = r + 1 {
    for k = 0; k < self.cols; k = k + 1 {
      let a_rk = self.get(r, k)
      if a_rk != 0.0 {
        for c = 0; c < b_mat.cols; c = c + 1 {
          let curr = c_mat.get(r, c)
          c_mat.set(r, c, curr + a_rk * b_mat.get(k, c))
        }
      }
    }
  }
  c_mat
}

///|
/// Transposes matrix and returns a new matrix.
pub fn Matrix::transpose(self : Matrix) -> Matrix {
  let t_mat = Matrix::zeros(self.cols, self.rows)
  for r = 0; r < self.rows; r = r + 1 {
    for c = 0; c < self.cols; c = c + 1 {
      t_mat.set(c, r, self.get(r, c))
    }
  }
  t_mat
}

///|
/// Swaps row `r1` and row `r2` in-place.
pub fn Matrix::swap_rows(self : Matrix, r1 : Int, r2 : Int) -> Unit {
  if r1 == r2 {
    return
  }
  for c = 0; c < self.cols; c = c + 1 {
    let tmp = self.get(r1, c)
    self.set(r1, c, self.get(r2, c))
    self.set(r2, c, tmp)
  }
}

///|
/// Scales row `r` by scalar factor in-place.
pub fn Matrix::scale_row(self : Matrix, r : Int, scalar : Double) -> Unit {
  for c = 0; c < self.cols; c = c + 1 {
    self.set(r, c, self.get(r, c) * scalar)
  }
}

///|
/// Performs row operation: row[r1] = row[r1] + alpha * row[r2].
pub fn Matrix::add_row_multiple(
  self : Matrix,
  r1 : Int,
  r2 : Int,
  alpha : Double,
) -> Unit {
  for c = 0; c < self.cols; c = c + 1 {
    let val = self.get(r1, c) + alpha * self.get(r2, c)
    self.set(r1, c, val)
  }
}

///|
/// Computes Frobenius norm of matrix.
pub fn Matrix::norm_frobenius(self : Matrix) -> Double {
  let mut sum_sq = 0.0
  let total = self.rows * self.cols
  for i = 0; i < total; i = i + 1 {
    let v = self.data[i]
    sum_sq = sum_sq + v * v
  }
  sum_sq.sqrt()
}

///|
/// Computes infinity norm (max row sum).
pub fn Matrix::norm_inf(self : Matrix) -> Double {
  let mut max_sum = 0.0
  for r = 0; r < self.rows; r = r + 1 {
    let mut row_sum = 0.0
    for c = 0; c < self.cols; c = c + 1 {
      let v = self.get(r, c)
      let abs_v = if v < 0.0 { -v } else { v }
      row_sum = row_sum + abs_v
    }
    if row_sum > max_sum {
      max_sum = row_sum
    }
  }
  max_sum
}
