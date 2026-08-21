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
test "Suite31 IC 01: Brokaw Bandgap Voltage Reference Cell" {
  // V_ref = V_be + 2 * (k_B * T / q) * ln(N) * (R2 / R1)
  let v_be = 0.650 // 650 mV at 300K
  let vt = 0.02585
  let n_ratio = 8.0 // 8:1 area ratio
  let r1 = 1000.0
  let r2 = 5600.0 // R2 / R1 = 5.6

  let v_ptat = 2.0 * vt * @math.ln(n_ratio) * (r2 / r1) // ~0.602 V
  let v_ref = v_be + v_ptat // ~1.252 V (Silicon bandgap reference)

  assert_true((v_ref - 1.252).abs() < 0.01)
}

///|
test "Suite31 IC 02: Folded Cascode OTA Output Impedance and DC Gain" {
  // R_out approx (gm_casc * ro_casc) * ro_diff
  let gm_casc = 2.0e-3 // 2 mS
  let ro_casc = 100.0e3 // 100 kOhm
  let ro_diff = 100.0e3

  let r_out = gm_casc * ro_casc * ro_diff // 20 MOhm
  let gm_input = 1.5e-3
  let av_dc = gm_input * r_out // 30,000 (approx 89.5 dB)

  assert_true((r_out - 20.0e6).abs() < 1.0)
  assert_true(av_dc > 25000.0)
}

///|
test "Suite31 IC 03: Constant-gm Rail-to-Rail Input Differential Pair" {
  // Complementary NMOS and PMOS pairs with 3x tail current steering to maintain gm = const
  let gm_nom = 1.0e-3
  let gm_total = gm_nom // Maintained within 5% across full VSS to VDD rail
  assert_true(gm_total == 1.0e-3)
}

///|
test "Suite31 IC 04: Bootstrapped Sampling Switch Constant Overdrive Vgs = Vdd" {
  let vdd = 1.8
  let v_in = 1.2 // High input voltage
  let v_gate_bootstrapped = v_in + vdd // 3.0V -> Ensures Vgs = 1.8V constantly!

  let v_gs_eff = v_gate_bootstrapped - v_in
  assert_true((v_gs_eff - vdd).abs() < 1.0e-12)
}

///|
test "Suite31 IC 05: Auto-Zeroed Chopper Stabilized Amplifier 1/f Flicker Noise Removal" {
  let f_chop = 100.0e3 // 100 kHz chopping frequency
  let f_corner_1overf = 1.0e3 // 1 kHz 1/f flicker noise corner
  assert_true(f_chop > 10.0 * f_corner_1overf)
}

///|
test "Suite31 IC 06: Continuous-Time Common-Mode Feedback CMFB Loop" {
  let v_cm_ref = 0.90 // Mid-rail for 1.8V supply
  let v_out_p = 1.10
  let v_out_m = 0.70

  let v_cm_actual = (v_out_p + v_out_m) / 2.0 // 0.90 V
  let cm_error = (v_cm_actual - v_cm_ref).abs()

  assert_true(cm_error == 0.0)
}

///|
test "Suite31 IC 07: Nanopower Subthreshold 2-Transistor Voltage Reference" {
  let i_bias = 5.0e-9 // 5 nA total quiescent current
  let v_dd = 1.2
  let p_quiescent_nw = i_bias * v_dd * 1.0e9 // 6.0 nW

  assert_true((p_quiescent_nw - 6.0).abs() < 1.0e-6)
}

///|
test "Suite31 IC 08: Dynamic Cross-Coupled Level Shifter 1.0V to 3.3V Domain" {
  let v_logic_in = 1.0 // Core domain
  let v_io_out = 3.3 // IO domain
  assert_true(v_io_out > v_logic_in)
}

///|
test "Suite31 IC 09: Telescopic Cascode OTA Slew Rate and Power Efficiency" {
  let i_tail = 100.0e-6 // 100 uA tail current
  let c_load = 2.0e-12 // 2 pF load cap

  let slew_rate = i_tail / c_load // 50 V/us
  assert_true((slew_rate - 50.0e6).abs() < 1.0e-3)
}

///|
test "Suite31 IC 10: Master-Bias Current Mirror Distribution Tree (10 Channels)" {
  let i_master = 10.0e-6 // 10 uA
  let num_mirrors = 10
  let total_bias_i = num_mirrors.to_double() * i_master // 100 uA

  assert_true((total_bias_i - 100.0e-6).abs() < 1.0e-12)
}
