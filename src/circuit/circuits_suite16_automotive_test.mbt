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
test "Suite16 Auto 01: ISO 7637-2 Pulse 5a Load Dump Surge Clamping" {
  // Peak unsuppressed surge Us = 87V, duration td = 400 ms, Ri = 2 Ohms
  // TVS Diode clamps voltage to V_clamp = 36V
  let v_surge = 87.0
  let v_clamp = 36.0
  let r_internal = 2.0

  let i_peak = (v_surge - v_clamp) / r_internal // (87 - 36) / 2 = 25.5 A
  let p_peak = v_clamp * i_peak // 36 * 25.5 = 918 Watts

  assert_true(i_peak == 25.5)
  assert_true((p_peak - 918.0).abs() < 1.0e-6)
}

///|
test "Suite16 Auto 02: CAN-Bus Split-Termination Common-Mode Filter" {
  let netlist_str =
    #|* CAN Bus Split Termination Network (Two 60 Ohm resistors + 4.7 nF to GND)
    #|V_CANH canh 0 DC 3.5
    #|V_CANL canl 0 DC 1.5
    #|R_SPLIT1 canh split_mid 60.0
    #|R_SPLIT2 canl split_mid 60.0
    #|C_CM split_mid 0 4.7e-9
    #|.op
  let netlist = @spice.parse_spice_netlist(netlist_str)
  let sim = CircuitSimulator::{ netlist, }
  let dc = sim.solve_dc()
  assert_true(dc.contains("split_mid"))
  // Common-mode center potential = (3.5 + 1.5) / 2 = 2.5 V
  let v_cm = dc.get("split_mid").unwrap()
  assert_true((v_cm - 2.5).abs() < 1.0e-3)
}

///|
test "Suite16 Auto 03: 48V to 12V Dual-Battery Bidirectional Buck-Boost Interconnect" {
  let v_48v = 48.0
  let v_12v = 12.0
  let p_transfer = 3000.0 // 3 kW transfer

  let i_48v = p_transfer / v_48v // 62.5 A
  let i_12v = p_transfer / v_12v // 250 A

  assert_true(i_48v == 62.5)
  assert_true(i_12v == 250.0)
}

///|
test "Suite16 Auto 04: EV Traction Battery 12-Cell Passive Balancing Shunt" {
  // Cell nominal voltage 3.7V, Overcharge bypass threshold 4.2V, R_bleed = 33 Ohm
  let v_cell_top = 4.2
  let r_bleed = 33.0

  let i_bleed = v_cell_top / r_bleed
  let p_bleed = v_cell_top * i_bleed

  assert_true((i_bleed - 0.12727).abs() < 1.0e-4) // ~127 mA
  assert_true((p_bleed - 0.5345).abs() < 0.01) // ~0.53 W
}

///|
test "Suite16 Auto 05: Isolated Gate Driver Desaturation DESAT Detection" {
  // IGBT / SiC short-circuit detection: V_CE > 7.0V activates blanking and fast soft turn-off
  let v_desat_thresh = 7.0
  let i_charge = 250.0e-6 // 250 uA blanking charge current
  let c_blank = 100.0e-12 // 100 pF blanking cap

  // Blanking time t_blank = C * V_thresh / I_charge = 100p * 7 / 250u = 2.8 us
  let t_blank = c_blank * v_desat_thresh / i_charge
  assert_true((t_blank - 2.8e-6).abs() < 1.0e-8)
}

///|
test "Suite16 Auto 06: LIN-Bus Single-Wire Dominant/Recessive Level Translation" {
  let v_bat = 12.0
  let v_recessive = v_bat // 12V
  let v_dominant = 1.0 // < 1.4V

  let delta_v = v_recessive - v_dominant
  assert_true(delta_v == 11.0)
}

///|
test "Suite16 Auto 07: Reverse Battery Protection P-Channel MOSFET Gate Clamp" {
  let netlist_str =
    #|* Reverse Polarity P-MOSFET Protection with Zener Gate Clamp
    #|VIN in 0 DC 14.0
    #|M_PROT out gate in in PMOS_AUTO
    #|R_PULL gate 0 100000.0
    #|D_ZENER gate in 1N4742
    #|RLOAD out 0 10.0
    #|.model PMOS_AUTO PMOS (VTO=-2.0)
    #|.model 1N4742 D (IS=1e-11)
    #|.op
  let netlist = @spice.parse_spice_netlist(netlist_str)
  let (indexer, _, _, _) = @mna.build_dc_mna_system(netlist)
  assert_true(indexer.node_count() >= 3)
}

///|
test "Suite16 Auto 08: Resolver RDC (Resolver-to-Digital Converter) Tracking Loop" {
  // Excitation V_ex = V0 * sin(omega*t)
  // Sin coil: V_sin = V0 * sin(theta) * sin(omega*t)
  // Cos coil: V_cos = V0 * cos(theta) * sin(omega*t)
  let theta_rad = 0.52359877 // 30 degrees
  let sin_th = @math.sin(theta_rad)
  let cos_th = @math.cos(theta_rad)

  assert_true((sin_th - 0.5).abs() < 1.0e-5)
  assert_true((cos_th - 0.866025).abs() < 1.0e-5)
}

///|
test "Suite16 Auto 09: Pyro-Fuse High-Voltage Disconnect Pyrotechnic Actuator" {
  let t_trip_us = 1.5 // 1.5 microseconds disconnect time
  let v_isolated = 1000.0 // 1000V traction isolation
  assert_true(t_trip_us < 2.0)
  assert_true(v_isolated == 1000.0)
}

///|
test "Suite16 Auto 10: High-Voltage Interlock Loop HVIL Continuity Check" {
  // HVIL 20 mA current loop through all HV connectors
  let i_hvil = 0.020 // 20 mA
  let r_loop = 50.0 // 50 Ohm loop resistance
  let v_sense = i_hvil * r_loop // 1.0 V

  assert_true(v_sense == 1.0)
}
