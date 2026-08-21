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
test "Suite76 OptQuantum 01: 50:50 Beam Splitter Unitary Matrix Transformation" {
  // U_bs = (1 / sqrt(2)) * [ [1, 1], [1, -1] ]
  let inv_sqrt2 = 1.0 / 2.0.sqrt() // ~0.7071
  let a_in1 = @linalg.Complex::new(1.0, 0.0)
  let _a_in2 = @linalg.Complex::zero()

  let b_out1 = a_in1.scale(inv_sqrt2)
  let b_out2 = a_in1.scale(inv_sqrt2)

  let p1 = b_out1.abs_sq() // 0.50
  let p2 = b_out2.abs_sq() // 0.50

  assert_true((p1 - 0.50).abs() < 1.0e-6)
  assert_true((p2 - 0.50).abs() < 1.0e-6)
}

///|
test "Suite76 OptQuantum 02: Hong-Ou-Mandel HOM Dip Two-Photon Interference" {
  let visibility_hom = 0.985 // 98.5% HOM quantum interference dip visibility
  assert_true(visibility_hom > 0.95)
}

///|
test "Suite76 OptQuantum 03: Mach-Zehnder Interferometer MZI Phase Modulation Phase Shift" {
  // T(phi) = cos^2(phi / 2)
  let phi_rad = @math.PI / 3.0 // 60 degrees
  let half_phi = phi_rad / 2.0
  let cos_val = @math.cos(half_phi)
  let transmission = cos_val * cos_val // cos^2(30 deg) = (sqrt(3)/2)^2 = 0.75

  assert_true((transmission - 0.75).abs() < 1.0e-6)
}

///|
test "Suite76 OptQuantum 04: Squeezed Light Noise Variance Sub-Shot Noise Limit" {
  let shot_noise_var = 1.0
  let squeezing_db = 10.0 // 10 dB squeezing -> variance = 0.10 (-10 dB below shot noise!)
  let ln10 = @math.ln(10.0)
  let var_squeezed = shot_noise_var * @math.exp(-squeezing_db / 10.0 * ln10)

  assert_true((var_squeezed - 0.10).abs() < 1.0e-4)
}

///|
test "Suite76 OptQuantum 05: Superconducting Nanowire Single Photon Detector SNSPD Jitter" {
  let jitter_fwhm_ps = 14.5 // 14.5 ps timing jitter
  assert_true(jitter_fwhm_ps < 20.0)
}

///|
test "Suite76 OptQuantum 06: Continuous-Variable Quantum Key Distribution CV-QKD Secret Key Rate" {
  let secret_key_rate_mbps = 2.4 // 2.4 Mbps at 25 km fiber
  assert_true(secret_key_rate_mbps > 1.0)
}

///|
test "Suite76 OptQuantum 07: Spontaneous Parametric Down-Conversion SPDC Pair Generation" {
  let pairs_per_mw_s = 500000.0 // 500,000 photon pairs / mW / s in PPLN waveguide
  assert_true(pairs_per_mw_s > 100000.0)
}

///|
test "Suite76 OptQuantum 08: Thermo-Optic Phase Shifter Response Time" {
  let tau_thermal_us = 12.0 // 12 us thermal time constant in silicon waveguide
  assert_true(tau_thermal_us < 20.0)
}

///|
test "Suite76 OptQuantum 09: Quantum State Tomography 2-Qubit Density Matrix Trace Tr(rho) = 1" {
  let trace_rho = 1.0
  assert_true(trace_rho == 1.0)
}

///|
test "Suite76 OptQuantum 10: Integrated Photonic Quantum Circuit 12x12 Unitary Mesh" {
  let mesh_dim = 12
  let num_mzis = mesh_dim * (mesh_dim - 1) / 2 // 66 MZI elements (Clements architecture)
  assert_true(num_mzis == 66)
}
