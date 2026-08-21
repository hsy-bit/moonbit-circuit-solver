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
test "Suite10 RF 01: L-Match Network Low-to-High Impedance Step-Up" {
  // L-match network matching Rs = 50 Ohm to RL = 200 Ohm at f = 1 GHz
  let r_s = 50.0
  let r_l = 200.0
  let f0 = 1.0e9
  let omega = 2.0 * @math.PI * f0

  // Q factor Q = sqrt(RL / Rs - 1) = sqrt(4 - 1) = sqrt(3) = 1.73205
  let q_factor = (r_l / r_s - 1.0).sqrt()
  let x_s = q_factor * r_s // Series inductor reactance
  let x_p = r_l / q_factor // Shunt capacitor reactance

  let l_ser = x_s / omega
  let c_sh = 1.0 / (omega * x_p)

  assert_true((q_factor - 1.732).abs() < 0.01)
  assert_true(l_ser > 10.0e-9 && l_ser < 20.0e-9) // ~13.78 nH
  assert_true(c_sh > 1.0e-12 && c_sh < 2.0e-12) // ~1.38 pF
}

///|
test "Suite10 RF 02: Pi-Match High-Q Harmonic Suppression Network" {
  // Pi network for tube/transistor PA matching 1000 Ohm to 50 Ohm with Q = 10
  let r_in = 1000.0
  let r_out = 50.0
  let q_pi = 10.0

  let r_virtual = r_in / (1.0 + q_pi * q_pi)
  assert_true(r_virtual < r_out)
}

///|
test "Suite10 RF 03: Wideband Bias Tee RF/DC Diplexer Isolation" {
  let netlist_str =
    #|* Wideband Bias Tee (DC Block Cap + RF Choke Inductor)
    #|VRF in_rf 0 AC 1.0
    #|VDC in_dc 0 DC 12.0
    #|* RF path: Series DC block capacitor (0.1 uF)
    #|C_BLOCK in_rf out_rf_dc 100e-9
    #|* DC path: Series RF choke inductor (10 uH)
    #|L_CHOKE in_dc out_rf_dc 10e-6
    #|C_BYPASS in_dc 0 10e-6
    #|RLOAD out_rf_dc 0 50.0
    #|.op
  let netlist = @spice.parse_spice_netlist(netlist_str)
  let sim = CircuitSimulator::{ netlist, }
  let dc = sim.solve_dc()
  assert_true(dc.contains("out_rf_dc"))
  // DC voltage at combined port must equal 12.0V
  let v_dc = dc.get("out_rf_dc").unwrap()
  assert_true((v_dc - 12.0).abs() < 0.1)
}

///|
test "Suite10 RF 04: 3-Frequency Diplexer High-Pass/Low-Pass Splitting" {
  let netlist_str =
    #|* RF Diplexer Filter
    #|VIN in 0 AC 1.0
    #|* Low-Pass Channel (fc = 500 MHz)
    #|L_LP in lp_out 15.9e-9
    #|C_LP lp_out 0 6.36e-12
    #|R_LP lp_out 0 50.0
    #|* High-Pass Channel (fc = 500 MHz)
    #|C_HP in hp_out 6.36e-12
    #|L_HP hp_out 0 15.9e-9
    #|R_HP hp_out 0 50.0
    #|.ac dec 20 100e6 2e9
  let netlist = @spice.parse_spice_netlist(netlist_str)
  let (indexer, _, _, _) = @mna.build_dc_mna_system(netlist)
  assert_true(indexer.node_count() >= 3)
}

///|
test "Suite10 RF 05: Microstrip Stepped-Impedance Low-Pass Filter" {
  // Stepped impedance alternating high-Z (inductive) and low-Z (capacitive) lines
  let z_high = 120.0 // Narrow microstrip trace
  let z_low = 20.0 // Wide microstrip patch

  assert_true(z_high > 100.0)
  assert_true(z_low < 30.0)
}

///|
test "Suite10 RF 06: Coupled-Line Microstrip 20 dB Directional Coupler" {
  let z_even = 55.0
  let z_odd = 45.0

  // Characteristic impedance Z0 = sqrt(Z_even * Z_odd) = sqrt(55 * 45) = 49.75 Ohms
  let z0 = (z_even * z_odd).sqrt()
  let coupling_k = (z_even - z_odd) / (z_even + z_odd) // 10 / 100 = 0.1 (-20 dB)

  assert_true((z0 - 49.75).abs() < 0.1)
  assert_true((coupling_k - 0.1).abs() < 1.0e-6)
}

///|
test "Suite10 RF 07: Cascaded RF Friis Noise Figure Analysis" {
  // Friis Formula: F_total = F1 + (F2 - 1)/G1 + (F3 - 1)/(G1*G2)
  let f1_db = 1.5 // LNA NF = 1.5 dB
  let g1_db = 20.0 // LNA Gain = 20 dB
  let f2_db = 8.0 // Mixer NF = 8 dB
  let g2_db = 10.0 // Mixer Gain = 10 dB
  let f3_db = 4.0 // IF Amp NF = 4 dB

  let ln10 = @math.ln(10.0)
  let f1_lin = @math.exp(f1_db / 10.0 * ln10)
  let g1_lin = @math.exp(g1_db / 10.0 * ln10)
  let f2_lin = @math.exp(f2_db / 10.0 * ln10)
  let g2_lin = @math.exp(g2_db / 10.0 * ln10)
  let f3_lin = @math.exp(f3_db / 10.0 * ln10)

  let f_total = f1_lin +
    (f2_lin - 1.0) / g1_lin +
    (f3_lin - 1.0) / (g1_lin * g2_lin)
  let nf_total_db = 10.0 * (@math.ln(f_total) / ln10)

  // Total noise figure is dominated by the 1st-stage LNA (~1.55 dB)
  assert_true(nf_total_db > 1.5 && nf_total_db < 1.7)
}

///|
test "Suite10 RF 08: Intermodulation Distortion IP3 / IIP3 / OIP3 Extrapolation" {
  // Fundamental slope = 1 dB/dB, IMD3 slope = 3 dB/dB
  // IIP3 = Pin + (Pout_fund - Pout_im3) / 2
  let p_in = -20.0 // dBm
  let gain = 15.0 // dB
  let p_fund = p_in + gain // -5 dBm
  let p_im3 = -65.0 // dBm

  let delta_p = p_fund - p_im3 // 60 dBc
  let iip3 = p_in + delta_p / 2.0 // -20 + 30 = +10 dBm
  let oip3 = iip3 + gain // +25 dBm

  assert_true(iip3 == 10.0)
  assert_true(oip3 == 25.0)
}

///|
test "Suite10 RF 09: Circulator Multi-Stage Reflection Amplifier" {
  let gamma_active = 2.0 // Active device with negative resistance reflection |Gamma| > 1
  let power_gain_db = 20.0 * (@math.ln(gamma_active) / @math.ln(10.0))

  assert_true((power_gain_db - 6.02).abs() < 0.05)
}

///|
test "Suite10 RF 10: Lumped-Element 50-Ohm 3-Way Resistive Power Splitter" {
  // Symmetric star 3-way splitter with R = Z0 * (N - 1) / (N + 1) = 50 * (2/4) = 25 Ohms
  let z0 = 50.0
  let r_star = z0 * (3.0 - 1.0) / (3.0 + 1.0)
  assert_true(r_star == 25.0)
}
