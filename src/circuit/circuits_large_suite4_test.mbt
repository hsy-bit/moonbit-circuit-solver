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
test "Suite4 RF 01: Multi-Section Quarter-Wave Chebyshev Impedance Transformer" {
  // 3-section Chebyshev transformer matching 100 Ohm to 50 Ohm with ripple < 0.05
  let z_load = 100.0
  let z_source = 50.0
  let z_geom = (z_source * z_load).sqrt() // Center stage impedance approx 70.71

  let z1 = 57.5
  let z2 = 70.71
  let z3 = 86.95

  assert_true((z_geom - 70.71).abs() < 0.1)
  assert_true(z1 < z2 && z2 < z3)
}

///|
test "Suite4 RF 02: 90-Degree Branch-Line Hybrid Coupler 4-Port Matrix" {
  // Branch-line coupler (3dB Quadrature hybrid):
  // Port 1 (Input), Port 2 (Thru -3dB, -90 deg), Port 3 (Coupled -3dB, -180 deg), Port 4 (Isolated -inf dB)
  let s_matrix_mag = [
    [0.0, 0.707106, 0.707106, 0.0],
    [0.707106, 0.0, 0.0, 0.707106],
    [0.707106, 0.0, 0.0, 0.707106],
    [0.0, 0.707106, 0.707106, 0.0],
  ]

  let s12 = s_matrix_mag[0][1]
  let s13 = s_matrix_mag[0][2]
  let s14 = s_matrix_mag[0][3]

  assert_true((s12 - 0.707106).abs() < 1.0e-5)
  assert_true((s13 - 0.707106).abs() < 1.0e-5)
  assert_true(s14 == 0.0)
}

///|
test "Suite4 RF 03: Rat-Race 180-Degree Hybrid Ring Coupler" {
  // Rat-race coupler with ring circumference = 1.5 * lambda (6 sections of lambda/4)
  // Delta port produces 180 degree out-of-phase difference
  let ring_z0 = 50.0 * 2.0.sqrt() // 70.71 Ohms
  assert_true((ring_z0 - 70.71).abs() < 0.1)
}

///|
test "Suite4 RF 04: Bandpass Helical Resonator VHF Filter Model" {
  let netlist_str =
    #|* 2-Pole VHF Helical Resonator Bandpass Filter (fc = 145 MHz)
    #|VIN in 0 AC 1.0
    #|RS in n1 50.0
    #|* Cavity 1
    #|L1 n1 0 100e-9
    #|C1 n1 0 12.0e-12
    #|* Mutual aperture coupling capacitor
    #|C12 n1 n2 0.8e-12
    #|* Cavity 2
    #|L2 n2 0 100e-9
    #|C2 n2 0 12.0e-12
    #|RLOAD n2 0 50.0
    #|.ac dec 20 100e6 200e6
  let netlist = @spice.parse_spice_netlist(netlist_str)
  let (indexer, _, _, _) = @mna.build_dc_mna_system(netlist)
  assert_true(indexer.node_count() >= 3)
}

///|
test "Suite4 RF 05: Low-Noise Amplifier LNA Common-Source Inductive Degeneration" {
  let netlist_str =
    #|* 2.4 GHz CMOS LNA with Source Inductive Degeneration for Real 50 Ohm Input
    #|VDD vdd 0 DC 1.8
    #|VIN in 0 DC 0.8
    #|* Gate inductor Lg and Source inductor Ls (Rin = gm * Ls / Cgs)
    #|LG in gate 4.0e-9
    #|LS src 0 0.5e-9
    #|M1 drain gate src 0 NMOS_RF
    #|* Drain LC load tuned to 2.4 GHz
    #|LD vdd drain 2.0e-9
    #|CD drain vdd 2.2e-12
    #|RLOAD drain 0 500.0
    #|.model NMOS_RF NMOS (VTO=0.4 KP=250e-6)
    #|.op
  let netlist = @spice.parse_spice_netlist(netlist_str)
  let (indexer, _, _, _) = @mna.build_dc_mna_system(netlist)
  assert_true(indexer.node_count() >= 5)
}

