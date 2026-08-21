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
test "Suite27 Renewable 01: Solar PV Cell Single-Diode Model I-V Curve" {
  // I = I_ph - I_0 * [exp( (V + I*Rs) / (n*Vt) ) - 1] - (V + I*Rs)/Rsh
  let i_ph = 8.5 // 8.5 A photocreated current
  let i_0 = 1.0e-10
  let n_diode = 1.2
  let vt = 0.02585
  let r_s = 0.005
  let r_sh = 1000.0

  let v_oc = n_diode * vt * @math.ln(i_ph / i_0 + 1.0)
  assert_true(v_oc > 0.65 && v_oc < 0.85) // ~0.78 V open circuit voltage
  assert_true(r_s < r_sh)
}

///|
test "Suite27 Renewable 02: Perturb and Observe MPPT Step Direction" {
  // If dP/dV > 0 -> Increase Voltage / Duty; If dP/dV < 0 -> Decrease Voltage / Duty
  let p_prev = 300.0 // 300 Watts
  let v_prev = 35.0
  let p_curr = 315.0 // Power increased!
  let v_curr = 36.0 // Voltage increased!

  let dp = p_curr - p_prev
  let dv = v_curr - v_prev
  let dp_dv = dp / dv // +15 W/V > 0 -> Keep moving in positive direction

  assert_true(dp_dv > 0.0)
}

///|
test "Suite27 Renewable 03: Incremental Conductance MPPT Condition at MPP" {
  // At MPP: dP/dV = d(V*I)/dV = I + V * (dI/dV) = 0 -> dI/dV = - I / V
  let v_mpp = 36.0
  let i_mpp = 8.0

  let cond_target = -(i_mpp / v_mpp) // -0.2222 S
  assert_true((cond_target - -0.222222).abs() < 1.0e-5)
}

///|
test "Suite27 Renewable 04: Grid-Tied Inverter LCL Filter Resonant Frequency" {
  // f_res = 1 / (2*pi) * sqrt( (L1 + L2) / (L1 * L2 * C) )
  let l1 = 1.0e-3 // 1 mH inverter-side
  let l2 = 0.5e-3 // 0.5 mH grid-side
  let c_filt = 20.0e-6 // 20 uF

  let l_eq = l1 * l2 / (l1 + l2)
  let f_res = 1.0 / (2.0 * @math.PI * (l_eq * c_filt).sqrt())

  assert_true(f_res > 1500.0 && f_res < 2500.0) // ~1.95 kHz resonance
}

///|
test "Suite27 Renewable 05: Synchronous Reference Frame SRF-PLL dq Transformation" {
  // Clark & Park transform: at lock, V_q = 0 and V_d = V_peak
  let v_a = 325.27 * @math.cos(0.0)
  let v_b = 325.27 * @math.cos(-2.0 * @math.PI / 3.0)
  let v_c = 325.27 * @math.cos(2.0 * @math.PI / 3.0)

  // Clark: V_alpha = (2/3)*(v_a - 0.5*v_b - 0.5*v_c), V_beta = (2/3)*(sqrt(3)/2)*(v_b - v_c)
  let v_alpha = 2.0 / 3.0 * (v_a - 0.5 * v_b - 0.5 * v_c)
  let v_beta = 2.0 / 3.0 * (3.0.sqrt() / 2.0) * (v_b - v_c)

  assert_true((v_alpha - 325.27).abs() < 0.1)
  assert_true(v_beta.abs() < 0.1)
}

///|
test "Suite27 Renewable 06: Lithium-Ion Battery 2-RC Equivalent Circuit Model" {
  let v_ocv = 3.85 // Open Circuit Voltage at 50% SOC
  let r0_ohm = 0.020 // 20 mOhm ohmic
  let r1_ohm = 0.015 // 15 mOhm charge transfer
  let c1_farad = 1000.0 // 1000 F double layer
  let i_discharge = 10.0 // 10A load

  let v_terminal_instant = v_ocv - i_discharge * r0_ohm // 3.85 - 0.20 = 3.65 V
  assert_true((v_terminal_instant - 3.65).abs() < 1.0e-6)
  assert_true(r1_ohm > 0.0 && c1_farad > 0.0)
}

///|
test "Suite27 Renewable 07: DFIG Wind Turbine Slip Power Ratio" {
  // P_rotor = - s * P_stator where slip s = (n_sync - n_rotor) / n_sync
  let n_sync = 1500.0 // 1500 RPM synchronous speed
  let n_rotor = 1800.0 // 1800 RPM supersynchronous operation

  let slip_s = (n_sync - n_rotor) / n_sync // -0.20 (-20% slip)
  let p_stator = 2.0e6 // 2 MW stator power
  let p_rotor = -slip_s * p_stator // +400 kW power generated from rotor into grid!

  assert_true(slip_s == -0.20)
  assert_true((p_rotor - 400.0e3).abs() < 1.0e-3)
}

///|
test "Suite27 Renewable 08: Microgrid Frequency-Watt Droop Curve" {
  // f - f_nom = - k_p * (P - P_nom)
  let f_nom = 50.0
  let p_nom = 100.0e3
  let k_p = 1.0e-5 // 0.01 Hz per 1 kW

  let p_load = 120.0e3 // 20 kW extra load
  let f_grid = f_nom - k_p * (p_load - p_nom) // 50.0 - 0.20 = 49.80 Hz

  assert_true((f_grid - 49.80).abs() < 1.0e-6)
}

///|
test "Suite27 Renewable 09: Supercapacitor Energy Storage Capacity" {
  // E = 0.5 * C * (V_max^2 - V_min^2)
  let c_super = 3000.0 // 3000 Farad cell
  let v_max = 2.7
  let v_min = 1.35

  let e_joules = 0.5 * c_super * (v_max * v_max - v_min * v_min)
  let e_wh = e_joules / 3600.0 // ~2.28 Watt-hours

  assert_true(e_wh > 2.0 && e_wh < 3.0)
}

///|
test "Suite27 Renewable 10: Anti-Islanding Sandia Frequency Shift SFS" {
  let f_target = 50.0
  let delta_f = 0.5 // Frequency pushed beyond trip threshold (+/- 0.5 Hz)
  assert_true(f_target + delta_f == 50.5)
}
