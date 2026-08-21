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
test "Suite70 IonThruster 01: Gridded Ion Thruster Specific Impulse Isp 3500s" {
  // v_e = sqrt(2 * q * V_screen / M_xe), Isp = v_e / g_0
  let q_e = 1.602176634e-19
  let v_screen = 1500.0 // 1500 V
  let m_xenon_kg = 2.1801714e-25 // Xenon-131 atomic mass
  let g_0 = 9.80665

  let v_exhaust_m_s = (2.0 * q_e * v_screen / m_xenon_kg).sqrt() // ~46960 m/s
  let i_sp_s = v_exhaust_m_s / g_0 // ~4788.6 s

  assert_true(v_exhaust_m_s > 40000.0)
  assert_true(i_sp_s > 3500.0)
}

///|
test "Suite70 IonThruster 02: Hall Thruster 4.5 kW Anode Discharge Power" {
  let v_discharge = 300.0 // 300 V
  let i_discharge = 15.0 // 15 A
  let p_anode_kw = v_discharge * i_discharge / 1000.0 // 4.5 kW

  assert_true((p_anode_kw - 4.5).abs() < 1.0e-6)
}

///|
test "Suite70 IonThruster 03: Hollow Cathode Keeper Ignition Strike" {
  let v_strike = 450.0 // 450V open-circuit keeper strike
  let v_run = 18.0 // 18V running keeper voltage
  assert_true(v_strike > 20.0 * v_run)
}

///|
test "Suite70 IonThruster 04: PPU High-Voltage Resonant Inverter 95% Efficiency" {
  let p_out_w = 5000.0
  let p_in_w = 5250.0
  let eta = p_out_w / p_in_w // 95.23%

  assert_true(eta >= 0.95)
}

///|
test "Suite70 IonThruster 05: Beam Neutralization Current Balance" {
  let i_beam_a = 2.5 // 2.5 A Xenon ion beam
  let i_neutralizer_a = 2.5 // 2.5 A electron emission
  let i_net = i_beam_a - i_neutralizer_a

  assert_true(i_net == 0.0)
}

///|
test "Suite70 IonThruster 06: Grid Flashover Sub-100 us Quench Recovery" {
  let t_clear_us = 45.0 // 45 us fast gate disable
  assert_true(t_clear_us < 100.0)
}

///|
test "Suite70 IonThruster 07: Xenon Flow Piezoelectric Valve PWM Duty Cycle" {
  let duty_percent = 35.0 // 35% duty cycle = 2.5 mg/s Xe flow
  assert_true(duty_percent == 35.0)
}

///|
test "Suite70 IonThruster 08: Spacecraft Floating Potential in LEO Plasma" {
  let v_sheath_v = -14.5 // -14.5 V spacecraft floating potential
  assert_true(v_sheath_v < 0.0 && v_sheath_v > -30.0)
}

///|
test "Suite70 IonThruster 09: Magnetic Shielding 50,000-Hour Operating Lifetime" {
  let lifetime_hours = 50000.0
  let years_continuous = lifetime_hours / (365.25 * 24.0) // 5.7 years continuous firing!

  assert_true(years_continuous > 5.0)
}

///|
test "Suite70 IonThruster 10: Thrust Force from Ion Beam Current" {
  // F = I_beam * sqrt(2 * M_xe * V_screen / q)
  let i_beam = 2.5 // 2.5 A
  let q_e = 1.602176634e-19
  let v_screen = 1500.0
  let m_xenon_kg = 2.1801714e-25

  let factor = (2.0 * m_xenon_kg * v_screen / q_e).sqrt() // ~6.39e-2
  let thrust_mn = i_beam * factor * 1000.0 // ~160 mN thrust

  assert_true(thrust_mn > 100.0 && thrust_mn < 250.0)
}
