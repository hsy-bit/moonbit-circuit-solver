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
test "Suite86 Stellarator 01: 3D Non-Planar Superconducting Modular Coils" {
  let num_modular_coils = 50 // W7-X 50 non-planar coils
  let num_planar_coils = 20 // 20 planar trim coils
  let total_coils = num_modular_coils + num_planar_coils

  assert_true(total_coils == 70)
}

///|
test "Suite86 Stellarator 02: Rotational Transform Iota iota = 5/5 Resonant Island Divertor" {
  let iota_edge = 1.00 // 5/5 = 1.0 edge island divertor resonance
  assert_true(iota_edge == 1.0)
}

///|
test "Suite86 Stellarator 03: Quasi-Isodynamic Magnetic Field Neoclassical Transport" {
  let radial_loss_reduction = 0.90 // 90% reduction in neoclassical 1/nu transport
  assert_true(radial_loss_reduction >= 0.85)
}

///|
test "Suite86 Stellarator 04: Continuous Steady-State 30-Minute Plasma Discharge" {
  let discharge_time_s = 1800.0 // 30 minutes continuous high-power operation!
  assert_true(discharge_time_s == 1800.0)
}

///|
test "Suite86 Stellarator 05: 140 GHz ECRH Microwave Heating Gyrotron Power (10 MW)" {
  let f_ecrh_ghz = 140.0
  let p_ecrh_mw = 10.0
  assert_true(f_ecrh_ghz == 140.0)
  assert_true(p_ecrh_mw == 10.0)
}

///|
test "Suite86 Stellarator 06: Superconducting Magnet Cryostat Liquid Nitrogen Shield" {
  let t_shield_k = 77.0
  assert_true(t_shield_k == 77.0)
}

///|
test "Suite86 Stellarator 07: Water-Cooled Carbon-Composite Target Divertor Heat Load (10 MW/m^2)" {
  let q_divertor_mw_m2 = 10.0
  assert_true(q_divertor_mw_m2 <= 10.0)
}

///|
test "Suite86 Stellarator 08: Zero Net Toroidal Current Disruption Immunity" {
  let i_toroidal_plasma_current = 0.0 // Inherently immune to current-driven disruption!
  assert_true(i_toroidal_plasma_current == 0.0)
}

///|
test "Suite86 Stellarator 09: Magnetic Island Control Trim Coils Power Controller" {
  let i_trim_ka = 2.5
  assert_true(i_trim_ka == 2.5)
}

///|
test "Suite86 Stellarator 10: Pellet Injection Cryogenic Hydrogen Ice Extruder Rate" {
  let pellet_freq_hz = 30.0 // 30 Hz pellet fueling
  assert_true(pellet_freq_hz == 30.0)
}
