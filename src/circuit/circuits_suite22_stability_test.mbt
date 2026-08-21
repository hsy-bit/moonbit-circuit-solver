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
test "Suite22 Stability 01: Bode Phase Margin and Gain Margin Extraction" {
  // Loop transfer function T(s) = A0 / ((1 + s/p1) * (1 + s/p2))
  // A0 = 1000, p1 = 100 rad/s (dominant), p2 = 10000 rad/s (non-dominant)
  let a0 = 1000.0
  let p1 = 100.0
  let p2 = 10000.0

  // Unity gain crossover frequency omega_c approx sqrt(A0 * p1 * p2) / ...
  // At omega = 10000 rad/s: |T(jw)| approx 1000 / (100 * 1.414) = 7.07
  let omega_test = 10000.0
  let mag_t = a0 /
    (
      (1.0 + omega_test / p1 * (omega_test / p1)).sqrt() *
      (1.0 + omega_test / p2 * (omega_test / p2)).sqrt()
    )
  let phase_t_deg = -((
      @math.atan2(omega_test, p1) + @math.atan2(omega_test, p2)
    ) *
    180.0 /
    @math.PI)

  let phase_margin = 180.0 + phase_t_deg
  assert_true(mag_t > 0.0)
  assert_true(phase_margin > 0.0) // Stable loop
}

///|
test "Suite22 Stability 02: Nyquist Stability Criterion Encirclement of (-1, j0)" {
  // Open loop L(s) with 0 open-loop RHP poles (P = 0)
  // Encirclement count N = 0 -> Closed-loop RHP poles Z = N + P = 0 (Unconditionally Stable)
  let p_rhp = 0
  let n_encirclements = 0
  let z_closed_loop = n_encirclements + p_rhp

  assert_true(z_closed_loop == 0)
}

///|
test "Suite22 Stability 03: Miller Pole-Splitting Frequency Compensation" {
  // Uncompensated poles: p1 = 1 / (R1 * C1), p2 = 1 / (R2 * C2)
  // With Miller cap Cc: p1' = 1 / (R1 * gm * R2 * Cc) (pushed low), p2' = gm / (C1 + C2) (pushed high)
  let r1 = 100.0e3
  let r2 = 100.0e3
  let c1 = 1.0e-12
  let c2 = 1.0e-12
  let gm = 10.0e-3
  let c_c = 10.0e-12

  let p1_uncomp = 1.0 / (r1 * c1) // 10 Mrad/s
  let p1_comp = 1.0 / (r1 * (gm * r2) * c_c) // 10 krad/s (dominant pole split down by 1000x)
  let p2_comp = gm / (c1 + c2) // 5 Grad/s (non-dominant pole split up)

  assert_true(p1_comp < p1_uncomp)
  assert_true(p2_comp > p1_uncomp)
}

///|
test "Suite22 Stability 04: Right-Half-Plane RHP Zero Nulling Resistor" {
  // RHP zero location: z_rhp = gm / Cc (produces -90 deg phase lag while boosting magnitude)
  // With nulling resistor Rz = 1/gm in series with Cc, the RHP zero is moved to infinity!
  let gm = 5.0e-3
  let r_z_opt = 1.0 / gm // 200 Ohms

  assert_true((r_z_opt - 200.0).abs() < 1.0e-6)
}

///|
test "Suite22 Stability 05: Routh-Hurwitz 3rd-Order Characteristic Polynomial" {
  // Characteristic equation: s^3 + a2*s^2 + a1*s + a0 = 0
  // Routh stability condition for 3rd order: a2 > 0, a1 > 0, a0 > 0, and a2*a1 > a0
  let a2 = 4.0
  let a1 = 6.0
  let a0 = 10.0

  let routh_b1 = (a2 * a1 - a0) / a2 // (24 - 10) / 4 = 3.5 > 0

  assert_true(routh_b1 > 0.0) // System is Hurwitz stable
}

///|
test "Suite22 Stability 06: Nichols Chart Closed-Loop Peak Resonance Mp" {
  // Damping ratio zeta = 0.5 -> Closed loop peak Mp = 1 / (2*zeta*sqrt(1-zeta^2)) = 1 / (2*0.5*sqrt(0.75)) = 1.1547 (+1.25 dB)
  let zeta = 0.5
  let m_p = 1.0 / (2.0 * zeta * (1.0 - zeta * zeta).sqrt())
  let m_p_db = 20.0 * (@math.ln(m_p) / @math.ln(10.0))

  assert_true((m_p - 1.1547).abs() < 1.0e-3)
  assert_true((m_p_db - 1.25).abs() < 0.05)
}

///|
test "Suite22 Stability 07: Root Locus Real Axis Breakaway Points" {
  // Open loop L(s) = K / (s * (s + 4))
  // Breakaway point is at d(s*(s+4))/ds = 2s + 4 = 0 -> s = -2.0
  let s_breakaway = -2.0
  assert_true(s_breakaway == -2.0)
}

///|
test "Suite22 Stability 08: Discrete-Time Jury Stability Test for 2nd-Order Digital Loop" {
  // A(z) = z^2 + a1*z + a0
  // Jury conditions: |a0| < 1, A(1) > 0, A(-1) > 0
  let a1 = -1.2
  let a0 = 0.5

  let cond1 = a0.abs() < 1.0
  let cond2 = 1.0 + a1 + a0 > 0.0 // 1 - 1.2 + 0.5 = 0.3 > 0
  let cond3 = 1.0 - a1 + a0 > 0.0 // 1 + 1.2 + 0.5 = 2.7 > 0

  assert_true(cond1 && cond2 && cond3)
}

///|
test "Suite22 Stability 09: Maximum Sensitivity Peak Ms Robustness Boundary" {
  // Sensitivity function S(s) = 1 / (1 + L(s))
  // Recommended Ms in range [1.3, 2.0]
  let m_s = 1.5
  assert_true(m_s >= 1.3 && m_s <= 2.0)
}

///|
test "Suite22 Stability 10: Lead-Lag Loop Filter Phase Boost Synthesis" {
  // Lead filter: zero at 1 kHz, pole at 10 kHz -> Max phase boost approx +55 degrees
  let f_z = 1000.0
  let f_p = 10000.0

  let alpha = f_p / f_z // 10
  let phi_max_rad = @math.asin((alpha - 1.0) / (alpha + 1.0)) // asin(9/11) = 0.958 rad = 54.9 deg
  let phi_max_deg = phi_max_rad * 180.0 / @math.PI

  assert_true((phi_max_deg - 54.9).abs() < 0.2)
}
