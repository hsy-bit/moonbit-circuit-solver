// Linear Algebra Module - Sparse Matrix (CSR & Triplet Builder)
// MoonBit Circuit Solver Engine

///|
/// Triplet entry used during dynamic sparse matrix assembly.
pub struct MatrixTriplet {
  row : Int
  col : Int
  val : Double
} derive(Debug, Eq)

///|
/// Builder for dynamically assembling sparse matrices via triplets.
pub struct SparseBuilder {
  rows : Int
  cols : Int
  triplets : Array[MatrixTriplet]
} derive(Debug, Eq)

///|
/// Creates a new SparseBuilder for an N x M matrix.
pub fn SparseBuilder::new(rows : Int, cols : Int) -> SparseBuilder {
  SparseBuilder::{ rows, cols, triplets: [] }
}

///|
/// Adds a value to element (row, col).
pub fn SparseBuilder::add_entry(
  self : SparseBuilder,
  row : Int,
  col : Int,
  val : Double,
) -> Unit {
  if val != 0.0 {
    self.triplets.push(MatrixTriplet::{ row, col, val })
  }
}

///|
/// Compressed Sparse Row (CSR) format matrix.
pub struct CsrMatrix {
  rows : Int
  cols : Int
  row_ptr : Array[Int]
  col_ind : Array[Int]
  values : Array[Double]
} derive(Debug, Eq)

///|
/// Converts a SparseBuilder into a compressed CSR matrix.
pub fn SparseBuilder::to_csr(self : SparseBuilder) -> CsrMatrix {
  let num_triplets = self.triplets.length()
  // Count non-zeros per row
  let row_counts = Array::make(self.rows, 0)
  for i = 0; i < num_triplets; i = i + 1 {
    let r = self.triplets[i].row
    row_counts[r] = row_counts[r] + 1
  }

  // Prefix sum for row pointers
  let row_ptr = Array::make(self.rows + 1, 0)
  for r = 0; r < self.rows; r = r + 1 {
    row_ptr[r + 1] = row_ptr[r] + row_counts[r]
  }

  let total_nnz = row_ptr[self.rows]
  let col_ind = Array::make(total_nnz, 0)
  let values = Array::make(total_nnz, 0.0)

  // Current insertion offsets per row
  let current_offset = row_ptr.copy()

  for i = 0; i < num_triplets; i = i + 1 {
    let r = self.triplets[i].row
    let c = self.triplets[i].col
    let v = self.triplets[i].val
    let dest_idx = current_offset[r]
    col_ind[dest_idx] = c
    values[dest_idx] = v
    current_offset[r] = current_offset[r] + 1
  }

  CsrMatrix::{ rows: self.rows, cols: self.cols, row_ptr, col_ind, values }
}

///|
/// Converts a dense Matrix into CSR format.
pub fn CsrMatrix::from_dense(mat : Matrix) -> CsrMatrix {
  let rows = mat.num_rows()
  let cols = mat.num_cols()
  let builder = SparseBuilder::new(rows, cols)
  for r = 0; r < rows; r = r + 1 {
    for c = 0; c < cols; c = c + 1 {
      let v = mat.get(r, c)
      if v != 0.0 {
        builder.add_entry(r, c, v)
      }
    }
  }
  builder.to_csr()
}

///|
/// Converts CSR matrix back to dense Matrix format.
pub fn CsrMatrix::to_dense(self : CsrMatrix) -> Matrix {
  let mat = Matrix::zeros(self.rows, self.cols)
  for r = 0; r < self.rows; r = r + 1 {
    let start = self.row_ptr[r]
    let end = self.row_ptr[r + 1]
    for idx = start; idx < end; idx = idx + 1 {
      let c = self.col_ind[idx]
      let v = self.values[idx]
      mat.set(r, c, mat.get(r, c) + v)
    }
  }
  mat
}

///|
/// Matrix-vector multiplication for CSR matrix: y = A * x.
pub fn CsrMatrix::multiply_vector(self : CsrMatrix, x : Vector) -> Vector {
  if self.cols != x.length() {
    abort("CSR matrix-vector dimension mismatch")
  }
  let y = Array::make(self.rows, 0.0)
  for r = 0; r < self.rows; r = r + 1 {
    let start = self.row_ptr[r]
    let end = self.row_ptr[r + 1]
    let mut sum = 0.0
    for idx = start; idx < end; idx = idx + 1 {
      let c = self.col_ind[idx]
      let v = self.values[idx]
      sum = sum + v * x.get(c)
    }
    y[r] = sum
  }
  Vector::from_array(y)
}

///|
/// Returns the number of non-zero entries.
pub fn CsrMatrix::nnz(self : CsrMatrix) -> Int {
  self.values.length()
}

///|
/// Element lookup at (row, col) in CSR matrix.
pub fn CsrMatrix::get(self : CsrMatrix, r : Int, c : Int) -> Double {
  if r < 0 || r >= self.rows || c < 0 || c >= self.cols {
    return 0.0
  }
  let start = self.row_ptr[r]
  let end = self.row_ptr[r + 1]
  let mut sum = 0.0
  for idx = start; idx < end; idx = idx + 1 {
    if self.col_ind[idx] == c {
      sum = sum + self.values[idx]
    }
  }
  sum
}
