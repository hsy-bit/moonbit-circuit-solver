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
/// Markowitz pivot selection data for sparse matrix factorization.
pub struct MarkowitzPivot {
  row : Int
  col : Int
  score : Int
  pivot_val : Double
} derive(Eq, Debug)

///|
/// Sparse Direct LU Factorization using Markowitz threshold pivoting and sparse linked-list / CSR structure.
pub struct SparseLuSolver {
  n : Int
  row_perm : Array[Int]
  col_perm : Array[Int]
  l_csr : CsrMatrix
  u_csr : CsrMatrix
  fill_in_count : Int
  is_valid : Bool
} derive(Eq, Debug)

///|
/// Computes Markowitz score matrix: for each active element, score = (row_nnz - 1) * (col_nnz - 1).
pub fn compute_markowitz_scores(
  mat : Matrix,
  active_rows : Array[Bool],
  active_cols : Array[Bool],
  threshold_u : Double,
) -> MarkowitzPivot? {
  let n = mat.num_rows()
  let row_nnz = Array::make(n, 0)
  let col_nnz = Array::make(n, 0)
  let col_max = Array::make(n, 0.0)

  // Count active non-zeros and column max magnitudes
  for r in 0..<n {
    if active_rows[r] {
      for c in 0..<n {
        if active_cols[c] {
          let val = mat.get(r, c)
          let mag = if val < 0.0 { -val } else { val }
          if mag > 1.0e-15 {
            row_nnz[r] = row_nnz[r] + 1
            col_nnz[c] = col_nnz[c] + 1
            if mag > col_max[c] {
              col_max[c] = mag
            }
          }
        }
      }
    }
  }

  let mut best_score = 1000000000
  let mut best_pivot : MarkowitzPivot? = None

  for r in 0..<n {
    if active_rows[r] && row_nnz[r] > 0 {
      for c in 0..<n {
        if active_cols[c] && col_nnz[c] > 0 {
          let val = mat.get(r, c)
          let mag = if val < 0.0 { -val } else { val }
          // Threshold pivoting condition: |a_rc| >= u * max_k |a_kc|
          let pass_threshold = mag >= threshold_u * col_max[c] && mag > 1.0e-15
          if pass_threshold {
            let score = (row_nnz[r] - 1) * (col_nnz[c] - 1)
            if score < best_score {
              best_score = score
              best_pivot = Some({ row: r, col: c, score, pivot_val: val })
            }
          }
        }
      }
    }
  }

  best_pivot
}

///|
/// Factors a sparse system matrix into L and U with fill-in minimization.
pub fn factorize_sparse_lu(
  dense_mat : Matrix,
  threshold_u : Double,
) -> SparseLuSolver {
  let n = dense_mat.num_rows()
  let work = dense_mat.copy()
  let row_perm = Array::make(n, 0)
  let col_perm = Array::make(n, 0)
  let active_rows = Array::make(n, true)
  let active_cols = Array::make(n, true)

  let mut fill_ins = 0

  for step in 0..<n {
    let pivot_opt = compute_markowitz_scores(
      work, active_rows, active_cols, threshold_u,
    )
    match pivot_opt {
      Some(p) => {
        let p_row = p.row
        let p_col = p.col
        row_perm[step] = p_row
        col_perm[step] = p_col
        active_rows[p_row] = false
        active_cols[p_col] = false

        let p_val = work.get(p_row, p_col)
        if (if p_val < 0.0 { -p_val } else { p_val }) > 1.0e-15 {
          let inv_p = 1.0 / p_val
          // Eliminate rows
          for r in 0..<n {
            if active_rows[r] {
              let a_rc = work.get(r, p_col)
              if (if a_rc < 0.0 { -a_rc } else { a_rc }) > 1.0e-15 {
                let factor = a_rc * inv_p
                work.set(r, p_col, factor) // Store L entry
                for c in 0..<n {
                  if active_cols[c] {
                    let a_pc = work.get(p_row, c)
                    if (if a_pc < 0.0 { -a_pc } else { a_pc }) > 1.0e-15 {
                      let old_val = work.get(r, c)
                      let was_zero = (if old_val < 0.0 {
                          -old_val
                        } else {
                          old_val
                        }) <
                        1.0e-15
                      let new_val = old_val - factor * a_pc
                      work.set(r, c, new_val)
                      if was_zero &&
                        (if new_val < 0.0 { -new_val } else { new_val }) >
                        1.0e-15 {
                        fill_ins = fill_ins + 1
                      }
                    }
                  }
                }
              }
            }
          }
        }
      }
      None =>
        // Fallback for remaining diagonal entries
        for r in 0..<n {
          if active_rows[r] {
            row_perm[step] = r
            col_perm[step] = r
            active_rows[r] = false
            active_cols[r] = false
            break
          }
        }
    }
  }

  // Separate L and U into CSR matrices
  let l_builder = SparseBuilder::new(n, n)
  let u_builder = SparseBuilder::new(n, n)

  for i in 0..<n {
    let r_i = row_perm[i]
    // L diagonal is 1.0
    l_builder.add_entry(i, i, 1.0)
    for j in 0..<i {
      let c_j = col_perm[j]
      let val = work.get(r_i, c_j)
      if (if val < 0.0 { -val } else { val }) > 1.0e-15 {
        l_builder.add_entry(i, j, val)
      }
    }

    for j in i..<n {
      let c_j = col_perm[j]
      let val = work.get(r_i, c_j)
      if (if val < 0.0 { -val } else { val }) > 1.0e-15 {
        u_builder.add_entry(i, j, val)
      }
    }
  }

  let l_csr = l_builder.to_csr()
  let u_csr = u_builder.to_csr()

  {
    n,
    row_perm,
    col_perm,
    l_csr,
    u_csr,
    fill_in_count: fill_ins,
    is_valid: true,
  }
}

///|
/// Solves sparse linear system P_r * A * P_c^T * (P_c * x) = P_r * b using L and U.
pub fn SparseLuSolver::solve(self : SparseLuSolver, b : Vector) -> Vector {
  let n = self.n
  let pb = Vector::zeros(n)
  for i in 0..<n {
    pb.set(i, b.get(self.row_perm[i]))
  }

  // Forward solve: L * y = P_r * b
  let y = Vector::zeros(n)
  for i in 0..<n {
    let mut sum = pb.get(i)
    let start_ptr = self.l_csr.row_ptr[i]
    let end_ptr = self.l_csr.row_ptr[i + 1]
    for p in start_ptr..<end_ptr {
      let col = self.l_csr.col_ind[p]
      if col < i {
        sum = sum - self.l_csr.values[p] * y.get(col)
      }
    }
    y.set(i, sum)
  }

  // Backward solve: U * z = y
  let z = Vector::zeros(n)
  for i = n - 1; i >= 0; i = i - 1 {
    let mut sum = y.get(i)
    let mut diag_val = 1.0
    let start_ptr = self.u_csr.row_ptr[i]
    let end_ptr = self.u_csr.row_ptr[i + 1]
    for p in start_ptr..<end_ptr {
      let col = self.u_csr.col_ind[p]
      if col > i {
        sum = sum - self.u_csr.values[p] * z.get(col)
      } else if col == i {
        diag_val = self.u_csr.values[p]
      }
    }
    let sol = if (if diag_val < 0.0 { -diag_val } else { diag_val }) > 1.0e-15 {
      sum / diag_val
    } else {
      0.0
    }
    z.set(i, sol)
  }

  // Unpermute: x = P_c^T * z
  let x = Vector::zeros(n)
  for i in 0..<n {
    x.set(self.col_perm[i], z.get(i))
  }
  x
}
