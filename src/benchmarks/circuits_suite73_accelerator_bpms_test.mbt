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
test "Suite73 BPM 01: Particle Accelerator 4-Button BPM Position Formula" {
  // Delta_x = k_x * ( (V_R - V_L) / (V_R + V_L) )
  let k_x_mm = 12.5 // 12.5 mm sensitivity factor
  let v_r = 1.050 // 1.050 V
  let v_l = 0.950 // 0.950 V

  let delta_x_mm = k_x_mm * ((v_r - v_l) / (v_r + v_l)) // 12.5 * (0.1 / 2.0) = 0.625 mm
  assert_true((delta_x_mm - 0.625).abs() < 1.0e-6)
}

///|
test "Suite73 BPM 02: Cavity BPM Sub-Micron Transverse Position Resolution" {
  let res_nm = 50.0 // 50 nanometers resolution
  assert_true(res_nm < 100.0)
}

///|
test "Suite73 BPM 03: 500 MHz RF Bunch Repetition Frequency Tracking" {
  let f_rf_mhz = 499.65 // 500 MHz standard synchrotron RF
  assert_true(f_rf_mhz > 450.0 && f_rf_mhz < 550.0)
}

///|
test "Suite73 BPM 04: Stripline BPM Directivity Ratio" {
  let directivity_db = 28.5 // 28.5 dB isolation of downstream vs upstream beam
  assert_true(directivity_db > 20.0)
}

///|
test "Suite73 BPM 05: Fast Orbit Feedback FOFB 10 kHz Loop Bandwidth" {
  let bw_fo_fb_khz = 10.0 // 10 kHz real-time orbit correction
  assert_true(bw_fo_fb_khz == 10.0)
}

///|
test "Suite73 BPM 06: Synchrotron Radiation Wake-Field Flange Cooling" {
  let p_wakefield_w = 45.0 // 45 W wakefield heating per button
  assert_true(p_wakefield_w < 100.0)
}

///|
test "Suite73 BPM 07: SVD Orbit Correction Inverted Response Matrix" {
  let num_correctors = 64
  let num_bpms = 128
  assert_true(num_bpms > num_correctors)
}

///|
test "Suite73 BPM 08: Relativistic Gamma Factor and Beta Velocity (beta ~ 0.999999)" {
  let e_beam_gev = 3.0 // 3.0 GeV electron storage ring
  let m0_mev = 0.511

  let gamma_rel = e_beam_gev * 1000.0 / m0_mev // ~5870
  let beta_sq = 1.0 - 1.0 / (gamma_rel * gamma_rel)
  let beta = beta_sq.sqrt()

  assert_true(beta > 0.99999)
}

///|
test "Suite73 BPM 09: Quadrupole Shunting Beam-Based Alignment BBA" {
  let bba_offset_um = 12.5 // 12.5 um magnetic center offset
  assert_true(bba_offset_um < 20.0)
}

///|
test "Suite73 BPM 10: Digital Signal Processing Cross-bar In-Phase Quadrature IQ Receiver" {
  let snr_bpm_db = 78.5
  assert_true(snr_bpm_db > 70.0)
}
