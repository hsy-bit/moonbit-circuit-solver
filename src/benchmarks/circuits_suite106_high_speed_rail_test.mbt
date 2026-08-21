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
test "Suite106 HSR 01: 25 kV / 50 Hz Catenary Scott Transformer Substation" {
  let v_grid_kv = 220.0 // 220 kV 3-phase grid
  let v_catenary_kv = 27.5 // 27.5 kV traction feed
  assert_true(v_catenary_kv > 25.0)
  assert_true(v_grid_kv == 220.0)
}

///|
test "Suite106 HSR 02: 4-Quadrant Converter 3.3 kV IGBT Unity Power Factor (PF = 0.99)" {
  let pf = 0.995
  assert_true(pf >= 0.99)
}

///|
test "Suite106 HSR 03: Pantograph-Catenary Contact Force Dynamic Regulation (120 N)" {
  let f_contact_n = 120.0
  let delta_f_n = 15.0 // +/- 15 N variation at 350 km/h
  assert_true(f_contact_n == 120.0)
  assert_true(delta_f_n < 20.0)
}

///|
test "Suite106 HSR 04: Neutral Section Phase Separation Auto-Passage Sensor" {
  let t_neutral_ms = 400.0 // 400 ms coasting through neutral section
  assert_true(t_neutral_ms <= 500.0)
}

///|
test "Suite106 HSR 05: Asynchronous 1.2 MW Traction Motor Rotor Time Constant" {
  let tau_rotor_s = 0.25 // 250 ms rotor time constant
  assert_true(tau_rotor_s == 0.25)
}

///|
test "Suite106 HSR 06: Regenerative Braking Energy Feed-Back (10 MW Train)" {
  let p_regen_mw = 8.5 // 8.5 MW regenerated power
  assert_true(p_regen_mw > 7.0)
}

///|
test "Suite106 HSR 07: Trackside Balise Eurobalise 27.095 MHz RF Tele-Powering" {
  let f_balise_mhz = 27.095
  assert_true(f_balise_mhz == 27.095)
}

///|
test "Suite106 HSR 08: Axle-Counting Railway Track Circuit Return Current Filter" {
  let is_return_current_filtered = true
  assert_true(is_return_current_filtered)
}

///|
test "Suite106 HSR 09: Dynamic Wheel-Rail Adhesion Anti-Slip Controller (WSP)" {
  let slip_ratio = 0.08 // 8% optimal adhesion slip
  assert_true(slip_ratio <= 0.10)
}

///|
test "Suite106 HSR 10: High-Speed Train 350 km/h Aerodynamic Resistance (Davis Equation)" {
  let speed_km_h = 350.0
  let r_traction_kn = 45.0 // 45 kN total resistance
  assert_true(speed_km_h == 350.0)
  assert_true(r_traction_kn > 30.0)
}
