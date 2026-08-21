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
/// Result of GMRES Iterative Linear Solver.
pub struct GmresResult {
  solution : Vector
  iterations : Int
  converged : Bool
  final_residual : Double
} derive(Eq, Debug)

///|
/// Solves A * x = b using Restarted GMRES(m) with Arnoldi Modified Gram-Schmidt orthogonalization.
pub fn gmres_solve(
  a_mat : Matrix,
  b_vec : Vector,
  restart_m : Int,
  max_restarts : Int,
  tol : Double,
) -> GmresResult {
  let n = a_mat.num_rows()
  let x = Vector::zeros(n)
  let mut total_iters = 0
  let mut conv = false
  let mut final_res = b_vec.norm_l2()

  if final_res < 1.0e-15 {
    return { solution: x, iterations: 0, converged: true, final_residual: 0.0 }
  }

  for _restart = 0; _restart < max_restarts; _restart = _restart + 1 {
    // 1. Initial residual r0 = b - A * x
    let r0 = b_vec.sub(a_mat.multiply_vector(x))
    let beta = r0.norm_l2()
    final_res = beta
    if beta < tol {
      conv = true
      break
    }

    // 2. Krylov basis V = [v0, v1, ..., vm]
    let v_basis : Array[Vector] = []
    v_basis.push(r0.scale(1.0 / beta))

    // Upper Hessenberg matrix H of size (m+1) x m
    let h_mat = Matrix::zeros(restart_m + 1, restart_m)
    let g_vec = Vector::zeros(restart_m + 1)
    g_vec.set(0, beta)

    let mut actual_k = 0

    for j = 0; j < restart_m; j = j + 1 {
      total_iters = total_iters + 1
      actual_k = j + 1

      // Arnoldi step: w = A * v_j
      let mut w = a_mat.multiply_vector(v_basis[j])

      // Modified Gram-Schmidt orthogonalization against previous vectors
      for i = 0; i <= j; i = i + 1 {
        let h_ij = w.dot(v_basis[i])
        h_mat.set(i, j, h_ij)
        w = w.sub(v_basis[i].scale(h_ij))
      }

      let h_next = w.norm_l2()
      h_mat.set(j + 1, j, h_next)

      if h_next > 1.0e-15 {
        v_basis.push(w.scale(1.0 / h_next))
      } else {
        v_basis.push(Vector::zeros(n))
      }
    }

    // Solve least squares: H * y approx g via small dense Gaussian elimination on H^T * H
    let ht_h = Matrix::zeros(actual_k, actual_k)
    let ht_g = Vector::zeros(actual_k)

    for r = 0; r < actual_k; r = r + 1 {
      let mut sum_g = 0.0
      for k = 0; k <= actual_k; k = k + 1 {
        sum_g = sum_g + h_mat.get(k, r) * g_vec.get(k)
      }
      ht_g.set(r, sum_g)

      for c = 0; c < actual_k; c = c + 1 {
        let mut sum_h = 0.0
        for k = 0; k <= actual_k; k = k + 1 {
          sum_h = sum_h + h_mat.get(k, r) * h_mat.get(k, c)
        }
        ht_h.set(r, c, sum_h)
      }
    }

    // Add regularization to diagonal for stability
    for r = 0; r < actual_k; r = r + 1 {
      ht_h.set(r, r, ht_h.get(r, r) + 1.0e-12)
    }

    let y_sol = match gaussian_solve(ht_h, ht_g) {
      Success(sol) => sol
      SingularMatrix(_) => Vector::zeros(actual_k)
    }

    // Update x = x + sum_i y_i * v_i
    for i = 0; i < actual_k; i = i + 1 {
      let coeff = y_sol.get(i)
      for k = 0; k < n; k = k + 1 {
        x.set(k, x.get(k) + coeff * v_basis[i].get(k))
      }
    }

    let cur_res = b_vec.sub(a_mat.multiply_vector(x)).norm_l2()
    final_res = cur_res
    if cur_res < tol {
      conv = true
      break
    }
  }

  {
    solution: x,
    iterations: total_iters,
    converged: conv,
    final_residual: final_res,
  }
}
