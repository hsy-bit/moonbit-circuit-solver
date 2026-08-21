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
test "Suite26 HVDC 01: 12-Pulse Graetz Bridge DC Voltage Profile" {
  // V_dc = (6 * sqrt(2) / pi) * V_LL * cos(alpha)
  let v_ll_rms = 400.0e3 // 400 kV AC line-to-line
  let alpha_firing_deg = 15.0
  let alpha_rad = alpha_firing_deg * @math.PI / 180.0

  let v_dc_ideal = 6.0 * 2.0.sqrt() / @math.PI * v_ll_rms * @math.cos(alpha_rad)
  assert_true(v_dc_ideal > 1.0e6 && v_dc_ideal < 1.1e6) // ~1.044 MV DC
}

///|
test "Suite26 HVDC 02: MMC Modular Multilevel Converter 100-Submodule Voltage Balancing" {
  let num_submodules = 100
  let v_dc_bus = 500.0e3 // 500 kV DC link
  let v_sm_nom = v_dc_bus / num_submodules.to_double() // 5 kV per submodule

  assert_true((v_sm_nom - 5000.0).abs() < 1.0e-6)
  assert_true(num_submodules == 100)
}

///|
test "Suite26 HVDC 03: Hybrid DC Circuit Breaker 5 ms Interruption" {
  let t_clear_ms = 3.0 // 3 milliseconds ultrafast clearance
  let i_fault_peak = 15.0e3 // 15 kA fault current
  let e_absorbed_mj = 12.5 // 12.5 Megajoules absorbed by zinc oxide surge arrester stack

  assert_true(t_clear_ms < 5.0)
  assert_true(i_fault_peak == 15.0e3)
  assert_true(e_absorbed_mj > 10.0)
}

///|
test "Suite26 HVDC 04: HVDC Smoothing Reactor di/dt Current Rate of Rise" {
  // di/dt = V_dc / L_smooth
  let v_dc = 500.0e3
  let l_smooth = 0.300 // 300 mH air-core smoothing reactor

  let di_dt = v_dc / l_smooth // ~1.67 MA/s = 1.67 A/us
  assert_true((di_dt - 1.666667e6).abs() < 1.0e2)
}

///|
test "Suite26 HVDC 05: LCC Inverter Commutation Margin Angle Gamma Control" {
  // Extinction angle gamma = 180 - alpha - u >= 15 degrees to prevent commutation failure
  let alpha = 145.0 // Inverter mode
  let overlap_u = 18.0 // 18 deg overlap

  let gamma_angle = 180.0 - alpha - overlap_u // 17 degrees >= 15 degrees
  assert_true(gamma_angle >= 15.0)
}

///|
test "Suite26 HVDC 06: STATCOM Reactive Power Compensation Q" {
  // Q = (V_statcom * V_grid / X_coupling) * sin(delta) approx (V_s - V_g)*V_g / X
  let v_grid = 230.0e3
  let v_statcom = 235.0e3 // Boosting voltage
  let x_coupling = 5.0 // 5 Ohms

  let q_var = (v_statcom - v_grid) * v_grid / x_coupling // 230 MVAR capacitive support
  assert_true(q_var > 200.0e6)
}

///|
test "Suite26 HVDC 07: Multi-Terminal HVDC Droop Control Current Sharing" {
  // I_i = (V_dc_meas - V_dc_ref) / R_droop
  let v_ref = 500.0e3
  let v_meas = 495.0e3 // 5 kV voltage dip
  let r_droop = 2.0 // 2 V / A droop characteristic

  let i_injected = (v_ref - v_meas) / r_droop // 2500 A
  assert_true((i_injected - 2500.0).abs() < 1.0e-6)
}

///|
test "Suite26 HVDC 08: 5th and 7th AC Harmonic Trap Filters Resonant Tuning" {
  let f_fund = 50.0 // 50 Hz grid
  let f_5th = 5.0 * f_fund // 250 Hz
  let f_7th = 7.0 * f_fund // 350 Hz

  // C = 10 uF -> L_5th = 1 / ( (2*pi*250)^2 * 10uF )
  let c_filt = 10.0e-6
  let omega_5th = 2.0 * @math.PI * f_5th
  let l_5th = 1.0 / (omega_5th * omega_5th * c_filt) // ~40.5 mH

  assert_true(f_5th == 250.0)
  assert_true(f_7th == 350.0)
  assert_true(l_5th > 0.035 && l_5th < 0.045)
}

///|
test "Suite26 HVDC 09: Bipolar Metallic Return Neutral Current Imbalance" {
  let i_pos_pole = 2000.0 // 2000 A positive pole
  let i_neg_pole = 1980.0 // 1980 A negative pole (1% imbalance)

  let i_neutral = (i_pos_pole - i_neg_pole).abs() // 20 A in ground / metallic return
  assert_true(i_neutral == 20.0)
}

///|
test "Suite26 HVDC 10: UPFC Unified Power Flow Controller Phase Angle Injection" {
  let v_line = 500.0e3
  let v_inj_quad = 50.0e3 // 50 kV in quadrature (+90 deg)

  let v_resultant = (v_line * v_line + v_inj_quad * v_inj_quad).sqrt()
  let phase_shift_deg = @math.atan2(v_inj_quad, v_line) * 180.0 / @math.PI

  assert_true(v_resultant > v_line)
  assert_true(phase_shift_deg > 5.0 && phase_shift_deg < 6.0) // ~5.71 degrees phase advance
}
