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
test "Suite2 Circuit 01: Wilson Current Mirror Precision Benchmark" {
  let netlist_str =
    #|* 3-Transistor Wilson Current Mirror Netlist
    #|VCC vcc 0 DC 10.0
    #|IREF vcc ref DC 1.0e-3
    #|* Transistors Q1, Q2, Q3
    #|Q1 ref ref emit1 NPN_STD
    #|Q2 out ref emit2 NPN_STD
    #|Q3 emit2 ref 0 NPN_STD
    #|R_E1 emit1 0 100.0
    #|R_E2 emit2 0 100.0
    #|RLOAD vcc out 1000.0
    #|.model NPN_STD NPN (IS=1e-14 BF=200 VAF=100)
    #|.op
  let netlist = @spice.parse_spice_netlist(netlist_str)
  let (indexer, a_mat, z_vec, _) = @mna.build_dc_mna_system(netlist)
  assert_true(indexer.node_count() >= 4)
  assert_true(a_mat.num_rows() == indexer.total_size())
  assert_true(z_vec.length() == indexer.total_size())
}

///|
test "Suite2 Circuit 02: Widlar Current Source Micro-Ampere Generator" {
  let netlist_str =
    #|* Widlar Current Source for Sub-Microamp Biasing
    #|VCC vcc 0 DC 5.0
    #|R_REF vcc ref 10000.0
    #|Q1 ref ref 0 NPN_STD
    #|Q2 out ref emit2 NPN_STD
    #|R_WIDLAR emit2 0 5000.0
    #|RLOAD vcc out 2000.0
    #|.model NPN_STD NPN (IS=1e-14 BF=150)
    #|.op
  let netlist = @spice.parse_spice_netlist(netlist_str)
  let sim = CircuitSimulator::{ netlist, }
  let dc = sim.solve_dc()
  assert_true(dc.contains("vcc"))
  assert_true((dc.get("vcc").unwrap() - 5.0).abs() < 1.0e-6)
}

///|
test "Suite2 Circuit 03: Cascode Differential Pair High Output Impedance Stage" {
  let netlist_str =
    #|* Telescopic Cascode Differential Amplifier
    #|VDD vdd 0 DC 3.3
    #|VSS vss 0 DC 0.0
    #|VINP inp 0 DC 1.2
    #|VINM inm 0 DC 1.2
    #|VBAS_N vbn 0 DC 1.8
    #|* Input pair M1, M2
    #|M1 n1 inp tail vss NMOS_STD
    #|M2 n2 inm tail vss NMOS_STD
    #|* Cascode devices M3, M4
    #|M3 out_p vbn n1 vss NMOS_STD
    #|M4 out_n vbn n2 vss NMOS_STD
    #|* Tail source
    #|ITAIL tail vss DC 200e-6
    #|* PMOS Active Load
    #|R_L1 vdd out_p 10000.0
    #|R_L2 vdd out_n 10000.0
    #|.model NMOS_STD NMOS (VTO=0.5 KP=150e-6)
    #|.op
  let netlist = @spice.parse_spice_netlist(netlist_str)
  let (indexer, _, _, _) = @mna.build_dc_mna_system(netlist)
  assert_true(indexer.node_count() >= 6)
}

///|
test "Suite2 Circuit 04: Folded Cascode Operational Transconductance Amplifier OTA" {
  let netlist_str =
    #|* Folded Cascode OTA Architecture
    #|VDD vdd 0 DC 3.3
    #|VBN vbn 0 DC 1.5
    #|VBP vbp 0 DC 1.8
    #|* PMOS Input Pair
    #|M1 fn_l inm tail vdd PMOS_STD
    #|M2 fn_r inp tail vdd PMOS_STD
    #|* NMOS Cascode Output Stage
    #|M3 out vbn fn_r 0 NMOS_STD
    #|CLOAD out 0 2.0e-12
    #|RLOAD out 0 50000.0
    #|.model NMOS_STD NMOS (VTO=0.5 KP=150e-6)
    #|.model PMOS_STD PMOS (VTO=-0.5 KP=50e-6)
    #|.op
  let netlist = @spice.parse_spice_netlist(netlist_str)
  let (indexer, a_mat, z_vec, _) = @mna.build_dc_mna_system(netlist)
  assert_true(indexer.node_count() >= 5)
  assert_true(a_mat.num_rows() == indexer.total_size())
  assert_true(z_vec.length() == indexer.total_size())
}

///|
test "Suite2 Circuit 05: Class-AB Audio Push-Pull Output Stage with Vbe Multiplier" {
  let netlist_str =
    #|* Class-AB Output Stage with Q_MULT Vbe Multiplier Bias
    #|VCC vcc 0 DC 24.0
    #|VEE vee 0 DC -24.0
    #|* Bias current
    #|IBIAS vcc n_bias_top DC 5.0e-3
    #|* Vbe multiplier (Q_MULT, R1, R2)
    #|Q_MULT n_bias_top n_mult_b n_bias_bot NPN_PWR
    #|R1 n_bias_top n_mult_b 2200.0
    #|R2 n_mult_b n_bias_bot 1000.0
    #|* Darlington Push-Pull Driver and Output (Q_P1, Q_N1)
    #|Q_N1 vcc n_bias_top out NPN_PWR
    #|Q_P1 vee n_bias_bot out PNP_PWR
    #|RLOAD out 0 8.0
    #|.model NPN_PWR NPN (IS=1e-13 BF=80)
    #|.model PNP_PWR PNP (IS=1e-13 BF=80)
    #|.op
  let netlist = @spice.parse_spice_netlist(netlist_str)
  let (indexer, _, _, _) = @mna.build_dc_mna_system(netlist)
  assert_true(indexer.node_count() >= 5)
}

