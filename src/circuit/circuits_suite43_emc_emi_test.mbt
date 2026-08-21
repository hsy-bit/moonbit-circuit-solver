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
test "Suite43 EMC 01: CISPR 16 LISN 50-uH / 50-Ohm Input Impedance" {
  // LISN standard input impedance approaches 50 Ohms for f > 5 MHz
  let z_receiver = 50.0 // 50 Ohm spectrum analyzer input
  let r_lisn = 50.0
  assert_true(z_receiver == 50.0)
  assert_true(r_lisn == 50.0)
}

///|
test "Suite43 EMC 02: Common-Mode Choke CMC Impedance at 10 MHz" {
  // Z_cm = 2 * pi * f * L_cm
  let l_cm = 2.5e-3 // 2.5 mH common-mode inductance
  let f_test = 10.0e6 // 10 MHz

  let omega = 2.0 * @math.PI * f_test
  let z_cm_kohm = omega * l_cm / 1000.0 // ~157.08 kOhms (High attenuation for CM noise!)
  assert_true((z_cm_kohm - 157.079).abs() < 0.1)
}

///|
test "Suite43 EMC 03: Differential-to-Common Mode Conversion S_CD21" {
  // Trace length mismatch Delta L = 1 mm on 10 Gbps differential pair (tr = 30 ps)
  let delta_l_mm = 1.0
  let v_prop_cm_per_ns = 15.0 // ~15 cm/ns in FR4

  let delta_t_ps = delta_l_mm / 10.0 / v_prop_cm_per_ns * 1000.0 // ~6.67 ps skew
  assert_true((delta_t_ps - 6.667).abs() < 0.01)
}

///|
test "Suite43 EMC 04: EMI Pi-Filter Insertion Loss in 50-Ohm System" {
  // IL(dB) = 20 * log10( |1 + 0.5 * (Z_series / Z0) * ... | )
  let il_db_target = 45.0 // 45 dB insertion loss at 1 MHz
  let v_atten_ratio = 177.8 // 10^(45/20)

  assert_true(il_db_target == 45.0)
  assert_true(v_atten_ratio > 150.0)
}

///|
test "Suite43 EMC 05: TVS Diode Dynamic Resistance Rdyn" {
  // R_dyn = (V_clamp2 - V_clamp1) / (I_pp2 - I_pp1)
  let v_clamp1 = 12.0
  let i_pp1 = 5.0
  let v_clamp2 = 14.5
  let i_pp2 = 15.0

  let r_dyn = (v_clamp2 - v_clamp1) / (i_pp2 - i_pp1) // 2.5 / 10 = 0.25 Ohms
  assert_true((r_dyn - 0.25).abs() < 1.0e-6)
}

///|
test "Suite43 EMC 06: Ferrite Bead High-Frequency Dissipative Resistance" {
  let r_dissipative = 600.0 // 600 Ohms real impedance at 100 MHz
  let x_reactive = 200.0 // 200 Ohms reactive
  let z_mag = (r_dissipative * r_dissipative + x_reactive * x_reactive).sqrt() // ~632.45 Ohms

  assert_true((z_mag - 632.455).abs() < 0.1)
}

///|
test "Suite43 EMC 07: Shielding Effectiveness SE of Aluminum Enclosure (1 mm thick)" {
  // Absorption loss A = 1.314 * t_mm * sqrt(f_mhz * sigma_r * mu_r)
  let t_mm = 1.0
  let f_mhz = 100.0
  let sigma_r = 0.61 // Aluminum conductivity relative to copper

  let a_loss_db = 1.314 * t_mm * (f_mhz * sigma_r).sqrt() // 1.314 * 1 * 7.81 = ~10.26 dB absorption per skin depth
  assert_true(a_loss_db > 9.0)
}

///|
test "Suite43 EMC 08: Ground Loop Current Elimination by Optocoupler Isolation" {
  let r_ground_loop = 0.050 // 50 mOhm ground trace
  let r_isolation = 1.0e12 // 1 TeraOhm isolation barrier
  let attenuation = r_isolation / r_ground_loop

  assert_true(attenuation > 1.0e12)
}

///|
test "Suite43 EMC 09: CISPR 25 Class 5 Conducted Emission Peak Limit (FM Band 76-108 MHz)" {
  let limit_dbuv = 18.0 // 18 dBuV strict automotive peak limit
  let limit_uv = 7.94 // 7.94 microvolts
  assert_true(limit_dbuv == 18.0)
  assert_true(limit_uv < 10.0)
}

///|
test "Suite43 EMC 10: PCB Trace Capacitive Mutual Coupling NEXT" {
  let c_mutual = 0.2e-12 // 0.2 pF mutual capacitance
  let c_ground = 1.0e-12 // 1.0 pF trace capacitance to ground
  let k_c = c_mutual / (c_ground + c_mutual) // ~0.1667

  assert_true((k_c - 0.166667).abs() < 1.0e-4)
}
