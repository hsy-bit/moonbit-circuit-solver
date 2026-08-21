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
/// Incomplete Cholesky (IC0) preconditioner for symmetric positive-definite sparse systems: A approx L * L^T.
pub struct IncompleteCholeskyPreconditioner {
  n : Int
  l_csr : CsrMatrix
} derive(Eq, Debug)

///|
/// Constructs IC(0) factor from symmetric positive-definite CSR matrix keeping only original non-zero pattern.
pub fn IncompleteCholeskyPreconditioner::new(
  a_csr : CsrMatrix,
) -> IncompleteCholeskyPreconditioner {
  let n = a_csr.rows
  let dense = a_csr.to_dense()

  for i in 0..<n {
    let mut d_sum = 0.0
    for k in 0..<i {
      let l_ik = dense.get(i, k)
      d_sum = d_sum + l_ik * l_ik
    }
    let d_diff = dense.get(i, i) - d_sum
    let l_ii = if d_diff > 1.0e-14 { d_diff.sqrt() } else { 1.0e-7 }
    dense.set(i, i, l_ii)

    let inv_l_ii = 1.0 / l_ii
    for j in (i + 1)..<n {
      // Check if original matrix has non-zero at (j, i)
      if (if a_csr.get(j, i) < 0.0 {
          -a_csr.get(j, i)
        } else {
          a_csr.get(j, i)
        }) >
        1.0e-15 {
        let mut sum_jk = 0.0
        for k in 0..<i {
          sum_jk = sum_jk + dense.get(j, k) * dense.get(i, k)
        }
        let l_ji = (dense.get(j, i) - sum_jk) * inv_l_ii
        dense.set(j, i, l_ji)
      } else {
        dense.set(j, i, 0.0)
      }
    }
  }

  let l_builder = SparseBuilder::new(n, n)
  for r in 0..<n {
    for c in 0..<=r {
      let val = dense.get(r, c)
      if (if val < 0.0 { -val } else { val }) > 1.0e-15 {
        l_builder.add_entry(r, c, val)
      }
    }
  }

  { n, l_csr: l_builder.to_csr() }
}

///|
/// Applies IC(0) preconditioner M z = r by solving L y = r and L^T z = y.
pub fn IncompleteCholeskyPreconditioner::apply(
  self : IncompleteCholeskyPreconditioner,
  r : Vector,
) -> Vector {
  let n = self.n
  let y = Vector::zeros(n)

  // Forward solve: L * y = r
  for i in 0..<n {
    let mut sum = r.get(i)
    let mut diag = 1.0
    let start_ptr = self.l_csr.row_ptr[i]
    let end_ptr = self.l_csr.row_ptr[i + 1]
    for p in start_ptr..<end_ptr {
      let col = self.l_csr.col_ind[p]
      if col < i {
        sum = sum - self.l_csr.values[p] * y.get(col)
      } else if col == i {
        diag = self.l_csr.values[p]
      }
    }
    let sol = if (if diag < 0.0 { -diag } else { diag }) > 1.0e-15 {
      sum / diag
    } else {
      0.0
    }
    y.set(i, sol)
  }

  // Backward solve: L^T * z = y
  let z = Vector::zeros(n)
  let l_dense = self.l_csr.to_dense()
  for i = n - 1; i >= 0; i = i - 1 {
    let mut sum = y.get(i)
    for j in (i + 1)..<n {
      sum = sum - l_dense.get(j, i) * z.get(j)
    }
    let diag = l_dense.get(i, i)
    let sol = if (if diag < 0.0 { -diag } else { diag }) > 1.0e-15 {
      sum / diag
    } else {
      0.0
    }
    z.set(i, sol)
  }

  z
}

///|
/// Block Jacobi Preconditioner (decoupling into block_size x block_size local dense inversions).
pub struct BlockJacobiPreconditioner {
  n : Int
  block_size : Int
  inv_blocks : Array[Matrix]
} derive(Eq, Debug)

