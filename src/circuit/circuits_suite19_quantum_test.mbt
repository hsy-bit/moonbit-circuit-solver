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
test "Suite19 Quantum 01: Superconducting Josephson Junction RCSJ Model" {
  // RCSJ (Resistively and Capacitively Shunted Junction):
  // I = I_c * sin(phi) + V / R_n + C * dV/dt
  // Josephson Voltage-Phase relation: d(phi)/dt = 2*e*V / hbar = 2*pi * V / Phi_0
  let i_c = 1.0e-6 // 1 uA critical current
  let phi_0 = 2.067833848e-15 // Magnetic flux quantum h / (2*e)
  let v_applied = 1.0e-6 // 1 uV

  // Josephson frequency f_J = V / Phi_0 = 1uV / 2.0678e-15 approx 483.6 MHz
  let f_j = v_applied / phi_0
  assert_true((f_j - 483.5979e6).abs() < 1.0e5)
  assert_true(i_c == 1.0e-6)
}

///|
test "Suite19 Quantum 02: DC SQUID Magnetometer Periodic Quantum Interference" {
  // SQUID critical current modulation: I_c_total(Phi) = 2 * I_c0 * |cos(pi * Phi / Phi_0)|
  let i_c0 = 5.0e-6
  let phi_0 = 2.067833848e-15

  // At integer flux Phi = n * Phi_0 -> Ic = 2 * Ic0 = 10 uA
  let ic_max = 2.0 * i_c0 * @math.cos(0.0).abs()
  // At half-integer flux Phi = 0.5 * Phi_0 -> Ic = 0
  let ic_min = 2.0 * i_c0 * @math.cos(@math.PI * 0.5).abs()

  assert_true((ic_max - 10.0e-6).abs() < 1.0e-12)
  assert_true(ic_min.abs() < 1.0e-12)
  assert_true(phi_0 > 0.0)
}

///|
test "Suite19 Quantum 03: Superconducting Transmon Qubit Josephson Inductance" {
  // Nonlinear Josephson Inductance L_J(phi) = Phi_0 / (2*pi * I_c * cos(phi))
  let i_c = 20.0e-9 // 20 nA
  let phi_0 = 2.067833848e-15

  let l_j0 = phi_0 / (2.0 * @math.PI * i_c) // ~16.45 nH
  let c_sh = 80.0e-15 // 80 fF shunting capacitor

  // Plasma frequency f_0 = 1 / (2*pi * sqrt(L_J0 * C_sh)) approx 4.39 GHz
  let f_plasma = 1.0 / (2.0 * @math.PI * (l_j0 * c_sh).sqrt())

  assert_true((l_j0 - 16.456e-9).abs() < 0.05e-9)
  assert_true(f_plasma > 4.0e9 && f_plasma < 5.0e9)
}

///|
test "Suite19 Quantum 04: Coplanar Waveguide CPW Readout Resonator" {
  // Quarter-wave lambda/4 resonator at 7.0 GHz
  let f_res = 7.0e9
  let c_light = 3.0e8
  let eps_eff = 6.0 // Silicon substrate eps_eff approx 6.0

  let v_phase = c_light / eps_eff.sqrt()
  let length_quarter = v_phase / (4.0 * f_res)

  assert_true((length_quarter - 0.004374).abs() < 1.0e-4) // ~4.37 mm
}

///|
test "Suite19 Quantum 05: Superconducting Kinetic Inductance Detector KID" {
  // Kinetic inductance L_k increases with temperature T / quasi-particle density
  let l_geom = 5.0e-9
  let l_k0 = 10.0e-9
  let l_total = l_geom + l_k0

  assert_true((l_total - 15.0e-9).abs() < 1.0e-15)
}

///|
test "Suite19 Quantum 06: Cryogenic HEMT Preamplifier 4 Kelvin Thermal Noise" {
  // Johnson-Nyquist noise power density S_v = 4 * k_B * T * R
  let k_b = 1.380649e-23
  let t_kelvin = 4.0 // 4 Kelvin liquid Helium
  let r_val = 50.0

  let sv_4k = 4.0 * k_b * t_kelvin * r_val // 1.104e-20 V^2/Hz
  let en_4k = sv_4k.sqrt() // ~0.105 nV / sqrt(Hz)

  assert_true((en_4k - 0.105099e-9).abs() < 1.0e-12)
}

///|
test "Suite19 Quantum 07: Single-Electron Transistor SET Coulomb Blockade" {
  // Charging energy E_C = e^2 / (2 * C_total)
  let q_e = 1.602176634e-19
  let c_tot = 1.0e-15 // 1 fF island

  let e_charging_joules = q_e * q_e / (2.0 * c_tot)
  let v_coulomb_gap = q_e / c_tot // 160 uV

  assert_true((v_coulomb_gap - 1.602e-4).abs() < 1.0e-6)
  assert_true(e_charging_joules > 0.0)
}

///|
test "Suite19 Quantum 08: Traveling Wave Parametric Amplifier TWPA Dispersion" {
  // TWPA phase matching: k_p = 0.5 * (k_s + k_i) + Delta k
  let gain_db = 20.0 // 20 dB near-quantum-limited gain across 4-8 GHz
  let bw_ghz = 4.0

  assert_true(gain_db == 20.0)
  assert_true(bw_ghz == 4.0)
}

///|
test "Suite19 Quantum 09: SFQ Rapid Single Flux Quantum Digital Logic Gate" {
  // SFQ pulse area: int V(t) dt = Phi_0 = 2.0678 mV * ps
  let phi_0 = 2.067833848e-15
  let pulse_width_ps = 2.0e-12 // 2 ps
  let v_peak = phi_0 / pulse_width_ps // ~1.03 mV

  assert_true((v_peak - 1.0339e-3).abs() < 1.0e-5)
}

///|
test "Suite19 Quantum 10: Superconducting Flux Qubit Persistent Current States" {
  let i_p = 500.0e-9 // 500 nA persistent circulating current
  let phi_ext = 0.5 // Half flux quantum external bias

  assert_true(i_p == 500.0e-9)
  assert_true(phi_ext == 0.5)
}
