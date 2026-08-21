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
test "Suite41 Grid 01: IEEE 14-Bus Power Flow Nodal Admittance Matrix Y_bus" {
  // Y_bus diagonal: Y_ii = y_shunt + sum_{j != i} y_ij
  // Off-diagonal: Y_ij = - y_ij
  let n_buses = 14
  let y_line = @linalg.Complex::new(2.0, -10.0) // Line admittance (g + jb)

  let y_diag = y_line.scale(3.0) // 3 connected lines
  let y_off = y_line.scale(-1.0)

  assert_true(n_buses == 14)
  assert_true((y_off.re - -2.0).abs() < 1.0e-12)
  assert_true((y_off.im - 10.0).abs() < 1.0e-12)
  assert_true((y_diag.re - 6.0).abs() < 1.0e-12)
}

///|
test "Suite41 Grid 02: Newton-Raphson Power Flow Active Power Injection P_i" {
  // P_i = |V_i| * sum_j |V_j| * (G_ij * cos(theta_i - theta_j) + B_ij * sin(theta_i - theta_j))
  let v1_mag = 1.0
  let v2_mag = 1.0
  let delta_12 = 0.087266 // 5 degrees in radians
  let g12 = 2.0
  let b12 = -10.0

  let p12 = v1_mag *
    v2_mag *
    (g12 * @math.cos(delta_12) + b12 * @math.sin(delta_12))
  // 1.0 * (2 * 0.9962 - 10 * 0.08715) = 1.9924 - 0.8715 = 1.1209 pu
  assert_true((p12 - 1.1209).abs() < 0.01)
}

///|
test "Suite41 Grid 03: Transformer On-Load Tap Changer OLTC Voltage Regulation" {
  // V_secondary = V_primary * (1 + tap_step * N)
  let v_prim = 110.0e3 // 110 kV
  let tap_step = 0.0125 // 1.25% per tap
  let tap_position = 4 // +4 taps (+5.0%)

  let v_sec = v_prim * (1.0 + tap_step * tap_position.to_double()) // 110k * 1.05 = 115.5 kV
  assert_true((v_sec - 115.5e3).abs() < 1.0)
}

///|
test "Suite41 Grid 04: Slack Bus Power Balance and Reference Angle Delta_0 = 0" {
  let delta_slack = 0.0 // Reference angle fixed to 0.0
  let v_slack_pu = 1.05 // Slack voltage fixed to 1.05 pu
  assert_true(delta_slack == 0.0)
  assert_true(v_slack_pu == 1.05)
}

///|
test "Suite41 Grid 05: Transmission Line Surge Impedance Loading SIL" {
  // SIL = V_LL^2 / Z_0
  let v_ll_kv = 500.0 // 500 kV line
  let z_0_ohm = 250.0 // 250 Ohm surge impedance

  let sil_mw = v_ll_kv * v_ll_kv / z_0_ohm // 250,000 / 250 = 1000 MW
  assert_true((sil_mw - 1000.0).abs() < 1.0e-6)
}

///|
test "Suite41 Grid 06: PV Bus Reactive Power Q Limit Checking" {
  let q_min = -50.0 // -50 MVAR
  let q_max = 100.0 // +100 MVAR
  let q_calc = 120.0 // Exceeds limit -> Converted to PQ bus with Q = Q_max!

  let q_clamped = if q_calc > q_max {
    q_max
  } else if q_calc < q_min {
    q_min
  } else {
    q_calc
  }
  assert_true(q_clamped == 100.0)
}

///|
test "Suite41 Grid 07: 3-Phase Symmetrical Short-Circuit Fault Current I_sc" {
  // I_sc = V_pre / Z_thevenin
  let v_pre_ln = 230.0e3 / 3.0.sqrt() // 132.79 kV line-to-neutral
  let z_th = 4.0 // 4 Ohms Thevenin short-circuit reactance

  let i_sc_ka = v_pre_ln / z_th / 1000.0 // ~33.20 kA
  assert_true((i_sc_ka - 33.197).abs() < 0.01)
}

///|
test "Suite41 Grid 08: Ferranti Effect Open-Circuit Receiving-End Voltage Rise" {
  // V_rx = V_tx / cos(beta * l) approx V_tx * (1 + 0.5 * beta^2 * l^2)
  let beta_l = 0.15 // 0.15 radians
  let v_tx = 400.0e3

  let v_rx = v_tx / @math.cos(beta_l) // 400k / 0.98877 = 404.54 kV
  assert_true(v_rx > v_tx)
  assert_true((v_rx - 404543.0).abs() < 100.0)
}

///|
test "Suite41 Grid 09: Power System Stabilizer PSS Phase Compensation Lead Lag" {
  let f_osc = 1.0 // 1.0 Hz inter-area electromechanical oscillation
  let lead_angle_deg = 35.0 // +35 degrees damping lead phase
  assert_true(f_osc == 1.0)
  assert_true(lead_angle_deg == 35.0)
}

///|
test "Suite41 Grid 10: Automatic Generation Control AGC Area Control Error ACE" {
  // ACE = (P_actual - P_scheduled) + 10 * B * (f_actual - f_scheduled)
  let delta_p_mw = 25.0
  let beta_freq_bias = 20.0 // MW / 0.1 Hz = 200 MW / Hz
  let delta_f_hz = -0.05 // -0.05 Hz frequency drop

  let ace_mw = delta_p_mw + 10.0 * beta_freq_bias * delta_f_hz // 25 + 200 * (-0.05) = 25 - 10 = 15 MW
  assert_true((ace_mw - 15.0).abs() < 1.0e-6)
}
