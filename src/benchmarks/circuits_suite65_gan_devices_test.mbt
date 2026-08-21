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
test "Suite65 GaN 01: AlGaN/GaN Heterojunction 2DEG Sheet Carrier Density" {
  // n_s = 1.0e13 cm^-2 = 1.0e17 m^-2
  // Sheet resistance R_sheet = 1 / (q * mu * n_s)
  let q_e = 1.602176634e-19
  let mu_2deg = 0.20 // 2000 cm^2/V*s = 0.20 m^2/V*s
  let n_s = 1.0e17 // 1.0e17 m^-2

  let r_sheet = 1.0 / (q_e * mu_2deg * n_s) // ~312 Ohms / sq
  assert_true((r_sheet - 312.077).abs() < 1.0)
}

///|
test "Suite65 GaN 02: Zero Reverse Recovery Charge Qrr = 0 in GaN HEMT" {
  // Majority carrier device has NO minority carrier storage!
  let q_rr_gan = 0.0
  let q_rr_silicon_diode = 50.0e-9 // 50 nC

  assert_true(q_rr_gan == 0.0)
  assert_true(q_rr_silicon_diode > 0.0)
}

///|
test "Suite65 GaN 03: Ultrafast Switching 150 V/ns dv/dt Rate" {
  let delta_v = 400.0 // 400V hard switching
  let t_sw_ns = 2.67 // 2.67 ns transition time

  let dv_dt = delta_v / t_sw_ns // 150 V/ns
  assert_true((dv_dt - 150.0).abs() < 1.0)
}

///|
test "Suite65 GaN 04: GaN Miller Ratio Cgd / Cgs Margin Against False Turn-On" {
  let c_gd = 5.0e-12 // 5 pF
  let c_gs = 200.0e-12 // 200 pF
  let miller_ratio = c_gd / c_gs // 0.025 (< 0.05 safe threshold)

  assert_true(miller_ratio <= 0.05)
}

///|
test "Suite65 GaN 05: 10 MHz Resonant Inverter Gate Drive Power" {
  // P_gate = Q_gate * V_gs * f_sw
  let q_gate = 4.0e-9 // 4 nC
  let v_gs = 5.0 // 5.0 V gate drive
  let f_sw = 10.0e6 // 10 MHz

  let p_gate_w = q_gate * v_gs * f_sw // 0.20 W (200 mW)
  assert_true((p_gate_w - 0.20).abs() < 1.0e-6)
}

///|
test "Suite65 GaN 06: Enhancement-Mode p-GaN Gate Threshold Voltage" {
  let v_th_e_mode = 1.45 // 1.45V normally-off threshold
  assert_true(v_th_e_mode > 1.0 && v_th_e_mode < 2.0)
}

///|
test "Suite65 GaN 07: Dynamic Rds(on) Trapping Ratio at 400V Hard Switching" {
  let r_ds_dc = 0.025 // 25 mOhm static
  let r_ds_dyn = 0.028 // 28 mOhm dynamic (Under 15% increase!)
  let ratio = r_ds_dyn / r_ds_dc // 1.12

  assert_true(ratio < 1.20)
}

///|
test "Suite65 GaN 08: GaN-on-Diamond Thermal Substrate Advantage" {
  let k_diamond = 2000.0 // 2000 W/m*K
  let k_silicon = 150.0 // 150 W/m*K
  let ratio_k = k_diamond / k_silicon // 13.33x

  assert_true(ratio_k > 10.0)
}

///|
test "Suite65 GaN 09: Gate Driver Parasitic Loop Inductance Induced Vgs Spike" {
  // Delta V_gs = L_common_source * (di_drain / dt)
  let l_cs_nh = 0.5e-9 // 0.5 nH
  let di_dt_a_per_ns = 20.0e9 // 20 A/ns = 2e10 A/s

  let delta_vgs_spike = l_cs_nh * di_dt_a_per_ns // 10.0 V -> Critical to eliminate via Kelvin source!
  assert_true((delta_vgs_spike - 10.0).abs() < 1.0e-6)
}

///|
test "Suite65 GaN 10: Monolithic Integrated eGaN Half-Bridge Area" {
  let die_area_mm2 = 12.5
  assert_true(die_area_mm2 < 20.0)
}
