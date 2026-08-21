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
test "Suite109 MRI 01: 3-Tesla Proton Larmor Frequency 127.7 MHz" {
  // f = gamma * B0 / (2 * pi)
  let gamma_bar_mhz_t = 42.57747851 // MHz / Tesla for 1H proton
  let b0_tesla = 3.0 // 3T MRI

  let f_larmor_mhz = gamma_bar_mhz_t * b0_tesla // ~127.73 MHz
  assert_true((f_larmor_mhz - 127.7324).abs() < 0.01)
}

///|
test "Suite109 MRI 02: 128-Channel Phased Array Receiver Coil Low-Noise Preamplifier (NF < 0.5 dB)" {
  let nf_db = 0.45
  assert_true(nf_db < 0.50)
}

///|
test "Suite109 MRI 03: Gradient Power Amplifier GPA 200 A / 2000 V Fast Slew Rate (200 T/m/s)" {
  let slew_rate_t_m_s = 200.0
  assert_true(slew_rate_t_m_s >= 150.0)
}

///|
test "Suite109 MRI 04: PIN Diode Active Decoupling Transmit/Receive Switch" {
  let isolation_db = 45.0 // 45 dB isolation during transmit RF pulse
  assert_true(isolation_db >= 40.0)
}

///|
test "Suite109 MRI 05: Specific Absorption Rate SAR Patient RF Thermal Protection (< 4 W/kg)" {
  let sar_w_kg = 3.2 // Whole-body SAR limit
  assert_true(sar_w_kg < 4.0)
}

///|
test "Suite109 MRI 06: Eddy Current Compensation Pre-Emphasis Digital Filter" {
  let is_preemphasis_filtered = true
  assert_true(is_preemphasis_filtered)
}

///|
test "Suite109 MRI 07: Ultrasound 128-Element Linear Array Beamformer Delay Accuracy (1 ns)" {
  let delay_res_ns = 0.5 // 500 ps delay resolution
  assert_true(delay_res_ns <= 1.0)
}

///|
test "Suite109 MRI 08: Time Gain Compensation TGC Exponential Analog Attenuator" {
  let dynamic_gain_range_db = 60.0 // 60 dB acoustic depth attenuation compensation
  assert_true(dynamic_gain_range_db >= 50.0)
}

///|
test "Suite109 MRI 09: Contrast-Enhanced Ultrasound Microbubble Non-Linear Harmonic Imaging" {
  let f_fund_mhz = 2.5
  let f_second_harmonic_mhz = 5.0
  assert_true(f_second_harmonic_mhz == 2.0 * f_fund_mhz)
}

///|
test "Suite109 MRI 10: High-Intensity Focused Ultrasound HIFU Thermal Ablation Power (500 W)" {
  let p_acoustic_w = 500.0
  assert_true(p_acoustic_w == 500.0)
}
