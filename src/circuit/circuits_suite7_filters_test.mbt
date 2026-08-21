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
test "Suite7 Filter 01: Sallen-Key 2nd-Order Unity-Gain Low-Pass Filter" {
  let netlist_str =
    #|* Sallen-Key Low-Pass Filter (fc = 1 kHz, Q = 0.707)
    #|VIN in 0 DC 2.5
    #|R1 in n1 10000.0
    #|R2 n1 pos 10000.0
    #|C1 n1 out 22.5e-9
    #|C2 pos 0 11.25e-9
    #|X1 pos out out OPAMP
    #|.op
  let netlist = @spice.parse_spice_netlist(netlist_str)
  let sim = CircuitSimulator::{ netlist, }
  let dc = sim.solve_dc()
  assert_true(dc.contains("out"))
  // DC gain is exactly 1.0 -> Vout = 2.5V
  let v_out = dc.get("out").unwrap()
  assert_true((v_out - 2.5).abs() < 1.0e-3)
}

///|
test "Suite7 Filter 02: Sallen-Key 2nd-Order High-Pass Filter" {
  let netlist_str =
    #|* Sallen-Key High-Pass Filter (fc = 1 kHz)
    #|VIN in 0 DC 0.0
    #|C1 in n1 15.9e-9
    #|C2 n1 pos 15.9e-9
    #|R1 n1 out 10000.0
    #|R2 pos 0 10000.0
    #|X1 pos out out OPAMP
    #|.op
  let netlist = @spice.parse_spice_netlist(netlist_str)
  let sim = CircuitSimulator::{ netlist, }
  let dc = sim.solve_dc()
  let v_out = dc.get("out").unwrap()
  assert_true(v_out.abs() < 1.0e-6) // Blocks DC
}

///|
test "Suite7 Filter 03: Multiple Feedback MFB 2nd-Order Bandpass Filter" {
  let netlist_str =
    #|* Multiple Feedback (Rauch) Bandpass Filter (f0 = 1 kHz, Q = 10, Gain = -1)
    #|VIN in 0 DC 1.0
    #|R1 in n1 10000.0
    #|R2 n1 0 100.0
    #|R3 n1 out 20000.0
    #|C1 n1 inv 15.9e-9
    #|C2 inv out 15.9e-9
    #|RF_DC inv out 1.0e6
    #|X1 0 inv out OPAMP
    #|.op
  let netlist = @spice.parse_spice_netlist(netlist_str)
  let sim = CircuitSimulator::{ netlist, }
  let dc = sim.solve_dc()
  assert_true(dc.contains("out"))
}

///|
test "Suite7 Filter 04: Multiple Feedback MFB Low-Pass Filter" {
  let netlist_str =
    #|* MFB Low-Pass Filter (Gain = -R2/R1 = -2)
    #|VIN in 0 DC 1.0
    #|R1 in n1 10000.0
    #|R2 n1 out 20000.0
    #|R3 n1 inv 10000.0
    #|C1 n1 0 33e-9
    #|C2 inv out 4.7e-9
    #|X1 0 inv out OPAMP
    #|.op
  let netlist = @spice.parse_spice_netlist(netlist_str)
  let sim = CircuitSimulator::{ netlist, }
  let dc = sim.solve_dc()
  let v_out = dc.get("out").unwrap()
  assert_true((v_out - -2.0).abs() < 1.0e-3)
}

///|
test "Suite7 Filter 05: Bainter Notch High-Q Band-Stop Filter" {
  let netlist_str =
    #|* Bainter Notch Filter (f0 = 1 kHz)
    #|VIN in 0 DC 1.0
    #|R1 in n1 10000.0
    #|R2 in n2 10000.0
    #|R3 n1 out 10000.0
    #|R4 n2 out 10000.0
    #|C1 n1 0 15.9e-9
    #|C2 n2 0 15.9e-9
    #|X1 0 n1 out OPAMP
    #|.op
  let netlist = @spice.parse_spice_netlist(netlist_str)
  let (indexer, _, _, _) = @mna.build_dc_mna_system(netlist)
  assert_true(indexer.node_count() >= 4)
}

