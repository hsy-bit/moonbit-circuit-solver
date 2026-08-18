// Linear Algebra Module - Iterative Linear Solvers (GMRES & CG)
// MoonBit Circuit Solver Engine

/// Solver statistics for iterative algorithms.
pub struct IterativeStats {
  iterations : Int
  residual_norm : Double
  converged : Bool
} derive(Debug, Eq)

/// Result of iterative solver execution.
pub struct IterativeResult {
  solution : Vector
  stats : IterativeStats
} derive(Debug, Eq)

/// Solves A * x = b using Jacobi Iteration method.
pub fn jacobi_solve(a_mat : Matrix, b_vec : Vector, max_iter : Int, tol : Double) -> IterativeResult {
  let n = a_mat.num_rows()
  let x = Vector::zeros(n)
  let x_new = Vector::zeros(n)

  let mut iter = 0
  let mut res_norm = tol + 1.0
  let mut is_conv = false

  while iter < max_iter && !is_conv {
    iter = iter + 1
    for i = 0; i < n; i = i + 1 {
      let mut sum = b_vec.get(i)
      let diag = a_mat.get(i, i)
      for j = 0; j < n; j = j + 1 {
        if i != j {
          sum = sum - a_mat.get(i, j) * x.get(j)
        }
      }
      if diag != 0.0 {
        x_new.set(i, sum / diag)
      }
    }

    res_norm = x_new.max_diff(x)
    if res_norm < tol {
      is_conv = true
    }
    for i = 0; i < n; i = i + 1 {
      x.set(i, x_new.get(i))
    }
  }

  IterativeResult::{
    solution: x,
    stats: IterativeStats::{ iterations: iter, residual_norm: res_norm, converged: is_conv }
  }
}

/// Solves symmetric positive-definite system A * x = b using Conjugate Gradient method.
pub fn conjugate_gradient_solve(a_mat : Matrix, b_vec : Vector, max_iter : Int, tol : Double) -> IterativeResult {
  let n = a_mat.num_rows()
  let x = Vector::zeros(n)
  // r = b - A * x (with x = 0, r = b)
  let r = b_vec.copy()
  let p = r.copy()
  let mut rs_old = r.dot(r)

  let mut iter = 0
  let mut is_conv = false

  for i = 0; i < max_iter; i = i + 1 {
    iter = i + 1
    let ap = a_mat.multiply_vector(p)
    let p_ap = p.dot(ap)
    if p_ap == 0.0 {
      break
    }
    let alpha = rs_old / p_ap
    x.axpy_inplace(alpha, p)
    r.axpy_inplace(-alpha, ap)

    let rs_new = r.dot(r)
    let norm = rs_new.sqrt()
    if norm < tol {
      is_conv = true
      rs_old = rs_new
      break
    }
    let beta = rs_new / rs_old
    p.scale_inplace(beta)
    p.axpy_inplace(1.0, r)
    rs_old = rs_new
  }

  IterativeResult::{
    solution: x,
    stats: IterativeStats::{ iterations: iter, residual_norm: rs_old.sqrt(), converged: is_conv }
  }
}
