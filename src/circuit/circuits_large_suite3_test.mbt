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
test "Suite3 Circuit 01: 5-Stage CMOS Inverter Ring Oscillator Delay Chain" {
  let netlist_str =
    #|* 5-Stage Odd Inverter Ring Oscillator
    #|VDD vdd 0 DC 3.3
    #|* Inverter 1 (n5 -> n1)
    #|M1_P n1 n5 vdd vdd PMOS_STD
    #|M1_N n1 n5 0 0 NMOS_STD
    #|C1 n1 0 10e-15
    #|* Inverter 2 (n1 -> n2)
    #|M2_P n2 n1 vdd vdd PMOS_STD
    #|M2_N n2 n1 0 0 NMOS_STD
    #|C2 n2 0 10e-15
    #|* Inverter 3 (n2 -> n3)
    #|M3_P n3 n2 vdd vdd PMOS_STD
    #|M3_N n3 n2 0 0 NMOS_STD
    #|C3 n3 0 10e-15
    #|* Inverter 4 (n3 -> n4)
    #|M4_P n4 n3 vdd vdd PMOS_STD
    #|M4_N n4 n3 0 0 NMOS_STD
    #|C4 n4 0 10e-15
    #|* Inverter 5 (n4 -> n5)
    #|M5_P n5 n4 vdd vdd PMOS_STD
    #|M5_N n5 n4 0 0 NMOS_STD
    #|C5 n5 0 10e-15
    #|.model NMOS_STD NMOS (VTO=0.5 KP=150e-6)
    #|.model PMOS_STD PMOS (VTO=-0.5 KP=50e-6)
    #|.tran 1e-12 5e-10
  let netlist = @spice.parse_spice_netlist(netlist_str)
  let (indexer, a_mat, z_vec, _) = @mna.build_dc_mna_system(netlist)
  assert_true(indexer.node_count() >= 6)
  assert_true(a_mat.num_rows() == indexer.total_size())
  assert_true(z_vec.length() == indexer.total_size())
}

///|
test "Suite3 Circuit 02: Schmitt Trigger Inverting Comparator with Hysteresis" {
  let netlist_str =
    #|* OpAmp Inverting Schmitt Trigger (Vth_high = +Vsat * R1/(R1+R2), Vth_low = -Vsat * R1/(R1+R2))
    #|VIN in 0 DC 1.0
    #|R1 v_pos 0 10000.0
    #|R2 out v_pos 40000.0
    #|X1 v_pos in out OPAMP
    #|.op
  let netlist = @spice.parse_spice_netlist(netlist_str)
  let sim = CircuitSimulator::{ netlist, }
  let dc = sim.solve_dc()
  assert_true(dc.contains("out"))
  assert_true(dc.contains("v_pos"))
}

///|
test "Suite3 Circuit 03: Voltage-Controlled Crystal Oscillator VCXO Equivalent Circuit" {
  let netlist_str =
    #|* Butterworth-van Dyke (BVD) Quartz Crystal Motional Model (fs = 10 MHz)
    #|VIN in 0 AC 1.0
    #|* Motional Arm (Lm, Cm, Rm)
    #|L_M in n1 25.33e-3
    #|C_M n1 n2 0.01e-12
    #|R_M n2 out 10.0
    #|* Shunt static package capacitance C0
    #|C0 in out 4.0e-12
    #|RLOAD out 0 50.0
    #|.ac dec 50 9.9e6 10.1e6
  let netlist = @spice.parse_spice_netlist(netlist_str)
  let (indexer, _, _, _) = @mna.build_dc_mna_system(netlist)
  assert_true(indexer.node_count() >= 4)
}

///|
test "Suite3 Circuit 04: Twin-T Notch Active Filter at 50/60 Hz Power Line Rejection" {
  let netlist_str =
    #|* Twin-T Active Notch Filter for 50 Hz Hum Elimination
    #|VIN in 0 DC 1.0
    #|* Low-pass T: R, R, 2C
    #|R1 in n_mid1 31830.0
    #|R2 n_mid1 n_sum 31830.0
    #|C3 n_mid1 0 200e-9
    #|* High-pass T: C, C, R/2
    #|C1 in n_mid2 100e-9
    #|C2 n_mid2 n_sum 100e-9
    #|R3 n_mid2 0 15915.0
    #|* Buffer OpAmp
    #|X1 n_sum out out OPAMP
    #|.op
  let netlist = @spice.parse_spice_netlist(netlist_str)
  let sim = CircuitSimulator::{ netlist, }
  let dc = sim.solve_dc()
  assert_true(dc.contains("out"))
  assert_true((dc.get("out").unwrap() - 1.0).abs() < 1.0e-2)
}

