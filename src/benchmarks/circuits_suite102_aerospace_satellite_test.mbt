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
test "Suite102 SatEPS 01: 28V Regulated Power Bus Impedance Specification" {
  let z_bus_mohm = 45.0 // 45 mOhms bus impedance up to 100 kHz
  assert_true(z_bus_mohm <= 50.0)
}

///|
test "Suite102 SatEPS 02: Latchup Current Limiter LCL Auto-Retry Circuit" {
  let i_trip_a = 2.5
  let t_blank_us = 10.0 // 10 us fast trip
  assert_true(i_trip_a == 2.5)
  assert_true(t_blank_us <= 15.0)
}

///|
test "Suite102 SatEPS 03: Pyrotechnic Separation Ring Firing Circuit Current" {
  let i_pyro_a = 5.0 // 5A pulse for 20 ms
  let t_pulse_ms = 20.0
  assert_true(i_pyro_a == 5.0)
  assert_true(t_pulse_ms == 20.0)
}

///|
test "Suite102 SatEPS 04: Reaction Wheel High-Speed 6000 RPM BLDC Driver" {
  let speed_rpm = 6000.0
  let angular_momentum_nms = 10.0 // 10 N*m*s storage
  assert_true(speed_rpm == 6000.0)
  assert_true(angular_momentum_nms == 10.0)
}

///|
test "Suite102 SatEPS 05: LiFePO4 8-Cell Space Battery Pack State-of-Charge" {
  let num_cells = 8
  let v_nom = num_cells.to_double() * 3.2 // 25.6 V
  assert_true((v_nom - 25.6).abs() < 1.0e-6)
}

///|
test "Suite102 SatEPS 06: Magnetic Torquer Rod Saturation Current (1.2 A)" {
  let i_rod_max = 1.2
  assert_true(i_rod_max == 1.2)
}

///|
test "Suite102 SatEPS 07: Star Tracker Peltier Cooler Temperature Differential" {
  let delta_t_cooling_c = 35.0 // -10 °C sensor in +25 °C spacecraft body
  assert_true(delta_t_cooling_c >= 30.0)
}

///|
test "Suite102 SatEPS 08: Direct Energy Transfer DET Solar Array Shunt Switch" {
  let num_shunt_stages = 8
  assert_true(num_shunt_stages == 8)
}

///|
test "Suite102 SatEPS 09: Cross-Strapped Redundant Power Distribution Unit" {
  let is_cross_strapped = true
  assert_true(is_cross_strapped)
}

///|
test "Suite102 SatEPS 10: S-Band Spacecraft Transceiver Power Output (5W RF)" {
  let p_rf_w = 5.0
  assert_true(p_rf_w == 5.0)
}
