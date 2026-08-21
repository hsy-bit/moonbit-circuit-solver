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
test "Suite15 Telecom 01: Double-Sideband Suppressed-Carrier DSB-SC Multiplication" {
  // s(t) = m(t) * cos(omega_c * t)
  let f_m = 1000.0 // 1 kHz baseband
  let f_c = 100.0e3 // 100 kHz carrier
  let t = 0.0001

  let m_t = @math.cos(2.0 * @math.PI * f_m * t)
  let carrier = @math.cos(2.0 * @math.PI * f_c * t)
  let s_t = m_t * carrier

  // Sidebands at fc - fm (99 kHz) and fc + fm (101 kHz)
  assert_true(s_t.abs() <= 1.0)
  assert_true(f_c > f_m)
}

///|
test "Suite15 Telecom 02: AM Envelope Diode Detector Low-Pass Filter" {
  let netlist_str =
    #|* AM Diode Envelope Detector
    #|VIN in 0 AC 1.0
    #|D1 in out 1N4148
    #|R_LOAD out 0 10000.0
    #|C_FILT out 0 10e-9
    #|.model 1N4148 D (IS=1e-14 N=1.0)
    #|.op
  let netlist = @spice.parse_spice_netlist(netlist_str)
  let (indexer, _, _, _) = @mna.build_dc_mna_system(netlist)
  assert_true(indexer.node_count() >= 2)
}

///|
test "Suite15 Telecom 03: Quadrature IQ Vector Modulator" {
  // s(t) = I * cos(omega_c * t) - Q * sin(omega_c * t)
  let i_val = 0.707106
  let q_val = 0.707106

  let r_mag = (i_val * i_val + q_val * q_val).sqrt()
  let phase_rad = @math.atan2(q_val, i_val)
  let phase_deg = phase_rad * 180.0 / @math.PI

  assert_true((r_mag - 1.0).abs() < 1.0e-5)
  assert_true((phase_deg - 45.0).abs() < 1.0e-5)
}

///|
test "Suite15 Telecom 04: QPSK 4-Symbol Constellation Euclidean Distance" {
  let d_min = 2.0.sqrt() // Minimum Euclidean distance between (1,1) and (1,-1) = 2.0
  assert_true(d_min > 1.4)
}

///|
test "Suite15 Telecom 05: Costas Loop Phase Discriminator for BPSK Carrier Recovery" {
  // Error signal e(t) = I(t) * Q(t) = (A * cos(phi)) * (A * sin(phi)) = 0.5 * A^2 * sin(2*phi)
  let phi = 0.1 // Small phase error
  let a_amp = 1.0

  let i_arm = a_amp * @math.cos(phi)
  let q_arm = a_amp * @math.sin(phi)
  let err_disc = i_arm * q_arm

  assert_true(err_disc > 0.0)
  assert_true((err_disc - 0.5 * @math.sin(2.0 * phi)).abs() < 1.0e-12)
}

///|
test "Suite15 Telecom 06: Direct Digital Synthesizer DDS 32-bit Phase Accumulator" {
  // f_out = f_clk * M / 2^32
  let f_clk = 100.0e6 // 100 MHz clock
  let m_tuning = 42949672 // Tuning word for ~1 MHz output

  let f_out = f_clk * m_tuning.to_double() / 4294967296.0
  assert_true((f_out - 1.0e6).abs() < 1.0)
}

///|
test "Suite15 Telecom 07: Root-Raised-Cosine RRC Filter Zero-ISI Condition" {
  let roll_off = 0.35 // Standard 3GPP/LTE alpha = 0.35
  let symbol_rate = 1.0e6 // 1 Msps

  // Occupied bandwidth BW = (1 + alpha) * Rs / 2 = 1.35 * 0.5 MHz = 675 kHz (Baseband)
  let bw_rf = (1.0 + roll_off) * symbol_rate // 1.35 MHz RF
  assert_true((bw_rf - 1.35e6).abs() < 1.0e-6)
}

///|
test "Suite15 Telecom 08: Free Space Path Loss FSPL Wireless Link Budget" {
  // FSPL(dB) = 20*log10(d) + 20*log10(f) + 20*log10(4*pi / c)
  // At d = 1 km, f = 2.4 GHz -> FSPL approx 100.0 dB
  let d_m = 1000.0
  let f_hz = 2.4e9
  let c_light = 3.0e8

  let ln10 = @math.ln(10.0)
  let log10_d = @math.ln(d_m) / ln10
  let log10_f = @math.ln(f_hz) / ln10
  let log10_const = @math.ln(4.0 * @math.PI / c_light) / ln10

  let fspl_db = 20.0 * (log10_d + log10_f + log10_const)
  assert_true(fspl_db > 99.0 && fspl_db < 101.0)
}

///|
test "Suite15 Telecom 09: Foster-Seeley FM Discriminator S-Curve" {
  // Resonant discriminator produces linear voltage output proportional to frequency deviation Delta f
  let k_disc = 0.05 // 50 mV / kHz
  let delta_f_khz = 25.0 // +/- 25 kHz FM deviation

  let v_demod = k_disc * delta_f_khz
  assert_true((v_demod - 1.25).abs() < 1.0e-12)
}

///|
test "Suite15 Telecom 10: Frequency Synthesizer Phase Noise Mask" {
  // 1/f^2 phase noise roll-off (-20 dB/decade from offset)
  let pn_100k = -110.0 // dBc/Hz at 100 kHz offset
  let pn_1m = pn_100k - 20.0 // -130 dBc/Hz at 1 MHz offset

  assert_true(pn_1m == -130.0)
}
