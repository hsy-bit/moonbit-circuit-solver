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
/// Full spectral spectrum of a square matrix.
pub struct SpectrumResult {
  eigenvalues : Array[Complex]
  is_converged : Bool
} derive(Eq, Debug)

///|
/// Reduces general real matrix to upper Hessenberg form using Householder similarity transformations.
pub fn hessenberg_reduction(mat : Matrix) -> Matrix {
  let n = mat.num_rows()
  let h = mat.copy()

  for k in 0..<(n - 2) {
    let mut norm_sq = 0.0
    for i in (k + 1)..<n {
      let v = h.get(i, k)
      norm_sq = norm_sq + v * v
    }
    let norm = norm_sq.sqrt()

    if norm > 1.0e-14 {
      let x0 = h.get(k + 1, k)
      let alpha = if x0 >= 0.0 { -norm } else { norm }
      let v0 = x0 - alpha

      let v_vec = Vector::zeros(n)
      v_vec.set(k + 1, 1.0)
      let inv_v0 = 1.0 / v0
      for i in (k + 2)..<n {
        v_vec.set(i, h.get(i, k) * inv_v0)
      }

      let beta = 2.0 / (1.0 + norm_sq / (v0 * v0))

      // Apply H = (I - beta * v * v^T) * H from left
      for col in k..<n {
        let mut dot = 0.0
        for i in (k + 1)..<n {
          dot = dot + v_vec.get(i) * h.get(i, col)
        }
        for i in (k + 1)..<n {
          h.set(i, col, h.get(i, col) - beta * dot * v_vec.get(i))
        }
      }

      // Apply H = H * (I - beta * v * v^T) from right
      for row in 0..<n {
        let mut dot = 0.0
        for i in (k + 1)..<n {
          dot = dot + v_vec.get(i) * h.get(row, i)
        }
        for i in (k + 1)..<n {
          h.set(row, i, h.get(row, i) - beta * dot * v_vec.get(i))
        }
      }
    }
  }

  h
}

