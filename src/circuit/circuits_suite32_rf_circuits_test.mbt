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
test "Suite32 RF 01: Cross-Coupled LC Oscillator Negative Resistance Startup" {
  // Tank parallel equivalent resistance R_p = Q^2 * R_s = 20^2 * 1.5 = 600 Ohms
  // Startup condition: gm >= 2 / R_p = 2 / 600 = 3.33 mS
  let r_p = 600.0
  let gm_required = 2.0 / r_p // 3.33 mS
  let gm_actual = 8.0e-3 // 8.0 mS (Safety margin > 2.0)

  assert_true(gm_actual > gm_required)
  assert_true((gm_required - 0.003333).abs() < 1.0e-5)
}

///|
test "Suite32 RF 02: Varactor Diode LC VCO Tuning Range and Kvco" {
  let f_min = 2.40e9 // 2.40 GHz at V_ctrl = 0V
  let f_max = 2.48e9 // 2.48 GHz at V_ctrl = 1.8V

  let kvco = (f_max - f_min) / 1.8 // 44.44 MHz / V
  assert_true((kvco - 44.444e6).abs() < 1.0e4)
}

///|
test "Suite32 RF 03: Class-E High Efficiency Power Amplifier Optimal Load" {
  // R_opt = 0.5768 * Vdd^2 / P_out
  let vdd = 3.3
  let p_out = 0.100 // 100 mW (+20 dBm)

  let r_opt = 0.5768 * (vdd * vdd) / p_out // 62.8 Ohms
  assert_true((r_opt - 62.81).abs() < 0.1)
}

///|
test "Suite32 RF 04: Class-F 3rd Harmonic Voltage Squaring Efficiency" {
  // Ideal Class-F efficiency = 88.4% (with 3rd harmonic trap shorting even and peaking odd)
  let eff_ideal = 0.884
  assert_true(eff_ideal > 0.85)
}

///|
test "Suite32 RF 05: Gilbert Cell Mixer Conversion Gain" {
  // CG = (2 / pi) * gm * R_L
  let gm_rf = 10.0e-3 // 10 mS
  let r_load = 500.0 // 500 Ohm load

  let conversion_gain = 2.0 / @math.PI * gm_rf * r_load // ~3.18 (approx +10 dB)
  assert_true((conversion_gain - 3.183).abs() < 0.01)
}

///|
test "Suite32 RF 06: Branchline 90-Degree Hybrid Coupler Power Split" {
  // S21 = -j / sqrt(2), S31 = -1 / sqrt(2) -> Equal 3 dB power split with 90 degree phase difference
  let s21_power = 0.5
  let s31_power = 0.5
  let total_power = s21_power + s31_power

  assert_true(total_power == 1.0)
}

///|
test "Suite32 RF 07: Rat-Race 180-Degree Hybrid Coupler Sum and Delta Ports" {
  let s_sum = 0.707106
  let s_delta = 0.707106
  assert_true((s_sum * s_sum + s_delta * s_delta - 1.0).abs() < 1.0e-5)
}

///|
test "Suite32 RF 08: Friis 3-Stage Cascaded Noise Figure" {
  // F_tot = F1 + (F2 - 1)/G1 + (F3 - 1)/(G1 * G2)
  let f1 = 1.5 // 1.76 dB NF
  let g1 = 10.0 // 10 dB gain
  let f2 = 4.0 // 6 dB NF
  let g2 = 10.0 // 10 dB gain
  let f3 = 10.0 // 10 dB NF

  let f_tot = f1 + (f2 - 1.0) / g1 + (f3 - 1.0) / (g1 * g2) // 1.5 + 0.3 + 0.09 = 1.89
  assert_true((f_tot - 1.89).abs() < 1.0e-6)
}

///|
test "Suite32 RF 09: Inductive Source Degeneration 50-Ohm Input Match" {
  // R_in = (gm / Cgs) * Ls = omega_T * Ls = 50 Ohms (No noisy physical resistor needed!)
  let gm = 25.0e-3 // 25 mS
  let c_gs = 200.0e-15 // 200 fF -> omega_T = 125 Grad/s
  let l_s = 400.0e-12 // 400 pH degeneration inductor

  let r_in_match = gm / c_gs * l_s // 50.0 Ohms
  assert_true((r_in_match - 50.0).abs() < 1.0e-6)
}

///|
test "Suite32 RF 10: IIP3 and 1dB Compression Point Relationship" {
  let p1db_dbm = -10.0 // -10 dBm
  let iip3_dbm = p1db_dbm + 9.6 // -0.4 dBm
  assert_true(iip3_dbm > p1db_dbm)
}
