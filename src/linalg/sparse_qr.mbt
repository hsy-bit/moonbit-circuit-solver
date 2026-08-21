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
/// Sparse Givens Rotation record for zeroing out element (r2, col).
pub struct GivensRotation {
  r1 : Int
  r2 : Int
  c : Double
  s : Double
} derive(Eq, Debug)

///|
/// Sparse QR Decomposition result: Q * R = A.
pub struct SparseQrResult {
  m : Int
  n : Int
  rotations : Array[GivensRotation]
  r_csr : CsrMatrix
} derive(Eq, Debug)

///|
/// Computes Givens rotation parameters c = cos(theta), s = sin(theta) to eliminate b:
/// [ c  s ] [ a ] = [ r ]
/// [-s  c ] [ b ]   [ 0 ]
pub fn compute_givens(a : Double, b : Double) -> (Double, Double, Double) {
  if b == 0.0 {
    (1.0, 0.0, a)
  } else if (if a < 0.0 { -a } else { a }) == 0.0 {
    (0.0, 1.0, b)
  } else {
    let r = (a * a + b * b).sqrt()
    let c = a / r
    let s = b / r
    (c, s, r)
  }
}

///|
/// Computes Sparse QR Decomposition of m x n matrix (m >= n) using Givens rotations.
pub fn sparse_qr_decompose(mat : Matrix) -> SparseQrResult {
  let m = mat.num_rows()
  let n = mat.num_cols()
  let r_work = mat.copy()
  let rotations : Array[GivensRotation] = []

  for col in 0..<n {
    for row = m - 1; row > col; row = row - 1 {
      let a = r_work.get(col, col)
      let b = r_work.get(row, col)

      if (if b < 0.0 { -b } else { b }) > 1.0e-15 {
        let (c, s, _) = compute_givens(a, b)
        rotations.push({ r1: col, r2: row, c, s })

        // Apply Givens rotation to rows col and row of R
        for j in col..<n {
          let v1 = r_work.get(col, j)
          let v2 = r_work.get(row, j)
          r_work.set(col, j, c * v1 + s * v2)
          r_work.set(row, j, -s * v1 + c * v2)
        }
      }
    }
  }

  // Convert upper triangular R to CSR
  let r_builder = SparseBuilder::new(n, n)
  for r in 0..<n {
    for c in r..<n {
      let val = r_work.get(r, c)
      if (if val < 0.0 { -val } else { val }) > 1.0e-15 {
        r_builder.add_entry(r, c, val)
      }
    }
  }

  { m, n, rotations, r_csr: r_builder.to_csr() }
}

///|
/// Solves least-squares problem min ||A * x - b||_2 using Sparse QR.
pub fn SparseQrResult::solve_least_squares(
  self : SparseQrResult,
  b : Vector,
) -> Vector {
  let qtb = b.copy()

  // Apply Q^T = G_k ... G_2 G_1 to vector b
  for i in 0..<self.rotations.length() {
    let rot = self.rotations[i]
    let r1 = rot.r1
    let r2 = rot.r2
    let c = rot.c
    let s = rot.s

    let v1 = qtb.get(r1)
    let v2 = qtb.get(r2)
    qtb.set(r1, c * v1 + s * v2)
    qtb.set(r2, -s * v1 + c * v2)
  }

  // Back substitution with upper triangular R: R * x = (Q^T * b)[0..n]
  let n = self.n
  let x = Vector::zeros(n)
  let r_dense = self.r_csr.to_dense()

  for i = n - 1; i >= 0; i = i - 1 {
    let mut sum = qtb.get(i)
    for j in (i + 1)..<n {
      sum = sum - r_dense.get(i, j) * x.get(j)
    }
    let diag = r_dense.get(i, i)
    let sol = if (if diag < 0.0 { -diag } else { diag }) > 1.0e-15 {
      sum / diag
    } else {
      0.0
    }
    x.set(i, sol)
  }

  x
}
