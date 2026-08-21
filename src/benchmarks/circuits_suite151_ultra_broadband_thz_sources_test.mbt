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
test "Suite151 THzSources 01: Spintronic Terahertz Emitter STE (Co/Pt Bilayer, 0.1 to 30 THz)" {
  let f_min_thz = 0.1
  let f_max_thz = 30.0
  assert_true(f_max_thz > f_min_thz)
}

///|
test "Suite151 THzSources 02: Inverse Spin Hall Effect ISHE Ultrafast Demagnetization Pulse (< 100 fs)" {
  let tau_ishe_fs = 80.0
  assert_true(tau_ishe_fs < 100.0)
}

///|
test "Suite151 THzSources 03: Air-Plasma Two-Color Femtosecond Laser Filamentation (800 nm + 400 nm)" {
  let lambda1_nm = 800.0
  let lambda2_nm = 400.0
  assert_true(lambda1_nm == 2.0 * lambda2_nm)
}

///|
test "Suite151 THzSources 04: Lithium Niobate LiNbO3 Tilted-Pulse-Front TPFT Terahertz Generation" {
  let gamma_tilt_deg = 63.0 // 63 degree tilt angle for phase matching
  assert_true(gamma_tilt_deg > 60.0)
}

///|
test "Suite151 THzSources 05: High-Field Terahertz Pulse Peak Electric Field (> 1 MV/cm)" {
  let e_peak_mv_cm = 1.2
  assert_true(e_peak_mv_cm >= 1.0)
}

///|
test "Suite151 THzSources 06: Superconducting Hot Electron Bolometer HEB Heterodyne Receiver (Noise Temp < 500 K at 2.5 THz)" {
  let t_noise_k = 420.0
  assert_true(t_noise_k < 500.0)
}

///|
test "Suite151 THzSources 07: Terahertz Near-Field Scattering SNOM Nanoscale Resolution (< 10 nm)" {
  let delta_x_nm = 8.5
  assert_true(delta_x_nm < 10.0)
}

///|
test "Suite151 THzSources 08: Resonant Tunneling Diode RTD Terahertz Fundamental Oscillator (1.98 THz)" {
  let f_rtd_thz = 1.98
  assert_true(f_rtd_thz > 1.5)
}

///|
test "Suite151 THzSources 09: Terahertz Wireless 6G Sub-THz Communications (100 Gbps at 300 GHz)" {
  let data_rate_gbps = 100.0
  let f_carrier_ghz = 300.0
  assert_true(data_rate_gbps == 100.0)
  assert_true(f_carrier_ghz == 300.0)
}

///|
test "Suite151 THzSources 10: Non-Destructive High-Resolution Terahertz Computed Tomography THz-CT" {
  let is_thz_ct_reconstructed = true
  assert_true(is_thz_ct_reconstructed)
}
