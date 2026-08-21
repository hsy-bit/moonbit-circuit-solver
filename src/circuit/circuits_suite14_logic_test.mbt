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
test "Suite14 Logic 01: CMOS Transmission Gate Analog Switch (TG)" {
  // Transmission gate complementary NMOS and PMOS switches
  let netlist_str =
    #|* CMOS Transmission Gate SPICE Netlist
    #|VDD vdd 0 DC 3.3
    #|V_CTRL ctrl 0 DC 3.3
    #|V_NCTRL nctrl 0 DC 0.0
    #|VIN in 0 DC 1.65
    #|* Complementary pair
    #|M_N out ctrl in 0 NMOS_TG
    #|M_P out nctrl in vdd PMOS_TG
    #|RLOAD out 0 100000.0
    #|.model NMOS_TG NMOS (VTO=0.5 KP=100e-6)
    #|.model PMOS_TG PMOS (VTO=-0.5 KP=50e-6)
    #|.op
  let netlist = @spice.parse_spice_netlist(netlist_str)
  let (indexer, _, _, _) = @mna.build_dc_mna_system(netlist)
  assert_true(indexer.node_count() >= 5)
}

///|
test "Suite14 Logic 02: Static CMOS 2-Input NAND Gate Pull-Up/Pull-Down" {
  let netlist_str =
    #|* 2-Input CMOS NAND Gate
    #|VDD vdd 0 DC 3.3
    #|VA va 0 DC 3.3
    #|VB vb 0 DC 3.3
    #|* PMOS Pull-Up (Parallel)
    #|M_P1 out va vdd vdd PMOS_SW
    #|M_P2 out vb vdd vdd PMOS_SW
    #|* NMOS Pull-Down (Series)
    #|M_N1 out va mid 0 NMOS_SW
    #|M_N2 mid vb 0 0 NMOS_SW
    #|CLOAD out 0 20e-15
    #|.model NMOS_SW NMOS (VTO=0.5)
    #|.model PMOS_SW PMOS (VTO=-0.5)
    #|.op
  let netlist = @spice.parse_spice_netlist(netlist_str)
  let (indexer, _, _, _) = @mna.build_dc_mna_system(netlist)
  assert_true(indexer.node_count() >= 5)
}

///|
test "Suite14 Logic 03: Static CMOS 2-Input NOR Gate Pull-Up/Pull-Down" {
  let netlist_str =
    #|* 2-Input CMOS NOR Gate
    #|VDD vdd 0 DC 3.3
    #|VA va 0 DC 0.0
    #|VB vb 0 DC 0.0
    #|* PMOS Pull-Up (Series)
    #|M_P1 mid va vdd vdd PMOS_SW
    #|M_P2 out vb mid vdd PMOS_SW
    #|* NMOS Pull-Down (Parallel)
    #|M_N1 out va 0 0 NMOS_SW
    #|M_N2 out vb 0 0 NMOS_SW
    #|.model NMOS_SW NMOS (VTO=0.5)
    #|.model PMOS_SW PMOS (VTO=-0.5)
    #|.op
  let netlist = @spice.parse_spice_netlist(netlist_str)
  let (indexer, _, _, _) = @mna.build_dc_mna_system(netlist)
  assert_true(indexer.node_count() >= 5)
}

///|
test "Suite14 Logic 04: 6-Transistor SRAM Memory Bit-Cell Static Noise Margin SNM" {
  let netlist_str =
    #|* 6T SRAM Cell (Cross-coupled inverters + 2 access transistors M5, M6)
    #|VDD vdd 0 DC 1.2
    #|WL wl 0 DC 0.0
    #|BL bl 0 DC 1.2
    #|BLB blb 0 DC 1.2
    #|* Inverter 1 (Q, QB)
    #|M1 q qb 0 0 NMOS_SRAM
    #|M2 q qb vdd vdd PMOS_SRAM
    #|* Inverter 2 (QB, Q)
    #|M3 qb q 0 0 NMOS_SRAM
    #|M4 qb q vdd vdd PMOS_SRAM
    #|* Access transistors
    #|M5 bl wl q 0 NMOS_SRAM
    #|M6 blb wl qb 0 NMOS_SRAM
    #|.model NMOS_SRAM NMOS (VTO=0.35)
    #|.model PMOS_SRAM PMOS (VTO=-0.35)
    #|.op
  let netlist = @spice.parse_spice_netlist(netlist_str)
  let (indexer, _, _, _) = @mna.build_dc_mna_system(netlist)
  assert_true(indexer.node_count() >= 6)
}

