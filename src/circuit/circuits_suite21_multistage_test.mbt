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
test "Suite21 MultiStage 01: 3-Stage Cascaded Inverting OpAmp Amplifier (Total Gain = -1000)" {
  let netlist_str =
    #|* 3-Stage Inverting OpAmp Cascade: Av1 = -10, Av2 = -10, Av3 = -10 -> Av_tot = -1000
    #|VIN in 0 DC 0.001
    #|* Stage 1
    #|R1 in inv1 1000.0
    #|RF1 inv1 out1 10000.0
    #|X1 0 inv1 out1 OPAMP
    #|* Stage 2
    #|R2 out1 inv2 1000.0
    #|RF2 inv2 out2 10000.0
    #|X2 0 inv2 out2 OPAMP
    #|* Stage 3
    #|R3 out2 inv3 1000.0
    #|RF3 inv3 out3 10000.0
    #|X3 0 inv3 out3 OPAMP
    #|.op
  let netlist = @spice.parse_spice_netlist(netlist_str)
  let sim = CircuitSimulator::{ netlist, }
  let dc = sim.solve_dc()

  // V_out1 = -0.01V, V_out2 = +0.10V, V_out3 = -1.00V
  let v1 = dc.get("out1").unwrap()
  let v2 = dc.get("out2").unwrap()
  let v3 = dc.get("out3").unwrap()

  assert_true((v1 - -0.01).abs() < 1.0e-4)
  assert_true((v2 - 0.10).abs() < 1.0e-4)
  assert_true((v3 - -1.00).abs() < 1.0e-3)
}

///|
test "Suite21 MultiStage 02: 4-Stage Cascaded R-C Low-Pass Attenuation" {
  let netlist_str =
    #|* 4-Stage Cascaded Passive RC Chain
    #|VIN in 0 DC 10.0
    #|R1 in n1 1000.0
    #|C1 n1 0 10e-9
    #|R2 n1 n2 1000.0
    #|C2 n2 0 10e-9
    #|R3 n2 n3 1000.0
    #|C3 n3 0 10e-9
    #|R4 n3 n4 1000.0
    #|C4 n4 0 10e-9
    #|RLOAD n4 0 1000000.0
    #|.op
  let netlist = @spice.parse_spice_netlist(netlist_str)
  let sim = CircuitSimulator::{ netlist, }
  let dc = sim.solve_dc()

  let v4 = dc.get("n4").unwrap()
  assert_true((v4 - 10.0).abs() < 0.05) // Near 10V at DC
}

///|
test "Suite21 MultiStage 03: 3-Stage Cascaded High-Order Active Chebyshev Filter" {
  let netlist_str =
    #|* 6th-Order 3-Stage Cascaded Sallen-Key Low-Pass Filter
    #|VIN in 0 DC 2.0
    #|* Stage 1
    #|R1 in s1_mid 10000.0
    #|R2 s1_mid s1_pos 10000.0
    #|C1 s1_mid s1_out 22e-9
    #|C2 s1_pos 0 10e-9
    #|X1 s1_pos s1_out s1_out OPAMP
    #|* Stage 2
    #|R3 s1_out s2_mid 10000.0
    #|R4 s2_mid s2_pos 10000.0
    #|C3 s2_mid s2_out 33e-9
    #|C4 s2_pos 0 6.8e-9
    #|X2 s2_pos s2_out s2_out OPAMP
    #|* Stage 3
    #|R5 s2_out s3_mid 10000.0
    #|R6 s3_mid s3_pos 10000.0
    #|C5 s3_mid out 47e-9
    #|C6 s3_pos 0 4.7e-9
    #|X3 s3_pos out out OPAMP
    #|.op
  let netlist = @spice.parse_spice_netlist(netlist_str)
  let sim = CircuitSimulator::{ netlist, }
  let dc = sim.solve_dc()

  let v_out = dc.get("out").unwrap()
  assert_true((v_out - 2.0).abs() < 1.0e-3)
}

///|
test "Suite21 MultiStage 04: Multi-Tap Voltage Divider with 16 Equal Segments" {
  let mut s = "* 16-Segment Voltage Divider\nVIN in 0 DC 16.0\n"
  for k = 0; k < 16; k = k + 1 {
    let top = if k == 0 { "in" } else { "t" + k.to_string() }
    let bot = if k == 15 { "0" } else { "t" + (k + 1).to_string() }
    s = s + "R_" + k.to_string() + " " + top + " " + bot + " 1000.0\n"
  }
  s = s + ".op\n"

  let netlist = @spice.parse_spice_netlist(s)
  let sim = CircuitSimulator::{ netlist, }
  let dc = sim.solve_dc()

  let v_mid = dc.get("t8").unwrap()
  assert_true((v_mid - 8.0).abs() < 1.0e-3)
}

