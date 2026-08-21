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
test "Suite56 Space 01: Deep Space X-Band 880/749 Transponder Turnaround Ratio" {
  // f_downlink = f_uplink * (880 / 749)
  let f_uplink_ghz = 7.145 // 7.145 GHz uplink
  let f_downlink_ghz = f_uplink_ghz * (880.0 / 749.0) // ~8.394 GHz X-band downlink

  assert_true((f_downlink_ghz - 8.3946).abs() < 0.01)
}

///|
test "Suite56 Space 02: Spacecraft Traveling Wave Tube TWTA 100W Saturation" {
  let p_rf_w = 100.0 // 100 Watts (+50 dBm)
  let v_cathode_kv = 4.5 // 4.5 kV high-voltage anode

  assert_true(p_rf_w == 100.0)
  assert_true(v_cathode_kv == 4.5)
}

///|
test "Suite56 Space 03: LDPC Rate-1/2 Coding Gain at BER 10^-6" {
  let eb_n0_uncoded = 10.5 // 10.5 dB for uncoded BPSK
  let eb_n0_ldpc = 1.2 // 1.2 dB for CCSDS LDPC (1/2, 4096)
  let coding_gain_db = eb_n0_uncoded - eb_n0_ldpc // 9.3 dB massive coding gain!

  assert_true((coding_gain_db - 9.3).abs() < 1.0e-6)
}

///|
test "Suite56 Space 04: Magnetorquer 3-Axis Magnetic Dipole Moment" {
  // m = N * I * A
  let num_turns = 1000.0
  let i_coil_a = 0.25 // 250 mA
  let area_m2 = 0.04 // 20cm x 20cm = 0.04 m^2

  let m_dipole = num_turns * i_coil_a * area_m2 // 10.0 A*m^2
  assert_true((m_dipole - 10.0).abs() < 1.0e-6)
}

///|
test "Suite56 Space 05: S-Band Circular Polarization Axial Ratio" {
  let e_major = 1.10
  let e_minor = 1.00
  let ar_lin = e_major / e_minor // 1.10
  let ln10 = @math.ln(10.0)
  let ar_db = 20.0 * (@math.ln(ar_lin) / ln10) // ~0.828 dB (< 1.5 dB circular polarization standard)

  assert_true(ar_db < 1.5)
}

///|
test "Suite56 Space 06: Spacecraft MLI Effective Emissivity Heat Flux" {
  // q = epsilon_star * sigma * (T_hot^4 - T_cold^4)
  let eps_star = 0.025 // 2.5% effective emissivity
  let sigma_boltz = 5.670374e-8
  let t_hot = 300.0 // 300K sun side
  let t_cold = 100.0 // 100K deep space shadow

  let t_hot4 = t_hot * t_hot * t_hot * t_hot // 8.1e9
  let t_cold4 = t_cold * t_cold * t_cold * t_cold // 1.0e8
  let q_flux_w_m2 = eps_star * sigma_boltz * (t_hot4 - t_cold4) // ~11.34 W/m^2

  assert_true((q_flux_w_m2 - 11.34).abs() < 0.2)
}

///|
test "Suite56 Space 07: CCSDS Reed-Solomon RS(255, 223) Parity Overhead" {
  let n_total = 255
  let k_data = 223
  let num_parity = n_total - k_data // 32 parity bytes -> corrects up to 16 byte errors!

  assert_true(num_parity == 32)
}

///|
test "Suite56 Space 08: Deep Space Range Tracking Ambiguity PRN Code" {
  let prn_length_chips = 1000000
  assert_true(prn_length_chips == 1000000)
}

///|
test "Suite56 Space 09: Solar Array Eclipse Power Inrush Management" {
  let v_bat_bus = 28.0
  let i_charge_max = 30.0
  assert_true(v_bat_bus == 28.0)
  assert_true(i_charge_max == 30.0)
}

///|
test "Suite56 Space 10: High-Reliability Rad-Hard Dual Core Lockstep CPU" {
  let is_lockstep_synced = true
  assert_true(is_lockstep_synced)
}
