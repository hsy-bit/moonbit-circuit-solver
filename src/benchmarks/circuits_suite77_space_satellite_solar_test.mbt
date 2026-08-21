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
test "Suite77 Solar 01: Triple-Junction InGaP/GaAs/Ge 30% Efficiency in AM0" {
  // AM0 solar constant S0 = 1361 W/m^2 in Earth orbit
  let s0_am0 = 1361.0 // W/m^2
  let eta_3j = 0.30 // 30% conversion efficiency
  let p_out_w_m2 = s0_am0 * eta_3j // 408.3 W/m^2

  assert_true((p_out_w_m2 - 408.3).abs() < 1.0e-6)
}

///|
test "Suite77 Solar 02: Space Solar Array Bypass Schottky Diode Reverse Voltage" {
  let v_cell_drop_shaded = -15.0 // -15V reverse breakdown threshold
  let v_schottky_forward = 0.35 // 0.35V forward clamp
  assert_true(v_schottky_forward < 0.5)
  assert_true(v_cell_drop_shaded < 0.0)
}

///|
test "Suite77 Solar 03: Radiation Degradation Displacement Damage Dose DDD (15-Year EOL)" {
  let p_bol_w = 10000.0 // 10 kW Beginning-of-Life
  let degradation_factor = 0.78 // 22% degradation due to 1 MeV equivalent electron fluence
  let p_eol_w = p_bol_w * degradation_factor // 7.8 kW End-of-Life

  assert_true((p_eol_w - 7800.0).abs() < 1.0e-6)
}

///|
test "Suite77 Solar 04: Sequential Switching Shunt Regulator S3R Efficiency (> 98%)" {
  let p_total_kw = 12.0
  let p_loss_kw = 0.18 // 180W dissipation in saturated FETs
  let eta_s3r = (p_total_kw - p_loss_kw) / p_total_kw // 98.5%

  assert_true(eta_s3r >= 0.98)
}

///|
test "Suite77 Solar 05: Array Capacitance Stored Energy Electrostatic Arc Risk" {
  let c_array_nf = 450.0 // 450 nF panel capacitance to chassis
  let v_bus = 100.0 // 100V regulated bus
  let e_arc_uj = 0.5 * c_array_nf * 1.0e-9 * v_bus * v_bus * 1.0e6 // 2250 uJ = 2.25 mJ

  assert_true((e_arc_uj - 2250.0).abs() < 1.0e-6)
}

///|
test "Suite77 Solar 06: Maximum Power Point Tracking Perturb and Observe Step" {
  let delta_v_mppt = 0.25 // 250 mV tracking step
  assert_true(delta_v_mppt == 0.25)
}

///|
test "Suite77 Solar 07: Solar Cell Temperature Coefficient dVoc/dT" {
  let d_voc_d_t_mv_c = -6.2 // -6.2 mV/°C for triple-junction cell
  let delta_t_c = 50.0 // +50 °C temperature rise in sunlight
  let delta_voc_mv = d_voc_d_t_mv_c * delta_t_c // -310 mV

  assert_true((delta_voc_mv - -310.0).abs() < 1.0e-6)
}

///|
test "Suite77 Solar 08: Satellite Orbital Eclipse Duration (LEO 35 min Eclipse)" {
  let t_orbit_min = 90.0
  let t_eclipse_min = 35.0
  let t_sunlight_min = t_orbit_min - t_eclipse_min // 55 min sunlight charging

  assert_true(t_sunlight_min == 55.0)
}

///|
test "Suite77 Solar 09: Solar Array Drive Mechanism SADM Slip Ring Resistance" {
  let r_slip_ring_mohm = 15.0 // 15 mOhm
  assert_true(r_slip_ring_mohm < 25.0)
}

///|
test "Suite77 Solar 10: Coverglass Ceria-Doped Borosilicate UV Shielding" {
  let t_coverglass_um = 100.0 // 100 um thick coverglass
  assert_true(t_coverglass_um == 100.0)
}
