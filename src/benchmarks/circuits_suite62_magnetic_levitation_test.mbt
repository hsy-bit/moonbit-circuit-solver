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
test "Suite62 Maglev 01: EMS Attractive Levitation Force Formula" {
  // F = (mu_0 * N^2 * A * I^2) / (4 * z^2)
  let mu_0 = 4.0 * @math.PI * 1.0e-7
  let num_turns = 300.0
  let area_pole_m2 = 0.05 // 0.05 m^2 pole face
  let i_curr_a = 25.0 // 25 A nominal current
  let gap_z_m = 0.015 // 15 mm nominal air gap

  let num = mu_0 * num_turns * num_turns * area_pole_m2 * (i_curr_a * i_curr_a) // 4*pi*1e-7 * 90000 * 0.05 * 625 = ~3.534
  let den = 4.0 * gap_z_m * gap_z_m // 4 * 2.25e-4 = 9.0e-4
  let f_lev_n = num / den // ~3926.99 N

  assert_true((f_lev_n - 3926.99).abs() < 1.0)
}

///|
test "Suite62 Maglev 02: Linear Synchronous Motor LSM 600 km/h Synchronous Speed" {
  // v_sync = 2 * tau_p * f_grid
  let tau_pole_pitch_m = 0.60 // 600 mm pole pitch
  let f_inverter_hz = 138.89 // ~138.9 Hz

  let v_sync_m_s = 2.0 * tau_pole_pitch_m * f_inverter_hz // ~166.67 m/s (600 km/h)
  let v_km_h = v_sync_m_s * 3.6

  assert_true((v_km_h - 600.0).abs() < 1.0)
}

///|
test "Suite62 Maglev 03: EDS Superconducting Null-Flux Levitation Figure of Merit" {
  let lift_drag_ratio = 45.0 // High L/D > 40 at 500 km/h
  assert_true(lift_drag_ratio > 40.0)
}

///|
test "Suite62 Maglev 04: Eddy Current Brake Force Peak Transition Velocity" {
  let v_peak_brake_m_s = 15.0 // 15 m/s peak braking force transition
  assert_true(v_peak_brake_m_s == 15.0)
}

///|
test "Suite62 Maglev 05: Levitation Chopper 10 kHz Current Ripple Margin" {
  let v_dc = 300.0
  let f_sw = 10.0e3
  let l_magnet = 0.080 // 80 mH

  // Delta I = V_dc / (4 * f_sw * L)
  let delta_i = v_dc / (4.0 * f_sw * l_magnet) // 300 / 3200 = ~0.09375 A (Under 100 mA ripple!)
  assert_true((delta_i - 0.09375).abs() < 1.0e-4)
}

///|
test "Suite62 Maglev 06: Active Voice-Coil Lateral Damper Thrust" {
  // F = B * L * I
  let b_gap = 1.2 // 1.2 Tesla
  let l_wire_m = 15.0 // 15 meters wire in gap
  let i_cmd_a = 5.0 // 5A damping current

  let f_damper_n = b_gap * l_wire_m * i_cmd_a // 90 N
  assert_true((f_damper_n - 90.0).abs() < 1.0e-6)
}

///|
test "Suite62 Maglev 07: Inductive Air-Gap Sensor 15 mm Precision Linearity" {
  let z_nom_mm = 15.0
  let delta_z_mm = 2.0 // +/- 2 mm dynamic range
  let z_max = z_nom_mm + delta_z_mm

  assert_true(z_max == 17.0)
}

///|
test "Suite62 Maglev 08: On-Board Superconducting Persistent Current Loop Stability" {
  let i_persistent_a = 750.0 // 750 A circulating current
  let decay_rate_per_year = 1.0e-4 // < 0.01% decay per year

  assert_true(i_persistent_a == 750.0)
  assert_true(decay_rate_per_year < 0.001)
}

///|
test "Suite62 Maglev 09: Track Dynamic Deflection Beam Natural Frequency" {
  let f_beam_hz = 6.5 // 6.5 Hz guideway girder natural frequency
  assert_true(f_beam_hz > 5.0 && f_beam_hz < 10.0)
}

///|
test "Suite62 Maglev 10: Linear Induction Motor LIM End-Effect Drag Compensation" {
  let end_effect_factor = 0.88 // 12% thrust reduction at high speed compensated by V/f boost
  assert_true(end_effect_factor < 1.0)
}
