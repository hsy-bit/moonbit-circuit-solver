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
/// Result of Successive Over-Relaxation (SOR) iterative solver.
pub struct SorResult {
  solution : Vector
  iterations : Int
  converged : Bool
  residual_norm : Double
} derive(Eq, Debug)

///|
/// Solves linear system A * x = b using Successive Over-Relaxation (SOR) with relaxation factor omega.
pub fn sor_solve(
  a_mat : Matrix,
  b_vec : Vector,
  omega : Double, // Optimal in range [1.0, 1.95]
  max_iters : Int,
  tol : Double,
) -> SorResult {
  let n = a_mat.num_rows()
  let x = Vector::zeros(n)
  let mut conv = false
  let mut iter = 0
  let mut res_norm = b_vec.norm_l2()

  while iter < max_iters && !conv {
    iter = iter + 1
    let mut max_err = 0.0

    for i = 0; i < n; i = i + 1 {
      let mut sigma = 0.0
      for j = 0; j < n; j = j + 1 {
        if j != i {
          sigma = sigma + a_mat.get(i, j) * x.get(j)
        }
      }

      let a_ii = a_mat.get(i, i)
      let safe_aii = if a_ii.abs() > 1.0e-15 { a_ii } else { 1.0e-15 }
      let x_new = (1.0 - omega) * x.get(i) +
        omega / safe_aii * (b_vec.get(i) - sigma)
      let err = (x_new - x.get(i)).abs()
      if err > max_err {
        max_err = err
      }
      x.set(i, x_new)
    }

    let cur_res = a_mat.multiply_vector(x).sub(b_vec).norm_l2()
    res_norm = cur_res
    if max_err < tol || cur_res < tol {
      conv = true
    }
  }

  { solution: x, iterations: iter, converged: conv, residual_norm: res_norm }
}

///|
/// Computes Matrix Infinity Norm: max_i sum_j |A_ij|.
pub fn matrix_norm_inf(mat : Matrix) -> Double {
  let rows = mat.num_rows()
  let cols = mat.num_cols()
  let mut max_sum = 0.0

  for r in 0..<rows {
    let mut row_sum = 0.0
    for c in 0..<cols {
      row_sum = row_sum + mat.get(r, c).abs()
    }
    if row_sum > max_sum {
      max_sum = row_sum
    }
  }

  max_sum
}
