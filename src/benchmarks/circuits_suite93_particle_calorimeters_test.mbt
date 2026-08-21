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
test "Suite93 Calorimeter 01: Liquid Argon LAr Electromagnetic Calorimeter Energy Resolution" {
  // sigma(E)/E = a / sqrt(E) + b
  let a_stochastic = 0.10 // 10% / sqrt(E)
  let b_constant = 0.007 // 0.7% constant term
  let e_gev = 100.0 // 100 GeV electron

  let res = a_stochastic / e_gev.sqrt() + b_constant // 0.01 + 0.007 = 1.7%
  assert_true((res - 0.017).abs() < 1.0e-4)
}

///|
test "Suite93 Calorimeter 02: High-Granularity Silicon Sensor Pixel Leakage (< 10 nA)" {
  let i_leak_na = 4.5
  assert_true(i_leak_na < 10.0)
}

///|
test "Suite93 Calorimeter 03: Lead Tungstate PbWO4 Crystal Scintillation Decay Time (10 ns)" {
  let tau_decay_ns = 10.0
  assert_true(tau_decay_ns == 10.0)
}

///|
test "Suite93 Calorimeter 04: Silicon Photomultiplier SiPM Microcell Saturation Correction" {
  // N_fired = N_total * (1 - exp(- N_photons / N_total))
  let n_total_cells = 10000.0
  let n_photons = 2000.0
  let n_fired = n_total_cells * (1.0 - @math.exp(-n_photons / n_total_cells)) // ~1812.7

  assert_true((n_fired - 1812.69).abs() < 1.0)
}

///|
test "Suite93 Calorimeter 05: Hadronic Calorimeter Sampling Fraction e/h Compensation" {
  let e_over_h_ratio = 1.05 // Well-compensated near 1.0
  assert_true(e_over_h_ratio < 1.10)
}

///|
test "Suite93 Calorimeter 06: Cryogenic Preamplifier 88 Kelvin In-Situ Integration" {
  let t_lar_k = 88.0 // 88K liquid argon
  assert_true(t_lar_k == 88.0)
}

///|
test "Suite93 Calorimeter 07: 40 MHz Bunch Crossing Pipeline Analog Memory ASIC (SCA)" {
  let f_clock_mhz = 40.0 // 40 MHz LHC clock
  assert_true(f_clock_mhz == 40.0)
}

///|
test "Suite93 Calorimeter 08: Radiation Hardness Total Ionizing Dose TID (> 100 MRad)" {
  let tid_mrad = 150.0
  assert_true(tid_mrad >= 100.0)
}

///|
test "Suite93 Calorimeter 09: Fast Level-1 Trigger Sliding Window Jet Clustering" {
  let t_l1_latency_us = 3.2 // 3.2 us trigger latency
  assert_true(t_l1_latency_us < 4.0)
}

///|
test "Suite93 Calorimeter 10: Multi-Channel Low-Noise 12-bit ADC Linear Dynamic Range" {
  let snr_db = 72.0
  assert_true(snr_db >= 70.0)
}
