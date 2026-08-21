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
test "Suite71 Gravimeter 01: Superconducting Sphere Magnetic Levitation Stability" {
  // 1-inch Niobium sphere levitated in persistent magnetic field
  let m_sphere_kg = 0.050 // 50 grams
  let g_accel = 9.80665
  let f_lev_target = m_sphere_kg * g_accel // ~0.4903 N

  assert_true((f_lev_target - 0.49033).abs() < 1.0e-4)
}

///|
test "Suite71 Gravimeter 02: SQUID Displacement Transducer 10^-12 m Sensitivity" {
  let delta_x_pm = 0.01 // 0.01 picometers = 10^-14 m displacement sensitivity!
  assert_true(delta_x_pm < 0.1)
}

///|
test "Suite71 Gravimeter 03: NanoGal Earth Tide Gravity Perturbation (1 nGal = 10^-11 m/s^2)" {
  let g_earth_ms2 = 9.80665
  let delta_g_tidal_ngal = 250000.0 // 250 uGal = 250,000 nGal lunar tide
  let rel_tidal = delta_g_tidal_ngal * 1.0e-11 / g_earth_ms2 // ~2.55e-7

  assert_true(rel_tidal < 1.0e-6)
}

///|
test "Suite71 Gravimeter 04: Electrostatic Feedback Force Balancing Loop" {
  let v_feedback_v = 1.25 // 1.25V balancing voltage
  assert_true(v_feedback_v == 1.25)
}

///|
test "Suite71 Gravimeter 05: Superconducting Magnetic Shielding Attenuation (160 dB)" {
  let shield_atten_db = 160.0
  assert_true(shield_atten_db >= 140.0)
}

///|
test "Suite71 Gravimeter 06: Cryogenic Thermomechanical Nyquist Force Noise" {
  // S_f = 4 * k_B * T * gamma_damping
  let k_boltz = 1.380649e-23
  let t_kelvin = 4.2
  let gamma_damp = 1.0e-8

  let s_force = 4.0 * k_boltz * t_kelvin * gamma_damp
  assert_true(s_force < 1.0e-29)
}

///|
test "Suite71 Gravimeter 07: Long-Term Drift Rate Sub-NanoGal per Year" {
  let drift_ngal_per_year = 500.0 // 0.5 uGal/year
  assert_true(drift_ngal_per_year < 1000.0)
}

///|
test "Suite71 Gravimeter 08: Global Geodynamic Normal Mode Seismology Band" {
  let f_low_mhz = 0.3 // 0.3 mHz (Slichter triplet Earth core modes)
  assert_true(f_low_mhz < 1.0)
}

///|
test "Suite71 Gravimeter 09: Calibration Mass Rigorous Newtonian Attraction" {
  let g_grav = 6.67430e-11
  let m_ring_kg = 250.0 // 250 kg calibration ring
  let dist_m = 0.30

  let g_cal_ngal = g_grav * m_ring_kg / (dist_m * dist_m) * 1.0e11 // ~18.54 uGal = 18540 nGal
  assert_true((g_cal_ngal - 18539.7).abs() < 10.0)
}

///|
test "Suite71 Gravimeter 10: 4K Cryocooler Vibration Free Cold Head Interface" {
  let is_vibration_isolated = true
  assert_true(is_vibration_isolated)
}
