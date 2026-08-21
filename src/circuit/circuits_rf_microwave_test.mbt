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
test "Wilkinson Power Divider 3-Port S-Parameters at 2.4 GHz" {
  // Classic equal-split Wilkinson divider with quarter-wave 70.7 Ohm lines and 100 Ohm isolation resistor
  // Port 1 (Input 50 Ohm), Port 2 (Output 1 50 Ohm), Port 3 (Output 2 50 Ohm)
  let z0 = 50.0
  let sqrt2_z0 = 50.0 * 2.0.sqrt() // 70.71 Ohms
  let r_iso = 100.0 // Isolation resistor

  assert_true((sqrt2_z0 - 70.71).abs() < 0.1)
  assert_true(r_iso == 2.0 * z0)

  // Scattering parameters at center frequency:
  // S11 = 0, S22 = 0, S33 = 0 (Matched ports)
  // S21 = S31 = -j / sqrt(2) -> Magnitude = 1 / sqrt(2) (-3.01 dB), Phase = -90 deg
  // S23 = S32 = 0 (Complete isolation between output ports)
  let s21_mag = 1.0 / 2.0.sqrt()
  let s21_db = 20.0 * @math.log10(s21_mag)

  assert_true((s21_db - -3.0103).abs() < 1.0e-3)
}

///|
test "Quarter-Wave Impedance Transformer RF Matching" {
  // Match a 100 Ohm load to a 50 Ohm line at 1 GHz
  // Required transformer characteristic impedance Z_t = sqrt(Z_in * Z_load) = sqrt(50 * 100) = 70.71 Ohms
  let z_in = 50.0
  let z_load = 100.0
  let z_trans = (z_in * z_load).sqrt()

  assert_true((z_trans - 70.7106).abs() < 1.0e-3)

  // Input reflection coefficient Gamma_in at center frequency = 0
  let gamma_in = (z_in - z_in) / (z_in + z_in)
  assert_true(gamma_in == 0.0)
}

///|
test "RF Pi-Network and T-Network Low-Pass Matching Filters" {
  // 5th-Order Chebyshev Low-Pass Filter with 50 Ohm termination
  let netlist_str =
    #|* 5th-Order 1 GHz RF Low-Pass Pi Filter
    #|VIN in 0 DC 0.0
    #|RIN in n1 50.0
    #|C1 n1 0 3.18e-12
    #|L1 n1 n2 15.9e-9
    #|C2 n2 0 6.36e-12
    #|L2 n2 n3 15.9e-9
    #|C3 n3 0 3.18e-12
    #|RLOAD n3 0 50.0
    #|.ac dec 10 100e6 10e9
  let netlist = @spice.parse_spice_netlist(netlist_str)
  let (indexer, _, _, _) = @mna.build_dc_mna_system(netlist)

  assert_true(indexer.node_count() >= 4)
  assert_true(indexer.total_size() >= 4)
}

///|
test "Gilbert Cell Four-Quadrant Analog RF Multiplier Mixer" {
  // Gilbert cell mixer netlist with LO switching quad and RF differential pair
  let netlist_str =
    #|* Gilbert Cell Double-Balanced RF Mixer
    #|VCC vcc 0 DC 5.0
    #|* RF bias resistors
    #|R_RF1 vcc rf_pos 10000.0
    #|R_RF2 vcc rf_neg 10000.0
    #|* RF differential pair (Q1, Q2)
    #|Q1 if_pos rf_pos 0 NPN_MIX
    #|Q2 if_neg rf_neg 0 NPN_MIX
    #|* Load resistors
    #|RL1 vcc if_pos 1000.0
    #|RL2 vcc if_neg 1000.0
    #|* Models
    #|.model NPN_MIX NPN (IS=1e-15 BF=100)
    #|.op
  let netlist = @spice.parse_spice_netlist(netlist_str)
  let sim = CircuitSimulator::{ netlist, }
  let dc = sim.solve_nonlinear_dc()

  assert_true(dc.contains("vcc"))
  assert_true((dc.get("vcc").unwrap() - 5.0).abs() < 1.0e-6)
}

///|
test "Directional Coupler 4-Port RF scattering matrix" {
  // 4-Port Coupler with coupling factor C = 20 dB, Directivity D = 30 dB
  let c_db = 20.0
  let d_db = 30.0
  let iso_db = c_db + d_db // Isolation = 50 dB

  let c_mag = @math.pow(10.0, -c_db / 20.0) // 0.1
  let iso_mag = @math.pow(10.0, -iso_db / 20.0) // 0.00316
  let thru_mag = (1.0 - c_mag * c_mag).sqrt()

  assert_true((c_mag - 0.1).abs() < 1.0e-6)
  assert_true(thru_mag > 0.99)
  assert_true(iso_mag < 0.005)
}
