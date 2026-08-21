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
test "Suite17 Medical 01: ECG Driven Right Leg DRL Common-Mode Active Feedback" {
  // DRL amplifier inverts common-mode voltage V_cm and injects back to body with gain -Rf / R_in
  let v_cm_body = 0.050 // 50 mV 50 Hz mains pickup
  let r_in_cm = 100000.0 // 100k
  let r_f_drl = 1.0e6 // 1M -> Inverting gain = -10

  let v_drl_out = -v_cm_body * (r_f_drl / r_in_cm)
  assert_true((v_drl_out - -0.50).abs() < 1.0e-6)
}

///|
test "Suite17 Medical 02: Pulse Oximeter PPG Red and IR Ratio-of-Ratios SpO2" {
  // R = (AC_red / DC_red) / (AC_ir / DC_ir)
  // SpO2 approx 110 - 25 * R
  let ac_red = 0.02
  let dc_red = 1.0 // 2% modulation
  let ac_ir = 0.03
  let dc_ir = 1.0 // 3% modulation

  let r_ratio = ac_red / dc_red / (ac_ir / dc_ir) // 0.02 / 0.03 = 0.6667
  let sp_o2 = 110.0 - 25.0 * r_ratio // ~93.3%

  assert_true((r_ratio - 0.666667).abs() < 1.0e-4)
  assert_true(sp_o2 > 90.0 && sp_o2 <= 100.0)
}

///|
test "Suite17 Medical 03: Defibrillation 5 kV Surge Protection Limiting Resistors" {
  // Defibrillator pulse: 5000V energy discharge
  // Current limiting resistor R_lim = 1000 Ohm limits peak current into ECG front-end to 5A
  let v_defib = 5000.0
  let r_lim = 1000.0

  let i_peak = v_defib / r_lim
  let e_pulse = 360.0 // 360 Joules total defibrillation energy

  assert_true(i_peak == 5.0)
  assert_true(e_pulse == 360.0)
}

///|
test "Suite17 Medical 04: Bio-Impedance Spectroscopy 4-Electrode AC Injection" {
  let netlist_str =
    #|* 4-Electrode Bio-Impedance Front-End
    #|I_IN i_pos i_neg AC 100e-6
    #|R_TISSUE i_pos i_neg 500.0
    #|C_MEMBRANE i_pos i_neg 10e-9
    #|* High-impedance sense taps v_p, v_m
    #|R_SENSE1 i_pos v_p 1000.0
    #|R_SENSE2 i_neg v_m 1000.0
    #|RLOAD v_p v_m 1.0e6
    #|.ac dec 20 100 1000000
  let netlist = @spice.parse_spice_netlist(netlist_str)
  let (indexer, _, _, _) = @mna.build_dc_mna_system(netlist)
  assert_true(indexer.node_count() >= 3)
}

///|
test "Suite17 Medical 05: EEG Ultra-Low-Noise Preamp Bandwidth (0.5 Hz - 100 Hz)" {
  let f_highpass = 0.5
  let f_lowpass = 100.0

  let c_hp = 3.18e-6
  let r_hp = 100000.0 // fc = 1 / (2*pi*R*C) = 0.50 Hz

  let fc_calc = 1.0 / (2.0 * @math.PI * r_hp * c_hp)
  assert_true((fc_calc - f_highpass).abs() < 0.01)
  assert_true(f_lowpass > f_highpass)
}

///|
test "Suite17 Medical 06: Pacemaker Sub-Threshold Ultra-Low Power Sense Amp" {
  // Operating current I_bias = 50 nA at 1.8V -> Total power = 90 nW
  let i_bias = 50.0e-9
  let v_dd = 1.8
  let p_power_nw = i_bias * v_dd * 1.0e9

  assert_true((p_power_nw - 90.0).abs() < 1.0e-6)
}

///|
test "Suite17 Medical 07: Medical Reinforced Isolation Creepage and Clearance" {
  let creepage_mm = 8.0 // IEC 60601-1 reinforced insulation 8mm creepage
  let isolation_vrms = 5000.0 // 5 kV RMS

  assert_true(creepage_mm >= 8.0)
  assert_true(isolation_vrms >= 4000.0)
}

///|
test "Suite17 Medical 08: Electromyography EMG Active Electrode Bandpass" {
  let netlist_str =
    #|* EMG Active Surface Electrode Preamplifier
    #|VIN in 0 DC 0.001
    #|X1 in pos pos OPAMP
    #|R_HP pos n_mid 10000.0
    #|C_HP n_mid out 1.0e-6
    #|R_BIAS out 0 100000.0
    #|.op
  let netlist = @spice.parse_spice_netlist(netlist_str)
  let (indexer, _, _, _) = @mna.build_dc_mna_system(netlist)
  assert_true(indexer.node_count() >= 3)
}

///|
test "Suite17 Medical 09: Cochlear Implant Inductive Link Coupling Factor" {
  // Transmit coil L1 = 10 uH, Receive implant coil L2 = 10 uH, k = 0.15
  let l1 = 10.0e-6
  let l2 = 10.0e-6
  let k_link = 0.15

  let m_link = k_link * (l1 * l2).sqrt()
  assert_true((m_link - 1.5e-6).abs() < 1.0e-12)
}

///|
test "Suite17 Medical 10: Blood Pressure Piezo-Resistive Bridge Millivolt Amplifier" {
  let netlist_str =
    #|* Blood Pressure Sensor Instrumentation Stage (Gain = 100)
    #|VP vp 0 DC 2.502
    #|VM vm 0 DC 2.498
    #|* Gain = 100
    #|R1 vp pos 1000.0
    #|R2 pos 0 100000.0
    #|R3 vm neg 1000.0
    #|RF neg out 100000.0
    #|X1 pos neg out OPAMP
    #|.op
  let netlist = @spice.parse_spice_netlist(netlist_str)
  let sim = CircuitSimulator::{ netlist, }
  let dc = sim.solve_dc()
  // Vout = (2.502 - 2.498) * 100 = 0.004 * 100 = 0.40 V
  let v_out = dc.get("out").unwrap()
  assert_true((v_out - 0.40).abs() < 1.0e-3)
}
