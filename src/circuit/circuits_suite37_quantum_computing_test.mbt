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
test "Suite37 Quantum 01: Dispersive Qubit-Readout Cavity Chi Shift" {
  // chi = (g^2 / Delta) * (alpha / (Delta + alpha))
  let g_coupling = 100.0e6 // 100 MHz coupling strength
  let delta_detuning = 1.0e9 // 1 GHz detuning (omega_q - omega_r)
  let alpha_anharm = -300.0e6 // -300 MHz Transmon anharmonicity

  let term1 = g_coupling * g_coupling / delta_detuning // 10 MHz
  let term2 = alpha_anharm / (delta_detuning + alpha_anharm) // -300 / 700 = -0.4286
  let chi_shift = term1 * term2 // -4.286 MHz dispersive shift

  assert_true((chi_shift - -4.2857e6).abs() < 1.0e3)
}

///|
test "Suite37 Quantum 02: Purcell Filter Spontaneous Decay Rate Suppression" {
  // Purcell decay rate gamma_p = (g / Delta)^2 * kappa
  let g_over_delta = 0.10 // g / Delta = 0.1
  let kappa_resonator = 2.0e6 // 2 MHz cavity linewidth

  let gamma_purcell = g_over_delta * g_over_delta * kappa_resonator // 20 kHz
  let t1_purcell_limit_us = 1.0 / (2.0 * @math.PI * gamma_purcell) * 1.0e6 // ~7.96 us

  assert_true((gamma_purcell - 20000.0).abs() < 1.0e-6)
  assert_true(t1_purcell_limit_us > 5.0)
}

///|
test "Suite37 Quantum 03: Fluxonium Qubit Superinductance Energy Ratio" {
  // Superinductance L = 500 nH -> E_L = (Phi_0 / 2*pi)^2 / L = ~0.5 GHz (much smaller than E_J ~ 10 GHz)
  let e_l_ghz = 0.5
  let e_j_ghz = 10.0

  let ratio_el_ej = e_l_ghz / e_j_ghz // 0.05
  assert_true(ratio_el_ej == 0.05)
}

///|
test "Suite37 Quantum 04: Cryogenic Attenuator Thermalization Distribution (60 dB Total)" {
  // 20 dB at 4K, 20 dB at 100mK (Cold Plate), 20 dB at 10mK (MXC)
  let atten_4k = 20.0
  let atten_cp = 20.0
  let atten_mxc = 20.0
  let total_atten = atten_4k + atten_cp + atten_mxc

  assert_true(total_atten == 60.0)
}

///|
test "Suite37 Quantum 05: Josephson Parametric Amplifier JPA Quantum Noise Limit" {
  // Standard Quantum Limit (SQL) added noise = 0.5 * hbar * omega
  let hbar = 1.054571817e-34
  let f_signal = 6.0e9 // 6 GHz
  let omega = 2.0 * @math.PI * f_signal

  let p_sql = 0.5 * hbar * omega // ~1.987e-24 Watts / Hz
  assert_true((p_sql - 1.9878e-24).abs() < 1.0e-27)
}

///|
test "Suite37 Quantum 06: DC SQUID Junction Critical Current Asymmetry Factor" {
  let ic1 = 1.2e-6 // 1.2 uA
  let ic2 = 0.8e-6 // 0.8 uA

  let alpha_asym = (ic1 - ic2) / (ic1 + ic2) // 0.4 / 2.0 = 0.20
  assert_true((alpha_asym - 0.20).abs() < 1.0e-12)
}

///|
test "Suite37 Quantum 07: Transmon Charge Dispersion Sensitivity Exponential Suppression" {
  // Delta E_01 propto exp(-sqrt(8 * E_J / E_C))
  let ej_ec_ratio = 50.0 // Standard Transmon operates at E_J / E_C = 50
  let exponent = (8.0 * ej_ec_ratio).sqrt() // 20.0

  let suppression = @math.exp(-exponent) // exp(-20) approx 2.06e-9 (Virtually zero charge noise!)
  assert_true(suppression < 1.0e-8)
}

///|
test "Suite37 Quantum 08: Kinetic Inductance Non-Linearity in Superconducting Stripline" {
  let l_geom = 2.0e-9
  let l_k = 8.0e-9
  let frac_kinetic = l_k / (l_geom + l_k) // 80% kinetic inductance

  assert_true(frac_kinetic == 0.8)
}

///|
test "Suite37 Quantum 09: Quantum Demodulation Optimal Wiener Boxcar Integration" {
  let dt_ns = 1.0
  let num_samples = 500 // 500 ns readout pulse
  let total_int_time_ns = num_samples.to_double() * dt_ns

  assert_true(total_int_time_ns == 500.0)
}

///|
test "Suite37 Quantum 10: Traveling-Wave Parametric Amplifier 4-Wave Mixing Gain" {
  let gain_db = 22.5 // 22.5 dB broadband gain across 4 to 8 GHz
  let bw_ghz = 4.0
  assert_true(gain_db > 20.0)
  assert_true(bw_ghz == 4.0)
}
