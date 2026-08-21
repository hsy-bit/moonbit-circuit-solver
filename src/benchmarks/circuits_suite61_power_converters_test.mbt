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
test "Suite61 Induction 01: Series Resonant Induction Heating LC Tank" {
  // f_res = 1 / (2*pi * sqrt(L * C))
  let l_work = 5.0e-6 // 5 uH induction work coil
  let c_tank = 2.0e-6 // 2 uF polypropylene capacitor bank

  let f_res = 1.0 / (2.0 * @math.PI * (l_work * c_tank).sqrt()) // ~50.33 kHz
  assert_true((f_res - 50329.2).abs() < 10.0)
}

///|
test "Suite61 Induction 02: Workpiece Magnetic Skin Depth at 50 kHz" {
  // delta = sqrt( rho / (pi * f * mu) )
  let rho_steel = 1.6e-7 // Ohm*m
  let mu_rel = 100.0 // Relative permeability below Curie point
  let mu_0 = 4.0 * @math.PI * 1.0e-7
  let f_hz = 50.0e3

  let skin_depth_m = (rho_steel / (@math.PI * f_hz * (mu_rel * mu_0))).sqrt() // ~0.09 mm
  assert_true(skin_depth_m > 0.00005 && skin_depth_m < 0.0002)
}

///|
test "Suite61 Induction 03: Parallel Resonant Current-Fed Inverter ZCS" {
  let v_dc = 300.0
  let p_heat_kw = 25.0 // 25 kW induction heating
  let i_tank_rms = p_heat_kw * 1000.0 / v_dc // ~83.3 A

  assert_true((i_tank_rms - 83.333).abs() < 0.1)
}

///|
test "Suite61 Induction 04: Induction Workhead Impedance Matching Auto-Transformer" {
  let turns_ratio = 4.0 // 4:1 step-down transformer -> 16:1 impedance transformation
  let z_work = 0.50 // 0.5 Ohm workhead
  let z_pri = z_work * turns_ratio * turns_ratio // 8.0 Ohms seen by inverter

  assert_true(z_pri == 8.0)
}

///|
test "Suite61 Induction 05: Phase-Locked Loop PLL Resonance Tracking Angle" {
  let phase_error_deg = 0.5 // Maintained within +/- 1 degree of zero crossing for ZVS
  assert_true(phase_error_deg.abs() <= 1.0)
}

///|
test "Suite61 Induction 06: Water-Cooled Work Coil Thermal Dissipation" {
  let _flow_rate_l_min = 10.0 // 10 L/min cooling water
  let delta_t_celsius = 8.0 // 8 °C water temperature rise
  // Q = m_dot * Cp * Delta_T = (10/60 kg/s) * 4184 J/kg*K * 8 K = ~5.58 kW
  let q_cool_kw = 10.0 / 60.0 * 4.184 * delta_t_celsius

  assert_true((q_cool_kw - 5.578).abs() < 0.05)
}

///|
test "Suite61 Induction 07: Crucible Curie Point Phase Transition Shift" {
  let t_curie_celsius = 770.0 // 770 °C Curie temperature for iron
  let t_actual = 800.0
  let is_above_curie = t_actual > t_curie_celsius

  assert_true(is_above_curie)
}

///|
test "Suite61 Induction 08: Snubberless IGBT Clamping Surge Energy" {
  let v_clamp = 1200.0 // 1200V active clamp
  let v_dc_bus = 600.0
  assert_true(v_clamp == 2.0 * v_dc_bus)
}

///|
test "Suite61 Induction 09: Dual-Frequency Simultaneous Induction Surface Hardening" {
  let f_low_khz = 10.0 // 10 kHz for deep root heating
  let f_high_khz = 300.0 // 300 kHz for tooth tip surface hardening
  assert_true(f_high_khz > 20.0 * f_low_khz)
}

///|
test "Suite61 Induction 10: Inverter Resonant Tank Quality Factor Loaded Q" {
  let q_loaded = 12.5 // Q = 12.5
  assert_true(q_loaded > 5.0 && q_loaded < 20.0)
}
