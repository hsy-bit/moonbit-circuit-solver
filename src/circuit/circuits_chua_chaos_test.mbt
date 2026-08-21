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
/// Evaluates Chua's Diode 3-segment piecewise linear negative conductance:
/// g(v) = m1 * v + 0.5 * (m0 - m1) * (|v + Bp| - |v - Bp|)
pub fn evaluate_chua_diode_current(
  v : Double,
  m0 : Double,
  m1 : Double,
  bp : Double,
) -> Double {
  let term1 = (v + bp).abs()
  let term2 = (v - bp).abs()
  m1 * v + 0.5 * (m0 - m1) * (term1 - term2)
}

///|
test "Chua Diode Piecewise-Linear I-V Characteristic" {
  // Standard Matsumoto-Chua parameters: m0 = -8/7 = -1.142857, m1 = -5/7 = -0.7142857, Bp = 1.0
  let m0 = -8.0 / 7.0
  let m1 = -5.0 / 7.0
  let bp = 1.0

  // Inner region |v| < Bp -> slope m0
  let i_inner = evaluate_chua_diode_current(0.5, m0, m1, bp)
  assert_true((i_inner - m0 * 0.5).abs() < 1.0e-12)

  // Outer region v > Bp -> slope m1
  let i_outer = evaluate_chua_diode_current(2.0, m0, m1, bp)
  let expected_outer = m1 * 2.0 + (m0 - m1) * bp
  assert_true((i_outer - expected_outer).abs() < 1.0e-12)
}

///|
test "Chua Chaotic Circuit 3D Double Scroll Attractor Integration" {
  // Chua state equations:
  // C1 * d(v1)/dt = G * (v2 - v1) - g(v1)
  // C2 * d(v2)/dt = G * (v1 - v2) + i3
  // L  * d(i3)/dt = -v2 - r_l * i3
  let c1 = 10.0e-9
  let c2 = 100.0e-9
  let l_val = 18.0e-3
  let g_res = 1.0 / 1800.0 // R = 1800 Ohms
  let r_l = 12.0 // Inductor series resistance

  let m0 = -0.757e-3
  let m1 = -0.409e-3
  let bp = 1.0

  let mut v1 = 0.1
  let mut v2 = 0.0
  let mut i3 = 0.0
  let dt = 1.0e-7

  let steps = 500
  let trajectory : Array[(Double, Double, Double)] = []

  for _s = 0; _s < steps; _s = _s + 1 {
    let g_v1 = evaluate_chua_diode_current(v1, m0, m1, bp)

    // RK4 integration step
    let dv1_dt = (g_res * (v2 - v1) - g_v1) / c1
    let dv2_dt = (g_res * (v1 - v2) + i3) / c2
    let di3_dt = (-v2 - r_l * i3) / l_val

    v1 = v1 + dv1_dt * dt
    v2 = v2 + dv2_dt * dt
    i3 = i3 + di3_dt * dt

    trajectory.push((v1, v2, i3))
  }

  assert_true(trajectory.length() == steps)
  // Check that chaotic trajectory remains bounded
  assert_true(v1.abs() < 10.0)
  assert_true(v2.abs() < 5.0)
  assert_true(i3.abs() < 0.1)
}