///|
test "Suite3 Circuit 05: Current-Feedback Operational Amplifier CFA Architecture" {
  let netlist_str =
    #|* AD844-like Current-Feedback Amplifier (CFA) Buffer and Transimpedance Node
    #|VCC vcc 0 DC 15.0
    #|VEE vee 0 DC -15.0
    #|VIN in 0 DC 2.0
    #|* Input buffer (Unity gain from non-inv to inverting input)
    #|E_BUF inv_in 0 in 0 1.0
    #|* Inverting input terminal resistance
    #|R_INV inv_in n_err 50.0
    #|* Transimpedance node Tz
    #|G_TZ tz 0 n_err 0 1.0e-6
    #|R_TZ tz 0 1.0e6
    #|C_TZ tz 0 4.5e-12
    #|* Output buffer
    #|E_OUT out 0 tz 0 1.0
    #|RLOAD out 0 1000.0
    #|.op
  let netlist = @spice.parse_spice_netlist(netlist_str)
  let sim = CircuitSimulator::{ netlist, }
  let dc = sim.solve_dc()
  assert_true(dc.contains("out"))
  assert_true(dc.contains("vcc"))
  assert_true((dc.get("vcc").unwrap() - 15.0).abs() < 1.0e-6)
}

///|
test "Suite3 Circuit 06: Switched-Capacitor Resistor Equivalent Emulation" {
  // Switched capacitor resistor R_eq = 1 / (f_clk * C)
  // At f_clk = 100 kHz, C = 10 pF -> R_eq = 1 / (1e5 * 10e-12) = 1.0 MOhm
  let f_clk = 100.0e3
  let c_val = 10.0e-12
  let r_eq = 1.0 / (f_clk * c_val)
  assert_true((r_eq - 1.0e6).abs() < 1.0e-6)

  let netlist_str =
    #|* Switched-Capacitor Integrator DC Operating Point
    #|VIN in 0 DC 1.0
    #|R_EQ in n_inv 1.0e6
    #|C_INT n_inv out 100e-12
    #|X1 0 n_inv out OPAMP
    #|.op
  let netlist = @spice.parse_spice_netlist(netlist_str)
  let sim = CircuitSimulator::{ netlist, }
  let dc = sim.solve_dc()
  assert_true(dc.contains("out"))
}

///|
test "Suite3 Circuit 07: Cascaded RC Sallen-Key Band-Pass Active Filter" {
  let netlist_str =
    #|* Sallen-Key Band-Pass Active Filter (f0 = 1 kHz, Q = 5)
    #|VIN in 0 DC 1.0
    #|R1 in n1 10000.0
    #|R2 n1 0 10000.0
    #|C1 n1 n_pos 15.9e-9
    #|C2 n1 out 15.9e-9
    #|R3 n_pos 0 20000.0
    #|X1 n_pos out out OPAMP
    #|.op
  let netlist = @spice.parse_spice_netlist(netlist_str)
  let sim = CircuitSimulator::{ netlist, }
  let dc = sim.solve_dc()
  assert_true(dc.contains("out"))
}

///|
test "Suite3 Circuit 08: Peak Detector with Diode Reset and Hold Capacitor" {
  let netlist_str =
    #|* Analog Peak Detector Circuit
    #|VIN in 0 DC 5.0
    #|X1 in out_op out_op OPAMP
    #|D1 out_op hold 1N4148
    #|C_HOLD hold 0 100e-9
    #|R_LEAK hold 0 10.0e6
    #|X2 hold out out OPAMP
    #|.model 1N4148 D (IS=1e-14 N=1.0)
    #|.op
  let netlist = @spice.parse_spice_netlist(netlist_str)
  let (indexer, _, _, _) = @mna.build_dc_mna_system(netlist)
  assert_true(indexer.node_count() >= 4)
}

///|
test "Suite3 Circuit 09: Precision Full-Wave Absolute Value Rectifier" {
  let netlist_str =
    #|* High-Precision Absolute Value Rectifier Circuit
    #|VIN in 0 DC 3.0
    #|R1 in n1 10000.0
    #|R2 in n2 10000.0
    #|R3 n1 out1 10000.0
    #|D1 n1 out1 1N4148
    #|D2 out1 n1 1N4148
    #|X1 0 n1 out1 OPAMP
    #|R4 out1 n2 5000.0
    #|R5 n2 out 10000.0
    #|X2 0 n2 out OPAMP
    #|.model 1N4148 D (IS=1e-14 N=1.0)
    #|.op
  let netlist = @spice.parse_spice_netlist(netlist_str)
  let (indexer, _, _, _) = @mna.build_dc_mna_system(netlist)
  assert_true(indexer.node_count() >= 5)
}

///|
test "Suite3 Circuit 10: Wien Bridge High-Order Multi-Decade Frequency Step" {
  let netlist_str =
    #|* Multi-Decade Frequency Response Network
    #|VIN in 0 AC 1.0
    #|R1 in n1 1000.0
    #|C1 n1 n2 10e-9
    #|R2 n2 0 1000.0
    #|C2 n2 0 10e-9
    #|RLOAD n2 0 10000.0
    #|.ac dec 10 10 1000000
  let netlist = @spice.parse_spice_netlist(netlist_str)
  let (indexer, _, _, _) = @mna.build_dc_mna_system(netlist)
  assert_true(indexer.node_count() >= 3)
}
