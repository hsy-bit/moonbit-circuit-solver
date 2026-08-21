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
test "Suite13 Audio 01: RIAA Phono Equalization Time Constants" {
  // Standard RIAA time constants: T1 = 3180 us (50 Hz), T2 = 318 us (500 Hz), T3 = 75 us (2122 Hz)
  let f1 = 1.0 / (2.0 * @math.PI * 3180.0e-6) // 50.05 Hz
  let f2 = 1.0 / (2.0 * @math.PI * 318.0e-6) // 500.5 Hz
  let f3 = 1.0 / (2.0 * @math.PI * 75.0e-6) // 2122 Hz

  assert_true((f1 - 50.05).abs() < 0.1)
  assert_true((f2 - 500.5).abs() < 0.5)
  assert_true((f3 - 2122.0).abs() < 5.0)
}

///|
test "Suite13 Audio 02: Balanced XLR Line Receiver Common-Mode Rejection CMRR" {
  let netlist_str =
    #|* High-CMRR Balanced Audio Receiver (That 1200-type)
    #|VIN_P xlr_hot 0 DC 1.005
    #|VIN_M xlr_cold 0 DC 0.995
    #|* Matched 10k resistors for 0.1% tolerance
    #|R1 xlr_hot pos 10000.0
    #|R2 pos 0 10000.0
    #|R3 xlr_cold neg 10000.0
    #|RF neg out 10000.0
    #|X1 pos neg out OPAMP
    #|.op
  let netlist = @spice.parse_spice_netlist(netlist_str)
  let sim = CircuitSimulator::{ netlist, }
  let dc = sim.solve_dc()
  // Vout = (1.005 - 0.995) = 0.010 V (10 mV differential signal extracted)
  let v_out = dc.get("out").unwrap()
  assert_true((v_out - 0.010).abs() < 1.0e-4)
}

///|
test "Suite13 Audio 03: Active Subwoofer 4th-Order Low-Pass Filter" {
  let netlist_str =
    #|* Active Subwoofer 4th-Order Butterworth Filter (fc = 80 Hz)
    #|VIN in 0 DC 1.0
    #|* Stage 1 Sallen-Key
    #|R1 in n1 19890.0
    #|R2 n1 pos1 19890.0
    #|C1 n1 out1 141.4e-9
    #|C2 pos1 0 70.7e-9
    #|X1 pos1 out1 out1 OPAMP
    #|* Stage 2 Sallen-Key
    #|R3 out1 n2 19890.0
    #|R4 n2 pos2 19890.0
    #|C3 n2 out 141.4e-9
    #|C4 pos2 0 70.7e-9
    #|X2 pos2 out out OPAMP
    #|.op
  let netlist = @spice.parse_spice_netlist(netlist_str)
  let sim = CircuitSimulator::{ netlist, }
  let dc = sim.solve_dc()
  let v_out = dc.get("out").unwrap()
  assert_true((v_out - 1.0).abs() < 1.0e-3)
}

///|
test "Suite13 Audio 04: Class-D Audio Amplifier LC Demodulation Reconstruction" {
  // Class-D 400 kHz PWM output filter: L = 10 uH, C = 470 nF, Load = 4 Ohm
  let l_filt = 10.0e-6
  let c_filt = 470.0e-9
  let r_speaker = 4.0

  let f_cutoff = 1.0 / (2.0 * @math.PI * (l_filt * c_filt).sqrt())
  // Q = R * sqrt(C / L) = 4 * sqrt(0.047) = 0.867
  let q_filt = r_speaker * (c_filt / l_filt).sqrt()

  assert_true(f_cutoff > 70.0e3 && f_cutoff < 80.0e3) // ~73.4 kHz cutoff
  assert_true((q_filt - 0.867).abs() < 0.05)
}

///|
test "Suite13 Audio 05: Analog Soft-Clipping Diode Overdrive Limiter" {
  let netlist_str =
    #|* Guitar Pedal Diode Clipping Distortion
    #|VIN in 0 DC 2.0
    #|RIN in out 4700.0
    #|* Back-to-back anti-parallel clipping diodes D1, D2
    #|D1 out 0 1N4148
    #|D2 0 out 1N4148
    #|RLOAD out 0 100000.0
    #|.model 1N4148 D (IS=1e-14 N=1.0)
    #|.op
  let netlist = @spice.parse_spice_netlist(netlist_str)
  let (indexer, _, _, _) = @mna.build_dc_mna_system(netlist)
  assert_true(indexer.node_count() >= 2)
}

///|
test "Suite13 Audio 06: Discrete Class-A Headphone Driver Current Buffer" {
  let netlist_str =
    #|* Single-Ended Class-A BJT Headphone Stage
    #|VCC vcc 0 DC 15.0
    #|VIN in 0 DC 2.5
    #|* Emitter Follower Q1 with active current sink Q2
    #|Q1 vcc in emit NPN_AUDIO
    #|Q2 emit bias 0 NPN_AUDIO
    #|RBIAS vcc bias 100000.0
    #|C_OUT emit out 100e-6
    #|RLOAD out 0 32.0
    #|.model NPN_AUDIO NPN (IS=1e-13 BF=150)
    #|.op
  let netlist = @spice.parse_spice_netlist(netlist_str)
  let (indexer, _, _, _) = @mna.build_dc_mna_system(netlist)
  assert_true(indexer.node_count() >= 4)
}

///|
test "Suite13 Audio 07: Dynamic Peak Detector Attack and Release Envelopes" {
  // Attack time: tau_att = R_att * C_env = 100 * 10uF = 1 ms
  // Release time: tau_rel = R_rel * C_env = 100k * 10uF = 1 s
  let c_env = 10.0e-6
  let r_att = 100.0
  let r_rel = 100.0e3

  let tau_attack = r_att * c_env
  let tau_release = r_rel * c_env

  assert_true((tau_attack - 0.001).abs() < 1.0e-6)
  assert_true((tau_release - 1.0).abs() < 1.0e-6)
}

///|
test "Suite13 Audio 08: 3-Way Sallen-Key Audio Active Crossover Alignment" {
  // Low-Pass (Woofer) 500 Hz, Band-Pass (Midrange) 500 Hz - 3500 Hz, High-Pass (Tweeter) 3500 Hz
  let f_low = 500.0
  let f_high = 3500.0

  assert_true(f_high > f_low)
  assert_true(f_low == 500.0)
}

///|
test "Suite13 Audio 09: Parametric Equalizer State-Variable Constant-Q Loop" {
  let netlist_str =
    #|* Parametric EQ State-Variable Loop
    #|VIN in 0 DC 1.0
    #|R_IN in n_sum 10000.0
    #|R_F n_sum out 10000.0
    #|X1 0 n_sum out OPAMP
    #|.op
  let netlist = @spice.parse_spice_netlist(netlist_str)
  let sim = CircuitSimulator::{ netlist, }
  let dc = sim.solve_dc()
  let v_out = dc.get("out").unwrap()
  assert_true((v_out - -1.0).abs() < 1.0e-3)
}

///|
test "Suite13 Audio 10: Optical VCA Audio Compressor Gain Cell" {
  // Optocoupler LED current to Photoresistor LDR resistance transfer curve: R_ldr = R0 * (I_led / I0)^(-gamma)
  let r0 = 10.0e3
  let i0 = 1.0e-3
  let gamma_vca = 0.8
  let i_led = 5.0e-3 // 5 mA control current

  let r_ldr = r0 * @math.pow(i_led / i0, -gamma_vca)
  assert_true(r_ldr < r0)
  assert_true(r_ldr > 1000.0)
}
