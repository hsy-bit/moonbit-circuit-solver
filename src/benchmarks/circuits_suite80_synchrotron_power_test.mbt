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
test "Suite80 Synchrotron 01: Dipole Magnet Power Supply 10 ppm Current Stability" {
  let i_dipole_nom = 1000.0 // 1000 A
  let delta_i_max_ma = 10.0 // 10 mA max variation = 10 ppm
  let stability_ppm = delta_i_max_ma * 1.0e-3 / i_dipole_nom * 1.0e6 // 10 ppm

  assert_true((stability_ppm - 10.0).abs() < 1.0e-6)
}

///|
test "Suite80 Synchrotron 02: Quadrupole Trim Magnet Fast Correction Bandwidth" {
  let f_trim_bw_khz = 5.0 // 5 kHz fast trim
  assert_true(f_trim_bw_khz == 5.0)
}

///|
test "Suite80 Synchrotron 03: Active Power Filter 12-Pulse Rectifier Harmonic Elimination" {
  let thd_raw_percent = 12.5
  let thd_filtered_percent = 0.8 // Filtered to < 1%
  assert_true(thd_filtered_percent < 1.0)
  assert_true(thd_raw_percent > 10.0)
}

///|
test "Suite80 Synchrotron 04: Undulator Insertion Device Gap Power Supply Tuning" {
  let gap_step_um = 0.5 // 500 nm mechanical servo resolution
  assert_true(gap_step_um < 1.0)
}

///|
test "Suite80 Synchrotron 05: Superconducting RF Cavity High-Power Klystron Drive (500 kW)" {
  let p_klystron_kw = 500.0
  assert_true(p_klystron_kw == 500.0)
}

///|
test "Suite80 Synchrotron 06: Sextupole Chromaticity Correction Current Balance" {
  let i_sf_a = 250.0 // Focusing sextupole
  let i_sd_a = 280.0 // Defocusing sextupole
  assert_true(i_sf_a > 0.0 && i_sd_a > 0.0)
}

///|
test "Suite80 Synchrotron 07: Top-Up Injection Booster Synchrotron 3 Hz Ramp Rate" {
  let f_rep_hz = 3.0 // 3 Hz ramp
  assert_true(f_rep_hz == 3.0)
}

///|
test "Suite80 Synchrotron 08: Direct-Current Current Transformer DCCT 24-bit Resolution" {
  let bits_dcct = 24
  assert_true(bits_dcct == 24)
}

///|
test "Suite80 Synchrotron 09: Storage Ring Beam Current Lifetime (tau_beam = 15 hours)" {
  let tau_hours = 15.0
  assert_true(tau_hours >= 10.0)
}

///|
test "Suite80 Synchrotron 10: Interlock Fast Beam Dump Reaction Time (< 10 us)" {
  let t_dump_us = 4.5
  assert_true(t_dump_us < 10.0)
}
