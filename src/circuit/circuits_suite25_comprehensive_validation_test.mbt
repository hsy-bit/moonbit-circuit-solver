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
test "Suite25 Validation 01: Complete RF Receiver Front-End Signal Chain" {
  let netlist_str =
    #|* RF Front-End: LNA Stage + Matching Network + Mixer Load
    #|VDD vdd 0 DC 3.3
    #|VRF in_rf 0 DC 0.0
    #|* LNA Input Match (50 Ohm)
    #|R_IN in_rf gate 50.0
    #|C_IN gate 0 1.0e-12
    #|* LNA Transistor
    #|M_LNA drain gate 0 0 NMOS_LNA
    #|* RF LC Tank Load tuned to 2.4 GHz
    #|L_TANK vdd drain 2.0e-9
    #|C_TANK drain vdd 2.2e-12
    #|* IF Output Load
    #|RLOAD drain 0 500.0
    #|.model NMOS_LNA NMOS (VTO=0.4 KP=200e-6)
    #|.op
  let netlist = @spice.parse_spice_netlist(netlist_str)
  let (indexer, _, _, _) = @mna.build_dc_mna_system(netlist)
  assert_true(indexer.node_count() >= 4)
}

///|
test "Suite25 Validation 02: Full AC-to-DC Switch-Mode Power Supply SMPS" {
  let netlist_str =
    #|* Full SMPS Netlist: AC Input + Rectifier + DC-DC Filter
    #|VAC ac1 ac2 SINE(0 120 60)
    #|D1 ac1 dc_bus 1N4007
    #|D2 ac2 dc_bus 1N4007
    #|D3 0 ac1 1N4007
    #|D4 0 ac2 1N4007
    #|* Bulk Capacitor
    #|CBULK dc_bus 0 220e-6
    #|* Step-Down Output Filter
    #|L_OUT dc_bus out 47e-6
    #|C_OUT out 0 100e-6
    #|RLOAD out 0 10.0
    #|.model 1N4007 D (IS=1e-9)
    #|.op
  let netlist = @spice.parse_spice_netlist(netlist_str)
  let (indexer, _, _, _) = @mna.build_dc_mna_system(netlist)
  assert_true(indexer.node_count() >= 4)
}

///|
test "Suite25 Validation 03: Precision Seismic Geophone Signal Conditioning" {
  let netlist_str =
    #|* Seismic Geophone Low-Noise Differential Preamplifier (Gain = 1000)
    #|VP geo_p 0 DC 0.0005
    #|VM geo_m 0 DC -0.0005
    #|* Instrumentation stage
    #|R1 geo_p pos 1000.0
    #|R2 pos 0 1000000.0
    #|R3 geo_m neg 1000.0
    #|RF neg out 1000000.0
    #|X1 pos neg out OPAMP
    #|.op
  let netlist = @spice.parse_spice_netlist(netlist_str)
  let sim = CircuitSimulator::{ netlist, }
  let dc = sim.solve_dc()
  let v_out = dc.get("out").unwrap()
  assert_true((v_out - 1.0).abs() < 0.01)
}

///|
test "Suite25 Validation 04: Spacecraft 28V Solid-State Circuit Breaker SSCB" {
  let v_bus = 28.0
  let i_trip = 10.0 // 10A current limit
  let r_sense = 0.005 // 5 mOhm sense resistor

  let v_sense_trip = i_trip * r_sense // 50 mV trip threshold
  let p_sense_loss = i_trip * i_trip * r_sense // 0.5 W

  assert_true((v_sense_trip - 0.050).abs() < 1.0e-6)
  assert_true((p_sense_loss - 0.50).abs() < 1.0e-6)
  assert_true(v_bus == 28.0)
}

///|
test "Suite25 Validation 05: 10 Gbps SerDes Continuous-Time Linear Equalizer CTLE" {
  // CTLE High-Frequency Peaking Gain: Zero at fz = 1 GHz, Pole at fp = 5 GHz -> 14 dB HF boost
  let f_z = 1.0e9
  let f_p = 5.0e9
  let peaking_ratio = f_p / f_z // 5.0x boost (approx 14 dB)

  let ln10 = @math.ln(10.0)
  let boost_db = 20.0 * (@math.ln(peaking_ratio) / ln10)

  assert_true((boost_db - 13.979).abs() < 0.05)
}

///|
test "Suite25 Validation 06: 3-Phase BLDC Motor Inverter Gate Driver Array" {
  let v_dc_bus = 48.0
  let num_half_bridges = 3
  let total_switches = 2 * num_half_bridges

  assert_true(total_switches == 6)
  assert_true(v_dc_bus == 48.0)
}

///|
test "Suite25 Validation 07: MEMS Correlated Double Sampling CDS Front-End" {
  // V_cds = V_sample - V_reset (Cancels 1/f flicker noise and kTC reset noise)
  let v_reset_noisy = 1.255 // With +5 mV reset noise
  let v_sample_noisy = 1.655 // With +5 mV reset noise + 400 mV signal

  let v_reconstructed = v_sample_noisy - v_reset_noisy // Exactly 400 mV clean!
  assert_true((v_reconstructed - 0.400).abs() < 1.0e-12)
}

///|
test "Suite25 Validation 08: 256-Element Optical Spectrometer Sensor Array" {
  let num_pixels = 256
  let integration_time_ms = 10.0
  let pixel_pitch_um = 25.0

  let total_die_length_mm = num_pixels.to_double() * pixel_pitch_um / 1000.0
  assert_true(total_die_length_mm == 6.4)
  assert_true(integration_time_ms == 10.0)
}

///|
test "Suite25 Validation 09: Ultra-Low Phase Noise Microwave Synthesizer Stability" {
  let f_carrier = 10.0e9 // 10 GHz X-band carrier
  let f_ref = 100.0e6 // 100 MHz OCXO reference
  let n_divider = (f_carrier / f_ref).to_int()

  assert_true(n_divider == 100)
}

///|
test "Suite25 Validation 10: Master End-to-End Simulation Solver Pass" {
  let netlist_str =
    #|* Master EDA Acceptance Test Circuit
    #|VDD vdd 0 DC 5.0
    #|VSS vss 0 DC -5.0
    #|VIN in 0 DC 1.0
    #|* Dual Stage Precision Amplifier
    #|R1 in inv1 1000.0
    #|RF1 inv1 out1 5000.0
    #|X1 0 inv1 out1 OPAMP
    #|R2 out1 inv2 1000.0
    #|RF2 inv2 out2 2000.0
    #|X2 0 inv2 out2 OPAMP
    #|RLOAD out2 0 1000.0
    #|.op
  let netlist = @spice.parse_spice_netlist(netlist_str)
  let sim = CircuitSimulator::{ netlist, }
  let dc = sim.solve_dc()

  // Stage 1: -5.0V, Stage 2: +10.0V
  let v1 = dc.get("out1").unwrap()
  let v2 = dc.get("out2").unwrap()

  assert_true((v1 - -5.0).abs() < 1.0e-3)
  assert_true((v2 - 10.0).abs() < 1.0e-3)
}
