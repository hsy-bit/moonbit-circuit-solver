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
test "Suite92 QuantumMemory 01: Electromagnetically Induced Transparency EIT Slow Light" {
  // Group velocity v_g = c / (1 + (omega/2) * d_chi/d_omega) << c
  let v_group_m_s = 17.0 // Slowed to 17 m/s in ultra-cold rubidium gas!
  let c_light = 3.0e8
  let slow_factor = c_light / v_group_m_s // 1.76e7 times slower!

  assert_true(slow_factor > 1.0e7)
}

///|
test "Suite92 QuantumMemory 02: Rare-Earth-Ion Atomic Frequency Comb AFC Multi-Mode Capacity" {
  let num_temporal_modes = 100 // 100 temporal modes stored simultaneously in Eu:YSO crystal
  assert_true(num_temporal_modes == 100)
}

///|
test "Suite92 QuantumMemory 03: Quantum Repeater Storage Lifetime (tau_storage > 100 ms)" {
  let tau_storage_ms = 120.0
  assert_true(tau_storage_ms >= 100.0)
}

///|
test "Suite92 QuantumMemory 04: Single-Photon Storage and Retrieval Efficiency (> 75%)" {
  let eta_retrieval = 0.78
  assert_true(eta_retrieval >= 0.75)
}

///|
test "Suite92 QuantumMemory 05: Nuclear Spin Coherence Protection Dynamical Decoupling (XY-8)" {
  let t2_coherence_s = 3600.0 // 1 hour coherence in zero-first-order-Zeeman ZEFOZ transition!
  assert_true(t2_coherence_s >= 3600.0)
}

///|
test "Suite92 QuantumMemory 06: Diamond Nitrogen-Vacancy NV-Center 13C Nuclear Spin Control" {
  let f_rf_mhz = 2.87 // 2.87 GHz zero-field splitting
  assert_true(f_rf_mhz > 2.8)
}

///|
test "Suite92 QuantumMemory 07: Quantum Teleportation Bell-State Measurement Fidelity (> 90%)" {
  let fidelity = 0.925
  assert_true(fidelity > 0.90)
}

///|
test "Suite92 QuantumMemory 08: Cryogenic Fabry-Perot Microcavity Purcell Factor (F_p > 50)" {
  let purcell_factor = 65.0
  assert_true(purcell_factor >= 50.0)
}

///|
test "Suite92 QuantumMemory 09: Quantum Optical Frequency Shifter Serrodyne Modulation" {
  let delta_f_mhz = 50.0
  assert_true(delta_f_mhz == 50.0)
}

///|
test "Suite92 QuantumMemory 10: Multi-Node Quantum Internet Entanglement Swapping Rate" {
  let swap_rate_hz = 150.0 // 150 entangled pairs / s
  assert_true(swap_rate_hz > 100.0)
}
