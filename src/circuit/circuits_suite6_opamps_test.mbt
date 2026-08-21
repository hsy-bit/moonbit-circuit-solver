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
test "Suite6 OpAmp 01: Inverting Amplifier Gain Av = -Rf / Rin" {
  let netlist_str =
    #|* Inverting Amplifier Gain = -10
    #|VIN in 0 DC 0.5
    #|RIN in inv 1000.0
    #|RF inv out 10000.0
    #|X1 0 inv out OPAMP
    #|.op
  let netlist = @spice.parse_spice_netlist(netlist_str)
  let sim = CircuitSimulator::{ netlist, }
  let dc = sim.solve_dc()
  assert_true(dc.contains("out"))
  let v_out = dc.get("out").unwrap()
  assert_true((v_out - -5.0).abs() < 1.0e-3)
}

///|
test "Suite6 OpAmp 02: Non-Inverting Amplifier Gain Av = 1 + Rf / Rg" {
  let netlist_str =
    #|* Non-Inverting Amplifier Gain = 1 + 9k/1k = 10
    #|VIN in 0 DC 0.5
    #|RG inv 0 1000.0
    #|RF inv out 9000.0
    #|X1 in inv out OPAMP
    #|.op
  let netlist = @spice.parse_spice_netlist(netlist_str)
  let sim = CircuitSimulator::{ netlist, }
  let dc = sim.solve_dc()
  let v_out = dc.get("out").unwrap()
  assert_true((v_out - 5.0).abs() < 1.0e-3)
}

///|
test "Suite6 OpAmp 03: Unity-Gain Voltage Follower Buffer" {
  let netlist_str =
    #|* Unity-Gain Voltage Follower
    #|VIN in 0 DC 3.3
    #|X1 in out out OPAMP
    #|RLOAD out 0 500.0
    #|.op
  let netlist = @spice.parse_spice_netlist(netlist_str)
  let sim = CircuitSimulator::{ netlist, }
  let dc = sim.solve_dc()
  let v_out = dc.get("out").unwrap()
  assert_true((v_out - 3.3).abs() < 1.0e-3)
}

///|
test "Suite6 OpAmp 04: Summing Inverting Amplifier (Vout = - (V1 + 2*V2))" {
  let netlist_str =
    #|* Summing Amplifier: Vout = - (10k/10k * V1 + 10k/5k * V2)
    #|V1 v1 0 DC 1.0
    #|V2 v2 0 DC 2.0
    #|R1 v1 inv 10000.0
    #|R2 v2 inv 5000.0
    #|RF inv out 10000.0
    #|X1 0 inv out OPAMP
    #|.op
  let netlist = @spice.parse_spice_netlist(netlist_str)
  let sim = CircuitSimulator::{ netlist, }
  let dc = sim.solve_dc()
  // Vout = - (1.0 + 2 * 2.0) = -5.0 V
  let v_out = dc.get("out").unwrap()
  assert_true((v_out - -5.0).abs() < 1.0e-3)
}

///|
test "Suite6 OpAmp 05: Difference Amplifier Common-Mode Rejection" {
  let netlist_str =
    #|* Balanced Difference Amplifier: Vout = (Vp - Vm) * (Rf/R1)
    #|VP vp 0 DC 5.1
    #|VM vm 0 DC 5.0
    #|* Non-inverting divider
    #|R1 vp pos 10000.0
    #|R2 pos 0 10000.0
    #|* Inverting branch
    #|R3 vm neg 10000.0
    #|RF neg out 10000.0
    #|X1 pos neg out OPAMP
    #|.op
  let netlist = @spice.parse_spice_netlist(netlist_str)
  let sim = CircuitSimulator::{ netlist, }
  let dc = sim.solve_dc()
  // Vout = 5.1 - 5.0 = 0.1 V
  let v_out = dc.get("out").unwrap()
  assert_true((v_out - 0.1).abs() < 1.0e-3)
}

///|
test "Suite6 OpAmp 06: Howland Current Pump Bidirectional Source" {
  let netlist_str =
    #|* Howland Current Source: I_out = V_in / R_sense
    #|VIN in 0 DC 2.0
    #|R1 in neg 10000.0
    #|RF neg out 10000.0
    #|R2 0 pos 10000.0
    #|R3 pos out 10000.0
    #|R_LOAD pos 0 1000.0
    #|X1 pos neg out OPAMP
    #|.op
  let netlist = @spice.parse_spice_netlist(netlist_str)
  let sim = CircuitSimulator::{ netlist, }
  let dc = sim.solve_dc()
  assert_true(dc.contains("out"))
}

///|
test "Suite6 OpAmp 07: Current-to-Voltage Transimpedance Amplifier TIA" {
  let netlist_str =
    #|* Transimpedance Amplifier for Photodiode: Vout = - I_in * Rf
    #|I_IN 0 inv DC 100.0e-6
    #|RF inv out 50000.0
    #|CF inv out 10.0e-12
    #|X1 0 inv out OPAMP
    #|.op
  let netlist = @spice.parse_spice_netlist(netlist_str)
  let sim = CircuitSimulator::{ netlist, }
  let dc = sim.solve_dc()
  // Vout = - (100uA * 50k) = -5.0 V
  let v_out = dc.get("out").unwrap()
  assert_true((v_out - -5.0).abs() < 1.0e-3)
}

///|
test "Suite6 OpAmp 08: Charge Amplifier for Piezoelectric Accelerometers" {
  let netlist_str =
    #|* Charge Amplifier: Vout = - Q_in / C_f
    #|VIN in 0 DC 1.0
    #|C_IN in inv 100.0e-12
    #|C_F inv out 10.0e-12
    #|R_F inv out 10.0e6
    #|X1 0 inv out OPAMP
    #|.op
  let netlist = @spice.parse_spice_netlist(netlist_str)
  let (indexer, _, _, _) = @mna.build_dc_mna_system(netlist)
  assert_true(indexer.node_count() >= 3)
}

///|
test "Suite6 OpAmp 09: Audio Baxandall Active Bass and Treble Equalizer" {
  let netlist_str =
    #|* Baxandall Tone Control Stage
    #|VIN in 0 DC 1.0
    #|R_IN in n_in 10000.0
    #|R_BASS n_in out 50000.0
    #|C_BASS n_in out 47e-9
    #|R_TREBLE n_in out 10000.0
    #|C_TREBLE n_in out 4.7e-9
    #|X1 0 n_in out OPAMP
    #|.op
  let netlist = @spice.parse_spice_netlist(netlist_str)
  let sim = CircuitSimulator::{ netlist, }
  let dc = sim.solve_dc()
  assert_true(dc.contains("out"))
}

///|
test "Suite6 OpAmp 10: Precision Zero-Crossing Detector with Dual Clamping" {
  let netlist_str =
    #|* Zero Crossing Comparator with Diode Clamping
    #|VIN in 0 DC 0.05
    #|X1 in 0 out OPAMP
    #|RLOAD out 0 10000.0
    #|.op
  let netlist = @spice.parse_spice_netlist(netlist_str)
  let sim = CircuitSimulator::{ netlist, }
  let dc = sim.solve_dc()
  assert_true(dc.contains("out"))
}
