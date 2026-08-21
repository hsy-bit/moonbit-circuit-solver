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
/// Result of Periodic Steady State (PSS) Shooting simulation.
pub struct PssResult {
  period : Double
  converged : Bool
  shooting_iterations : Int
  limit_cycle_samples : Array[(Double, Double)] // (time, output_voltage) pairs
} derive(Eq, Debug)

///|
/// Solves Periodic Steady-State (PSS) of driven non-linear circuit with period T.
pub fn solve_pss_shooting(
  period : Double,
  samples_per_period : Int,
  max_shooting_iters : Int,
  tol : Double,
) -> PssResult {
  let dt = period / samples_per_period.to_double()
  let samples : Array[(Double, Double)] = []

  let mut current_state = 0.0
  let mut converged = false
  let mut iters = 0

  for shoot_iter = 0
      shoot_iter < max_shooting_iters
      shoot_iter = shoot_iter + 1 {
    iters = shoot_iter + 1
    let x0 = current_state
    let mut x = x0

    // Integrate one full period [0, T]
    for step = 0; step < samples_per_period; step = step + 1 {
      let t = step.to_double() * dt
      let drive = @math.sin(2.0 * @math.PI * t / period)
      // Non-linear autonomous/driven state update: dx/dt = -x + tanh(drive)
      let dx = -x + @math.tanh(drive * 2.0)
      x = x + dx * dt
    }

    let x_end = x
    let diff = x_end - x0
    let abs_diff = if diff < 0.0 { -diff } else { diff }

    if abs_diff < tol {
      converged = true
      // Record steady-state limit cycle
      let mut rec_x = x0
      for step = 0; step < samples_per_period; step = step + 1 {
        let t = step.to_double() * dt
        let drive = @math.sin(2.0 * @math.PI * t / period)
        let dx = -rec_x + @math.tanh(drive * 2.0)
        rec_x = rec_x + dx * dt
        samples.push((t, rec_x))
      }
      break
    }

    // Shooting Newton correction: x0_new = x0 - (dPhi/dx0 - I)^-1 * (x_end - x0)
    let dphi_dx = @math.exp(-period) // Sensitivity derivative
    let correction = diff / (dphi_dx - 1.0)
    current_state = current_state - correction
  }

  {
    period,
    converged,
    shooting_iterations: iters,
    limit_cycle_samples: samples,
  }
}
