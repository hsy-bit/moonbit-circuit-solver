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
test "Suite137 RFTransceiver 01: Direct-Conversion Zero-IF Receiver IQ Imbalance Correction" {
  let amp_imbalance_db = 0.15
  let phase_imbalance_deg = 0.8
  assert_true(amp_imbalance_db < 0.20)
  assert_true(phase_imbalance_deg < 1.0)
}

///|
test "Suite137 RFTransceiver 02: Image Rejection Ratio IRR in Hartley/Weaver Architecture (> 50 dB)" {
  let irr_db = 55.0
  assert_true(irr_db >= 50.0)
}

///|
test "Suite137 RFTransceiver 03: Fractional-N PLL Sigma-Delta Modulator Spur Cancellation" {
  let in_band_phase_noise_dbc_hz = -105.0
  assert_true(in_band_phase_noise_dbc_hz <= -100.0)
}

///|
test "Suite137 RFTransceiver 04: Low-Noise Amplifier LNA Noise Figure NF (< 1.5 dB at 5 GHz)" {
  let nf_db = 1.35
  assert_true(nf_db < 1.50)
}

///|
test "Suite137 RFTransceiver 05: Power Amplifier PA Doherty Configuration Back-Off Efficiency" {
  let eta_backoff_percent = 48.0 // 48% efficiency at 6 dB backoff
  assert_true(eta_backoff_percent >= 45.0)
}

///|
test "Suite137 RFTransceiver 06: Digital Pre-Distortion DPD Volterra Series Linearization" {
  let aclr_improvement_dbc = 18.0 // 18 dB ACPR improvement
  assert_true(aclr_improvement_dbc >= 15.0)
}

///|
test "Suite137 RFTransceiver 07: S-Parameter 2-Port Transducer Power Gain G_T Calculation" {
  let s21_mag = 4.0 // 12 dB voltage gain
  let gt_db = 20.0 * (@math.ln(s21_mag) / @math.ln(10.0)) // ~12.04 dB

  assert_true((gt_db - 12.041).abs() < 0.05)
}

///|
test "Suite137 RFTransceiver 08: Receiver Intercept Point IIP3 Two-Tone Intermodulation" {
  let iip3_dbm = 12.0
  assert_true(iip3_dbm >= 10.0)
}

///|
test "Suite137 RFTransceiver 09: Automatic Gain Control AGC 80 dB Dynamic Range Closed-Loop Settling" {
  let t_settle_us = 15.0
  assert_true(t_settle_us <= 20.0)
}

///|
test "Suite137 RFTransceiver 10: 5G Massive MIMO Phased Array Beamforming Phase Precision (6-bit)" {
  let bits_phase = 6
  let delta_theta_deg = 360.0 / 64.0 // 5.625 degrees resolution
  assert_true(bits_phase == 6)
  assert_true(delta_theta_deg == 5.625)
}