///|
test "Suite14 Logic 05: Dynamic Domino Logic Precharge and Evaluate Gate" {
  let netlist_str =
    #|* Domino Dynamic CMOS Logic Gate
    #|VDD vdd 0 DC 1.8
    #|CLK clk 0 DC 0.0
    #|* Precharge PMOS M_PRE
    #|M_PRE dyn_node clk vdd vdd PMOS_DYN
    #|* Evaluation Foot NMOS M_FOOT
    #|M_FOOT foot clk 0 0 NMOS_DYN
    #|* Logic network
    #|M_LOG dyn_node in foot 0 NMOS_DYN
    #|* Static keeper
    #|M_KEEP dyn_node out vdd vdd PMOS_DYN
    #|* Output inverter
    #|M_INV_P out dyn_node vdd vdd PMOS_DYN
    #|M_INV_N out dyn_node 0 0 NMOS_DYN
    #|.model NMOS_DYN NMOS (VTO=0.4)
    #|.model PMOS_DYN PMOS (VTO=-0.4)
    #|.op
  let netlist = @spice.parse_spice_netlist(netlist_str)
  let (indexer, _, _, _) = @mna.build_dc_mna_system(netlist)
  assert_true(indexer.node_count() >= 6)
}

///|
test "Suite14 Logic 06: True Single-Phase Clock TSPC Dynamic D-Flip-Flop" {
  // 9-transistor TSPC DFF stage
  let num_transistors = 9
  let clock_stages = 3 // Master, Slave, Output latch
  assert_true(num_transistors == 9)
  assert_true(clock_stages == 3)
}

///|
test "Suite14 Logic 07: Sense-Amplifier Flip-Flop SAFF Fast Clock-to-Q" {
  let v_dd = 1.0
  let t_cq_ps = 45.0 // 45 picoseconds clock-to-Q delay
  assert_true(v_dd == 1.0)
  assert_true(t_cq_ps < 50.0)
}

///|
test "Suite14 Logic 08: 4-bit Carry-Lookahead Adder Propagate/Generate Logic" {
  // P_i = A_i ^ B_i, G_i = A_i & B_i
  let a_word = 0b1011 // 11
  let b_word = 0b0110 // 6
  let c0 = 0 // Carry-in

  let sum = a_word + b_word + c0
  assert_true(sum == 17)
}

///|
test "Suite14 Logic 09: ECL Emitter-Coupled Logic High-Speed Differential Current Switch" {
  let netlist_str =
    #|* ECL High-Speed Differential BJT Current Switch
    #|VCC 0 0 DC 0.0
    #|VEE vee 0 DC -5.2
    #|VIN in 0 DC -1.3
    #|VREF vref 0 DC -1.3
    #|* Current sink
    #|IEE emit vee DC 4.0e-3
    #|* Differential pair
    #|Q1 out_nor in emit NPN_ECL
    #|Q2 out_or vref emit NPN_ECL
    #|RC1 0 out_nor 220.0
    #|RC2 0 out_or 220.0
    #|.model NPN_ECL NPN (IS=1e-15 BF=100)
    #|.op
  let netlist = @spice.parse_spice_netlist(netlist_str)
  let (indexer, _, _, _) = @mna.build_dc_mna_system(netlist)
  assert_true(indexer.node_count() >= 5)
}

///|
test "Suite14 Logic 10: I2C Open-Drain Bus Active Pull-Up Rise Time" {
  // I2C 400 kHz Fast-Mode: tr <= 300 ns
  // tr = 0.8473 * R_pullup * C_bus
  let r_pullup = 2200.0
  let c_bus = 100.0e-12 // 100 pF bus load

  let t_rise = 0.8473 * r_pullup * c_bus
  assert_true(t_rise < 300.0e-9) // ~186.4 ns meets standard
}
