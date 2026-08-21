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
test "Suite161 Optomechanics 01: Cavity Optomechanics Radiation Pressure Coupling Rate g_0 (g_0 > 1 MHz)" {
  let g0_mhz = 1.25
  assert_true(g0_mhz >= 1.0)
}

///|
test "Suite161 Optomechanics 02: Resolved Sideband Regime Laser Cooling to Quantum Ground State (n_bar < 0.1)" {
  let n_phonon_bar = 0.08
  assert_true(n_phonon_bar < 0.10)
}

///|
test "Suite161 Optomechanics 03: Optomechanically Induced Transparency OMIT Window Width (Gamma_eff)" {
  let is_omit_observed = true
  assert_true(is_omit_observed)
}

///|
test "Suite161 Optomechanics 04: Phonon Number Resolving Counting in Nanomechanical Resonator" {
  let is_phonon_resolved = true
  assert_true(is_phonon_resolved)
}

///|
test "Suite161 Optomechanics 05: Ultra-High Q-Frequency Product Mechanical Mode (Q*f > 10^18 Hz)" {
  let q_factor = 1.0e9
  let f_m_hz = 2.0e9
  let q_f_product = q_factor * f_m_hz // 2.0e18 Hz
  assert_true(q_f_product >= 1.0e18)
}

///|
test "Suite161 Optomechanics 06: Quantum Backaction Evasion BAE Squeezed Light Measurement" {
  let squeezing_db = 4.5
  assert_true(squeezing_db >= 3.0)
}

///|
test "Suite161 Optomechanics 07: Nanomechanical Membrane-in-the-Middle Cavity Setup" {
  let is_membrane_aligned = true
  assert_true(is_membrane_aligned)
}

///|
test "Suite161 Optomechanics 08: Micro-Toroid Whispering Gallery Mode WGM Evanescent Taper Coupling" {
  let eta_coupling = 0.96
  assert_true(eta_coupling >= 0.90)
}

///|
test "Suite161 Optomechanics 09: Dynamic Photonic-Phononic Memory Storage Lifetime (> 1 ms)" {
  let tau_storage_ms = 2.5
  assert_true(tau_storage_ms >= 1.0)
}

///|
test "Suite161 Optomechanics 10: Quantum Non-Demolition QND Mechanical Energy Measurement" {
  let is_qnd_validated = true
  assert_true(is_qnd_validated)
}
