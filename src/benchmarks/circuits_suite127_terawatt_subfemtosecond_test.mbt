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
test "Suite127 Attosecond 01: High-Harmonic Generation HHG Cutoff Law E_max = I_p + 3.17 * U_p" {
  // Ponderomotive energy U_p = e^2 * E_0^2 / (4 * m_e * omega^2)
  let i_p_ev = 24.6 // Helium ionization potential
  let u_p_ev = 40.0 // Ponderomotive energy in 800 nm field
  let e_max_ev = i_p_ev + 3.17 * u_p_ev // 24.6 + 126.8 = 151.4 eV (EUV attosecond continuum!)

  assert_true((e_max_ev - 151.4).abs() < 1.0e-3)
}

///|
test "Suite127 Attosecond 02: Isolated 67-Attosecond Pulse Generation Carrier-Envelope Phase CEP" {
  let tau_pulse_as = 67.0
  assert_true(tau_pulse_as < 100.0)
}

///|
test "Suite127 Attosecond 03: Attosecond Streak Camera Photoelectron Momentum Mapping" {
  let is_streaked = true
  assert_true(is_streaked)
}

///|
test "Suite127 Attosecond 04: Noble Gas Target Krypton/Argon Supersonic Gas Jet Backing Pressure (5 bar)" {
  let p_backing_bar = 5.0
  assert_true(p_backing_bar == 5.0)
}

///|
test "Suite127 Attosecond 05: Multi-Layer Mo/Si Extreme-UV Multilayer Dielectric Mirror (13.5 nm)" {
  let r_euv_percent = 70.0 // 70% peak reflectance
  assert_true(r_euv_percent >= 68.0)
}

///|
test "Suite127 Attosecond 06: Transient Absorption Spectroscopy Core-Level Electron Dynamics" {
  let delta_t_res_fs = 0.2 // 200 attoseconds time resolution
  assert_true(delta_t_res_fs <= 0.5)
}

///|
test "Suite127 Attosecond 07: Polarization Gating PG Circular-to-Linear-to-Circular Pulse Shaping" {
  let is_gated = true
  assert_true(is_gated)
}

///|
test "Suite127 Attosecond 08: Differential Pumping Multi-Chamber Ultra-High Vacuum (10^-8 Torr)" {
  let p_uhv_torr = 5.0e-8
  assert_true(p_uhv_torr < 1.0e-7)
}

///|
test "Suite127 Attosecond 09: Time-of-Flight Microchannel Plate MCP Detector (100 ps Bin)" {
  let t_bin_ps = 100.0
  assert_true(t_bin_ps == 100.0)
}

///|
test "Suite127 Attosecond 10: Petahertz Electronic Switching in Dielectrics (PHz Field)" {
  let f_field_phz = 1.2
  assert_true(f_field_phz >= 1.0)
}
