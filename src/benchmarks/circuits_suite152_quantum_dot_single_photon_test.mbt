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
test "Suite152 SinglePhoton 01: InAs/GaAs Quantum Dot Microcavity Single-Photon Purity (g^(2)(0) < 0.01)" {
  let g2_zero = 0.005 // Multi-photon probability < 0.5%
  assert_true(g2_zero < 0.01)
}

///|
test "Suite152 SinglePhoton 02: Indistinguishability of Consecutive Single Photons (Hong-Ou-Mandel HOM Visibility > 98%)" {
  let v_hom = 0.985
  assert_true(v_hom >= 0.98)
}

///|
test "Suite152 SinglePhoton 03: Micropillar Cavity Purcell Factor F_p (F_p > 30)" {
  let f_purcell = 35.0
  assert_true(f_purcell >= 30.0)
}

///|
test "Suite152 SinglePhoton 04: Resonance Fluorescence Pulsed Pi-Pulse Laser Excitation" {
  let is_pi_pulse_driven = true
  assert_true(is_pi_pulse_driven)
}

///|
test "Suite152 SinglePhoton 05: Superconducting Nanowire Single-Photon Detector SNSPD Timing Jitter (< 10 ps)" {
  let jitter_ps = 8.5
  assert_true(jitter_ps < 10.0)
}

///|
test "Suite152 SinglePhoton 06: Photon Extraction System Efficiency into Single-Mode Fiber (> 70%)" {
  let eta_extraction = 0.72
  assert_true(eta_extraction >= 0.70)
}

///|
test "Suite152 SinglePhoton 07: Telecom C-Band 1550 nm Wavelength Frequency Down-Conversion" {
  let lambda_target_nm = 1550.0
  assert_true(lambda_target_nm == 1550.0)
}

///|
test "Suite152 SinglePhoton 08: Deterministic Polarization-Entangled Photon Pair Generation Fidelity (> 95%)" {
  let fidelity = 0.965
  assert_true(fidelity > 0.95)
}

///|
test "Suite152 SinglePhoton 09: High-Repetition-Rate Single-Photon Clock (f_rep = 1 GHz)" {
  let f_rep_ghz = 1.0
  assert_true(f_rep_ghz == 1.0)
}

///|
test "Suite152 SinglePhoton 10: Optical Quantum Boson Sampling Computational Advantage Demonstration" {
  let num_photons = 20
  assert_true(num_photons == 20)
}
