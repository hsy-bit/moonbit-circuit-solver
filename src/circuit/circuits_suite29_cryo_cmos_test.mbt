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
test "Suite29 Cryo 01: Cryogenic 4.2K Thermal Voltage" {
  // U_T = k_B * T / q
  let k_b = 1.380649e-23
  let q_e = 1.602176634e-19
  let t_liquid_he = 4.2 // 4.2 Kelvin liquid helium

  let u_t_4k = k_b * t_liquid_he / q_e // ~362 microvolts (vs 25.85 mV at room temp!)
  assert_true((u_t_4k - 0.0003619).abs() < 1.0e-6)
}

///|
test "Suite29 Cryo 02: Cryogenic Subthreshold Slope Steepening" {
  // S = ln(10) * n * (k_B * T / q)
  let n_factor = 1.15
  let k_b = 1.380649e-23
  let q_e = 1.602176634e-19
  let ln10 = @math.ln(10.0)

  let s_300k = ln10 * n_factor * (k_b * 300.0 / q_e) * 1000.0 // ~68.4 mV/decade
  let s_4k = ln10 * n_factor * (k_b * 4.2 / q_e) * 1000.0 // ~0.958 mV/decade

  assert_true(s_4k < 1.5) // Less than 1.5 mV/dec at 4.2K
  assert_true(s_300k > 60.0)
}

///|
test "Suite29 Cryo 03: Dopant Freeze-Out Incomplete Ionization Ratio" {
  // At 77K Liquid Nitrogen: Fraction ionized = 1 / (1 + 2 * exp(E_d / k_B T))
  let e_d_joules = 0.045 * 1.602e-19 // 45 meV Boron ionization energy in Silicon
  let k_b = 1.380649e-23
  let t_77k = 77.0

  let ratio_arg = e_d_joules / (k_b * t_77k)
  let ion_fraction = 1.0 / (1.0 + 2.0 * @math.exp(ratio_arg))

  assert_true(ion_fraction > 0.0 && ion_fraction < 0.10) // Freeze-out causes >90% neutral dopants
}

///|
test "Suite29 Cryo 04: Cryogenic MOSFET Threshold Voltage Increase" {
  // V_th(4K) approx V_th(300K) + 0.15V to 0.25V due to Fermi level shift
  let v_th_300k = 0.40
  let delta_vth_cryo = 0.20
  let v_th_4k = v_th_300k + delta_vth_cryo // 0.60 V

  assert_true((v_th_4k - 0.60).abs() < 1.0e-6)
}

///|
test "Suite29 Cryo 05: Cryogenic Carrier Mobility and Saturated Velocity Peak" {
  // Phonon scattering freezes out -> electron mobility increases by 5x at 77K
  let mu_300k = 400.0 // cm^2 / V*s
  let mu_cryo = 2000.0

  assert_true(mu_cryo / mu_300k == 5.0)
}

///|
test "Suite29 Cryo 06: Cryogenic LNA Low-Noise Temperature (T_noise < 4 Kelvin)" {
  // Johnson noise drops linearly with physical temperature T
  let t_phys = 4.2
  let t_noise = 2.8 // 2.8 Kelvin equivalent noise temperature

  assert_true(t_noise < t_phys)
}

///|
test "Suite29 Cryo 07: Cryo-CMOS Qubit XY Pulse Controller DAC Clock Jitter" {
  let f_dac = 1.0e9 // 1 Gsps DAC
  let jitter_rms_fs = 80.0 // 80 femtoseconds RMS clock jitter
  assert_true(jitter_rms_fs < 100.0)
  assert_true(f_dac == 1.0e9)
}

///|
test "Suite29 Cryo 08: Dilution Refrigerator 4K Stage Cooling Power Margin" {
  // Pulse tube cooler cooling power at 4.2K stage = 1.5 Watts
  let p_cooling_budget_w = 1.50
  let p_chip_dissipation_w = 0.35 // 350 mW total dissipation of cryo-CMOS ASIC

  let margin_w = p_cooling_budget_w - p_chip_dissipation_w
  assert_true(margin_w > 1.0)
}

///|
test "Suite29 Cryo 09: SiGe Heterojunction Bipolar Transistor Beta Boost at 4K" {
  // Bandgap narrowing Delta E_g in SiGe base: Beta(T) propto exp(Delta E_g / k_B T) -> Beta rises dramatically at low T!
  let beta_300k = 200.0
  let beta_cryo = 2500.0 // 2500 at 77K

  assert_true(beta_cryo > 10.0 * beta_300k)
}

///|
test "Suite29 Cryo 10: 50-Ohm Superconductor-to-Semiconductor Transmission Interface" {
  let z0 = 50.0 // 50 Ohm matched interface
  let r_load = 50.0

  let gamma_match = (r_load - z0) / (r_load + z0)
  assert_true(gamma_match == 0.0)
}
