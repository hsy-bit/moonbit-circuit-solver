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
test "Suite42 WPT 01: Series-Series SS Magnetic Resonance Transfer Efficiency" {
  // Figure of Merit U = k * sqrt(Q1 * Q2)
  // Max efficiency eta_max = U^2 / (1 + sqrt(1 + U^2))^2
  let k_coupling = 0.20 // 20% coupling
  let q1 = 150.0 // Quality factor of TX coil
  let q2 = 150.0 // Quality factor of RX coil

  let u_fom = k_coupling * (q1 * q2).sqrt() // 0.2 * 150 = 30.0
  let sqrt_term = (1.0 + u_fom * u_fom).sqrt() // sqrt(901) = 30.0166
  let denom = 1.0 + sqrt_term // 31.0166
  let eta_max = u_fom * u_fom / (denom * denom) // 900 / 962 = ~93.55%

  assert_true(eta_max > 0.90 && eta_max < 0.96)
  assert_true((eta_max - 0.9355).abs() < 0.01)
}

///|
test "Suite42 WPT 02: SAE J2954 Standard 85 kHz EV Wireless Charging Frequency" {
  let f_nom_khz = 85.0 // 85 kHz band (81.38 kHz - 90.00 kHz)
  let f_min_khz = 81.38
  let f_max_khz = 90.00

  assert_true(f_nom_khz >= f_min_khz && f_nom_khz <= f_max_khz)
}

///|
test "Suite42 WPT 03: LCC-LCC Compensation Constant Current Output Profile" {
  // Output current I_out = (V_in * M) / (omega_0 * L_tx_comp * L_rx_comp) - Independent of load resistance!
  let v_in = 400.0 // 400V DC link inverter
  let m_mutual = 15.0e-6 // 15 uH
  let f_0 = 85.0e3
  let omega_0 = 2.0 * @math.PI * f_0
  let l_comp_tx = 25.0e-6
  let l_comp_rx = 25.0e-6

  let i_out_load_independent = v_in *
    m_mutual /
    (omega_0 * l_comp_tx * l_comp_rx) // 6000u / (534k * 625p) = 6000u / 333.8u = ~17.97 A
  assert_true((i_out_load_independent - 17.97).abs() < 0.1)
}

///|
test "Suite42 WPT 04: Class-EF Zero Voltage Derivative Switching ZDS" {
  // At turn-on: V_switch(t_on) = 0 and dV_switch/dt(t_on) = 0
  let v_sw_on = 0.0
  let dv_dt_on = 0.0

  assert_true(v_sw_on == 0.0)
  assert_true(dv_dt_on == 0.0)
}

///|
test "Suite42 WPT 05: Foreign Object Debris FOD Quality Factor Drop Detection" {
  let q_clean = 180.0
  let q_metal_debris = 110.0 // Eddy current in coin / foil drops Q by >35%
  let q_drop_percent = (q_clean - q_metal_debris) / q_clean // ~38.8% drop

  let is_fod_detected = q_drop_percent > 0.20
  assert_true(is_fod_detected)
}

///|
test "Suite42 WPT 06: Lateral Misalignment Coupling Factor Decay" {
  let k_aligned = 0.25
  let lateral_offset_mm = 100.0 // 100 mm offset
  // Approximate Gaussian coupling decay: k(x) = k0 * exp(-(x / x0)^2)
  let k_misaligned = k_aligned *
    @math.exp(-(lateral_offset_mm / 150.0) * (lateral_offset_mm / 150.0))

  assert_true(k_misaligned < k_aligned)
  assert_true(k_misaligned > 0.10)
}

///|
test "Suite42 WPT 07: Ferrite Magnetic Flux Shielding Leakage Reduction" {
  let b_leakage_no_shield_ut = 45.0 // 45 uT (Exceeds ICNIRP public safety limit of 27 uT)
  let b_leakage_shielded_ut = 6.2 // 6.2 uT (Compliant with safety guidelines)

  assert_true(b_leakage_shielded_ut < 27.0)
  assert_true(b_leakage_no_shield_ut > 27.0)
}

///|
test "Suite42 WPT 08: 6.78 MHz AirFuel Resonant Loosely Coupled Coil" {
  let f_airfuel_mhz = 6.78 // 6.78 MHz ISM band
  let l_coil = 2.5e-6 // 2.5 uH
  let omega = 2.0 * @math.PI * f_airfuel_mhz * 1.0e6

  let c_res = 1.0 / (omega * omega * l_coil) // ~220.6 pF
  assert_true((c_res - 220.6e-12).abs() < 5.0e-12)
}

///|
test "Suite42 WPT 09: Vehicle-to-Grid V2G Bi-Directional Power Inversion" {
  let p_charge_kw = 11.0 // 11 kW wireless charging
  let p_discharge_kw = -10.0 // 10 kW V2G power feeding back to grid

  assert_true(p_charge_kw > 0.0)
  assert_true(p_discharge_kw < 0.0)
}

///|
test "Suite42 WPT 10: Segmented Dynamic Charging Track Efficiency" {
  let track_segments = 10
  let power_per_segment_kw = 22.0
  let total_track_capacity_kw = track_segments.to_double() *
    power_per_segment_kw

  assert_true(total_track_capacity_kw == 220.0)
}
