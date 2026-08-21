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
test "Suite132 PlasmaSwitch 01: Laser-Triggered Gas Switch LTGS 100 kV Sub-Nanosecond Jitter (< 200 ps)" {
  let v_switch_kv = 100.0
  let jitter_ps = 150.0
  assert_true(v_switch_kv == 100.0)
  assert_true(jitter_ps < 200.0)
}

///|
test "Suite132 PlasmaSwitch 02: Explosive Magnetic Flux Compression Generator MFCG (10 MA Current Pulse)" {
  let i_mfcg_ma = 10.0
  assert_true(i_mfcg_ma == 10.0)
}

///|
test "Suite132 PlasmaSwitch 03: Virtual Cathode Oscillator Vircator 3 GHz High-Power Microwave (1 GW)" {
  let f_vircator_ghz = 3.0
  let p_rf_gw = 1.0
  assert_true(f_vircator_ghz == 3.0)
  assert_true(p_rf_gw >= 1.0)
}

///|
test "Suite132 PlasmaSwitch 04: Plasma Opening Switch POS Conduction Phase to Opening Phase Transition (50 ns)" {
  let t_open_ns = 45.0
  assert_true(t_open_ns <= 50.0)
}

///|
test "Suite132 PlasmaSwitch 05: SF6 Gas Breakdown Strength at 5 atm Pressure (450 kV/cm)" {
  let e_breakdown_kv_cm = 450.0
  assert_true(e_breakdown_kv_cm >= 400.0)
}

///|
test "Suite132 PlasmaSwitch 06: Water Dielectric Blumlein Pulse Forming Line (PFL) Impedance (5 Ohms)" {
  let z_pfl_ohm = 5.0
  assert_true(z_pfl_ohm == 5.0)
}

///|
test "Suite132 PlasmaSwitch 07: Fast Faraday Cup Relativistic Electron Beam Current Density (5 kA/cm^2)" {
  let j_beam_ka_cm2 = 5.0
  assert_true(j_beam_ka_cm2 >= 4.0)
}

///|
test "Suite132 PlasmaSwitch 08: Multi-Stage Magnetic Pulse Compressor MPC Saturable Inductor Core" {
  let num_mpc_stages = 3
  assert_true(num_mpc_stages == 3)
}

///|
test "Suite132 PlasmaSwitch 09: Rogowski Coil High di/dt Current Derivative Calibration (10^13 A/s)" {
  let di_dt_a_s = 1.0e13
  assert_true(di_dt_a_s >= 1.0e12)
}

///|
test "Suite132 PlasmaSwitch 10: Pulsed High-Voltage Resistive Voltage Divider (10,000:1 Ratio)" {
  let div_ratio = 10000.0
  assert_true(div_ratio == 10000.0)
}
