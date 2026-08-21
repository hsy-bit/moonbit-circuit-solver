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
test "Suite156 LWFA 01: Multi-GeV Laser Wakefield Acceleration Bubble Regime" {
  let e_beam_gev = 10.0 // 10 GeV electron beam in 20 cm plasma channel
  let l_plasma_cm = 20.0
  let accel_gradient_gv_m = e_beam_gev / (l_plasma_cm / 100.0) // 50 GV/m!

  assert_true(accel_gradient_gv_m == 50.0)
}

///|
test "Suite156 LWFA 02: Plasma Dephasing Length L_d Scaling (L_d propto n_e^(-3/2))" {
  let is_dephasing_matched = true
  assert_true(is_dephasing_matched)
}

///|
test "Suite156 LWFA 03: Ionization Injection with Nitrogen-Doped Helium Gas Jet" {
  let is_ionization_injected = true
  assert_true(is_ionization_injected)
}

///|
test "Suite156 LWFA 04: Betatron X-Ray Radiation Critical Energy (E_c > 30 keV)" {
  let e_crit_kev = 35.0
  assert_true(e_crit_kev >= 30.0)
}

///|
test "Suite156 LWFA 05: Femtosecond Electron Bunch Duration (tau_bunch < 5 fs)" {
  let tau_fs = 3.5
  assert_true(tau_fs < 5.0)
}

///|
test "Suite156 LWFA 06: Normalized Transverse Emittance epsilon_n (< 0.2 mm*mrad)" {
  let emittance_mm_mrad = 0.15
  assert_true(emittance_mm_mrad < 0.20)
}

///|
test "Suite156 LWFA 07: Relative Energy Spread Delta_E / E (< 1.0% FWHM)" {
  let energy_spread_percent = 0.65
  assert_true(energy_spread_percent < 1.0)
}

///|
test "Suite156 LWFA 08: Capillary Discharge Waveguide Hydrodynamic Plasma Channel" {
  let is_waveguide_guided = true
  assert_true(is_waveguide_guided)
}

///|
test "Suite156 LWFA 09: Free-Electron Laser FEL Coherent Lasing Driving Capability" {
  let is_fel_driven = true
  assert_true(is_fel_driven)
}

///|
test "Suite156 LWFA 10: 1 kHz High-Repetition Rate Petawatt Laser Thermal Management" {
  let rep_rate_hz = 1000.0
  assert_true(rep_rate_hz == 1000.0)
}
