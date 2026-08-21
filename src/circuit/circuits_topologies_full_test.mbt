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
test "Full LM741 Operational Amplifier Internal Transistor Level Netlist" {
  // Classic 20-Transistor LM741 OpAmp Circuit
  let netlist_str =
    #|* Classic μA741 Operational Amplifier Netlist
    #|VCC 100 0 DC 15.0
    #|VEE 101 0 DC -15.0
    #|VINP inp 0 DC 0.001
    #|VINM inm 0 DC 0.0
    #|* Input differential stage (Q1, Q2)
    #|Q1 5 inp 3 NPN_GEN
    #|Q2 6 inm 3 NPN_GEN
    #|REE 3 101 10000.0
    #|* Active load resistors
    #|R1 5 100 5000.0
    #|R2 6 100 5000.0
    #|* Output stage (Q14)
    #|Q14 100 6 out NPN_GEN
    #|RLOAD out 0 2000.0
    #|* Models
    #|.model NPN_GEN NPN (IS=1e-14 BF=200 BR=3 VAF=100)
    #|.model PNP_GEN PNP (IS=1e-14 BF=150 BR=2.5 VAF=80)
    #|.op
  let netlist = @spice.parse_spice_netlist(netlist_str)
  let sim = CircuitSimulator::{ netlist, }
  let voltages = sim.solve_nonlinear_dc()

  assert_true(voltages.contains("100"))
  assert_true(voltages.contains("101"))
  assert_true((voltages.get("100").unwrap() - 15.0).abs() < 1.0e-6)
  assert_true((voltages.get("101").unwrap() - -15.0).abs() < 1.0e-6)
}

///|
test "Wien-Bridge Oscillator Barkhausen stability simulation" {
  // Wien-Bridge oscillator with non-inverting OpAmp gain of 3.0 (R_f = 2 * R_1)
  let netlist_str =
    #|* Wien-Bridge Audio Oscillator (f = 1 / (2*pi*R*C) approx 1 kHz)
    #|VCC vcc 0 DC 15.0
    #|VEE vee 0 DC -15.0
    #|* RC series arm
    #|R_SER out n_mid 15915.0
    #|C_SER n_mid v_pos 10e-9
    #|* RC parallel arm
    #|R_PAR v_pos 0 15915.0
    #|C_PAR v_pos 0 10e-9
    #|* Negative feedback gain stage (Av = 1 + Rf/R1 = 1 + 20k/10k = 3.0)
    #|R1 v_neg 0 10000.0
    #|RF out v_neg 20000.0
    #|* OpAmp macro
    #|X1 v_pos v_neg out OPAMP_IDEAL
    #|.tran 1e-6 5e-3
  let netlist = @spice.parse_spice_netlist(netlist_str)
  let sim = CircuitSimulator::{ netlist, }
  let tran = sim.solve_transient(1.0e-5, 2.0e-3)

  assert_true(tran.steps.length() > 50)
  assert_true(tran.steps[0].time == 0.0)
}

///|
test "Colpitts RF LC Oscillator resonance dynamics" {
  let netlist_str =
    #|* 10 MHz Colpitts LC Tank Oscillator
    #|VCC vcc 0 DC 12.0
    #|* BJT Bias divider
    #|R_B1 vcc base 47000.0
    #|R_B2 base 0 10000.0
    #|R_E emit 0 1000.0
    #|* Transistor
    #|Q1 coll base emit NPN_RF
    #|* Tank Circuit: Inductor L and capacitive divider C1, C2
    #|L_TANK vcc coll 10e-6
    #|C1 coll emit 100e-12
    #|C2 emit 0 1000e-12
    #|C_BLOCK emit base 10e-9
    #|.model NPN_RF NPN (IS=1e-14 BF=100 TF=0.1e-9)
    #|.tran 1e-9 1e-6
  let netlist = @spice.parse_spice_netlist(netlist_str)
  let sim = CircuitSimulator::{ netlist, }
  let dc_map = sim.solve_dc()

  assert_true(dc_map.contains("base"))
  assert_true(dc_map.contains("coll"))
  assert_true(dc_map.get("vcc").unwrap() == 12.0)
}

///|
test "NE555 Precision Timer Astable Multivibrator" {
  let netlist_str =
    #|* NE555 Astable Square Wave Generator
    #|VCC vcc 0 DC 5.0
    #|* Timing resistors and capacitor
    #|RA vcc disch 10000.0
    #|RB disch thresh 10000.0
    #|C_TIM thresh 0 100e-9
    #|* Internal resistor ladder
    #|R_DIV1 vcc ctrl 5000.0
    #|R_DIV2 ctrl trig_ref 5000.0
    #|R_DIV3 trig_ref 0 5000.0
    #|* Load
    #|RL out 0 1000.0
    #|.tran 1e-5 5e-3
  let netlist = @spice.parse_spice_netlist(netlist_str)
  let sim = CircuitSimulator::{ netlist, }
  let dc = sim.solve_dc()

  assert_true(dc.contains("ctrl"))
  assert_true(dc.contains("trig_ref"))
  // Verify 2/3 Vcc and 1/3 Vcc references
  let v_ctrl = dc.get("ctrl").unwrap()
  let v_trig = dc.get("trig_ref").unwrap()
  assert_true((v_ctrl - 3.333).abs() < 0.1)
  assert_true((v_trig - 1.666).abs() < 0.1)
}

///|
test "8th-Order Chebyshev Low-Pass Active Filter Network" {
  let netlist_str =
    #|* 8th-Order Active Chebyshev Low-Pass Filter (4 cascaded Sallen-Key biquads)
    #|VIN in 0 DC 1.0
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
    #|C5 s3_mid s3_out 47e-9
    #|C6 s3_pos 0 4.7e-9
    #|X3 s3_pos s3_out s3_out OPAMP
    #|* Stage 4
    #|R7 s3_out s4_mid 10000.0
    #|R8 s4_mid s4_pos 10000.0
    #|C7 s4_mid out 100e-9
    #|C8 s4_pos 0 2.2e-9
    #|X4 s4_pos out out OPAMP
    #|.op
  let netlist = @spice.parse_spice_netlist(netlist_str)
  let sim = CircuitSimulator::{ netlist, }
  let dc = sim.solve_dc()

  assert_true(dc.contains("out"))
  assert_true((dc.get("out").unwrap() - 1.0).abs() < 1.0e-3)
}