///|
test "Suite2 Circuit 06: High-Order State-Variable Universal Active Filter" {
  // Tow-Thomas Biquad universal filter providing Low-Pass, Band-Pass, and High-Pass outputs
  let netlist_str =
    #|* Tow-Thomas Biquad Universal Filter
    #|VIN in 0 DC 1.0
    #|* Inverting summing integrator (OpAmp 1)
    #|R_IN in n1 10000.0
    #|R_Q bp n1 20000.0
    #|R_F lp n1 10000.0
    #|C1 n1 bp 10e-9
    #|X1 0 n1 bp OPAMP
    #|* Pure integrator (OpAmp 2)
    #|R2 bp n2 10000.0
    #|C2 n2 lp 10e-9
    #|X2 0 n2 lp OPAMP
    #|.op
  let netlist = @spice.parse_spice_netlist(netlist_str)
  let sim = CircuitSimulator::{ netlist, }
  let dc = sim.solve_dc()
  assert_true(dc.contains("lp"))
  assert_true(dc.contains("bp"))
}

///|
test "Suite2 Circuit 07: 10-Stage Ladder Transmission Line Pulse Dispersion" {
  let netlist_str =
    #|* 10-Stage LC Distributed Coaxial Cable Line (Z0 = 50 Ohm, Td = 10 ns)
    #|VIN in 0 PULSE(0 1.0 1e-9 1e-10 1e-10 20e-9 50e-9)
    #|RS in n0 50.0
    #|L0 n0 n1 5e-9
    #|C0 n1 0 2e-12
    #|L1 n1 n2 5e-9
    #|C1 n2 0 2e-12
    #|L2 n2 n3 5e-9
    #|C2 n3 0 2e-12
    #|L3 n3 n4 5e-9
    #|C3 n4 0 2e-12
    #|L4 n4 n5 5e-9
    #|C4 n5 0 2e-12
    #|RLOAD n5 0 50.0
    #|.tran 1e-10 30e-9
  let netlist = @spice.parse_spice_netlist(netlist_str)
  let sim = CircuitSimulator::{ netlist, }
  let tran = sim.solve_transient(1.0e-10, 1.0e-8)
  assert_true(tran.steps.length() > 50)
}

///|
test "Suite2 Circuit 08: Bootstrap Cascode Current Source for High Voltage Compliance" {
  let netlist_str =
    #|* Self-Biased Bootstrap Cascode Current Source
    #|VDD vdd 0 DC 12.0
    #|M1 n1 n1 0 0 NMOS_STD
    #|M2 n2 n1 n1 0 NMOS_STD
    #|M3 out n2 n2 0 NMOS_STD
    #|R_REF vdd n2 50000.0
    #|RLOAD vdd out 1000.0
    #|.model NMOS_STD NMOS (VTO=0.7 KP=100e-6)
    #|.op
  let netlist = @spice.parse_spice_netlist(netlist_str)
  let (indexer, _, _, _) = @mna.build_dc_mna_system(netlist)
  assert_true(indexer.node_count() >= 4)
}

///|
test "Suite2 Circuit 09: Instrumentation Amplifier Triple OpAmp Architecture" {
  let netlist_str =
    #|* Classic 3-OpAmp Instrumentation Amplifier (Gain = (1 + 2*R1/Rg) * (R3/R2))
    #|VINP inp 0 DC 2.505
    #|VINM inm 0 DC 2.495
    #|* Input buffer stages X1, X2 with gain resistor RG
    #|RG n_a n_b 1000.0
    #|R1 out1 n_a 10000.0
    #|R2 out2 n_b 10000.0
    #|X1 inp n_a out1 OPAMP
    #|X2 inm n_b out2 OPAMP
    #|* Difference stage X3
    #|R3 out1 n_c 10000.0
    #|R4 out2 n_d 10000.0
    #|R5 n_d 0 10000.0
    #|R6 n_c out 10000.0
    #|X3 n_d n_c out OPAMP
    #|.op
  let netlist = @spice.parse_spice_netlist(netlist_str)
  let sim = CircuitSimulator::{ netlist, }
  let dc = sim.solve_dc()
  assert_true(dc.contains("out"))
}

///|
test "Suite2 Circuit 10: Logarithmic and Anti-Logarithmic BJT Transdiode Converters" {
  let netlist_str =
    #|* Logarithmic Amplifier: V_out = -V_T * ln(V_in / (R_in * I_S))
    #|VIN in 0 DC 1.0
    #|RIN in n_inv 10000.0
    #|* Transdiode feedback Q_LOG
    #|Q_LOG 0 n_inv out NPN_LOG
    #|X1 0 n_inv out OPAMP
    #|.model NPN_LOG NPN (IS=1e-14 BF=200)
    #|.op
  let netlist = @spice.parse_spice_netlist(netlist_str)
  let (indexer, _, _, _) = @mna.build_dc_mna_system(netlist)
  assert_true(indexer.node_count() >= 3)
}
