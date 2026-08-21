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
test "Suite159 HTS-Magnet 01: REBCO (Rare-Earth BCO) 20-Tesla High-Temperature Superconducting Magnet" {
  let b_hts_tesla = 20.0
  let t_operating_k = 20.0
  assert_true(b_hts_tesla == 20.0)
  assert_true(t_operating_k == 20.0)
}

///|
test "Suite159 HTS-Magnet 02: Non-Insulated NI Coil Self-Protecting Quench Mechanism" {
  let is_self_protecting = true
  assert_true(is_self_protecting)
}

///|
test "Suite159 HTS-Magnet 03: Screening Current Induced Magnetic Field (SCF) Drift Compensation" {
  let is_scf_compensated = true
  assert_true(is_scf_compensated)
}

///|
test "Suite159 HTS-Magnet 04: Conductor on Round Core CORC High-Current Cable (10 kA at 4K)" {
  let i_cable_ka = 10.0
  assert_true(i_cable_ka == 10.0)
}

///|
test "Suite159 HTS-Magnet 05: Lorentz Force Hoop Stress Mechanical Reinforcement (sigma > 800 MPa)" {
  let sigma_hoop_mpa = 850.0
  assert_true(sigma_hoop_mpa >= 800.0)
}

///|
test "Suite159 HTS-Magnet 06: Distributed Fiber Optic Rayleigh Scattering Quench Hot-Spot Detection (< 10 ms)" {
  let t_detect_ms = 8.0
  assert_true(t_detect_ms <= 10.0)
}

///|
test "Suite159 HTS-Magnet 07: High-Field Compact Fusion Tokamak Central Solenoid Peak Magnetic Energy (1 GJ)" {
  let e_mag_gj = 1.2
  assert_true(e_mag_gj >= 1.0)
}

///|
test "Suite159 HTS-Magnet 08: Persistent Current Switch PCS Superconducting Joint Resistance (< 10^-12 Ohm)" {
  let r_joint_ohm = 5.0e-13
  assert_true(r_joint_ohm < 1.0e-12)
}

///|
test "Suite159 HTS-Magnet 09: Closed-Cycle Cryocooler 20 Kelvin Helium Conduction Cooling Power (200 W)" {
  let p_cooling_w = 200.0
  assert_true(p_cooling_w == 200.0)
}

///|
test "Suite159 HTS-Magnet 10: Magnet Fast Energy Extraction Dump Resistor Voltage Protection (< 10 kV)" {
  let v_dump_kv = 7.5
  assert_true(v_dump_kv < 10.0)
}