///|
/// Constructs Block Jacobi preconditioner with block size k.
pub fn BlockJacobiPreconditioner::new(
  mat : Matrix,
  block_size : Int,
) -> BlockJacobiPreconditioner {
  let n = mat.num_rows()
  let num_blocks = (n + block_size - 1) / block_size
  let inv_blocks = []

  for b in 0..<num_blocks {
    let start_idx = b * block_size
    let cur_block_size = if start_idx + block_size > n {
      n - start_idx
    } else {
      block_size
    }

    let b_mat = Matrix::zeros(cur_block_size, cur_block_size)
    for r in 0..<cur_block_size {
      for c in 0..<cur_block_size {
        b_mat.set(r, c, mat.get(start_idx + r, start_idx + c))
      }
    }

    let inv_b = match compute_matrix_inverse(b_mat) {
      Some(inv) => inv
      None => Matrix::identity(cur_block_size)
    }
    inv_blocks.push(inv_b)
  }

  { n, block_size, inv_blocks }
}

///|
/// Applies Block Jacobi preconditioner: z = M^-1 * r.
pub fn BlockJacobiPreconditioner::apply(
  self : BlockJacobiPreconditioner,
  r : Vector,
) -> Vector {
  let n = self.n
  let z = Vector::zeros(n)
  let num_blocks = self.inv_blocks.length()

  for b in 0..<num_blocks {
    let start_idx = b * self.block_size
    let inv_b = self.inv_blocks[b]
    let cur_bs = inv_b.num_rows()

    let r_local = Vector::zeros(cur_bs)
    for i in 0..<cur_bs {
      r_local.set(i, r.get(start_idx + i))
    }

    let z_local = inv_b.multiply_vector(r_local)
    for i in 0..<cur_bs {
      z.set(start_idx + i, z_local.get(i))
    }
  }

  z
}

///|
/// Symmetric Successive Over-Relaxation (SSOR) preconditioner for Krylov solvers.
pub struct SsorPreconditioner {
  n : Int
  omega : Double
  dense_mat : Matrix
} derive(Eq, Debug)

///|
/// Creates an SSOR preconditioner with relaxation parameter omega (typically in range [1.0, 1.9]).
pub fn SsorPreconditioner::new(
  mat : Matrix,
  omega : Double,
) -> SsorPreconditioner {
  { n: mat.num_rows(), omega, dense_mat: mat.copy() }
}

///|
/// Applies SSOR preconditioner: (D / omega + L) * (D / omega)^-1 * (D / omega + U) * z = r.
pub fn SsorPreconditioner::apply(
  self : SsorPreconditioner,
  r : Vector,
) -> Vector {
  let n = self.n
  let w = self.omega
  let mat = self.dense_mat

  // Step 1: (D / omega + L) * y = r (Forward sweep)
  let y = Vector::zeros(n)
  for i in 0..<n {
    let mut sum = r.get(i)
    for j in 0..<i {
      sum = sum - mat.get(i, j) * y.get(j)
    }
    let diag = mat.get(i, i) / w
    let sol = if (if diag < 0.0 { -diag } else { diag }) > 1.0e-15 {
      sum / diag
    } else {
      0.0
    }
    y.set(i, sol)
  }

  // Step 2: (2 - omega) * D * y_scaled
  let factor = (2.0 - w) / w
  let y2 = Vector::zeros(n)
  for i in 0..<n {
    y2.set(i, y.get(i) * factor * mat.get(i, i))
  }

  // Step 3: (D / omega + U) * z = y2 (Backward sweep)
  let z = Vector::zeros(n)
  for i = n - 1; i >= 0; i = i - 1 {
    let mut sum = y2.get(i)
    for j in (i + 1)..<n {
      sum = sum - mat.get(i, j) * z.get(j)
    }
    let diag = mat.get(i, i) / w
    let sol = if (if diag < 0.0 { -diag } else { diag }) > 1.0e-15 {
      sum / diag
    } else {
      0.0
    }
    z.set(i, sol)
  }

  z
}
