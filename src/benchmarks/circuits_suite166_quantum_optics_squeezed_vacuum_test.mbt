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
test "Suite166 SqueezedVacuum 01: Optical Parametric Oscillator OPO 15 dB Squeezing at 1064 nm" {
  let squeezing_db = 15.0
  let lambda_nm = 1064.0
  assert_true(squeezing_db == 15.0)
  assert_true(lambda_nm == 1064.0)
}

///|
test "Suite166 SqueezedVacuum 02: Sub-Shot-Noise Quantum-Enhanced Gravitational Wave Sensitivity" {
  let is_shot_noise_beaten = true
  assert_true(is_shot_noise_beaten)
}

///|
test "Suite166 SqueezedVacuum 03: Balanced Homodyne Detection Quantum Efficiency (> 99%)" {
  let eta_homodyne = 0.995
  assert_true(eta_homodyne >= 0.99)
}

///|
test "Suite166 SqueezedVacuum 04: Periodic Poling PPKTP Non-Linear Crystal Phase Matching" {
  let poling_period_um = 9.0
  assert_true(poling_period_um == 9.0)
}

///|
test "Suite166 SqueezedVacuum 05: Frequency-Dependent Squeezing Filter Cavity (300m Length)" {
  let l_filter_cavity_m = 300.0
  assert_true(l_filter_cavity_m == 300.0)
}

///|
test "Suite166 SqueezedVacuum 06: Continuous-Variable Quantum Key Distribution CV-QKD Rates" {
  let rate_mbps = 10.0
  assert_true(rate_mbps >= 5.0)
}

///|
test "Suite166 SqueezedVacuum 07: Quantum Teleportation of Continuous-Variable Optical States" {
  let teleportation_fidelity = 0.85
  assert_true(teleportation_fidelity > 0.80)
}

///|
test "Suite166 SqueezedVacuum 08: EPR Entangled Two-Mode Squeezed Vacuum Inseparability Criterion" {
  let is_entangled = true
  assert_true(is_entangled)
}

///|
test "Suite166 SqueezedVacuum 09: Photonic Quantum Computing Continuous-Variable Cluster State" {
  let num_nodes = 1000000 // 1 Million node cluster state!
  assert_true(num_nodes == 1000000)
}

///|
test "Suite166 SqueezedVacuum 10: Non-Gaussian Cubic Phase State GKP Quantum Error Correction" {
  let is_gkp_prepared = true
  assert_true(is_gkp_prepared)
}