///|
/// Francis double-shift implicitly shifted QR algorithm on upper Hessenberg matrix to find all eigenvalues.
pub fn francis_qr_eigenvalues(
  mat : Matrix,
  max_iters : Int,
  tol : Double,
) -> SpectrumResult {
  let n = mat.num_rows()
  if n == 0 {
    return { eigenvalues: [], is_converged: true }
  }
  if n == 1 {
    return {
      eigenvalues: [Complex::new(mat.get(0, 0), 0.0)],
      is_converged: true,
    }
  }

  let h = hessenberg_reduction(mat)
  let eigs : Array[Complex] = []
  let mut m = n - 1
  let mut iters = 0

  while m > 0 && iters < max_iters {
    iters = iters + 1

    // Check 1x1 sub-diagonal decoupling
    let sub1 = h.get(m, m - 1)
    let diag_sum1 = (if h.get(m - 1, m - 1) < 0.0 {
        -h.get(m - 1, m - 1)
      } else {
        h.get(m - 1, m - 1)
      }) +
      (if h.get(m, m) < 0.0 { -h.get(m, m) } else { h.get(m, m) })
    if (if sub1 < 0.0 { -sub1 } else { sub1 }) <=
      tol * (if diag_sum1 == 0.0 { 1.0 } else { diag_sum1 }) {
      eigs.push(Complex::new(h.get(m, m), 0.0))
      m = m - 1
      continue
    }

    // Check 2x2 block decoupling
    if m >= 2 {
      let sub2 = h.get(m - 1, m - 2)
      let diag_sum2 = (if h.get(m - 2, m - 2) < 0.0 {
          -h.get(m - 2, m - 2)
        } else {
          h.get(m - 2, m - 2)
        }) +
        (if h.get(m - 1, m - 1) < 0.0 {
          -h.get(m - 1, m - 1)
        } else {
          h.get(m - 1, m - 1)
        })
      if (if sub2 < 0.0 { -sub2 } else { sub2 }) <=
        tol * (if diag_sum2 == 0.0 { 1.0 } else { diag_sum2 }) {
        // Solve 2x2 characteristic polynomial
        let a = h.get(m - 1, m - 1)
        let b = h.get(m - 1, m)
        let c = h.get(m, m - 1)
        let d = h.get(m, m)

        let tr = a + d
        let det = a * d - b * c
        let disc = tr * tr - 4.0 * det

        if disc >= 0.0 {
          let sqrt_disc = disc.sqrt()
          eigs.push(Complex::new((tr + sqrt_disc) / 2.0, 0.0))
          eigs.push(Complex::new((tr - sqrt_disc) / 2.0, 0.0))
        } else {
          let im_part = (-disc).sqrt() / 2.0
          eigs.push(Complex::new(tr / 2.0, im_part))
          eigs.push(Complex::new(tr / 2.0, -im_part))
        }
        m = m - 2
        continue
      }
    }

    // Compute Wilkinson / Francis double shift from trailing 2x2 block
    let d1 = h.get(m - 1, m - 1)
    let d2 = h.get(m, m)
    let b_sub = h.get(m - 1, m)
    let c_sub = h.get(m, m - 1)

    let s = d1 + d2
    let t = d1 * d2 - b_sub * c_sub

    // Francis double-step transformation (bulge chasing)
    let x = h.get(0, 0) * h.get(0, 0) +
      h.get(0, 1) * h.get(1, 0) -
      s * h.get(0, 0) +
      t
    let y = h.get(1, 0) * (h.get(0, 0) + h.get(1, 1) - s)
    let z = h.get(1, 0) * h.get(2, 1)

    for k in 0..<(m - 1) {
      let mut v1 = if k == 0 { x } else { h.get(k, k - 1) }
      let mut v2 = if k == 0 { y } else { h.get(k + 1, k - 1) }
      let mut v3 = if k == 0 {
        z
      } else if k + 2 <= m {
        h.get(k + 2, k - 1)
      } else {
        0.0
      }

      let norm_sq = v1 * v1 + v2 * v2 + v3 * v3
      let norm = norm_sq.sqrt()

      if norm > 1.0e-15 {
        let alpha = if v1 >= 0.0 { -norm } else { norm }
        v1 = v1 - alpha
        let inv_v1 = 1.0 / v1
        v2 = v2 * inv_v1
        v3 = v3 * inv_v1
        let beta = 2.0 / (1.0 + (v2 * v2 + v3 * v3))

        // Left Householder update
        for col in k..<n {
          let dot = h.get(k, col) +
            v2 * h.get(k + 1, col) +
            (if k + 2 <= m { v3 * h.get(k + 2, col) } else { 0.0 })
          h.set(k, col, h.get(k, col) - beta * dot)
          h.set(k + 1, col, h.get(k + 1, col) - beta * dot * v2)
          if k + 2 <= m {
            h.set(k + 2, col, h.get(k + 2, col) - beta * dot * v3)
          }
        }

        // Right Householder update
        let r_max = if k + 3 < n { k + 3 } else { n - 1 }
        for row in 0..<=r_max {
          let dot = h.get(row, k) +
            v2 * h.get(row, k + 1) +
            (if k + 2 <= m { v3 * h.get(row, k + 2) } else { 0.0 })
          h.set(row, k, h.get(row, k) - beta * dot)
          h.set(row, k + 1, h.get(row, k + 1) - beta * dot * v2)
          if k + 2 <= m {
            h.set(row, k + 2, h.get(row, k + 2) - beta * dot * v3)
          }
        }
      }
    }
  }

  // Handle final 1x1 block if remaining
  if m == 0 {
    eigs.push(Complex::new(h.get(0, 0), 0.0))
  }

  { eigenvalues: eigs, is_converged: iters < max_iters }
}

///|
/// Arnoldi iteration producing an orthonormal basis of the Krylov subspace and upper Hessenberg projection.
pub fn arnoldi_iteration(
  a_csr : CsrMatrix,
  k_steps : Int,
) -> (Matrix, Array[Vector]) {
  let n = a_csr.rows
  let q_basis = []
  let h_mat = Matrix::zeros(k_steps + 1, k_steps)

  let q0 = Vector::zeros(n)
  q0.set(0, 1.0)
  q_basis.push(q0)

  for j in 0..<k_steps {
    if j >= q_basis.length() {
      break
    }
    let mut v = a_csr.multiply_vector(q_basis[j])
    for i in 0..<=j {
      let h_ij = v.dot(q_basis[i])
      h_mat.set(i, j, h_ij)
      v = v.sub(q_basis[i].scale(h_ij))
    }

    let h_next = v.norm_l2()
    h_mat.set(j + 1, j, h_next)

    if h_next > 1.0e-15 && j + 1 < k_steps {
      q_basis.push(v.scale(1.0 / h_next))
    } else if h_next <= 1.0e-15 {
      break
    }
  }

  (h_mat, q_basis)
}
