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
test "Suite63 PulsedPower 01: 10-Stage 500 kV Marx Generator Output" {
  // V_out = N * V_charge
  let num_stages = 10
  let v_charge_kv = 50.0 // 50 kV charge per stage

  let v_out_kv = num_stages.to_double() * v_charge_kv // 500 kV erection voltage
  assert_true((v_out_kv - 500.0).abs() < 1.0e-6)
}

///|
test "Suite63 PulsedPower 02: Blumlein Pulse Forming Line Square Pulse Duration" {
  // Pulse duration tau = 2 * L_line / v_prop
  let length_m = 3.0 // 3 meters
  let eps_r_water = 81.0 // Deionized water dielectric (eps_r = 81 -> v = c/9)
  let c_light = 3.0e8

  let v_prop = c_light / eps_r_water.sqrt() // 3.33e7 m/s
  let tau_pulse_ns = 2.0 * length_m / v_prop * 1.0e9 // ~180.0 ns

  assert_true((tau_pulse_ns - 180.0).abs() < 1.0)
}

///|
test "Suite63 PulsedPower 03: Magnetic Pulse Compressor Saturable Inductor Volt-Second Product" {
  // Volt-second integral: int V dt = N * A_core * Delta_B
  let num_turns = 5.0
  let area_core_m2 = 0.002 // 20 cm^2
  let delta_b_tesla = 3.0 // 3.0 Tesla saturation flux swing in amorphous Metglas

  let volt_seconds = num_turns * area_core_m2 * delta_b_tesla // 0.030 V*s (30 mV*s)
  assert_true((volt_seconds - 0.030).abs() < 1.0e-6)
}

///|
test "Suite63 PulsedPower 04: Electromagnetic Railgun Mega-Ampere Lorentz Force" {
  // F = 0.5 * L' * I^2
  let l_prime_u_h_per_m = 0.40e-6 // 0.4 uH / m rail inductance gradient
  let i_current_ma = 1.5e6 // 1.5 Megamperes

  let f_lorentz_mn = 0.5 *
    l_prime_u_h_per_m *
    i_current_ma *
    i_current_ma /
    1.0e6 // 450 kN = 0.45 MN
  assert_true((f_lorentz_mn - 0.45).abs() < 1.0e-6)
}

///|
test "Suite63 PulsedPower 05: Spark Gap Avalanche Nanosecond Rise Time" {
  let t_rise_ns = 1.5 // 1.5 ns pressurized SF6 spark gap
  assert_true(t_rise_ns < 2.0)
}

///|
test "Suite63 PulsedPower 06: Linear Transformer Driver LTD Cavity Stacking" {
  let num_cavities = 20
  let v_per_cavity_kv = 100.0
  let v_beam_mv = num_cavities.to_double() * v_per_cavity_kv / 1000.0 // 2.0 Megavolts

  assert_true((v_beam_mv - 2.0).abs() < 1.0e-6)
}

///|
test "Suite63 PulsedPower 07: Laser Flashlamp Simmer Power Supply Keep-Alive Current" {
  let i_simmer_ma = 80.0 // 80 mA DC simmer keeps xenon pre-ionized
  let v_simmer_v = 150.0
  let p_simmer_w = i_simmer_ma * 1.0e-3 * v_simmer_v // 12 W

  assert_true((p_simmer_w - 12.0).abs() < 1.0e-6)
}

///|
test "Suite63 PulsedPower 08: Solid-State Marx 20-Stage SiC MOSFET Stack" {
  let num_fet_stages = 20
  let v_dc_per_stage = 1000.0 // 1 kV SiC modules
  let v_pulse_tot_kv = num_fet_stages.to_double() * v_dc_per_stage / 1000.0 // 20 kV

  assert_true(v_pulse_tot_kv == 20.0)
}

///|
test "Suite63 PulsedPower 09: Capacitive Energy Storage Bank Total Joules" {
  // E = 0.5 * C * V^2
  let c_bank_uf = 40.0 // 40 uF high-energy film capacitor
  let v_charge_kv = 25.0 // 25 kV

  let e_joules_kj = 0.5 *
    c_bank_uf *
    1.0e-6 *
    (v_charge_kv * 1000.0) *
    (v_charge_kv * 1000.0) /
    1000.0 // 12.5 kJ
  assert_true((e_joules_kj - 12.5).abs() < 1.0e-6)
}

///|
test "Suite63 PulsedPower 10: Peaking Capacitor Sharpened dv/dt Slope" {
  let delta_v_kv = 200.0
  let t_rise_ns = 2.0
  let dv_dt_kv_per_ns = delta_v_kv / t_rise_ns // 100 kV/ns ultrafast edge!

  assert_true(dv_dt_kv_per_ns == 100.0)
}
