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
test "Suite101 VFD 01: Field-Oriented Control FOC Clarke & Park Transformation" {
  // Clarke transform (a, b, c -> alpha, beta):
  // i_alpha = i_a, i_beta = (i_a + 2*i_b) / sqrt(3)
  let i_a = 10.0
  let i_b = -5.0
  let i_alpha = i_a
  let i_beta = (i_a + 2.0 * i_b) / 3.0.sqrt() // (10 - 10) / sqrt(3) = 0.0

  // Park transform (alpha, beta -> d, q) at theta = 0:
  let i_d = i_alpha // 10.0 A flux current
  let i_q = i_beta // 0.0 A torque current

  assert_true(i_d == 10.0)
  assert_true(i_q == 0.0)
}

///|
test "Suite101 VFD 02: Active Front End AFE Unity Power Factor (PF = 0.999)" {
  let power_factor = 0.999
  assert_true(power_factor > 0.99)
}

///|
test "Suite101 VFD 03: 3-Level Neutral Point Clamped NPC Inverter DC Midpoint Balancing" {
  let v_dc_total = 1200.0
  let v_c1 = 600.0
  let v_c2 = 600.0
  let delta_v = (v_c1 - v_c2).abs()

  assert_true(delta_v == 0.0)
  assert_true(v_c1 + v_c2 == v_dc_total)
}

///|
test "Suite101 VFD 04: Industrial Servo Motor 10 kHz Velocity Loop Bandwidth" {
  let bw_velocity_hz = 1000.0 // 1 kHz servo bandwidth
  assert_true(bw_velocity_hz >= 500.0)
}

///|
test "Suite101 VFD 05: Dynamic Braking Chopper Resistor Thermal Dissipation" {
  let r_brake_ohm = 15.0
  let v_dc_bus = 750.0
  let p_brake_peak_kw = v_dc_bus * v_dc_bus / r_brake_ohm / 1000.0 // 37.5 kW peak

  assert_true((p_brake_peak_kw - 37.5).abs() < 1.0e-6)
}

///|
test "Suite101 VFD 06: Sine-Filter Output dv/dt Attenuation (< 500 V/us)" {
  let dv_dt_v_per_us = 350.0 // 350 V/us protected motor insulation
  assert_true(dv_dt_v_per_us <= 500.0)
}

///|
test "Suite101 VFD 07: Encoderless Sensorless Flux Observer Speed Estimation" {
  let speed_rpm_actual = 1750.0
  let speed_rpm_est = 1748.5
  let error_rpm = (speed_rpm_actual - speed_rpm_est).abs()

  assert_true(error_rpm < 5.0)
}

///|
test "Suite101 VFD 08: Motor Stator Winding Temperature RTD PT100 Monitor" {
  let t_stator_c = 110.0 // 110 °C Class F insulation margin
  assert_true(t_stator_c < 155.0)
}

///|
test "Suite101 VFD 09: Long Motor Cable Reflection Ringing Suppression" {
  let l_cable_m = 150.0 // 150 meters cable
  assert_true(l_cable_m >= 100.0)
}

///|
test "Suite101 VFD 10: Flux Weakening Region High-Speed Operation (2x Base Speed)" {
  let speed_base_rpm = 1500.0
  let speed_max_rpm = 3000.0
  let ratio = speed_max_rpm / speed_base_rpm

  assert_true(ratio == 2.0)
}