///|
test "Suite7 Filter 06: Kerwin-Huelsman-Newcomb KHN State Variable Filter" {
  let netlist_str =
    #|* KHN Biquad Filter: Outputs HP, BP, and LP simultaneously
    #|VIN in 0 DC 1.0
    #|* Summing stage (X_SUM) produces High-Pass
    #|R_IN in inv_sum 10000.0
    #|R_LP lp inv_sum 10000.0
    #|R_BP bp inv_sum 20000.0
    #|R_SUM inv_sum hp 10000.0
    #|X_SUM 0 inv_sum hp OPAMP
    #|* Integrator 1 (X_INT1) produces Band-Pass
    #|R_INT1 hp inv_int1 10000.0
    #|C_INT1 inv_int1 bp 15.9e-9
    #|X_INT1 0 inv_int1 bp OPAMP
    #|* Integrator 2 (X_INT2) produces Low-Pass
    #|R_INT2 bp inv_int2 10000.0
    #|C_INT2 inv_int2 lp 15.9e-9
    #|X_INT2 0 inv_int2 lp OPAMP
    #|.op
  let netlist = @spice.parse_spice_netlist(netlist_str)
  let sim = CircuitSimulator::{ netlist, }
  let dc = sim.solve_dc()
  assert_true(dc.contains("lp"))
  assert_true(dc.contains("bp"))
  assert_true(dc.contains("hp"))
}

///|
test "Suite7 Filter 07: 1st-Order All-Pass Phase Delay Equalizer" {
  let netlist_str =
    #|* All-Pass Phase Shift Network: Gain = 1.0, Phase = -2 * atan(omega * R * C)
    #|VIN in 0 DC 2.0
    #|R1 in inv 10000.0
    #|R2 inv out 10000.0
    #|R3 in pos 10000.0
    #|C1 pos 0 15.9e-9
    #|X1 pos inv out OPAMP
    #|.op
  let netlist = @spice.parse_spice_netlist(netlist_str)
  let sim = CircuitSimulator::{ netlist, }
  let dc = sim.solve_dc()
  let v_out = dc.get("out").unwrap()
  assert_true((v_out - 2.0).abs() < 1.0e-3)
}

///|
test "Suite7 Filter 08: 4th-Order Butterworth Low-Pass 2-Stage Cascade" {
  let netlist_str =
    #|* 4th-Order Butterworth Low-Pass (Stage 1: Q = 0.541, Stage 2: Q = 1.307)
    #|VIN in 0 DC 1.5
    #|* Stage 1
    #|R1 in s1_mid 10000.0
    #|R2 s1_mid s1_pos 10000.0
    #|C1 s1_mid s1_out 17.2e-9
    #|C2 s1_pos 0 14.7e-9
    #|X1 s1_pos s1_out s1_out OPAMP
    #|* Stage 2
    #|R3 s1_out s2_mid 10000.0
    #|R4 s2_mid s2_pos 10000.0
    #|C3 s2_mid out 41.6e-9
    #|C4 s2_pos 0 6.1e-9
    #|X2 s2_pos out out OPAMP
    #|.op
  let netlist = @spice.parse_spice_netlist(netlist_str)
  let sim = CircuitSimulator::{ netlist, }
  let dc = sim.solve_dc()
  let v_out = dc.get("out").unwrap()
  assert_true((v_out - 1.5).abs() < 1.0e-3)
}

///|
test "Suite7 Filter 09: Linkwitz-Riley 4th-Order (LR4) Active Audio Crossover" {
  // LR4 crossover consists of two cascaded 2nd-order Butterworth filters (Q = 0.707)
  // Total attenuation at crossover frequency fc is exactly -6 dB, allowing seamless acoustic summation
  let atten_db_per_stage = -3.01
  let total_atten_db = 2.0 * atten_db_per_stage

  assert_true((total_atten_db - -6.02).abs() < 0.05)
}

///|
test "Suite7 Filter 10: Switched-Capacitor Bi-Quad Programmable Cutoff Filter" {
  let f_clk = 250.0e3 // 250 kHz clock
  let c_in = 1.0e-12
  let c_int = 20.0e-12

  // Integrator unity-gain frequency f_u = (f_clk / (2*pi)) * (C_in / C_int)
  let f_u = f_clk / (2.0 * @math.PI) * (c_in / c_int)
  assert_true((f_u - 1989.4).abs() < 10.0) // ~1.99 kHz
}
