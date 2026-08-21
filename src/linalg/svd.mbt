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
/// Result of Singular Value Decomposition: A = U * diag(S) * V^T.
pub struct SvdResult {
  u : Matrix
  s : Vector
  v : Matrix
  rank : Int
} derive(Eq, Debug)

///|
/// Computes SVD of matrix A (m x n, m >= n) using one-sided Jacobi orthogonalization algorithm.
pub fn compute_svd(mat : Matrix, max_iters : Int, tol : Double) -> SvdResult {
  let m = mat.num_rows()
  let n = mat.num_cols()

  // Copy matrix into work matrix A
  let a_work = mat.copy()
  // Initialize V to identity n x n
  let v_mat = Matrix::identity(n)

  // One-sided Hestenes-Jacobi orthogonalization on columns of A
  for _iter in 0..<max_iters {
    let mut max_corr = 0.0

    for i in 0..<(n - 1) {
      for j in (i + 1)..<n {
        // Compute column dot products: a_ii = a_i . a_i, a_jj = a_j . a_j, a_ij = a_i . a_j
        let mut a_ii = 0.0
        let mut a_jj = 0.0
        let mut a_ij = 0.0

        for r in 0..<m {
          let vi = a_work.get(r, i)
          let vj = a_work.get(r, j)
          a_ii = a_ii + vi * vi
          a_jj = a_jj + vj * vj
          a_ij = a_ij + vi * vj
        }

        let abs_ij = if a_ij < 0.0 { -a_ij } else { a_ij }
        let norm_prod = (a_ii * a_jj).sqrt()

        if norm_prod > 1.0e-16 {
          let corr = abs_ij / norm_prod
          if corr > max_corr {
            max_corr = corr
          }

          if corr > tol {
            // Compute 2x2 Jacobi rotation angle
            let tau = (a_jj - a_ii) / (2.0 * a_ij)
            let t = if tau >= 0.0 {
              1.0 / (tau + (1.0 + tau * tau).sqrt())
            } else {
              -1.0 / (-tau + (1.0 + tau * tau).sqrt())
            }
            let c = 1.0 / (1.0 + t * t).sqrt()
            let s = t * c

            // Apply rotation to columns i and j of A
            for r in 0..<m {
              let vi = a_work.get(r, i)
              let vj = a_work.get(r, j)
              a_work.set(r, i, c * vi - s * vj)
              a_work.set(r, j, s * vi + c * vj)
            }

            // Accumulate right singular vectors in V
            for r in 0..<n {
              let vi = v_mat.get(r, i)
              let vj = v_mat.get(r, j)
              v_mat.set(r, i, c * vi - s * vj)
              v_mat.set(r, j, s * vi + c * vj)
            }
          }
        }
      }
    }

    if max_corr <= tol {
      break
    }
  }

  // Singular values are column norms of A
  let s_vec = Vector::zeros(n)
  let u_mat = Matrix::zeros(m, n)

  for j in 0..<n {
    let mut sum_sq = 0.0
    for r in 0..<m {
      let val = a_work.get(r, j)
      sum_sq = sum_sq + val * val
    }
    let sigma = sum_sq.sqrt()
    s_vec.set(j, sigma)

    if sigma > 1.0e-15 {
      let inv_sigma = 1.0 / sigma
      for r in 0..<m {
        u_mat.set(r, j, a_work.get(r, j) * inv_sigma)
      }
    }
  }

  // Sort singular values in descending order
  for i in 0..<(n - 1) {
    let mut max_idx = i
    let mut max_s = s_vec.get(i)
    for j in (i + 1)..<n {
      if s_vec.get(j) > max_s {
        max_s = s_vec.get(j)
        max_idx = j
      }
    }
    if max_idx != i {
      // Swap singular values
      let tmp_s = s_vec.get(i)
      s_vec.set(i, s_vec.get(max_idx))
      s_vec.set(max_idx, tmp_s)

      // Swap columns of U
      for r in 0..<m {
        let tmp = u_mat.get(r, i)
        u_mat.set(r, i, u_mat.get(r, max_idx))
        u_mat.set(r, max_idx, tmp)
      }

      // Swap columns of V
      for r in 0..<n {
        let tmp = v_mat.get(r, i)
        v_mat.set(r, i, v_mat.get(r, max_idx))
        v_mat.set(r, max_idx, tmp)
      }
    }
  }

  // Determine effective numerical rank
  let max_sigma = s_vec.get(0)
  let rank_thresh = 1.0e-12 * max_sigma
  let mut rank = 0
  for j in 0..<n {
    if s_vec.get(j) > rank_thresh {
      rank = rank + 1
    }
  }

  { u: u_mat, s: s_vec, v: v_mat, rank }
}

///|
/// Computes SVD-based regularized pseudoinverse A^+ = V * inv(S) * U^T.
pub fn svd_pseudo_inverse(mat : Matrix, rcond : Double) -> Matrix {
  let svd = compute_svd(mat, 50, 1.0e-12)
  let m = mat.num_rows()
  let n = mat.num_cols()
  let max_s = svd.s.get(0)
  let threshold = rcond * max_s

  let pinv = Matrix::zeros(n, m)

  for i in 0..<n {
    let sigma = svd.s.get(i)
    if sigma > threshold {
      let inv_sigma = 1.0 / sigma
      for r in 0..<n {
        let v_ri = svd.v.get(r, i)
        for c in 0..<m {
          let u_ci = svd.u.get(c, i)
          let term = v_ri * inv_sigma * u_ci
          pinv.add_to_element(r, c, term)
        }
      }
    }
  }

  pinv
}
