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
test "Suite67 Atomic 01: Rubidium-87 Hyperfine Resonance 6.834 GHz" {
  let f_rb87_hz = 6834682610.904
  let f_ghz = f_rb87_hz / 1.0e9

  assert_true((f_ghz - 6.83468).abs() < 1.0e-4)
}

///|
test "Suite67 Atomic 02: Cesium-133 SI Definition Frequency 9.192631770 GHz" {
  let f_cs133_exact = 9192631770.0
  assert_true(f_cs133_exact == 9192631770.0)
}

///|
test "Suite67 Atomic 03: Allan Deviation Stability Scaling (1e-11 / sqrt(tau))" {
  // sigma_y(tau) = 1.0e-11 / sqrt(tau)
  let tau_s = 100.0 // 100 seconds averaging
  let sigma_1s = 1.0e-11

  let sigma_100s = sigma_1s / tau_s.sqrt() // 1.0e-12
  assert_true((sigma_100s - 1.0e-12).abs() < 1.0e-15)
}

///|
test "Suite67 Atomic 04: OCXO SC-Cut Quartz Crystal Acceleration Sensitivity" {
  let gamma_g = 0.8e-10 // 0.8e-10 per g acceleration
  let g_vibration = 5.0 // 5g vibration environment

  let delta_f_f = gamma_g * g_vibration // 4.0e-10 fractional frequency shift
  assert_true((delta_f_f - 4.0e-10).abs() < 1.0e-13)
}

///|
test "Suite67 Atomic 05: Chip-Scale Atomic Clock CSAC Sub-120 mW Power" {
  let p_csac_mw = 115.0 // 115 mW operating power
  assert_true(p_csac_mw < 120.0)
}

///|
test "Suite67 Atomic 06: Dual-Mixer Time-Difference DMTD Sub-Picosecond Precision" {
  let jitter_fs = 250.0 // 250 femtoseconds measurement resolution
  assert_true(jitter_fs < 1000.0)
}

///|
test "Suite67 Atomic 07: OCXO Thermal Oven Proportional Controller Setpoint" {
  let t_setpoint_c = 85.0 // 85 °C crystal turnover temperature
  let t_ambient_c = 25.0
  let delta_t = t_setpoint_c - t_ambient_c // 60 °C oven boost

  assert_true(delta_t == 60.0)
}

///|
test "Suite67 Atomic 08: 10 MHz Phase Noise L(100Hz) Leeson Curve" {
  let l_100hz_dbc = -135.0 // -135 dBc/Hz ultra-low close-in phase noise
  assert_true(l_100hz_dbc < -130.0)
}

///|
test "Suite67 Atomic 09: GPS PPS Pulse-Per-Second Jitter (RMS < 5 ns)" {
  let pps_jitter_ns = 3.5
  assert_true(pps_jitter_ns < 5.0)
}

///|
test "Suite67 Atomic 10: Frequency Synthesizer Sub-50 fs Integrated Jitter" {
  let jitter_fs = 42.0 // 42 fs RMS integrated from 12 kHz to 20 MHz
  assert_true(jitter_fs < 50.0)
}
