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
test "Suite52 Radar 01: 77 GHz FMCW Automotive Radar Beat Frequency" {
  // f_b = 2 * R * S / c where S = B / T_chirp
  let r_target_m = 150.0 // 150 meters target
  let b_chirp_hz = 1.0e9 // 1 GHz chirp
  let t_chirp_s = 50.0e-6 // 50 us
  let c_light = 3.0e8

  let s_slope = b_chirp_hz / t_chirp_s // 2.0e13 Hz/s
  let f_beat_hz = 2.0 * r_target_m * s_slope / c_light // 20 MHz beat frequency

  assert_true((f_beat_hz - 20.0e6).abs() < 1.0e-3)
}

///|
test "Suite52 Radar 02: Radar Range Resolution at 4 GHz Bandwidth" {
  // Delta R = c / (2 * B)
  let b_rf_hz = 4.0e9 // 4 GHz bandwidth (77-81 GHz)
  let c_light = 3.0e8

  let delta_r_cm = c_light / (2.0 * b_rf_hz) * 100.0 // 3.75 cm resolution!
  assert_true((delta_r_cm - 3.75).abs() < 1.0e-6)
}

///|
test "Suite52 Radar 03: Doppler Velocity Shift at 77 GHz" {
  // f_d = 2 * v / lambda
  let v_target_m_s = 30.0 // 30 m/s (~108 km/h)
  let f_carrier = 77.0e9
  let c_light = 3.0e8
  let lambda_m = c_light / f_carrier // ~3.896 mm

  let f_doppler_hz = 2.0 * v_target_m_s / lambda_m // ~15.4 kHz
  assert_true((f_doppler_hz - 15400.0).abs() < 100.0)
}

///|
test "Suite52 Radar 04: LiDAR APD Transimpedance Amplifier Bandwidth" {
  let r_trans = 5000.0 // 5 kOhm
  let c_diode_apd = 0.5e-12 // 500 fF
  let f_3db_mhz = 1.0 / (2.0 * @math.PI * r_trans * c_diode_apd) / 1.0e6 // ~63.66 MHz
  assert_true(f_3db_mhz > 50.0 && f_3db_mhz < 70.0)
}

///|
test "Suite52 Radar 05: SPAD Active Quenching Avalanche Turn-Off Time" {
  let t_quench_ps = 800.0 // 800 picoseconds active quenching
  let dead_time_ns = 5.0 // 5 ns dead time

  assert_true(t_quench_ps < 1000.0)
  assert_true(dead_time_ns == 5.0)
}

///|
test "Suite52 Radar 06: MIMO Radar Virtual Antenna Array Aperture" {
  let num_tx = 3
  let num_rx = 4
  let num_virtual = num_tx * num_rx // 12 virtual antenna elements!

  assert_true(num_virtual == 12)
}

///|
test "Suite52 Radar 07: CA-CFAR Constant False Alarm Rate Threshold Multiplier" {
  // alpha_cfar = N * (Pfa^(-1/N) - 1)
  let n_guard = 16.0 // 16 reference cells
  let p_fa = 1.0e-4 // P_fa = 10^-4

  let pfa_inv_pow = @math.exp(-(1.0 / n_guard) * @math.ln(p_fa)) // (1e-4)^(-1/16) = 1.778
  let alpha_cfar = n_guard * (pfa_inv_pow - 1.0) // 16 * 0.778 = ~12.45

  assert_true((alpha_cfar - 12.45).abs() < 0.1)
}

///|
test "Suite52 Radar 08: Optical FMCW LiDAR Coherent Heterodyne Mixing Gain" {
  let p_lo_mw = 10.0 // 10 mW local oscillator
  let p_sig_nw = 1.0 // 1 nW reflected signal
  let i_heterodyne = 2.0 * (p_lo_mw * 1.0e-3 * p_sig_nw * 1.0e-9).sqrt() // 2 * sqrt(1e-11) = 6.32 uA

  assert_true(i_heterodyne > 6.0e-6)
}

///|
test "Suite52 Radar 09: Digital Beamforming 6-bit Phase Resolution" {
  let num_bits = 6
  let num_phases = 64
  let lsb_phase_deg = 360.0 / num_phases.to_double() // 5.625 degrees

  assert_true(num_bits == 6)
  assert_true((lsb_phase_deg - 5.625).abs() < 1.0e-6)
}

///|
test "Suite52 Radar 10: Radar Maximum Unambiguous Range R_max" {
  // R_max = c * T_chirp / 2
  let t_chirp = 50.0e-6
  let c_light = 3.0e8

  let r_max_m = c_light * t_chirp / 2.0 // 7500 meters
  assert_true((r_max_m - 7500.0).abs() < 1.0e-6)
}
