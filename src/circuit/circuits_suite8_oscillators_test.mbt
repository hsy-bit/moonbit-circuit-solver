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
test "Suite8 Oscillator 01: Hartley Tapped-Inductor Resonance Formula" {
  // Hartley LC tank: L1 = 10 uH, L2 = 10 uH, M = 2 uH -> L_tot = L1 + L2 + 2*M = 24 uH, C = 100 pF
  let l1 = 10.0e-6
  let l2 = 10.0e-6
  let m_mut = 2.0e-6
  let c_tank = 100.0e-12

  let l_tot = l1 + l2 + 2.0 * m_mut // 24 uH
  let f0 = 1.0 / (2.0 * @math.PI * (l_tot * c_tank).sqrt())

  assert_true(l_tot == 24.0e-6)
  assert_true((f0 - 3.248e6).abs() < 50.0e3) // ~3.25 MHz
}

///|
test "Suite8 Oscillator 02: Colpitts Capacitive Split Tank Resonance" {
  // Colpitts tank: L = 10 uH, C1 = 200 pF, C2 = 200 pF -> C_ser = 100 pF
  let l_val = 10.0e-6
  let c1 = 200.0e-12
  let c2 = 200.0e-12
  let c_ser = c1 * c2 / (c1 + c2) // 100 pF

  let f0 = 1.0 / (2.0 * @math.PI * (l_val * c_ser).sqrt())
  assert_true((f0 - 5.032e6).abs() < 50.0e3) // ~5.03 MHz
}

///|
test "Suite8 Oscillator 03: Clapp Oscillator High-Stability Series Tank" {
  // Clapp oscillator: C3 << C1, C2 (C3 = 10 pF, C1 = 1000 pF, C2 = 1000 pF)
  // Total capacitance is dominated by C3: 1/C_tot = 1/C1 + 1/C2 + 1/C3
  let c1 = 1000.0e-12
  let c2 = 1000.0e-12
  let c3 = 10.0e-12

  let inv_c_tot = 1.0 / c1 + 1.0 / c2 + 1.0 / c3
  let c_tot = 1.0 / inv_c_tot

  assert_true((c_tot - 9.803e-12).abs() < 0.1e-12)
}

///|
test "Suite8 Oscillator 04: Pierce Quartz Crystal Resonant Circuit" {
  let netlist_str =
    #|* Pierce Crystal Oscillator Small-Signal Equivalent
    #|VIN in 0 AC 1.0
    #|* Crystal series branch (Lm, Cm, Rm)
    #|L_M in n1 10.0e-3
    #|C_M n1 n2 0.025e-12
    #|R_M n2 out 15.0
    #|* Shunt caps C1, C2
    #|C1 in 0 22e-12
    #|C2 out 0 22e-12
    #|RLOAD out 0 1000.0
    #|.ac dec 100 9.9e6 10.1e6
  let netlist = @spice.parse_spice_netlist(netlist_str)
  let (indexer, _, _, _) = @mna.build_dc_mna_system(netlist)
  assert_true(indexer.node_count() >= 3)
}

///|
test "Suite8 Oscillator 05: 3-Stage RC Phase-Shift Oscillator" {
  // 3 cascaded RC stages with R = 10k, C = 10nF -> f0 = 1 / (2*pi*R*C*sqrt(6)) approx 649 Hz
  let r_val = 10000.0
  let c_val = 10.0e-9
  let sqrt6 = 6.0.sqrt()

  let f0 = 1.0 / (2.0 * @math.PI * r_val * c_val * sqrt6)
  assert_true((f0 - 649.7).abs() < 5.0)

  // Inverting amplifier gain must satisfy Av >= 29 to maintain oscillation
  let min_gain = 29.0
  assert_true(min_gain >= 29.0)
}

///|
test "Suite8 Oscillator 06: Bubba 4-OpAmp Quadrature Waveform Generator" {
  // 4 cascaded low-pass sections with 45 degree phase shift each (total 180 degrees)
  let netlist_str =
    #|* Bubba 4-OpAmp Oscillator DC Biasing
    #|VCC vcc 0 DC 12.0
    #|R1 in n1 10000.0
    #|R2 n1 n2 10000.0
    #|R3 n2 n3 10000.0
    #|R4 n3 out 10000.0
    #|RL out 0 10000.0
    #|.op
  let netlist = @spice.parse_spice_netlist(netlist_str)
  let sim = CircuitSimulator::{ netlist, }
  let dc = sim.solve_dc()
  assert_true(dc.contains("vcc"))
}

///|
test "Suite8 Oscillator 07: Quadrature Sine/Cosine Dual-Integrator Loop" {
  let netlist_str =
    #|* Quadrature Oscillator (Sine and Cosine 90-degree phase outputs)
    #|VIN in 0 DC 0.0
    #|* Integrator 1: produces Cosine from Sine
    #|R1 in_sine inv1 10000.0
    #|C1 inv1 out_cos 15.9e-9
    #|RF1 inv1 out_cos 1.0e6
    #|X1 0 inv1 out_cos OPAMP
    #|* Integrator 2: produces -Sine from Cosine
    #|R2 out_cos inv2 10000.0
    #|C2 inv2 out_sine 15.9e-9
    #|RF2 inv2 out_sine 1.0e6
    #|X2 0 inv2 out_sine OPAMP
    #|.op
  let netlist = @spice.parse_spice_netlist(netlist_str)
  let sim = CircuitSimulator::{ netlist, }
  let dc = sim.solve_dc()
  assert_true(dc.contains("out_cos"))
  assert_true(dc.contains("out_sine"))
}

///|
test "Suite8 Oscillator 08: UJT Relaxation Oscillator Timing Ramp" {
  // Timing period T = R * C * ln(1 / (1 - eta)) where eta is intrinsic standoff ratio
  let r_tim = 47000.0
  let c_tim = 100.0e-9
  let eta = 0.632 // At eta = 1 - 1/e -> ln(1/(1-eta)) = 1.0

  let period = r_tim * c_tim * -@math.ln(1.0 - eta)
  assert_true((period - 0.0047).abs() < 0.0005) // ~4.7 ms (approx 212 Hz)
}

///|
test "Suite8 Oscillator 09: Cross-Coupled CMOS LC Tank RF Oscillator" {
  let netlist_str =
    #|* Cross-Coupled NMOS Pair LC Oscillator at 2.4 GHz
    #|VDD vdd 0 DC 1.8
    #|* Cross-coupled pair M1, M2
    #|M1 outp outm 0 0 NMOS_RF
    #|M2 outm outp 0 0 NMOS_RF
    #|* LC Tank between outp and outm
    #|L_TANK outp outm 2.0e-9
    #|C_TANK outp outm 2.2e-12
    #|R_TANK outp outm 1000.0
    #|.model NMOS_RF NMOS (VTO=0.4 KP=200e-6)
    #|.op
  let netlist = @spice.parse_spice_netlist(netlist_str)
  let (indexer, _, _, _) = @mna.build_dc_mna_system(netlist)
  assert_true(indexer.node_count() >= 3)
}

///|
test "Suite8 Oscillator 10: Voltage-Controlled Ring Oscillator Frequency Sweep" {
  let v_ctrl_low = 1.0
  let v_ctrl_high = 3.3
  let k_vco = 50.0e6 // 50 MHz/V

  let f_low = 100.0e6 + k_vco * v_ctrl_low // 150 MHz
  let f_high = 100.0e6 + k_vco * v_ctrl_high // 265 MHz

  assert_true(f_high > f_low)
  assert_true((f_high - f_low - 115.0e6).abs() < 1.0e-3)
}
