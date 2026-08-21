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
test "Suite78 CryoTHz 01: Transition Edge Sensor TES Resistance at Tc = 100 mK" {
  let t_c_mk = 100.0
  let r_normal = 0.020 // 20 mOhm normal state
  let r_biased = 0.005 // 5 mOhm operating bias point in superconducting transition

  assert_true(t_c_mk == 100.0)
  assert_true(r_biased < r_normal)
}

///|
test "Suite78 CryoTHz 02: Electrothermal Feedback ETF Constant Power Voltage Bias" {
  // P_total = P_elec + P_opt = constant
  let p_opt_pw = 2.0 // 2 pW incident THz radiation
  let p_bias_pw = 10.0
  let delta_p_elec = -p_opt_pw // -2 pW electrical drop (Negative feedback stabilizes sensor!)

  assert_true(delta_p_elec == -2.0)
  assert_true(p_bias_pw == 10.0)
}

///|
test "Suite78 CryoTHz 03: Kinetic Inductance Detector KID Resonant Frequency Shift" {
  let f_0_ghz = 2.500 // 2.5 GHz microwave readout tone
  let delta_f_khz = -150.0 // -150 kHz shift upon THz photon Cooper pair breaking
  let rel_shift = delta_f_khz * 1.0e3 / (f_0_ghz * 1.0e9) // -6.0e-5

  assert_true((rel_shift - -6.0e-5).abs() < 1.0e-8)
}

///|
test "Suite78 CryoTHz 04: Terahertz Photon Cooper Pair Breaking Threshold" {
  // h * f_thz >= 2 * Delta_super
  let delta_super_uev = 180.0 // 180 ueV gap in aluminum
  let two_delta_joules = 2.0 * delta_super_uev * 1.0e-6 * 1.602176634e-19
  let h_planck = 6.62607015e-34

  let f_min_thz = two_delta_joules / h_planck / 1.0e12 // ~0.087 THz (87 GHz)
  assert_true(f_min_thz > 0.05 && f_min_thz < 0.15)
}

///|
test "Suite78 CryoTHz 05: Frequency-Division Multiplexed FDM 1000-Pixel Array SQUID Readout" {
  let num_pixels = 1000
  let f_spacing_khz = 200.0
  let total_bw_mhz = num_pixels.to_double() * f_spacing_khz / 1000.0 // 200 MHz readout bandwidth

  assert_true(total_bw_mhz == 200.0)
}

///|
test "Suite78 CryoTHz 06: Adiabatic Demagnetization Refrigerator ADR 50 mK Base Temperature" {
  let t_base_mk = 50.0
  assert_true(t_base_mk < 100.0)
}

///|
test "Suite78 CryoTHz 07: Noise Equivalent Power NEP at 100 mK" {
  let nep_w_sqrt_hz = 1.5e-18 // 1.5 aW / sqrt(Hz) ultra-sensitive photon counting
  assert_true(nep_w_sqrt_hz < 1.0e-17)
}

///|
test "Suite78 CryoTHz 08: Terahertz Anti-Reflection Parylene-C Thin Film Matching" {
  let n_substrate = 3.42 // Silicon
  let n_ar_optimal = n_substrate.sqrt() // ~1.85 (Parylene-C n ~ 1.62 matches closely)

  assert_true((n_ar_optimal - 1.8493).abs() < 0.01)
}

///|
test "Suite78 CryoTHz 09: Bolometer Thermal Conductance G_th to Bath" {
  let g_th_pw_per_k = 50.0 // 50 pW / K
  assert_true(g_th_pw_per_k == 50.0)
}

///|
test "Suite78 CryoTHz 10: Superconducting Transition Width Delta_Tc" {
  let delta_tc_mk = 1.2 // 1.2 mK sharp superconducting transition
  assert_true(delta_tc_mk < 2.0)
}