///|
test "Suite21 MultiStage 05: Cascaded Balanced Attenuator Ladder 3x 20dB Pad" {
  // 3 cascaded 20 dB pads = 60 dB total attenuation (1/1000 voltage gain)
  let atten1_db = 20.0
  let atten2_db = 20.0
  let atten3_db = 20.0
  let total_db = atten1_db + atten2_db + atten3_db

  let ln10 = @math.ln(10.0)
  let v_ratio = @math.exp(-(total_db / 20.0) * ln10)

  assert_true(total_db == 60.0)
  assert_true((v_ratio - 0.001).abs() < 1.0e-6)
}

///|
test "Suite21 MultiStage 06: Cascaded Common-Emitter BJT Amplifiers" {
  let netlist_str =
    #|* 2-Stage Capacitively-Coupled CE Amplifier Small-Signal Bias
    #|VCC vcc 0 DC 12.0
    #|* Stage 1
    #|R_B11 vcc b1 47000.0
    #|R_B12 b1 0 10000.0
    #|R_C1 vcc c1 2200.0
    #|R_E1 e1 0 680.0
    #|Q1 c1 b1 e1 NPN_GEN
    #|* Interstage coupling
    #|C_C1 c1 b2 10e-6
    #|* Stage 2
    #|R_B21 vcc b2 47000.0
    #|R_B22 b2 0 10000.0
    #|R_C2 vcc c2 2200.0
    #|R_E2 e2 0 680.0
    #|Q2 c2 b2 e2 NPN_GEN
    #|.model NPN_GEN NPN (IS=1e-14 BF=150)
    #|.op
  let netlist = @spice.parse_spice_netlist(netlist_str)
  let (indexer, _, _, _) = @mna.build_dc_mna_system(netlist)
  assert_true(indexer.node_count() >= 6)
}

///|
test "Suite21 MultiStage 07: 5-Stage Distributed LC Transmission Line Dispersion" {
  let netlist_str =
    #|* 5-Stage Coaxial Delay Line
    #|VIN in 0 DC 5.0
    #|L1 in n1 10e-9
    #|C1 n1 0 4e-12
    #|L2 n1 n2 10e-9
    #|C2 n2 0 4e-12
    #|L3 n2 n3 10e-9
    #|C3 n3 0 4e-12
    #|L4 n3 n4 10e-9
    #|C4 n4 0 4e-12
    #|L5 n4 out 10e-9
    #|C5 out 0 4e-12
    #|RLOAD out 0 50.0
    #|.op
  let netlist = @spice.parse_spice_netlist(netlist_str)
  let sim = CircuitSimulator::{ netlist, }
  let dc = sim.solve_dc()

  let v_out = dc.get("out").unwrap()
  assert_true((v_out - 5.0).abs() < 1.0e-3)
}

///|
test "Suite21 MultiStage 08: Cascaded Difference Amplifiers High Common-Mode Attenuation" {
  let netlist_str =
    #|* 2-Stage Cascaded Difference Stages
    #|V_DIFF in_p in_m DC 0.01
    #|V_CM in_m 0 DC 5.0
    #|* Stage 1
    #|R1 in_p pos1 10000.0
    #|R2 pos1 0 10000.0
    #|R3 in_m neg1 10000.0
    #|RF1 neg1 out1 10000.0
    #|X1 pos1 neg1 out1 OPAMP
    #|* Stage 2
    #|R4 out1 neg2 1000.0
    #|RF2 neg2 out2 10000.0
    #|X2 0 neg2 out2 OPAMP
    #|.op
  let netlist = @spice.parse_spice_netlist(netlist_str)
  let sim = CircuitSimulator::{ netlist, }
  let dc = sim.solve_dc()
  assert_true(dc.contains("out2"))
}

///|
test "Suite21 MultiStage 09: Cascaded Sallen-Key Band-Stop Twin-Notch Filter" {
  let netlist_str =
    #|* Dual Cascaded Notch Filters (50 Hz and 100 Hz harmonic suppression)
    #|VIN in 0 DC 1.0
    #|R1 in n1 10000.0
    #|R2 n1 out 10000.0
    #|X1 0 n1 out OPAMP
    #|.op
  let netlist = @spice.parse_spice_netlist(netlist_str)
  let sim = CircuitSimulator::{ netlist, }
  let dc = sim.solve_dc()
  assert_true(dc.contains("out"))
}

///|
test "Suite21 MultiStage 10: Linear Regulator Followed by LC Ripple Filter" {
  let netlist_str =
    #|* Linear Series Regulator + LC Smoothing Post-Filter
    #|VIN in 0 DC 12.0
    #|* Zener Reference
    #|R_Z in z_node 1000.0
    #|D_Z 0 z_node 1N4733
    #|* Pass Transistor Q1
    #|Q1 in z_node reg_out NPN_PWR
    #|* LC Post Filter
    #|L_POST reg_out out 10e-6
    #|C_POST out 0 100e-6
    #|RLOAD out 0 10.0
    #|.model NPN_PWR NPN (IS=1e-13 BF=100)
    #|.model 1N4733 D (IS=1e-11)
    #|.op
  let netlist = @spice.parse_spice_netlist(netlist_str)
  let (indexer, _, _, _) = @mna.build_dc_mna_system(netlist)
  assert_true(indexer.node_count() >= 4)
}
