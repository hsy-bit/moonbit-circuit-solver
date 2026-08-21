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
/// Continuous-Time Linear State-Space Circuit Model:
/// dx/dt = A * x(t) + B * u(t)
/// y(t)  = C * x(t) + D * u(t)
pub struct StateSpaceModel {
  a_mat : @linalg.Matrix
  b_mat : @linalg.Matrix
  c_mat : @linalg.Matrix
  d_mat : @linalg.Matrix
  num_states : Int
  num_inputs : Int
  num_outputs : Int
} derive(Eq, Debug)

///|
/// Creates a new StateSpaceModel.
pub fn StateSpaceModel::new(
  a_mat : @linalg.Matrix,
  b_mat : @linalg.Matrix,
  c_mat : @linalg.Matrix,
  d_mat : @linalg.Matrix,
) -> StateSpaceModel {
  {
    a_mat,
    b_mat,
    c_mat,
    d_mat,
    num_states: a_mat.num_rows(),
    num_inputs: b_mat.num_cols(),
    num_outputs: c_mat.num_rows(),
  }
}

///|
/// Computes matrix exponential exp(A) using [6/6] Padé approximation with scaling and squaring.
pub fn compute_matrix_exp(mat : @linalg.Matrix) -> @linalg.Matrix {
  let n = mat.num_rows()
  let norm_inf = mat.norm_inf()

  // Find scaling factor 2^s such that ||A / 2^s|| <= 0.5
  let mut s = 0
  let mut scaled_norm = norm_inf
  while scaled_norm > 0.5 && s < 25 {
    scaled_norm = scaled_norm / 2.0
    s = s + 1
  }

  let scale_factor = @math.pow(2.0, -s.to_double())
  let a_scaled = mat.scale(scale_factor)

  // Compute powers A^2, A^3, A^4, A^6
  let a2 = a_scaled.multiply(a_scaled)
  let a4 = a2.multiply(a2)
  let a6 = a4.multiply(a2)

  // Padé coefficients for degree 6:
  // c0 = 1, c1 = 1/2, c2 = 5/44, c3 = 1/66, c4 = 1/792, c5 = 1/15840, c6 = 1/665280
  let ident = @linalg.Matrix::identity(n)

  // U = A * (c1*I + c3*A^2 + c5*A^4)
  let u_inner = ident
    .scale(0.5)
    .add(a2.scale(1.0 / 66.0))
    .add(a4.scale(1.0 / 15840.0))
  let u_mat = a_scaled.multiply(u_inner)

  // V = c0*I + c2*A^2 + c4*A^4 + c6*A^6
  let v_mat = ident
    .add(a2.scale(5.0 / 44.0))
    .add(a4.scale(1.0 / 792.0))
    .add(a6.scale(1.0 / 665280.0))

  // Padé approximation R_6,6 = (V - U)^-1 * (V + U)
  let numerator = v_mat.add(u_mat)
  let denominator = v_mat.sub(u_mat)

  let inv_denom = match @linalg.compute_matrix_inverse(denominator) {
    Some(inv) => inv
    None => @linalg.Matrix::identity(n)
  }

  let mut exp_scaled = inv_denom.multiply(numerator)

  // Squaring step: exp(A) = (exp(A / 2^s))^(2^s)
  for _k in 0..<s {
    exp_scaled = exp_scaled.multiply(exp_scaled)
  }

  exp_scaled
}

///|
/// Discretizes continuous-time state-space system with zero-order hold (ZOH) at sampling interval dt:
/// x_{k+1} = A_d * x_k + B_d * u_k
/// y_k     = C * x_k + D * u_k
pub fn discretize_state_space_zoh(
  model : StateSpaceModel,
  dt : Double,
) -> (@linalg.Matrix, @linalg.Matrix) {
  let n = model.num_states
  let m = model.num_inputs

  // Construct augmented matrix M = [ A  B ] * dt
  //                                [ 0  0 ]
  let total_dim = n + m
  let m_aug = @linalg.Matrix::zeros(total_dim, total_dim)

  for r in 0..<n {
    for c in 0..<n {
      m_aug.set(r, c, model.a_mat.get(r, c) * dt)
    }
    for c in 0..<m {
      m_aug.set(r, n + c, model.b_mat.get(r, c) * dt)
    }
  }

  let exp_m = compute_matrix_exp(m_aug)

  // Extract A_d = exp_M[0..n, 0..n] and B_d = exp_M[0..n, n..n+m]
  let a_d = @linalg.Matrix::zeros(n, n)
  let b_d = @linalg.Matrix::zeros(n, m)

  for r in 0..<n {
    for c in 0..<n {
      a_d.set(r, c, exp_m.get(r, c))
    }
    for c in 0..<m {
      b_d.set(r, c, exp_m.get(r, n + c))
    }
  }

  (a_d, b_d)
}

///|
/// Simulates discrete-time state-space trajectory given initial state x0 and input sequence u_traj.
pub fn simulate_state_space(
  model : StateSpaceModel,
  x0 : @linalg.Vector,
  u_traj : Array[@linalg.Vector],
  dt : Double,
) -> Array[@linalg.Vector] {
  let (a_d, b_d) = discretize_state_space_zoh(model, dt)
  let y_outputs : Array[@linalg.Vector] = []
  let mut x = x0.copy()

  for k = 0; k < u_traj.length(); k = k + 1 {
    let u = u_traj[k]
    // Output: y_k = C * x_k + D * u_k
    let cx = model.c_mat.multiply_vector(x)
    let du = model.d_mat.multiply_vector(u)
    let y = cx.add(du)
    y_outputs.push(y)

    // State update: x_{k+1} = A_d * x_k + B_d * u_k
    let ax = a_d.multiply_vector(x)
    let bu = b_d.multiply_vector(u)
    x = ax.add(bu)
  }

  y_outputs
}
