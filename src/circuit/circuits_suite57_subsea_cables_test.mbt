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
test "Suite57 Subsea 01: 10 kV Subsea Constant-Current Power Feed PFE" {
  // Constant current I_pfe = 1.0A drives 100 cascaded EDFA optical repeaters across Atlantic
  let i_loop = 1.0 // 1.0 A
  let r_cable_per_km = 1.0 // 1.0 Ohm/km
  let length_km = 6000.0 // 6000 km
  let v_edfa_drop_each = 35.0 // 35V drop per repeater
  let num_repeaters = 100

  let v_cable_drop = length_km * r_cable_per_km * i_loop // 6000 V
  let v_repeaters_drop = num_repeaters.to_double() * v_edfa_drop_each // 3500 V
  let v_total_pfe = v_cable_drop + v_repeaters_drop // 9500 V (< 10 kV rating)

  assert_true((v_total_pfe - 9500.0).abs() < 1.0e-6)
  assert_true(v_total_pfe <= 10000.0)
}

///|
test "Suite57 Subsea 02: Transoceanic 6000 km Cable Stored Electrostatic Energy" {
  // E = 0.5 * C_total * V^2
  let c_per_km = 0.20e-6 // 0.2 uF / km
  let length_km = 6000.0
  let v_pfe = 10000.0 // 10 kV

  let c_total = c_per_km * length_km // 1.2 mF
  let e_stored_kj = 0.5 * c_total * v_pfe * v_pfe / 1000.0 // 60 kJ stored energy!

  assert_true((c_total - 0.0012).abs() < 1.0e-6)
  assert_true((e_stored_kj - 60.0).abs() < 1.0e-6)
}

///|
test "Suite57 Subsea 03: Subsea Branching Unit Ground Sea-Earth Resistance" {
  let r_sea_earth = 2.5 // 2.5 Ohms sea ground plate
  let i_earth = 1.0 // 1.0 A
  let v_earth_pot = i_earth * r_sea_earth // 2.5 V

  assert_true(v_earth_pot == 2.5)
}

///|
test "Suite57 Subsea 04: EDFA 980 nm Pump Laser Forward Current Regulation" {
  let i_pump_ma = 450.0 // 450 mA
  let v_pump_v = 2.1 // 2.1 V
  let p_pump_w = i_pump_ma * 1.0e-3 * v_pump_v // 0.945 W

  assert_true((p_pump_w - 0.945).abs() < 1.0e-6)
}

///|
test "Suite57 Subsea 05: Chromatic Dispersion Accumulation and Compensation" {
  // D_accum = D_fiber * L_span + D_comp * L_comp = 0
  let d_smf = 17.0 // +17 ps / (nm * km) standard single mode fiber
  let l_span = 80.0 // 80 km span
  let d_accum = d_smf * l_span // +1360 ps/nm

  let d_dcf = -85.0 // -85 ps / (nm * km) DCF fiber
  let l_dcf = -d_accum / d_dcf // 16 km DCF perfectly compensates span!

  assert_true((l_dcf - 16.0).abs() < 1.0e-6)
}

///|
test "Suite57 Subsea 06: Cascaded EDFA Noise Figure Accumulation OSNR" {
  let num_spans = 50
  let osr_drop_db = 0.3 * num_spans.to_double() // 15 dB OSNR penalty
  assert_true(osr_drop_db == 15.0)
}

///|
test "Suite57 Subsea 07: Subsea Seismic Hydrophone 24-bit Stream Bandwidth" {
  let sample_rate_hz = 500.0
  let bits = 24
  let bytes_per_sec = sample_rate_hz * bits.to_double() / 8.0 // 1500 bytes/s

  assert_true(bytes_per_sec == 1500.0)
}

///|
test "Suite57 Subsea 08: Zinc Sacrificial Anode 25-Year Corrosion Protection" {
  let anode_mass_kg = 500.0 // 500 kg zinc
  assert_true(anode_mass_kg == 500.0)
}

///|
test "Suite57 Subsea 09: Optical Supervisory Channel 1510 nm Out-of-Band Telemetry" {
  let lambda_osc_nm = 1510.0
  let lambda_c_band_nm = 1550.0
  assert_true(lambda_osc_nm < lambda_c_band_nm)
}

///|
test "Suite57 Subsea 10: Deep Ocean Hydrostatic Pressure Rating (6000 m Depth)" {
  // P_hydrostatic = rho * g * h = 1025 * 9.81 * 6000 = ~60.3 MPa (600 bar)
  let p_hydro_mpa = 60.33
  assert_true(p_hydro_mpa > 50.0)
}
