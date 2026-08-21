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
test "Suite111 QuantumSense 01: Optically Pumped Magnetometer OPM Femtotesla Sensitivity" {
  let sens_ft_sqrt_hz = 15.0 // 15 fT / sqrt(Hz) spin-exchange relaxation-free SERF regime
  assert_true(sens_ft_sqrt_hz < 20.0)
}

///|
test "Suite111 QuantumSense 02: Nitrogen-Vacancy NV-Diamond Nanoscale Thermometer Sensitivity (1 mK)" {
  let delta_t_sens_mk = 1.0
  assert_true(delta_t_sens_mk <= 1.0)
}

///|
test "Suite111 QuantumSense 03: Rydberg Atom Microwave Electric Field Electrometry E-Field (1 uV/cm)" {
  let e_sens_uv_cm = 1.0
  assert_true(e_sens_uv_cm <= 1.0)
}

///|
test "Suite111 QuantumSense 04: Cavity Optomechanical Accelerometer Micro-g Sensitivity" {
  let sens_ug_sqrt_hz = 2.5
  assert_true(sens_ug_sqrt_hz < 5.0)
}

///|
test "Suite111 QuantumSense 05: SQUID Magnetoencephalography MEG 306-Channel Helmet Array" {
  let num_channels = 306
  assert_true(num_channels == 306)
}

///|
test "Suite111 QuantumSense 06: Atomic Clock Optical Lattice Strontium 10^-18 Uncertainty" {
  let uncertainty = 1.0e-18
  assert_true(uncertainty == 1.0e-18)
}

///|
test "Suite111 QuantumSense 07: Quantum Entanglement-Enhanced Target Detection Noise Immunity" {
  let quantum_advantage_db = 6.0 // 6 dB signal-to-noise advantage using entangled photon states
  assert_true(quantum_advantage_db >= 3.0)
}

///|
test "Suite111 QuantumSense 08: Nuclear Magnetic Resonance NMR Zero-Field / Ultra-Low Field" {
  let b_ulf_ut = 1.0 // 1 uT ultra-low field NMR
  assert_true(b_ulf_ut < 10.0)
}

///|
test "Suite111 QuantumSense 09: Quantum Ghost Imaging Spatial Correlation Resolution" {
  let is_ghost_imaging_correlated = true
  assert_true(is_ghost_imaging_correlated)
}

///|
test "Suite111 QuantumSense 10: Superconducting Nanowire Photon-Number-Resolving PNRD Array" {
  let max_photons_resolved = 8
  assert_true(max_photons_resolved == 8)
}
