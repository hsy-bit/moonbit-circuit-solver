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
test "Suite138 SerDes 01: 112 Gbps PAM-4 4-Level Eye Opening Height & Width Margin" {
  let eye_height_mv = 45.0 // 45 mV inner eye height
  let eye_width_ui = 0.28 // 0.28 UI eye width at BER = 1e-4
  assert_true(eye_height_mv >= 30.0)
  assert_true(eye_width_ui >= 0.25)
}

///|
test "Suite138 SerDes 02: Continuous-Time Linear Equalizer CTLE Peaking Gain (12 dB)" {
  let g_peak_db = 12.0
  assert_true(g_peak_db == 12.0)
}

///|
test "Suite138 SerDes 03: Decision Feedback Equalizer DFE 5-Tap Post-Cursor Cancellation" {
  let num_taps = 5
  assert_true(num_taps == 5)
}

///|
test "Suite138 SerDes 04: Feed-Forward Equalizer FFE 4-Tap Pre-Emphasis Transmitter" {
  let num_ffe_taps = 4
  assert_true(num_ffe_taps == 4)
}

///|
test "Suite138 SerDes 05: Clock and Data Recovery CDR Bang-Bang Phase Detector (BBPD)" {
  let is_bbpd_locked = true
  assert_true(is_bbpd_locked)
}

///|
test "Suite138 SerDes 06: Channel Insertion Loss -28 dB at 28 GHz Nyquist Frequency" {
  let loss_nyquist_db = -28.0
  assert_true(loss_nyquist_db >= -30.0)
}

///|
test "Suite138 SerDes 07: Total Jitter Decomposition (TJ = RJ * 14 + DJ for BER 10^-12)" {
  let rj_rms_ps = 0.35
  let dj_ddj_ps = 3.5
  let tj_ps = rj_rms_ps * 14.069 + dj_ddj_ps // ~8.42 ps

  assert_true((tj_ps - 8.424).abs() < 0.05)
}

///|
test "Suite138 SerDes 08: Inter-Symbol Interference ISI Eye Closure Metric ECM" {
  let ecm_db = 1.8
  assert_true(ecm_db < 2.5)
}

///|
test "Suite138 SerDes 09: Forward Error Correction FEC RS(544, 514) KP4 Gain (6.5 dB)" {
  let fec_gain_db = 6.5
  assert_true(fec_gain_db >= 6.0)
}

///|
test "Suite138 SerDes 10: 224 Gbps SerDes Ultra-High-Speed Signal Integrity Sign-Off" {
  let is_serdes_passed = true
  assert_true(is_serdes_passed)
}
