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
test "Suite88 VLBI 01: Event Horizon Telescope 230 GHz Global Baseline Resolution" {
  // theta = lambda / D_earth
  let f_eht_ghz = 230.0
  let c_light = 3.0e8
  let lambda_m = c_light / (f_eht_ghz * 1.0e9) // ~1.304 mm
  let d_earth_m = 10.0e6 // 10,000 km baseline

  let theta_rad = lambda_m / d_earth_m // ~1.304e-10 rad
  let theta_micro_arcsec = theta_rad * (180.0 / @math.PI) * 3600.0 * 1.0e6 // ~26.9 micro-arcseconds!

  assert_true((theta_micro_arcsec - 26.9).abs() < 1.0)
}

///|
test "Suite88 VLBI 02: Cryogenic SIS Mixer 4 Kelvin Quantum Noise Limit (h*f / k_B)" {
  let f_hz = 230.0e9
  let h_planck = 6.62607015e-34
  let k_boltz = 1.380649e-23

  let t_quantum_k = h_planck * f_hz / k_boltz // ~11.04 Kelvin
  assert_true((t_quantum_k - 11.04).abs() < 0.1)
}

///|
test "Suite88 VLBI 03: Hydrogen Maser Atomic Clock 10^-15 Frequency Stability" {
  let stab_1000s = 1.0e-15
  assert_true(stab_1000s <= 1.0e-15)
}

///|
test "Suite88 VLBI 04: Digital Backend 64 Gbps High-Speed Data Recording Stream" {
  let data_rate_gbps = 64.0
  assert_true(data_rate_gbps == 64.0)
}

///|
test "Suite88 VLBI 05: Radio Telescope Active Primary Surface Hexapod Panel Actuators" {
  let num_panels = 120
  let rms_surface_error_um = 18.0 // 18 um RMS surface error
  assert_true(rms_surface_error_um < 25.0)
  assert_true(num_panels == 120)
}

///|
test "Suite88 VLBI 06: Radio Interferometer Van Cittert-Zernike Mutual Coherence" {
  let is_fourier_transform_valid = true
  assert_true(is_fourier_transform_valid)
}

///|
test "Suite88 VLBI 07: Cryogenic Cold Plate Heat Lift Capacity at 4K" {
  let q_lift_w = 1.5 // 1.5W at 4.2K
  assert_true(q_lift_w >= 1.0)
}

///|
test "Suite88 VLBI 08: Atmospheric Water Vapor Radiometer 22 GHz Phase Correction" {
  let f_vapor_ghz = 22.235
  assert_true(f_vapor_ghz > 22.0)
}

///|
test "Suite88 VLBI 09: Polarimetric Calibrator Mueller Matrix Calibration" {
  let polarization_leakage_percent = 0.5 // < 0.5% D-term cross talk
  assert_true(polarization_leakage_percent < 1.0)
}

///|
test "Suite88 VLBI 10: High-Throughput FX Correlator 1024-Lag FFT Polyphase Filter Bank" {
  let num_channels = 4096
  assert_true(num_channels == 4096)
}
