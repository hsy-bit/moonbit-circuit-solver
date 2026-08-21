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
test "Suite38 EV 01: 800V SiC Traction Inverter Dead-Time Conduction Loss" {
  // P_dead = 2 * V_sd * I_load * t_dead * f_sw
  let v_sd_body_diode = 3.5 // 3.5V SiC body diode drop
  let i_load_rms = 250.0 // 250 A
  let t_dead_ns = 150.0e-9 // 150 ns dead-time
  let f_sw = 40.0e3 // 40 kHz switching frequency

  let p_dead = 2.0 * v_sd_body_diode * i_load_rms * t_dead_ns * f_sw // 10.5 W
  assert_true((p_dead - 10.5).abs() < 1.0e-3)
}

///|
test "Suite38 EV 02: 800V DC Bus Pre-Charge Resistor Energy Dissipation" {
  // E_precharge = 0.5 * C_dc_link * V_bus^2
  let c_dc = 500.0e-6 // 500 uF film capacitor
  let v_bus = 800.0 // 800V battery pack

  let e_precharge_joules = 0.5 * c_dc * v_bus * v_bus // 160 Joules
  assert_true((e_precharge_joules - 160.0).abs() < 1.0e-6)
}

///|
test "Suite38 EV 03: Dual Active Bridge DAB Phase-Shift Power Transfer" {
  // P = (n * V1 * V2 / (2 * pi * f * L)) * phi * (1 - phi / pi)
  let v1 = 800.0
  let v2 = 400.0
  let turns_n = 0.5 // 800V to 400V
  let l_leak = 25.0e-6 // 25 uH
  let f_sw = 100.0e3 // 100 kHz
  let phi_rad = @math.PI / 4.0 // 45 degrees phase shift

  let omega_l = 2.0 * @math.PI * f_sw * l_leak // ~15.71 Ohms
  let v_term = turns_n * v1 * v2 / omega_l // 160000 / 15.71 = ~10186
  let p_dab = v_term * phi_rad * (1.0 - phi_rad / @math.PI) // 10186 * 0.785 * 0.75 = ~6000 W (6 kW)

  assert_true(p_dab > 5500.0 && p_dab < 6500.0)
}

///|
test "Suite38 EV 04: Space Vector PWM SVPWM Maximum Linear Modulation Index" {
  // Max linear phase voltage without overmodulation V_max = V_dc / sqrt(3) approx 0.577 * V_dc (15.5% higher than sinusoidal PWM!)
  let v_dc = 800.0
  let v_max_svpwm = v_dc / 3.0.sqrt() // 461.88 V

  assert_true((v_max_svpwm - 461.88).abs() < 0.1)
}

///|
test "Suite38 EV 05: Rogowski Coil High-Current Sensor Differentiator Output" {
  // V_rogowski = M * (di/dt)
  let m_mutual = 50.0e-9 // 50 nH mutual inductance
  let di_dt = 10.0e6 // 10 A/us = 10^7 A/s fault slope

  let v_sensor = m_mutual * di_dt // 0.50 V
  assert_true((v_sensor - 0.50).abs() < 1.0e-6)
}

///|
test "Suite38 EV 06: Isolated CAN-FD Transceiver 150 ns Loop Delay Limit" {
  let t_tx_delay = 45.0 // 45 ns
  let t_iso_barrier = 25.0 // 25 ns
  let t_rx_delay = 45.0 // 45 ns

  let t_loop = t_tx_delay + 2.0 * t_iso_barrier + t_rx_delay // 140 ns <= 150 ns
  assert_true(t_loop <= 150.0)
}

///|
test "Suite38 EV 07: High-Voltage Pyrofuse Fast Sub-Millisecond Trip" {
  let t_trip_us = 450.0 // 450 microseconds (< 1 ms)
  let i_rating_a = 600.0 // 600 A nominal
  assert_true(t_trip_us < 1000.0)
  assert_true(i_rating_a == 600.0)
}

///|
test "Suite38 EV 08: Resolver Tracking Observer Phase Error Angle" {
  let theta_actual = 0.785398 // 45 degrees
  let theta_estimated = 0.785000
  let err_rad = (theta_actual - theta_estimated).abs()

  assert_true(err_rad < 0.001)
}

///|
test "Suite38 EV 09: High-Voltage Isolation Creepage Distance (CTI >= 600)" {
  // Material Group I (CTI >= 600): 800V working voltage requires minimum 4.0 mm creepage for Pollution Degree 2
  let creepage_mm = 8.5 // 8.5 mm designed margin
  assert_true(creepage_mm >= 4.0)
}

///|
test "Suite38 EV 10: Traction Motor Regeneration Braking Energy Recovery" {
  // E_regen = 0.5 * m * (v1^2 - v2^2) * eta_regen
  let mass_kg = 2000.0 // 2000 kg EV
  let v1_m_s = 27.78 // 100 km/h
  let v2_m_s = 0.0
  let eta_regen = 0.75 // 75% efficiency

  let e_kinetic = 0.5 * mass_kg * (v1_m_s * v1_m_s - v2_m_s * v2_m_s) // ~771.7 kJ
  let e_recovered_kj = e_kinetic * eta_regen / 1000.0 // ~578.8 kJ

  assert_true(e_recovered_kj > 500.0 && e_recovered_kj < 650.0)
}
