// Linear Algebra Module - Advanced Matrix Operations & Eigenvalue Solver
// MoonBit Circuit Solver Engine

///|
/// Result of Jacobi Eigenvalue Decomposition for symmetric matrices.
pub struct EigenDecomposition {
  eigenvalues : Vector
  eigenvectors : Matrix
} derive(Debug, Eq)

///|
/// Computes eigenvalues and eigenvectors of a symmetric square matrix using Jacobi rotation method.
pub fn jacobi_eigen(
  a_mat : Matrix,
  max_iters : Int,
  tol : Double,
) -> EigenDecomposition {
  let n = a_mat.num_rows()
  if n != a_mat.num_cols() {
    abort("Eigenvalue decomposition requires square matrix")
  }

  let a = a_mat.copy()
  let v = Matrix::identity(n)

  let mut iter = 0
  let mut conv = false

  while iter < max_iters && !conv {
    iter = iter + 1
    // Find largest off-diagonal element
    let mut max_off = 0.0
    let mut p = 0
    let mut q = 1

    for r = 0; r < n; r = r + 1 {
      for c = r + 1; c < n; c = c + 1 {
        let abs_v = a.get(r, c).abs()
        if abs_v > max_off {
          max_off = abs_v
          p = r
          q = c
        }
      }
    }

    if max_off < tol {
      conv = true
    } else {
      let app = a.get(p, p)
      let aqq = a.get(q, q)
      let apq = a.get(p, q)

      let phi = 0.5 * @math.log10(((aqq - app) / (2.0 * apq)).abs())
      let c_val = @math.cos(phi)
      let s_val = @math.sin(phi)

      // Rotate A
      for i = 0; i < n; i = i + 1 {
        if i != p && i != q {
          let aip = a.get(i, p)
          let aiq = a.get(i, q)
          let new_aip = c_val * aip - s_val * aiq
          let new_aiq = s_val * aip + c_val * aiq
          a.set(i, p, new_aip)
          a.set(p, i, new_aip)
          a.set(i, q, new_aiq)
          a.set(q, i, new_aiq)
        }
      }

      let new_app = c_val * c_val * app -
        2.0 * s_val * c_val * apq +
        s_val * s_val * aqq
      let new_aqq = s_val * s_val * app +
        2.0 * s_val * c_val * apq +
        c_val * c_val * aqq
      a.set(p, p, new_app)
      a.set(q, q, new_aqq)
      a.set(p, q, 0.0)
      a.set(q, p, 0.0)

      // Rotate eigenvectors V
      for i = 0; i < n; i = i + 1 {
        let vip = v.get(i, p)
        let viq = v.get(i, q)
        v.set(i, p, c_val * vip - s_val * viq)
        v.set(i, q, s_val * vip + c_val * viq)
      }
    }
  }

  let evalues = Array::make(n, 0.0)
  for i = 0; i < n; i = i + 1 {
    evalues[i] = a.get(i, i)
  }

  EigenDecomposition::{
    eigenvalues: Vector::from_array(evalues),
    eigenvectors: v,
  }
}
