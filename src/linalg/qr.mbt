// Linear Algebra Module - QR Decomposition & Least Squares
// MoonBit Circuit Solver Engine

/// Represents QR Decomposition result A = Q * R.
pub struct QrDecomposition {
  rows : Int
  cols : Int
  q_mat : Matrix
  r_mat : Matrix
} derive(Debug, Eq)

/// Decomposes m x n matrix A into Q (m x m orthogonal) and R (m x n upper triangular).
pub fn QrDecomposition::decompose(a_mat : Matrix) -> QrDecomposition {
  let m = a_mat.num_rows()
  let n = a_mat.num_cols()

  let q_mat = Matrix::identity(m)
  let r_mat = a_mat.copy()

  let min_dim = if m < n { m } else { n }

  for k = 0; k < min_dim; k = k + 1 {
    // Compute Householder norm
    let mut norm_sq = 0.0
    for r = k; r < m; r = r + 1 {
      let v = r_mat.get(r, k)
      norm_sq = norm_sq + v * v
    }
    let norm = norm_sq.sqrt()
    if norm != 0.0 {
      let r_kk = r_mat.get(k, k)
      let alpha = if r_kk >= 0.0 { -norm } else { norm }
      let u1 = r_kk - alpha

      let v_vec = Array::make(m - k, 0.0)
      v_vec[0] = 1.0
      for r = k + 1; r < m; r = r + 1 {
        v_vec[r - k] = r_mat.get(r, k) / u1
      }

      let mut v_norm_sq = 0.0
      for idx = 0; idx < m - k; idx = idx + 1 {
        v_norm_sq = v_norm_sq + v_vec[idx] * v_vec[idx]
      }
      let beta = 2.0 / v_norm_sq

      // Apply Householder reflection to R
      for c = k; c < n; c = c + 1 {
        let mut dot = 0.0
        for r = k; r < m; r = r + 1 {
          dot = dot + v_vec[r - k] * r_mat.get(r, c)
        }
        let tau = beta * dot
        for r = k; r < m; r = r + 1 {
          let curr = r_mat.get(r, c)
          r_mat.set(r, c, curr - tau * v_vec[r - k])
        }
      }

      // Apply Householder reflection to Q
      for r = 0; r < m; r = r + 1 {
        let mut dot = 0.0
        for c = k; c < m; c = c + 1 {
          dot = dot + q_mat.get(r, c) * v_vec[c - k]
        }
        let tau = beta * dot
        for c = k; c < m; c = c + 1 {
          let curr = q_mat.get(r, c)
          q_mat.set(r, c, curr - tau * v_vec[c - k])
        }
      }
    }
  }

  QrDecomposition::{ rows: m, cols: n, q_mat, r_mat }
}

/// Solves overdetermined least-squares system A * x = b using QR decomposition.
pub fn qr_solve(a_mat : Matrix, b_vec : Vector) -> Vector {
  let qr = QrDecomposition::decompose(a_mat)
  let q_t = qr.q_mat.transpose()
  let q_t_b = q_t.multiply_vector(b_vec)

  let n = qr.cols
  let x = Array::make(n, 0.0)

  for i = n - 1; i >= 0; i = i - 1 {
    let mut sum = q_t_b.get(i)
    for j = i + 1; j < n; j = j + 1 {
      sum = sum - qr.r_mat.get(i, j) * x[j]
    }
    let diag = qr.r_mat.get(i, i)
    if diag != 0.0 {
      x[i] = sum / diag
    }
  }

  Vector::from_array(x)
}
