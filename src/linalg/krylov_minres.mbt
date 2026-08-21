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
/// Result of Dense MINRES Iterative Linear Solver.
pub struct DenseMinresResult {
  solution : Vector
  iterations : Int
  converged : Bool
  final_residual : Double
} derive(Eq, Debug)

///|
/// Solves symmetric (possibly indefinite) system A * x = b using MINRES Lanczos tridiagonalization on dense Matrix.
pub fn dense_minres_solve(
  a_mat : Matrix,
  b_vec : Vector,
  max_iters : Int,
  tol : Double,
) -> DenseMinresResult {
  let n = a_mat.num_rows()
  let x = Vector::zeros(n)
  let beta1 = b_vec.norm_l2()

  if beta1 < 1.0e-15 {
    return { solution: x, iterations: 0, converged: true, final_residual: 0.0 }
  }

  let mut v_old = Vector::zeros(n)
  let mut v_cur = b_vec.scale(1.0 / beta1)
  let mut beta_k = 0.0

  let mut w_old = Vector::zeros(n)
  let mut w_cur = Vector::zeros(n)

  let mut phi_bar = beta1
  let mut delta_bar = 0.0
  let mut c_cur = 1.0
  let mut s_cur = 0.0

  let mut iters = 0
  let mut conv = false
  let mut final_res = beta1

  for k = 1; k <= max_iters; k = k + 1 {
    iters = k

    // Lanczos step: p = A * v_cur - beta_k * v_old
    let p_vec = a_mat.multiply_vector(v_cur).sub(v_old.scale(beta_k))
    let alpha_k = v_cur.dot(p_vec)
    let p_ortho = p_vec.sub(v_cur.scale(alpha_k))
    let beta_next = p_ortho.norm_l2()

    // Previous Givens rotations on [delta_bar, alpha_k, beta_next]
    let delta_k = c_cur * delta_bar + s_cur * alpha_k
    let gamma_mid = s_cur * delta_bar - c_cur * alpha_k
    let eps_next = s_cur * beta_next
    let delta_next_bar = -c_cur * beta_next

    // Current Givens rotation to eliminate beta_next
    let gamma_k = (gamma_mid * gamma_mid + beta_next * beta_next).sqrt()
    if gamma_k > 1.0e-15 {
      c_cur = gamma_mid / gamma_k
      s_cur = beta_next / gamma_k
    } else {
      c_cur = 1.0
      s_cur = 0.0
    }

    let phi_k = c_cur * phi_bar
    phi_bar = s_cur * phi_bar

    // Update search direction w_k
    let denom = if gamma_k.abs() > 1.0e-15 { gamma_k } else { 1.0e-15 }
    let w_next = v_cur
      .sub(w_cur.scale(delta_k))
      .sub(w_old.scale(eps_next))
      .scale(1.0 / denom)

    // Update solution x = x + phi_k * w_next
    for i = 0; i < n; i = i + 1 {
      x.set(i, x.get(i) + phi_k * w_next.get(i))
    }

    final_res = phi_bar.abs()
    if final_res < tol {
      conv = true
      break
    }

    // Shift vectors
    v_old = v_cur
    if beta_next > 1.0e-15 {
      v_cur = p_ortho.scale(1.0 / beta_next)
    } else {
      v_cur = Vector::zeros(n)
    }
    beta_k = beta_next
    w_old = w_cur
    w_cur = w_next
    delta_bar = delta_next_bar
  }

  { solution: x, iterations: iters, converged: conv, final_residual: final_res }
}
