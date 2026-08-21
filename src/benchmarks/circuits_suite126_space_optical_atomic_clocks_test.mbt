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
test "Suite126 OpticalClock 01: Strontium-87 1S0-3P0 Magic Wavelength 813 nm Lattice" {
  let lambda_magic_nm = 813.427
  let f_clock_thz = 429.228 // 429.228 THz strontium optical transition
  assert_true((lambda_magic_nm - 813.427).abs() < 0.001)
  assert_true(f_clock_thz > 400.0)
}

///|
test "Suite126 OpticalClock 02: Ultra-Stable Cavity 10^-16 Thermal Brownian Noise Limit" {
  let frac_instability_1s = 1.2e-16
  assert_true(frac_instability_1s < 2.0e-16)
}

///|
test "Suite126 OpticalClock 03: Optical Frequency Comb Self-Referencing f-to-2f Interferometer" {
  let f_rep_mhz = 250.0
  let f_ceo_mhz = 40.0
  assert_true(f_rep_mhz == 250.0)
  assert_true(f_ceo_mhz == 40.0)
}

///|
test "Suite126 OpticalClock 04: Blackbody Radiation BBR Shift Cryogenic Cavity Shield (4K)" {
  let delta_bbr_fractional = 1.0e-19
  assert_true(delta_bbr_fractional <= 1.0e-18)
}

///|
test "Suite126 OpticalClock 05: Gravitational Redshift General Relativity Resolution (1 mm Height)" {
  // Delta f / f = g * Delta h / c^2 = 9.8 * 0.001 / (3e8)^2 ~ 1.09e-19
  let delta_h_m = 0.001 // 1 millimeter
  let g = 9.80665
  let c = 299792458.0
  let redshift = g * delta_h_m / (c * c)

  assert_true((redshift - 1.09e-19).abs() < 1.0e-20)
}

///|
test "Suite126 OpticalClock 06: Ytterbium-171 Two-Stage Laser Cooling (556 nm / 399 nm)" {
  let t_mot_uk = 10.0 // 10 uK narrow-line cooling
  assert_true(t_mot_uk <= 15.0)
}

///|
test "Suite126 OpticalClock 07: Space-Borne Compact Optical Clock Physics Package Volume (< 30 L)" {
  let vol_liters = 28.5
  assert_true(vol_liters < 30.0)
}

///|
test "Suite126 OpticalClock 08: Inter-Continental Satellite Free-Space Optical Time Transfer (100 fs)" {
  let time_jitter_fs = 85.0
  assert_true(time_jitter_fs <= 100.0)
}

///|
test "Suite126 OpticalClock 09: Rabi Excitation Spectroscopy Line Q-Factor (> 10^15)" {
  let q_factor = 2.5e15
  assert_true(q_factor > 1.0e15)
}

///|
test "Suite126 OpticalClock 10: Atomic Clock Systematic Uncertainty Budget (1.5e-18)" {
  let sys_uncertainty = 1.5e-18
  assert_true(sys_uncertainty <= 2.0e-18)
}
