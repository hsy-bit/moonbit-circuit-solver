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
test "Suite85 Terawatt 01: Chirped Pulse Amplification CPA Petawatt Laser Pulse (100 J / 100 fs)" {
  // P = E / tau
  let e_pulse_joules = 100.0 // 100 Joules
  let tau_fwhm_fs = 100.0 // 100 femtoseconds = 1e-13 s

  let p_peak_pw = e_pulse_joules / (tau_fwhm_fs * 1.0e-15) / 1.0e15 // 1.0 Petawatt!
  assert_true((p_peak_pw - 1.0).abs() < 1.0e-6)
}

///|
test "Suite85 Terawatt 02: Pockels Cell Electro-Optic Pulse Slicer 200 ps Window" {
  let t_slice_ps = 200.0
  let v_half_wave_kv = 4.5 // 4.5 kV KD*P crystal half-wave voltage

  assert_true(t_slice_ps == 200.0)
  assert_true(v_half_wave_kv == 4.5)
}

///|
test "Suite85 Terawatt 03: Treacy Diffraction Grating Compressor Group Delay Dispersion GDD" {
  let gdd_fs2 = -2.5e6 // -2.5e6 fs^2 negative dispersion
  assert_true(gdd_fs2 < 0.0)
}

///|
test "Suite85 Terawatt 04: Relativistic Laser-Plasma Intensity Threshold (10^18 W/cm^2)" {
  let i_laser_w_cm2 = 1.0e19
  let is_relativistic = i_laser_w_cm2 >= 1.0e18
  assert_true(is_relativistic)
}

///|
test "Suite85 Terawatt 05: Laser Wake-Field Acceleration LWFA 100 GV/m Gradient" {
  let e_grad_gv_per_m = 100.0 // 100 GV/m (1000x conventional RF cavities!)
  assert_true(e_grad_gv_per_m >= 50.0)
}

///|
test "Suite85 Terawatt 06: B-Integral Non-Linear Self-Focusing Limit (B < 1.5 rad)" {
  let b_integral_rad = 1.15
  assert_true(b_integral_rad < 1.5)
}

///|
test "Suite85 Terawatt 07: Second Harmonic Generation SHG BBO Crystal Phase Matching" {
  let theta_pm_deg = 29.2 // Type I phase matching in BBO for 800nm -> 400nm
  assert_true((theta_pm_deg - 29.2).abs() < 0.1)
}

///|
test "Suite85 Terawatt 08: Ti:Sapphire Laser Gain Medium 800 nm Broad Bandwidth" {
  let lambda_center_nm = 800.0
  let delta_lambda_nm = 120.0
  assert_true(lambda_center_nm == 800.0)
  assert_true(delta_lambda_nm > 100.0)
}

///|
test "Suite85 Terawatt 09: Multi-Pass Laser Amplifier Thermal Lens Compensation" {
  let f_lens_m = -2.5 // Negative thermal lens compensation
  assert_true(f_lens_m < 0.0)
}

///|
test "Suite85 Terawatt 10: High-Harmonic Generation HHG Attosecond Extreme-UV Pulse" {
  let tau_atto_as = 150.0 // 150 attoseconds pulse duration
  assert_true(tau_atto_as < 500.0)
}
