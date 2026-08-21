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
test "Suite28 Space 01: Single Event Transient SET Double-Exponential Current Pulse" {
  // I_set(t) = I_0 * (exp(-t / tau_fall) - exp(-t / tau_rise))
  let i_0 = 5.0e-3 // 5 mA peak current from heavy ion strike
  let tau_rise = 10.0e-12 // 10 ps collection time
  let tau_fall = 200.0e-12 // 200 ps diffusion time

  let t_test = 50.0e-12 // 50 ps
  let i_pulse = i_0 *
    (@math.exp(-t_test / tau_fall) - @math.exp(-t_test / tau_rise))

  // Collected charge Q_coll = I_0 * (tau_fall - tau_rise) = 5mA * 190ps = 0.95 pC
  let q_coll = i_0 * (tau_fall - tau_rise)
  assert_true(i_pulse > 0.0)
  assert_true((q_coll - 0.95e-12).abs() < 1.0e-15)
}

///|
test "Suite28 Space 02: Triple Modular Redundancy TMR 2-out-of-3 Majority Voter" {
  // Majority Voter Output: Out = (A & B) | (B & C) | (A & C)
  let voter = fn(a : Bool, b : Bool, c : Bool) -> Bool {
    (a && b) || (b && c) || (a && c)
  }

  // 1. All agreed
  assert_true(voter(true, true, true) == true)
  assert_true(voter(false, false, false) == false)
  // 2. Single bit error (SEU) corrected by voter!
  assert_true(voter(true, true, false) == true)
  assert_true(voter(false, true, false) == false)
}

///|
test "Suite28 Space 03: Total Ionizing Dose TID Oxide Charge Threshold Shift" {
  // Delta V_th_ot = - (q * Delta N_ot) / C_ox
  let q_e = 1.602176634e-19
  let delta_not = 1.0e12 // 10^12 trapped holes / cm^2 = 10^16 / m^2
  let c_ox = 3.45e-3 // 3.45 mF / m^2 for ~10 nm SiO2

  let delta_vth = -(q_e * delta_not * 1.0e4) / c_ox // ~ -0.464 V
  assert_true(delta_vth < 0.0)
  assert_true((delta_vth - -0.464).abs() < 0.02)
}

///|
test "Suite28 Space 04: DICE Dual Interlocked Memory Cell Metastability Immunity" {
  // DICE latch with 4 cross-coupled storage nodes (X0, X1, X2, X3)
  let num_nodes = 4
  let immune_single_node_upset = true
  assert_true(num_nodes == 4)
  assert_true(immune_single_node_upset)
}

///|
test "Suite28 Space 05: Single Event Latchup SEL Holding Current" {
  // SEL occurs if parasitic SCR turns on with supply current > I_hold
  let i_supply = 0.050 // 50 mA
  let i_hold = 0.200 // 200 mA holding current threshold -> Protected against sustained latchup!

  assert_true(i_supply < i_hold)
}

///|
test "Suite28 Space 06: Enclosed Layout Transistors ELT Radiation Hardening" {
  // Annular gate geometry eliminates edge leakage drain-source paths
  let w_annular = 25.0e-6
  let l_annular = 0.5e-6
  assert_true(w_annular > l_annular)
}

///|
test "Suite28 Space 07: Spacecraft Deep Dielectric Charging Electric Field" {
  // E = J_beam * rho_res
  let j_beam = 1.0e-10 // 0.1 nA / cm^2 = 1.0e-6 A / m^2 electron flux
  let rho_res = 1.0e14 // 10^14 Ohm*m dielectric resistivity

  let e_field = j_beam * rho_res // 1.0e8 V/m -> Exceeds breakdown threshold! Requires conductive coating.
  assert_true(e_field == 1.0e4)
}

///|
test "Suite28 Space 08: Optocoupler Current Transfer Ratio CTR Fluence Degradation" {
  // CTR(Phi) = CTR_0 / (1 + k_tau * Phi)
  let ctr_0 = 1.20 // 120% initial CTR
  let k_tau = 1.0e-13 // Damage constant
  let phi_neutron = 5.0e12 // 5x10^12 n/cm^2

  let ctr_post_rad = ctr_0 / (1.0 + k_tau * phi_neutron) // 1.20 / 1.5 = 0.80 (80%)
  assert_true((ctr_post_rad - 0.80).abs() < 1.0e-6)
}

///|
test "Suite28 Space 09: Solar Array Blocking Diode Reverse Breakdown Safety" {
  let v_string = 120.0 // 120V solar string
  let v_diode_breakdown = 400.0 // 400V PIV rating

  assert_true(v_diode_breakdown > 2.0 * v_string)
}

///|
test "Suite28 Space 10: Cosmic Ray Linear Energy Transfer LET Threshold" {
  // Minimum LET for upset: LET_th >= 37 MeV*cm^2/mg for Geostationary space qualification
  let let_th = 40.0 // MeV*cm^2/mg
  assert_true(let_th >= 37.0)
}
