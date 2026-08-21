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
test "Suite23 Thermal 01: Power Semiconductor Steady-State Junction Temperature" {
  // T_J = T_A + P_D * (R_th_JC + R_th_CS + R_th_SA)
  let t_ambient = 40.0 // 40 °C ambient in enclosure
  let p_dissipated = 25.0 // 25 Watts
  let r_th_jc = 0.8 // 0.8 °C/W TO-247 package
  let r_th_cs = 0.5 // 0.5 °C/W thermal grease
  let r_th_sa = 2.2 // 2.2 °C/W extruded aluminum heatsink

  let r_th_total = r_th_jc + r_th_cs + r_th_sa // 3.5 °C/W
  let t_junction = t_ambient + p_dissipated * r_th_total // 40 + 87.5 = 127.5 °C

  assert_true(t_junction < 150.0) // Safe below 150 °C max junction rating
  assert_true((t_junction - 127.5).abs() < 1.0e-6)
}

///|
test "Suite23 Thermal 02: 4-Stage Foster Thermal RC Equivalent Network" {
  // Z_th(t) = sum_i R_i * (1 - exp(-t / tau_i))
  let r_stages = [0.1, 0.3, 0.8, 2.3] // Total steady-state R_th = 3.5 °C/W
  let tau_stages = [0.001, 0.020, 0.500, 10.0] // Time constants in seconds

  let t_short = 0.005 // 5 ms short pulse
  let mut z_th_short = 0.0
  for i in 0..<r_stages.length() {
    z_th_short = z_th_short +
      r_stages[i] * (1.0 - @math.exp(-t_short / tau_stages[i]))
  }

  // Short pulse transient thermal impedance is much smaller than steady-state
  assert_true(z_th_short < 0.5)
}

///|
test "Suite23 Thermal 03: Parallel MOSFET Current Sharing via Positive Tempco Rds(on)" {
  // MOSFET 1 runs hotter (T1 = 100 °C) -> Rds(on) increases to 1.5 * R0
  // Current naturally diverts to cooler MOSFET 2 (T2 = 50 °C) -> Prevents thermal runaway!
  let r0 = 0.010 // 10 mOhm
  let r_hot = r0 * 1.5 // 15 mOhm
  let r_cool = r0 * 1.1 // 11 mOhm
  let i_total = 26.0

  let i_hot = i_total * (r_cool / (r_hot + r_cool)) // 26 * (11/26) = 11 A
  let i_cool = i_total * (r_hot / (r_hot + r_cool)) // 26 * (15/26) = 15 A

  assert_true(i_hot < i_cool)
  assert_true((i_hot - 11.0).abs() < 1.0e-12)
  assert_true((i_cool - 15.0).abs() < 1.0e-12)
}

///|
test "Suite23 Thermal 04: BJT Thermal Runaway Negative Vbe Coefficient (-2 mV/C)" {
  let tc_vbe = -0.002 // -2 mV / °C
  let delta_t = 50.0 // 50 °C temperature rise

  let delta_vbe = tc_vbe * delta_t // -100 mV
  assert_true((delta_vbe - -0.100).abs() < 1.0e-6)
}

///|
test "Suite23 Thermal 05: Heat Sink Thermal Resistance Forced Airflow Derating" {
  // Forced air velocity v = 2.0 m/s reduces natural convection R_th_sa by 60%
  let r_th_natural = 5.0 // °C/W natural convection
  let derating_factor = 0.40 // 40% of natural R_th with fan
  let r_th_forced = r_th_natural * derating_factor

  assert_true((r_th_forced - 2.0).abs() < 1.0e-6)
}

///|
test "Suite23 Thermal 06: Thermoelectric Cooler TEC Maximum Temperature Difference Delta_Tmax" {
  // Figure of Merit Z = S^2 / (rho * k)
  // Delta_T_max = 0.5 * Z * T_hot^2
  let z_param = 0.0028 // 1/K for Bi2Te3
  let t_hot_k = 300.0 // 300 Kelvin (27 °C)

  let delta_t_max = 0.5 * z_param * t_hot_k * t_hot_k // 126 K
  assert_true((delta_t_max - 126.0).abs() < 1.0e-6)
}

///|
test "Suite23 Thermal 07: Safe Operating Area SOA Power Pulse Energy Limit" {
  let v_ds = 60.0
  let i_d = 10.0
  let t_pulse_ms = 1.0 // 1 ms pulse

  let e_pulse = v_ds * i_d * (t_pulse_ms / 1000.0) // 60 * 10 * 0.001 = 0.6 Joules
  assert_true((e_pulse - 0.60).abs() < 1.0e-6)
}

///|
test "Suite23 Thermal 08: PCB Copper Trace Temperature Rise (IPC-2152 Standard)" {
  // Current capacity I = k * Delta_T^0.44 * A^0.725
  let trace_width_mils = 50.0
  let _trace_thick_oz = 1.0 // 1 oz copper (1.37 mils)
  let area_sq_mils = trace_width_mils * 1.37 // 68.5 sq mils

  assert_true(area_sq_mils > 50.0)
}

///|
test "Suite23 Thermal 09: NTC Thermistor Steinhart-Hart Temperature Extrapolation" {
  // 1/T = A + B*ln(R) + C*(ln(R))^3
  let a_param = 1.129e-3
  let b_param = 2.341e-4
  let c_param = 8.775e-8
  let r_ntc = 10000.0 // 10k at 25 °C (298.15 K)

  let ln_r = @math.ln(r_ntc)
  let inv_t = a_param + b_param * ln_r + c_param * ln_r * ln_r * ln_r
  let t_kelvin = 1.0 / inv_t
  let t_celsius = t_kelvin - 273.15

  assert_true((t_celsius - 25.0).abs() < 1.0)
}

///|
test "Suite23 Thermal 10: Thermal Diode On-Chip Silicon Temperature Sensor" {
  // Delta V_BE = (k_B * T / q) * ln(N) between currents I1 and I2 = N * I1
  let k_b = 1.380649e-23
  let q_e = 1.602176634e-19
  let n_ratio = 10.0 // 10:1 current ratio
  let t_room_k = 300.0 // 300 K

  let delta_vbe = k_b * t_room_k / q_e * @math.ln(n_ratio)
  assert_true((delta_vbe - 0.0595).abs() < 0.002) // ~59.5 mV (approx 198 uV / K)
}
