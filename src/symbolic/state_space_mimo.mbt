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
/// MIMO State-Space Continuous LTI System:
/// dx/dt = A*x + B*u
/// y     = C*x + D*u
pub struct MimoStateSpace {
  a_mat : @linalg.Matrix
  b_mat : @linalg.Matrix
  c_mat : @linalg.Matrix
  d_mat : @linalg.Matrix
  states : Int
  inputs : Int
  outputs : Int
} derive(Eq, Debug)

///|
/// Creates a new MIMO State-Space representation.
pub fn MimoStateSpace::new(
  a : @linalg.Matrix,
  b : @linalg.Matrix,
  c : @linalg.Matrix,
  d : @linalg.Matrix,
) -> MimoStateSpace {
  let states = a.num_rows()
  let inputs = b.num_cols()
  let outputs = c.num_rows()
  MimoStateSpace::{
    a_mat: a,
    b_mat: b,
    c_mat: c,
    d_mat: d,
    states,
    inputs,
    outputs,
  }
}

///|
/// Computes the n x (n*m) Controllability Matrix: C = [B, AB, A^2B, ..., A^(n-1)B].
pub fn MimoStateSpace::controllability_matrix(
  self : MimoStateSpace,
) -> @linalg.Matrix {
  let n = self.states
  let m = self.inputs
  let c_ctrl = @linalg.Matrix::zeros(n, n * m)

  let mut a_k_b = self.b_mat

  for k = 0; k < n; k = k + 1 {
    for r = 0; r < n; r = r + 1 {
      for c = 0; c < m; c = c + 1 {
        c_ctrl.set(r, k * m + c, a_k_b.get(r, c))
      }
    }
    a_k_b = self.a_mat.multiply(a_k_b)
  }

  c_ctrl
}

///|
/// Computes the (n*p) x n Observability Matrix: O = [C; CA; CA^2; ...; CA^(n-1)].
pub fn MimoStateSpace::observability_matrix(
  self : MimoStateSpace,
) -> @linalg.Matrix {
  let n = self.states
  let p = self.outputs
  let o_obs = @linalg.Matrix::zeros(n * p, n)

  let mut c_a_k = self.c_mat

  for k = 0; k < n; k = k + 1 {
    for r = 0; r < p; r = r + 1 {
      for c = 0; c < n; c = c + 1 {
        o_obs.set(k * p + r, c, c_a_k.get(r, c))
      }
    }
    c_a_k = c_a_k.multiply(self.a_mat)
  }

  o_obs
}

///|
/// Evaluates Frequency Response Transfer Matrix H(j*omega) = C * (j*omega*I - A)^(-1) * B + D.
pub fn MimoStateSpace::evaluate_frequency_response(
  self : MimoStateSpace,
  omega : Double,
) -> @linalg.ComplexMatrix {
  let n = self.states
  let s_i_minus_a = @linalg.ComplexMatrix::zeros(n, n)

  for r in 0..<n {
    for c in 0..<n {
      let a_val = self.a_mat.get(r, c)
      if r == c {
        s_i_minus_a.set(r, c, @linalg.Complex::new(-a_val, omega))
      } else {
        s_i_minus_a.set(r, c, @linalg.Complex::new(-a_val, 0.0))
      }
    }
  }

  let inv_resolvent = @linalg.complex_matrix_inverse(s_i_minus_a)

  // Complex C * inv * B + D
  let res = @linalg.ComplexMatrix::zeros(self.outputs, self.inputs)

  for p in 0..<self.outputs {
    for m in 0..<self.inputs {
      let mut sum_val = @linalg.Complex::new(self.d_mat.get(p, m), 0.0)

      for r in 0..<n {
        let c_pr = self.c_mat.get(p, r)
        for c in 0..<n {
          let b_cm = self.b_mat.get(c, m)
          let inv_rc = inv_resolvent.get(r, c)
          let term = inv_rc.scale(c_pr * b_cm)
          sum_val = sum_val.add(term)
        }
      }

      res.set(p, m, sum_val)
    }
  }

  res
}
