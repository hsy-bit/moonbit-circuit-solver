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
test "Suite58 Magnet 01: Tokamak TF Coil 40 Gigajoule Stored Magnetic Energy" {
  // E = 0.5 * L * I^2
  let l_mag = 16.0 // 16 Henry total Toroidal Field coil inductance
  let i_op = 70.0e3 // 70 kA operating current

  let e_stored_gj = 0.5 * l_mag * i_op * i_op / 1.0e9 // 39.2 Gigajoules!
  assert_true((e_stored_gj - 39.2).abs() < 0.1)
}

///|
test "Suite58 Magnet 02: Quench Fast Energy Dump Resistor Discharge Time Constant" {
  // tau = L / R_dump
  let l_coil = 2.0 // 2 Henry
  let r_dump = 0.20 // 200 mOhm water-cooled stainless steel dump resistor

  let tau_dump_s = l_coil / r_dump // 10.0 seconds
  let v_terminal_max_kv = 40.0e3 * r_dump / 1000.0 // 8.0 kV maximum terminal discharge voltage

  assert_true((tau_dump_s - 10.0).abs() < 1.0e-6)
  assert_true((v_terminal_max_kv - 8.0).abs() < 1.0e-6)
}

///|
test "Suite58 Magnet 03: Inductive Voltage Compensation Quench Detection" {
  // V_resistive = V_terminal - M * (di_ref/dt)
  let v_terminal = 1.050 // 1050 mV
  let v_inductive_comp = 1.000 // 1000 mV L*di/dt compensation

  let v_resistive_quench = v_terminal - v_inductive_comp // 50 mV (Exceeds 20 mV threshold -> Quench trigger!)
  assert_true((v_resistive_quench - 0.050).abs() < 1.0e-6)
}

///|
test "Suite58 Magnet 04: Adiabatic Hot Spot MIITs Integral Limit" {
  // MIITs = int_0^inf I(t)^2 dt * 10^-6
  let i0_ka = 50.0 // 50 kA
  let tau_dump = 8.0 // 8 s

  // For exponential decay: int I0^2 * exp(-2t/tau) dt = I0^2 * tau / 2
  let miits = i0_ka * i0_ka * (tau_dump / 2.0) // 2500 * 4 = 10,000 MA^2*s
  assert_true((miits - 10000.0).abs() < 1.0e-6)
}

///|
test "Suite58 Magnet 05: Superconducting Splice Joint 1 Nano-Ohm Resistance" {
  let r_splice = 1.0e-9 // 1 nOhm
  let i_curr = 20.0e3 // 20 kA
  let p_dissipation_mw = i_curr * i_curr * r_splice * 1000.0 // 400 mW at 4K

  assert_true((p_dissipation_mw - 400.0).abs() < 1.0e-6)
}

///|
test "Suite58 Magnet 06: MRI 3-Tesla Superconducting Magnet Persistent Switch" {
  let r_switch_cold = 0.0 // Zero resistance in persistent superconducting mode
  let r_switch_heated = 50.0 // 50 Ohms during ramp/charge
  assert_true(r_switch_cold == 0.0)
  assert_true(r_switch_heated == 50.0)
}

///|
test "Suite58 Magnet 07: High-Temperature Superconductor HTS Tape Critical Current" {
  let i_c_77k = 250.0 // 250 A at 77K self-field
  let i_c_20k = 800.0 // 800 A at 20K
  assert_true(i_c_20k > 3.0 * i_c_77k)
}

///|
test "Suite58 Magnet 08: Non-Insulated HTS NI Coil Radial Contact Resistance" {
  let r_contact_radial = 0.0001 // 100 uOhm radial bypass -> Self-protecting against quench
  assert_true(r_contact_radial < 0.001)
}

///|
test "Suite58 Magnet 09: Quench Protection Pyro-Breaker Interruption Time" {
  let t_pyro_trip_ms = 1.2 // 1.2 ms explosive pyro-breaker action
  assert_true(t_pyro_trip_ms < 2.0)
}

///|
test "Suite58 Magnet 10: Liquid Helium Cryostat Evaporation Heat Load" {
  let latent_heat_j_per_l = 2600.0 // 2.6 kJ / Liter liquid helium
  let q_heat_leak_w = 2.6 // 2.6 W heat leak
  let boil_off_l_per_hour = q_heat_leak_w * 3600.0 / latent_heat_j_per_l // 3.6 Liters / hour

  assert_true((boil_off_l_per_hour - 3.6).abs() < 1.0e-6)
}
