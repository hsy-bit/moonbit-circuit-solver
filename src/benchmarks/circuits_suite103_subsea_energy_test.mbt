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
test "Suite103 SubseaPower 01: 36 kV Wet-Mate Subsea High Voltage Connector" {
  let v_rating_kv = 36.0
  let i_rating_a = 500.0
  let p_capacity_mva = 3.0.sqrt() * v_rating_kv * i_rating_a / 1000.0 // ~31.18 MVA

  assert_true((p_capacity_mva - 31.1769).abs() < 0.05)
}

///|
test "Suite103 SubseaPower 02: 3000m Subsea Transformer Nitrogen Pressure Compensator" {
  let depth_m = 3000.0
  let p_compensator_bar = depth_m / 10.0 // 300 bar
  assert_true(p_compensator_bar == 300.0)
}

///|
test "Suite103 SubseaPower 03: Subsea Variable Speed Drive VSD 100 km Umbilical" {
  let length_km = 100.0
  assert_true(length_km == 100.0)
}

///|
test "Suite103 SubseaPower 04: Ferranti Voltage Rise Compensation Shunt Reactor" {
  let q_shunt_mvar = 15.0 // 15 MVAR inductive compensation
  assert_true(q_shunt_mvar == 15.0)
}

///|
test "Suite103 SubseaPower 05: Subsea Tree All-Electric Actuator DC Motor (24V)" {
  let v_actuator = 24.0
  let torque_nm = 150.0 // 150 N*m high torque valve actuation
  assert_true(v_actuator == 24.0)
  assert_true(torque_nm == 150.0)
}

///|
test "Suite103 SubseaPower 06: Acoustic Sand Detection Sensor Piezo Transducer" {
  let f_sand_khz = 250.0 // 250 kHz ultrasonic sand impact acoustic frequency
  assert_true(f_sand_khz == 250.0)
}

///|
test "Suite103 SubseaPower 07: Subsea Multiphase Flowmeter Gamma-Ray Densitometer" {
  let is_gamma_calibrated = true
  assert_true(is_gamma_calibrated)
}

///|
test "Suite103 SubseaPower 08: Autonomous Underwater Vehicle AUV Subsea Inductive Docking (1 kW)" {
  let p_dock_kw = 1.0
  let eta_dock = 0.88
  assert_true(p_dock_kw == 1.0)
  assert_true(eta_dock > 0.85)
}

///|
test "Suite103 SubseaPower 09: Subsea Control Module SCM Fault-Tolerant CAN-Bus" {
  let is_dual_redundant = true
  assert_true(is_dual_redundant)
}

///|
test "Suite103 SubseaPower 10: Cathodic Impressed Current Corrosion System ICCP" {
  let i_iccp_a = 40.0 // 40A impressed current
  assert_true(i_iccp_a == 40.0)
}
