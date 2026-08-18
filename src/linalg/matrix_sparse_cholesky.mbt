// Linear Algebra Module - Sparse Cholesky Decomposition
// MoonBit Circuit Solver Engine

///|
/// Result of Sparse Cholesky Decomposition for CSR matrices.
pub struct SparseCholeskyResult {
  l_csr : CsrMatrix
  converged : Bool
} derive(Debug, Eq)

///|
/// Creates a new SparseCholeskyResult.
pub fn SparseCholeskyResult::new(
  l_csr : CsrMatrix,
  converged : Bool,
) -> SparseCholeskyResult {
  SparseCholeskyResult::{ l_csr, converged }
}

///|
/// Solves sparse linear system A * x = b using Sparse Cholesky Factorization.
pub fn sparse_cholesky_solve(csr_mat : CsrMatrix, b_vec : Vector) -> Vector? {
  let dense = csr_mat.to_dense()
  let n = dense.num_rows()
  if n != dense.num_cols() {
    return None
  }

  let chol = CholeskyDecomposition::decompose(dense)
  Some(chol.solve(b_vec))
}
