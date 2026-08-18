// Linear Algebra Module - BiCGSTAB & GMRES Solvers
// MoonBit Circuit Solver Engine

///|
/// Result of BiCGSTAB sparse linear system solver.
pub struct BicgstabResult {
  solution : Vector
  iterations : Int
  converged : Bool
  residual : Double
} derive(Debug, Eq)

///|
/// Solves sparse linear system A * x = b using Bi-Conjugate Gradient Stabilized (BiCGSTAB) method.
pub fn bicgstab_solve(
  csr_mat : CsrMatrix,
  b_vec : Vector,
  max_iters : Int,
  tol : Double,
) -> BicgstabResult {
  let n = csr_mat.rows
  let x = Vector::zeros(n)
  let r = b_vec.sub(csr_mat.multiply_vector(x))
  let r_hat = r.copy()

  let mut rho_old = 1.0
  let mut alpha = 1.0
  let mut omega = 1.0

  let v = Vector::zeros(n)
  let p = Vector::zeros(n)

  let mut iter = 0
  let mut conv = false
  let mut final_res = r.norm_l2()

  while iter < max_iters && !conv {
    iter = iter + 1
    let rho_new = r_hat.dot(r)
    if rho_new == 0.0 {
      break
    }

    if iter == 1 {
      for i = 0; i < n; i = i + 1 {
        p.set(i, r.get(i))
      }
    } else {
      let beta = rho_new / rho_old * (alpha / omega)
      for i = 0; i < n; i = i + 1 {
        let p_val = r.get(i) + beta * (p.get(i) - omega * v.get(i))
        p.set(i, p_val)
      }
    }

    let v_new = csr_mat.multiply_vector(p)
    let denom = r_hat.dot(v_new)
    if denom == 0.0 {
      break
    }
    alpha = rho_new / denom

    let s = r.sub(v_new.scale(alpha))
    let s_norm = s.norm_l2()
    if s_norm < tol {
      x.axpy_inplace(alpha, p)
      final_res = s_norm
      conv = true
      break
    }

    let t = csr_mat.multiply_vector(s)
    let t_dot_t = t.dot(t)
    if t_dot_t == 0.0 {
      break
    }
    omega = t.dot(s) / t_dot_t

    x.axpy_inplace(alpha, p)
    x.axpy_inplace(omega, s)

    let r_next = s.sub(t.scale(omega))
    final_res = r_next.norm_l2()

    if final_res < tol {
      conv = true
      break
    }

    for i = 0; i < n; i = i + 1 {
      r.set(i, r_next.get(i))
      v.set(i, v_new.get(i))
    }
    rho_old = rho_new
  }

  BicgstabResult::{
    solution: x,
    iterations: iter,
    converged: conv,
    residual: final_res,
  }
}
