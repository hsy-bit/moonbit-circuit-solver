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
/// Result of matrix equilibration containing row scale factors, column scale factors, and scaled matrix.
pub struct EquilibrationResult {
  scaled_mat : Matrix
  row_scales : Vector
  col_scales : Vector
  condition_improvement : Double
} derive(Eq, Debug)

///|
/// Computes Hager-Higham 1-norm condition number estimate kappa_1(A) = ||A||_1 * ||A^-1||_1.
pub fn estimate_condition_1norm(mat : Matrix, max_iters : Int) -> Double {
  let n = mat.num_rows()
  if n == 0 {
    return 1.0
  }

  // 1-norm of A: max column sum of absolute values
  let mut norm_a = 0.0
  for c in 0..<n {
    let mut col_sum = 0.0
    for r in 0..<n {
      let v = mat.get(r, c)
      col_sum = col_sum + (if v < 0.0 { -v } else { v })
    }
    if col_sum > norm_a {
      norm_a = col_sum
    }
  }

  let lu = LuDecomposition::decompose(mat)

  // Hager's 1-norm estimation algorithm for ||A^-1||_1
  let mut x = Vector::make(n, 1.0 / n.to_double())
  let mut gamma = 0.0

  for _iter in 0..<max_iters {
    // Solve A * y = x
    let y = lu.solve(x)
    let y_norm = y.norm_l1()

    if y_norm > gamma {
      gamma = y_norm
    }

    // Sign vector xi = sign(y)
    let xi = Vector::zeros(n)
    for i in 0..<n {
      let yi = y.get(i)
      xi.set(i, if yi >= 0.0 { 1.0 } else { -1.0 })
    }

    // Solve A^T * z = xi
    let a_t = mat.transpose()
    let lu_t = LuDecomposition::decompose(a_t)
    let z = lu_t.solve(xi)

    // Find j that maximizes |z_j|
    let mut max_z = 0.0
    let mut max_j = 0
    for j in 0..<n {
      let zj = z.get(j)
      let abs_zj = if zj < 0.0 { -zj } else { zj }
      if abs_zj > max_z {
        max_z = abs_zj
        max_j = j
      }
    }

    if max_z <= z.dot(x) {
      break
    }

    // x = e_{max_j}
    x = Vector::zeros(n)
    x.set(max_j, 1.0)
  }

  norm_a * gamma
}

///|
/// Performs Row and Column Equilibration to reduce condition number: A_eq = R * A * C.
pub fn equilibrate_matrix(mat : Matrix) -> EquilibrationResult {
  let m = mat.num_rows()
  let n = mat.num_cols()
  let r_scales = Vector::zeros(m)
  let c_scales = Vector::zeros(n)

  // Compute row scale factors: r_i = 1 / max_j |a_ij|
  for r in 0..<m {
    let mut max_val = 0.0
    for c in 0..<n {
      let v = mat.get(r, c)
      let abs_v = if v < 0.0 { -v } else { v }
      if abs_v > max_val {
        max_val = abs_v
      }
    }
    r_scales.set(r, if max_val > 1.0e-15 { 1.0 / max_val } else { 1.0 })
  }

  // Row-scaled intermediate matrix
  let intermediate = Matrix::zeros(m, n)
  for r in 0..<m {
    let s_r = r_scales.get(r)
    for c in 0..<n {
      intermediate.set(r, c, mat.get(r, c) * s_r)
    }
  }

  // Compute column scale factors: c_j = 1 / max_i |intermediate_ij|
  for c in 0..<n {
    let mut max_val = 0.0
    for r in 0..<m {
      let v = intermediate.get(r, c)
      let abs_v = if v < 0.0 { -v } else { v }
      if abs_v > max_val {
        max_val = abs_v
      }
    }
    c_scales.set(c, if max_val > 1.0e-15 { 1.0 / max_val } else { 1.0 })
  }

  // Final scaled matrix: A_scaled(r, c) = r_scales[r] * mat(r, c) * c_scales[c]
  let scaled = Matrix::zeros(m, n)
  for r in 0..<m {
    let s_r = r_scales.get(r)
    for c in 0..<n {
      let s_c = c_scales.get(c)
      scaled.set(r, c, mat.get(r, c) * s_r * s_c)
    }
  }

  let cond_orig = estimate_condition_1norm(mat, 5)
  let cond_scaled = estimate_condition_1norm(scaled, 5)
  let ratio = if cond_scaled > 0.0 { cond_orig / cond_scaled } else { 1.0 }

  {
    scaled_mat: scaled,
    row_scales: r_scales,
    col_scales: c_scales,
    condition_improvement: ratio,
  }
}
