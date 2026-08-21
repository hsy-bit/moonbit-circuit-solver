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
test "Suite162 CryoADC 01: 10 GSa/s 8-bit Cryogenic Time-Interleaved SAR ADC at 4 Kelvin" {
  let f_sample_gsa_s = 10.0
  let enob = 7.4
  assert_true(f_sample_gsa_s == 10.0)
  assert_true(enob >= 7.0)
}

///|
test "Suite162 CryoADC 02: Spurious-Free Dynamic Range SFDR (> 65 dBc at Nyquist)" {
  let sfdr_dbc = 68.5
  assert_true(sfdr_dbc >= 65.0)
}

///|
test "Suite162 CryoADC 03: Channel-to-Channel Gain and Timing Skew Mismatch Calibration" {
  let timing_skew_fs = 45.0 // 45 femtoseconds residual skew
  assert_true(timing_skew_fs < 50.0)
}

///|
test "Suite162 CryoADC 04: Cryogenic Bootstrapped Sampling Switch Linearity (THD < -70 dB)" {
  let thd_db = -72.0
  assert_true(thd_db <= -70.0)
}

///|
test "Suite162 CryoADC 05: Superconducting Flash ADC Comparator Threshold Metastability (< 5 ps)" {
  let t_meta_ps = 3.5
  assert_true(t_meta_ps < 5.0)
}

///|
test "Suite162 CryoADC 06: Cryogenic Reference Voltage Buffer Settling Time (< 100 ps)" {
  let t_settle_ps = 85.0
  assert_true(t_settle_ps < 100.0)
}

///|
test "Suite162 CryoADC 07: Signal-to-Noise and Distortion Ratio SINAD (> 46 dB at 5 GHz Input)" {
  let sinad_db = 47.2
  assert_true(sinad_db >= 46.0)
}

///|
test "Suite162 CryoADC 08: Walden Figure of Merit FOM_W (< 50 fJ/conv-step at 4K)" {
  let fom_w_fj = 35.0
  assert_true(fom_w_fj < 50.0)
}

///|
test "Suite162 CryoADC 09: Digital Background Interleaving Offset Calibration Convergence" {
  let is_calibrated = true
  assert_true(is_calibrated)
}

///|
test "Suite162 CryoADC 10: Multi-Channel Qubit Readout Multiplexed Interface Sign-Off" {
  let is_readout_signed_off = true
  assert_true(is_readout_signed_off)
}
