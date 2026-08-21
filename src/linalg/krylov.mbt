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
/// Krylov subspace solver result containing solution vector, iteration count, and residual history.
pub struct KrylovResult {
  solution : Vector
  iterations : Int
  converged : Bool
  final_residual : Double
  residual_history : Array[Double]
} derive(Eq, Debug)

///|
/// Flexible Restarted GMRES (GMRES(m)) solver for general non-symmetric sparse linear systems A * x = b.
pub fn fgmres_solve(
  a_csr : CsrMatrix,
  b : Vector,
  restart_m : Int,
  max_outer_iters : Int,
  tol : Double,
) -> KrylovResult {
  let n = b.length()
  let x = Vector::zeros(n)
  let history = []

  let mut current_res = b.norm_l2()
  history.push(current_res)

  if current_res < tol {
    return {
      solution: x,
      iterations: 0,
      converged: true,
      final_residual: current_res,
      residual_history: history,
    }
  }

  let mut total_iters = 0
  let mut converged = false

  for _outer in 0..<max_outer_iters {
    let r0 = b.sub(a_csr.multiply_vector(x))
    let beta = r0.norm_l2()
    current_res = beta
    history.push(beta)

    if beta < tol {
      converged = true
      break
    }

    // Krylov basis V (m+1 vectors of length n)
    let v_basis = Array::make(restart_m + 1, Vector::zeros(n))
    v_basis[0] = r0.scale(1.0 / beta)

    // Hessenberg matrix H ((m+1) x m)
    let h_mat = Matrix::zeros(restart_m + 1, restart_m)
    // Rotation vectors for Givens reduction
    let cs = Array::make(restart_m, 0.0)
    let sn = Array::make(restart_m, 0.0)
    let s_vec = Vector::zeros(restart_m + 1)
    s_vec.set(0, beta)

    let mut actual_k = restart_m

    for k in 0..<restart_m {
      total_iters = total_iters + 1
      let v_k = v_basis[k]
      // Matrix-vector product w = A * v_k
      let mut w = a_csr.multiply_vector(v_k)

      // Modified Gram-Schmidt orthogonalization
      for i in 0..<=k {
        let h_ik = w.dot(v_basis[i])
        h_mat.set(i, k, h_ik)
        w = w.sub(v_basis[i].scale(h_ik))
      }

      let h_next = w.norm_l2()
      h_mat.set(k + 1, k, h_next)

      if h_next > 1.0e-15 {
        v_basis[k + 1] = w.scale(1.0 / h_next)
      }

      // Apply previous Givens rotations to column k of H
      for i in 0..<k {
        let temp = cs[i] * h_mat.get(i, k) + sn[i] * h_mat.get(i + 1, k)
        let temp2 = -sn[i] * h_mat.get(i, k) + cs[i] * h_mat.get(i + 1, k)
        h_mat.set(i, k, temp)
        h_mat.set(i + 1, k, temp2)
      }

      // Compute new Givens rotation to eliminate H(k+1, k)
      let a_k = h_mat.get(k, k)
      let b_k = h_mat.get(k + 1, k)
      let denom = (a_k * a_k + b_k * b_k).sqrt()
      if denom > 1.0e-15 {
        cs[k] = a_k / denom
        sn[k] = b_k / denom
      } else {
        cs[k] = 1.0
        sn[k] = 0.0
      }

      // Apply rotation to H and s
      h_mat.set(k, k, cs[k] * a_k + sn[k] * b_k)
      h_mat.set(k + 1, k, 0.0)

      let s_k = s_vec.get(k)
      let s_next = s_vec.get(k + 1)
      s_vec.set(k, cs[k] * s_k + sn[k] * s_next)
      s_vec.set(k + 1, -sn[k] * s_k + cs[k] * s_next)

      let res_k = if s_vec.get(k + 1) < 0.0 {
        -s_vec.get(k + 1)
      } else {
        s_vec.get(k + 1)
      }
      current_res = res_k
      history.push(res_k)

      if res_k < tol {
        actual_k = k + 1
        converged = true
        break
      }
    }

    // Solve upper triangular system H_k * y = s_k
    let y = Vector::zeros(actual_k)
    for i = actual_k - 1; i >= 0; i = i - 1 {
      let mut sum = s_vec.get(i)
      for j in (i + 1)..<actual_k {
        sum = sum - h_mat.get(i, j) * y.get(j)
      }
      let diag = h_mat.get(i, i)
      if (if diag < 0.0 { -diag } else { diag }) > 1.0e-15 {
        y.set(i, sum / diag)
      }
    }

    // Update solution x = x + V_k * y
    for i in 0..<actual_k {
      let y_i = y.get(i)
      x.axpy_inplace(y_i, v_basis[i])
    }

    if converged {
      break
    }
  }

  {
    solution: x,
    iterations: total_iters,
    converged,
    final_residual: current_res,
    residual_history: history,
  }
}

