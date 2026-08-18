// Linear Algebra Module - Cholesky Decomposition
// MoonBit Circuit Solver Engine

///|
/// Represents Cholesky Decomposition A = L * L^T.
pub struct CholeskyDecomposition {
  n : Int
  l_mat : Matrix
} derive(Debug, Eq)

///|
/// Computes Cholesky factor L for symmetric positive-definite matrix A.
pub fn CholeskyDecomposition::decompose(
  a_mat : Matrix,
) -> CholeskyDecomposition {
  let n = a_mat.num_rows()
  if n != a_mat.num_cols() {
    abort("Cholesky decomposition requires square matrix")
  }
  let l_mat = Matrix::zeros(n, n)

  for i = 0; i < n; i = i + 1 {
    for j = 0; j <= i; j = j + 1 {
      let mut sum = a_mat.get(i, j)
      for k = 0; k < j; k = k + 1 {
        sum = sum - l_mat.get(i, k) * l_mat.get(j, k)
      }
      if i == j {
        if sum <= 0.0 {
          abort("Matrix is not positive-definite for Cholesky decomposition")
        }
        l_mat.set(i, j, sum.sqrt())
      } else {
        let diag = l_mat.get(j, j)
        if diag != 0.0 {
          l_mat.set(i, j, sum / diag)
        }
      }
    }
  }

  CholeskyDecomposition::{ n, l_mat }
}

///|
/// Solves A * x = b using Cholesky factor L (L * L^T * x = b).
pub fn CholeskyDecomposition::solve(
  self : CholeskyDecomposition,
  b_vec : Vector,
) -> Vector {
  // Forward substitution L * y = b
  let y = Array::make(self.n, 0.0)
  for i = 0; i < self.n; i = i + 1 {
    let mut sum = b_vec.get(i)
    for j = 0; j < i; j = j + 1 {
      sum = sum - self.l_mat.get(i, j) * y[j]
    }
    let diag = self.l_mat.get(i, i)
    if diag != 0.0 {
      y[i] = sum / diag
    }
  }

  // Backward substitution L^T * x = y
  let x = Array::make(self.n, 0.0)
  for i = self.n - 1; i >= 0; i = i - 1 {
    let mut sum = y[i]
    for j = i + 1; j < self.n; j = j + 1 {
      sum = sum - self.l_mat.get(j, i) * x[j]
    }
    let diag = self.l_mat.get(i, i)
    if diag != 0.0 {
      x[i] = sum / diag
    }
  }

  Vector::from_array(x)
}
