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
test "Suite33 PMIC 01: 4-Phase Interleaved Buck Current Ripple Cancellation" {
  // At D = 0.25 (1/N), total output ripple is theoretically ZERO!
  let d_duty = 0.25
  let n_phases = 4
  let is_zero_ripple_point = (d_duty * n_phases.to_double() - 1.0).abs() <
    1.0e-6

  assert_true(is_zero_ripple_point)
  assert_true(n_phases == 4)
}

///|
test "Suite33 PMIC 02: Dickson 4-Stage Charge Pump Voltage Multiplier" {
  // V_out = (N + 1) * (V_in - V_diode)
  let v_in = 3.3
  let v_diode = 0.30 // Schottky drop
  let num_stages = 4

  let v_out = (num_stages + 1).to_double() * (v_in - v_diode) // 5 * 3.0 = 15.0 V
  assert_true((v_out - 15.0).abs() < 1.0e-6)
}

///|
test "Suite33 PMIC 03: Fibonacci Charge Pump Golden Ratio Step-Up" {
  // Sequence of voltages: 1, 1, 2, 3, 5, 8, 13
  let fib_5 = 8.0 // 8x multiplication with only 5 capacitor cells
  let fib_6 = 13.0
  assert_true(fib_6 > fib_5)
  assert_true(fib_5 == 8.0)
}

///|
test "Suite33 PMIC 04: Cockcroft-Walton Voltage Multiplier Output Ripple" {
  // Delta V = (I_load / (f * C)) * (N * (N + 1) / 2)
  let i_load = 1.0e-3 // 1 mA
  let f_switch = 50.0e3 // 50 kHz
  let c_stage = 100.0e-9 // 100 nF
  let n_stages = 5

  let factor_n = (n_stages * (n_stages + 1)).to_double() / 2.0 // 15
  let v_ripple = i_load / (f_switch * c_stage) * factor_n // (1m / 5m) * 15 = 0.2 * 15 = 3.0 V

  assert_true((v_ripple - 3.0).abs() < 1.0e-6)
}

///|
test "Suite33 PMIC 05: LDO Output Capacitor ESR Zero Frequency" {
  // f_zero_esr = 1 / (2*pi * R_esr * C_out)
  let r_esr = 0.050 // 50 mOhm ESR
  let c_out = 10.0e-6 // 10 uF ceramic

  let f_z_esr = 1.0 / (2.0 * @math.PI * r_esr * c_out) // ~318.3 kHz
  assert_true((f_z_esr - 318309.8).abs() < 10.0)
}

///|
test "Suite33 PMIC 06: Constant On-Time COT Hysteretic Buck Frequency vs Vin" {
  // f_sw = V_out / (V_in * T_on)
  let v_out = 1.0
  let v_in = 12.0
  let t_on = 100.0e-9 // 100 ns on-time

  let f_sw = v_out / (v_in * t_on) // 1.0 / 1.2e-6 = 833.3 kHz
  assert_true((f_sw - 833333.3).abs() < 10.0)
}

///|
test "Suite33 PMIC 07: Current-Mode Boost Converter Slope Compensation" {
  // Required external slope: S_e > 0.5 * S_n (downslope of inductor current) to prevent subharmonic oscillation for D > 0.5
  let s_n = 50.0e3 // 50 kV/s
  let s_e_min = 0.5 * s_n // 25 kV/s

  assert_true(s_e_min == 25.0e3)
}

///|
test "Suite33 PMIC 08: Flyback RCD Snubber Clamping Power Dissipation" {
  // P_snub = 0.5 * L_leak * I_peak^2 * f_sw * (V_clamp / (V_clamp - n*V_out))
  let l_leak = 2.0e-6 // 2 uH leakage inductance
  let i_pk = 4.0 // 4A peak switch current
  let f_sw = 100.0e3 // 100 kHz
  let v_clamp = 150.0
  let v_refl = 100.0 // n * V_out

  let e_leak = 0.5 * l_leak * i_pk * i_pk // 16 uJ
  let factor_clamp = v_clamp / (v_clamp - v_refl) // 150 / 50 = 3.0
  let p_snub = e_leak * f_sw * factor_clamp // 16u * 100k * 3 = 4.8 W

  assert_true((p_snub - 4.8).abs() < 1.0e-6)
}

///|
test "Suite33 PMIC 09: Boost PFC Power Factor and Harmonic Distortion THD" {
  let pf_measured = 0.995
  let thd_current = 0.035 // 3.5% THD
  assert_true(pf_measured > 0.99)
  assert_true(thd_current < 0.05)
}

///|
test "Suite33 PMIC 10: Battery Coulomb Counter Integration Amp-Hour Accuracy" {
  let i_discharge_a = 2.5 // 2.5 A constant discharge
  let t_hours = 2.0 // 2 hours

  let q_ah = i_discharge_a * t_hours // 5.0 Ah
  assert_true(q_ah == 5.0)
}
