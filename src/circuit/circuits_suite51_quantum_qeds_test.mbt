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
test "Suite51 cQED 01: Jaynes-Cummings Vacuum Rabi Splitting 2*g" {
  // 2*g splitting at zero detuning Delta = 0
  let g_mhz = 120.0 // 120 MHz coupling
  let rabi_split_mhz = 2.0 * g_mhz // 240 MHz

  assert_true(rabi_split_mhz == 240.0)
  assert_true(g_mhz > 100.0)
}

///|
test "Suite51 cQED 02: Critical Photon Number n_crit for Dispersive Breakdown" {
  // n_crit = (Delta / (2 * g))^2
  let delta_detuning_mhz = 800.0 // 800 MHz detuning
  let g_coupling_mhz = 80.0 // 80 MHz coupling

  let ratio = delta_detuning_mhz / (2.0 * g_coupling_mhz) // 800 / 160 = 5.0
  let n_crit = ratio * ratio // 25 photons

  assert_true((n_crit - 25.0).abs() < 1.0e-6)
}

///|
test "Suite51 cQED 03: Transmon Josephson Energy from Ambient Ambegaokar-Baratoff" {
  // I_c * R_n = (pi * Delta_super / (2 * e))
  let delta_super_ev = 200.0e-6 // 200 ueV Aluminum gap
  let r_normal = 8000.0 // 8 kOhm junction resistance

  let i_c_na = @math.PI * delta_super_ev / (2.0 * r_normal) * 1.0e9 // ~39.27 nA
  assert_true((i_c_na - 39.2699).abs() < 0.01)
}

///|
test "Suite51 cQED 04: Coplanar Resonator Internal Quality Factor Qi at Single Photon Level" {
  // 1/Q_tot = 1/Q_int + 1/Q_ext
  let q_int = 1.5e6 // 1.5 Million internal quality factor
  let q_ext = 50.0e3 // 50,000 coupling Q

  let q_tot = 1.0 / (1.0 / q_int + 1.0 / q_ext) // ~48.38k
  assert_true(q_tot < q_ext)
  assert_true(q_int > 1.0e6)
}

///|
test "Suite51 cQED 05: AC Stark Shift Cavity Pull per Photon" {
  // Delta omega_q = 2 * chi * n_photons
  let chi_shift_mhz = -2.5
  let n_photons = 4.0

  let ac_stark_mhz = 2.0 * chi_shift_mhz * n_photons // -20.0 MHz
  assert_true((ac_stark_mhz - -20.0).abs() < 1.0e-6)
}

///|
test "Suite51 cQED 06: Superconducting Resonator Kinetic Inductance Fraction" {
  let alpha_k = 0.35 // 35% kinetic inductance fraction in NbN film
  let f_0_geom = 8.0e9 // 8 GHz purely geometric
  let f_0_loaded = f_0_geom / (1.0 + alpha_k).sqrt() // ~6.86 GHz

  assert_true(f_0_loaded < f_0_geom)
  assert_true(alpha_k == 0.35)
}

///|
test "Suite51 cQED 07: Transmon Anharmonicity alpha = - E_C" {
  // Charging energy E_C = e^2 / (2 * C_total) = h * 250 MHz
  let c_total_ff = 77.5 // 77.5 fF
  let q_e = 1.602176634e-19
  let h_planck = 6.62607015e-34

  let e_c_hz = q_e * q_e / (2.0 * c_total_ff * 1.0e-15) / h_planck // ~249.7 MHz
  assert_true((e_c_hz - 249.7e6).abs() < 1.0e6)
}

///|
test "Suite51 cQED 08: Sideband Cooling Resolving Criterion (kappa << omega_m)" {
  let kappa_hz = 100.0e3 // 100 kHz optical/microwave cavity decay
  let omega_m_hz = 10.0e6 // 10 MHz mechanical motional mode
  let is_resolved = kappa_hz < omega_m_hz / 10.0

  assert_true(is_resolved)
}

///|
test "Suite51 cQED 09: Quantum Non-Demolition QND Measurement Fidelity" {
  let qnd_fidelity = 0.992 // 99.2% QND repeatability
  assert_true(qnd_fidelity > 0.99)
}

///|
test "Suite51 cQED 10: 2-Qubit Cross-Resonance CR Gate ZX Interaction Rate" {
  // omega_zx = (g12 * Omega_drive * alpha2) / (Delta_12 * (Delta_12 - alpha2))
  let g12 = 10.0e6
  let omega_drive = 50.0e6
  let delta12 = 200.0e6
  let alpha2 = -300.0e6

  let denom = delta12 * (delta12 - alpha2) // 200M * 500M = 1.0e17
  let num = g12 * omega_drive * alpha2.abs() // 10M * 50M * 300M = 1.5e23
  let omega_zx_mhz = num / denom / 1.0e6 // ~1.5 MHz

  assert_true((omega_zx_mhz - 1.5).abs() < 0.05)
}
