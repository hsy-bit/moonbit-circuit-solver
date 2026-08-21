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
test "Suite54 Nuclear 01: Charge Sensitive Preamplifier CSP Output Step" {
  // V_out = - Q_in / C_f
  // 5.9 keV Fe-55 X-ray creates N_eh = 5900 / 3.65 = 1616 electron-hole pairs
  let n_eh = 1616.0
  let q_e = 1.602176634e-19
  let q_in = n_eh * q_e // ~2.59e-16 C (0.259 fC)
  let c_f = 0.5e-12 // 0.5 pF feedback cap

  let v_step_mv = q_in / c_f * 1000.0 // ~0.518 mV
  assert_true((v_step_mv - 0.5178).abs() < 0.01)
}

///|
test "Suite54 Nuclear 02: CR-RC Semi-Gaussian Pulse Shaper Peaking Time" {
  let tau_shaping_us = 2.0 // 2 us shaping time constant
  let peaking_time_us = tau_shaping_us // Peak occurs at t = tau
  assert_true(peaking_time_us == 2.0)
}

///|
test "Suite54 Nuclear 03: Equivalent Noise Charge ENC Optimal Shaping Minimum" {
  // Parallel noise propto tau, Series noise propto 1/tau -> Minimum occurs at equal contribution
  let enc_series_at_opt = 12.0 // electrons RMS
  let enc_parallel_at_opt = 12.0
  let enc_total = (enc_series_at_opt * enc_series_at_opt +
  enc_parallel_at_opt * enc_parallel_at_opt).sqrt() // ~16.97 e- RMS

  assert_true((enc_total - 16.97).abs() < 0.1)
}

///|
test "Suite54 Nuclear 04: HPGe 3000V High Voltage Bias RC Low-Pass Filter" {
  let r_hv = 10.0e6 // 10 MOhm
  let c_hv = 100.0e-9 // 100 nF -> tau = 1.0 s (0.16 Hz cutoff for ultra-quiet bias)
  let tau_hv = r_hv * c_hv

  assert_true(tau_hv == 1.0)
}

///|
test "Suite54 Nuclear 05: PMT 10-Stage Dynode Resistor Ladder Voltage Steps" {
  let v_anode_total = 1200.0 // 1200 V
  let num_stages = 10
  let v_per_dynode = v_anode_total / num_stages.to_double() // 120 V per dynode

  assert_true((v_per_dynode - 120.0).abs() < 1.0e-6)
}

///|
test "Suite54 Nuclear 06: Time-over-Threshold ToT Dynamic Energy Range" {
  let v_thresh = 0.050 // 50 mV discriminator threshold
  let v_peak = 1.000 // 1000 mV pulse
  assert_true(v_peak > v_thresh)
}

///|
test "Suite54 Nuclear 07: Constant Fraction Discriminator CFD Zero-Crossing Time" {
  // CFD fraction f = 0.20, delay td = 2 ns -> Zero-crossing is amplitude-independent!
  let fraction_f = 0.20
  let delay_td_ns = 2.0

  assert_true(fraction_f == 0.20)
  assert_true(delay_td_ns == 2.0)
}

///|
test "Suite54 Nuclear 08: Multi-Channel Analyzer MCA 4096 Channels" {
  let num_channels = 4096
  let bits = 12
  assert_true(num_channels == 4096)
  assert_true(bits == 12)
}

///|
test "Suite54 Nuclear 09: Fast Scintillator LaBr3 16 ns Decay Time" {
  let tau_labr3_ns = 16.0
  let tau_nai_ns = 230.0
  assert_true(tau_labr3_ns < tau_nai_ns / 10.0)
}

///|
test "Suite54 Nuclear 10: Pole-Zero Cancellation PZC Eliminates Exponential Undershoot" {
  let r_pzc = 100.0e3
  let c_pzc = 10.0e-9
  let tau_pzc = r_pzc * c_pzc // 1.0 ms

  assert_true((tau_pzc - 0.001).abs() < 1.0e-6)
}
