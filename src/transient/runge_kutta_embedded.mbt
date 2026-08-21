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
/// Cash-Karp Embedded 5(4) Runge-Kutta Step Result.
pub struct EmbeddedRkStep {
  y_next : @linalg.Vector
  error_estimate : Double
  suggested_dt : Double
  is_accepted : Bool
} derive(Eq, Debug)

///|
/// Evaluates Cash-Karp 5(4) adaptive single step for ODE system dy/dt = f(t, y).
pub fn cash_karp_step(
  f_deriv : (Double, @linalg.Vector) -> @linalg.Vector,
  t : Double,
  y : @linalg.Vector,
  dt : Double,
  rel_tol : Double,
  abs_tol : Double,
) -> EmbeddedRkStep {
  // Cash-Karp Butcher Tableau coefficients
  let k1 = f_deriv(t, y)

  // k2 = f(t + a2*dt, y + dt * b21*k1) where a2 = 1/5, b21 = 1/5
  let y_stage2 = y.add(k1.scale(dt * 0.2))
  let k2 = f_deriv(t + 0.2 * dt, y_stage2)

  // k3 = f(t + a3*dt, y + dt * (b31*k1 + b32*k2))
  // a3 = 3/10, b31 = 3/40, b32 = 9/40
  let y_stage3 = y
    .add(k1.scale(dt * (3.0 / 40.0)))
    .add(k2.scale(dt * (9.0 / 40.0)))
  let k3 = f_deriv(t + 0.3 * dt, y_stage3)

  // k4 = f(t + a4*dt, y + dt * (b41*k1 + b42*k2 + b43*k3))
  // a4 = 3/5, b41 = 3/10, b42 = -9/10, b43 = 6/5
  let y_stage4 = y
    .add(k1.scale(dt * 0.3))
    .add(k2.scale(dt * -0.9))
    .add(k3.scale(dt * 1.2))
  let k4 = f_deriv(t + 0.6 * dt, y_stage4)

  // k5 = f(t + a5*dt, y + dt * (b51*k1 + b52*k2 + b53*k3 + b54*k4))
  // a5 = 1, b51 = -11/54, b52 = 5/2, b53 = -70/27, b54 = 35/27
  let y_stage5 = y
    .add(k1.scale(dt * (-11.0 / 54.0)))
    .add(k2.scale(dt * 2.5))
    .add(k3.scale(dt * (-70.0 / 27.0)))
    .add(k4.scale(dt * (35.0 / 27.0)))
  let k5 = f_deriv(t + dt, y_stage5)

  // k6 = f(t + a6*dt, y + dt * (b61*k1 + b62*k2 + b63*k3 + b64*k4 + b65*k5))
  // a6 = 7/8, b61 = 1631/55296, b62 = 175/512, b63 = 575/13824, b64 = 44275/110592, b65 = 253/4096
  let y_stage6 = y
    .add(k1.scale(dt * (1631.0 / 55296.0)))
    .add(k2.scale(dt * (175.0 / 512.0)))
    .add(k3.scale(dt * (575.0 / 13824.0)))
    .add(k4.scale(dt * (44275.0 / 110592.0)))
    .add(k5.scale(dt * (253.0 / 4096.0)))
  let k6 = f_deriv(t + 0.875 * dt, y_stage6)

  // 5th-order solution: y5 = y + dt * (37/378*k1 + 250/621*k3 + 125/594*k4 + 512/1771*k6)
  let y5 = y
    .add(k1.scale(dt * (37.0 / 378.0)))
    .add(k3.scale(dt * (250.0 / 621.0)))
    .add(k4.scale(dt * (125.0 / 594.0)))
    .add(k6.scale(dt * (512.0 / 1771.0)))

  // 4th-order embedded solution: y4 = y + dt * (2825/27648*k1 + 18575/48384*k3 + 13525/55296*k4 + 277/14336*k5 + 1/4*k6)
  let y4 = y
    .add(k1.scale(dt * (2825.0 / 27648.0)))
    .add(k3.scale(dt * (18575.0 / 48384.0)))
    .add(k4.scale(dt * (13525.0 / 55296.0)))
    .add(k5.scale(dt * (277.0 / 14336.0)))
    .add(k6.scale(dt * 0.25))

  // Local truncation error estimate: LTE = ||y5 - y4||
  let err_vec = y5.sub(y4)
  let err_norm = err_vec.norm_l2()

  let tol_sc = abs_tol + rel_tol * y5.norm_l2()
  let safe_tol = if tol_sc > 1.0e-15 { tol_sc } else { 1.0e-15 }

  let error_ratio = err_norm / safe_tol
  let is_accepted = error_ratio <= 1.0

  // Optimal timestep scaling with safety factor 0.90
  let factor = 0.90 *
    @math.pow(
      1.0 / (if error_ratio > 1.0e-4 { error_ratio } else { 1.0e-4 }),
      0.20,
    )
  let clamped_factor = if factor > 5.0 {
    5.0
  } else if factor < 0.2 {
    0.2
  } else {
    factor
  }
  let suggested_dt = dt * clamped_factor

  {
    y_next: if is_accepted {
      y5
    } else {
      y
    },
    error_estimate: err_norm,
    suggested_dt,
    is_accepted,
  }
}