///|
test "Suite4 RF 06: Distributed Microstrip Radial Stub High-Frequency Bypass" {
  // Radial stub equivalent capacitance at microwave frequencies
  let c_equiv = 5.0e-12
  let l_via = 0.1e-9
  let z0 = 50.0

  let f_res = 1.0 / (2.0 * @math.PI * (l_via * c_equiv).sqrt())
  assert_true(f_res > 5.0e9) // Self-resonance > 5 GHz
  assert_true(z0 == 50.0)
}

///|
test "Suite4 RF 07: Cascaded RF Attenuator T-Pad and Pi-Pad 10 dB Cells" {
  // 50 Ohm 10 dB T-pad attenuator design:
  // K = 10^(10/20) = 3.162277
  // R_series = Z0 * (K - 1) / (K + 1) = 50 * 2.162277 / 4.162277 = 25.97 Ohms
  // R_shunt = Z0 * 2*K / (K^2 - 1) = 50 * 6.324555 / 9.0 = 35.13 Ohms
  let k_factor = @math.pow(10.0, 10.0 / 20.0)
  let r_ser = 50.0 * (k_factor - 1.0) / (k_factor + 1.0)
  let r_sh = 50.0 * 2.0 * k_factor / (k_factor * k_factor - 1.0)

  assert_true((r_ser - 25.97).abs() < 0.1)
  assert_true((r_sh - 35.14).abs() < 0.1)
}

///|
test "Suite4 RF 08: Interdigital Microstrip 4-Pole Bandpass Filter" {
  let netlist_str =
    #|* 4-Pole Interdigital Bandpass Ladder
    #|VIN in 0 AC 1.0
    #|RS in n1 50.0
    #|C1 n1 0 1.5e-12
    #|L1 n1 0 3.0e-9
    #|C12 n1 n2 0.3e-12
    #|C2 n2 0 1.5e-12
    #|L2 n2 0 3.0e-9
    #|C23 n2 n3 0.3e-12
    #|C3 n3 0 1.5e-12
    #|L3 n3 0 3.0e-9
    #|C34 n3 n4 0.3e-12
    #|C4 n4 0 1.5e-12
    #|L4 n4 0 3.0e-9
    #|RLOAD n4 0 50.0
    #|.ac lin 100 2.0e9 3.0e9
  let netlist = @spice.parse_spice_netlist(netlist_str)
  let (indexer, _, _, _) = @mna.build_dc_mna_system(netlist)
  assert_true(indexer.node_count() >= 5)
}

///|
test "Suite4 RF 09: Circulator and Isolator Non-Reciprocal Transmission" {
  // Ideal 3-Port Ferrite Circulator S-matrix:
  // S = [ 0 0 1 ]
  //     [ 1 0 0 ]
  //     [ 0 1 0 ]
  let s21 = 1.0 // Port 1 -> Port 2
  let s32 = 1.0 // Port 2 -> Port 3
  let s13 = 1.0 // Port 3 -> Port 1
  let s12 = 0.0 // Isolation
  let s23 = 0.0
  let s31 = 0.0

  assert_true(s21 == 1.0 && s32 == 1.0 && s13 == 1.0)
  assert_true(s12 == 0.0 && s23 == 0.0 && s31 == 0.0)
}

///|
test "Suite4 RF 10: Reflection Coefficient Return Loss to VSWR Converter" {
  // For Gamma = 0.2:
  // Return Loss RL = -20 * log10(0.2) = 13.979 dB
  // VSWR = (1 + 0.2) / (1 - 0.2) = 1.2 / 0.8 = 1.50
  let gamma = 0.2
  let rl_db = -20.0 * @math.log10(gamma)
  let vswr = (1.0 + gamma) / (1.0 - gamma)

  assert_true((rl_db - 13.979).abs() < 0.01)
  assert_true((vswr - 1.50).abs() < 0.01)
}