///|
/// Transpose-Free Quasi-Minimal Residual (TFQMR) method for general non-symmetric sparse linear systems.
pub fn tfqmr_solve(
  a_csr : CsrMatrix,
  b : Vector,
  max_iters : Int,
  tol : Double,
) -> KrylovResult {
  let n = b.length()
  let x = Vector::zeros(n)
  let history = []

  let r0 = b.sub(a_csr.multiply_vector(x))
  let r = r0.copy()
  let r_star = r0.copy()

  let mut u = r.copy()
  let mut v = a_csr.multiply_vector(u)
  let mut d = Vector::zeros(n)
  let mut w = r.copy()

  let mut tau = r0.norm_l2()
  let mut theta = 0.0
  let mut eta = 0.0
  let mut rho = r_star.dot(r)

  history.push(tau)

  if tau < tol {
    return {
      solution: x,
      iterations: 0,
      converged: true,
      final_residual: tau,
      residual_history: history,
    }
  }

  let mut converged = false
  let mut iters = 0

  for iter in 0..<max_iters {
    iters = iter + 1
    let sigma = r_star.dot(v)
    if (if sigma < 0.0 { -sigma } else { sigma }) < 1.0e-20 {
      break
    }
    let alpha = rho / sigma

    // Sub-step m = 2*iter - 1
    for step in 1..<=2 {
      if step == 1 {
        let w_sub = w.sub(v.scale(alpha))
        w = w_sub
      } else {
        let a_u = a_csr.multiply_vector(u)
        let w_sub = w.sub(a_u.scale(alpha))
        w = w_sub
      }

      let theta_prev = theta
      theta = w.norm_l2() / tau
      let c = 1.0 / (1.0 + theta * theta).sqrt()
      tau = tau * theta * c
      eta = c * c * alpha

      let d_new = if step == 1 {
        u.add(
          d.scale(
            theta_prev *
            theta_prev *
            (eta / (if alpha == 0.0 { 1.0e-15 } else { alpha })),
          ),
        )
      } else {
        u.add(
          d.scale(
            theta_prev *
            theta_prev *
            (eta / (if alpha == 0.0 { 1.0e-15 } else { alpha })),
          ),
        )
      }
      d = d_new
      x.axpy_inplace(eta, d)

      history.push(tau)

      if tau < tol {
        converged = true
        break
      }
    }

    if converged {
      break
    }

    let rho_prev = rho
    rho = r_star.dot(w)
    if (if rho_prev < 0.0 { -rho_prev } else { rho_prev }) < 1.0e-20 {
      break
    }
    let beta = rho / rho_prev
    u = w.add(u.scale(beta))
    v = a_csr.multiply_vector(u).add(v.scale(beta))
  }

  {
    solution: x,
    iterations: iters,
    converged,
    final_residual: tau,
    residual_history: history,
  }
}

///|
/// MINRES (Minimal Residual method) for symmetric (possibly indefinite) linear systems A * x = b.
pub fn minres_solve(
  a_csr : CsrMatrix,
  b : Vector,
  max_iters : Int,
  tol : Double,
) -> KrylovResult {
  let n = b.length()
  let x = Vector::zeros(n)
  let history = []

  let r0 = b.sub(a_csr.multiply_vector(x))
  let beta1 = r0.norm_l2()
  history.push(beta1)

  if beta1 < tol {
    return {
      solution: x,
      iterations: 0,
      converged: true,
      final_residual: beta1,
      residual_history: history,
    }
  }

  let mut v_old = Vector::zeros(n)
  let mut v = r0.scale(1.0 / beta1)

  let mut w_old2 = Vector::zeros(n)
  let mut w_old1 = Vector::zeros(n)

  let mut phi_bar = beta1
  let mut c_old = 1.0
  let mut s_old = 0.0

  let mut beta = 0.0
  let mut converged = false
  let mut iters = 0

  for iter in 0..<max_iters {
    iters = iter + 1

    // Lanczos step: p = A * v - beta * v_old
    let p = a_csr.multiply_vector(v).sub(v_old.scale(beta))
    let alpha = v.dot(p)
    let p2 = p.sub(v.scale(alpha))
    let beta_new = p2.norm_l2()

    // QR factorization of tridiagonal matrix
    let gamma_bar = c_old * alpha - s_old * beta
    let delta = s_old * alpha + c_old * beta
    let gamma = (gamma_bar * gamma_bar + beta_new * beta_new).sqrt()

    let c = if gamma > 1.0e-15 { gamma_bar / gamma } else { 1.0 }
    let s = if gamma > 1.0e-15 { beta_new / gamma } else { 0.0 }

    let phi = c * phi_bar
    phi_bar = -s * phi_bar

    // Update search directions w
    let mut w = v.sub(w_old1.scale(delta)).sub(w_old2.scale(s_old * beta_new))
    if gamma > 1.0e-15 {
      w = w.scale(1.0 / gamma)
    }

    // Update solution
    x.axpy_inplace(phi, w)

    let cur_res = if phi_bar < 0.0 { -phi_bar } else { phi_bar }
    history.push(cur_res)

    if cur_res < tol {
      converged = true
      break
    }

    // Shift state for next iteration
    w_old2 = w_old1
    w_old1 = w
    v_old = v
    if beta_new > 1.0e-15 {
      v = p2.scale(1.0 / beta_new)
    }
    beta = beta_new
    c_old = c
    s_old = s
  }

  {
    solution: x,
    iterations: iters,
    converged,
    final_residual: if phi_bar < 0.0 {
      -phi_bar
    } else {
      phi_bar
    },
    residual_history: history,
  }
}
