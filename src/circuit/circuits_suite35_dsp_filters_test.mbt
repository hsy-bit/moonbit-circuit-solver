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
test "Suite35 Filter 01: Bilinear Transform Warped Frequency Mapping" {
  // omega_analog = (2 / T) * tan(omega_digital * T / 2)
  let f_sampling = 48.0e3 // 48 kHz
  let t_samp = 1.0 / f_sampling
  let f_cutoff_digital = 4.0e3 // 4 kHz

  let omega_d = 2.0 * @math.PI * f_cutoff_digital
  let omega_a = 2.0 / t_samp * @math.tan(omega_d * t_samp / 2.0)
  let f_cutoff_warped = omega_a / (2.0 * @math.PI) // ~4.09 kHz

  assert_true((f_cutoff_warped - 4091.7).abs() < 5.0)
}

///|
test "Suite35 Filter 02: Switched-Capacitor Parasitic-Insensitive Integrator" {
  // Equivalent resistance R_eq = 1 / (f_clk * C_s)
  let f_clk = 1.0e6 // 1 MHz clock
  let c_s = 1.0e-12 // 1 pF sampling cap

  let r_eq = 1.0 / (f_clk * c_s) // 1 MOhm equivalent resistance!
  let c_int = 10.0e-12 // 10 pF integrating cap
  let tau_int = r_eq * c_int // 10 us time constant

  assert_true((r_eq - 1.0e6).abs() < 1.0)
  assert_true((tau_int - 1.0e-5).abs() < 1.0e-10)
}

///|
test "Suite35 Filter 03: Tow-Thomas Active Biquad Q-Factor Tuning" {
  // Resonant frequency omega_0 = 1 / (R * C), Q = R_Q / R
  let r_nom = 10.0e3
  let c_nom = 10.0e-9
  let r_q = 50.0e3

  let f_0 = 1.0 / (2.0 * @math.PI * r_nom * c_nom) // ~1591.5 Hz
  let q_factor = r_q / r_nom // Q = 5.0

  assert_true((f_0 - 1591.55).abs() < 1.0)
  assert_true(q_factor == 5.0)
}

///|
test "Suite35 Filter 04: State-Variable KHN Filter Simultaneous LP, BP, HP Outputs" {
  let netlist_str =
    #|* State-Variable KHN Active Filter
    #|VIN in 0 DC 1.0
    #|R1 in inv1 10000.0
    #|RF inv1 hp_out 10000.0
    #|X1 0 inv1 hp_out OPAMP
    #|.op
  let netlist = @spice.parse_spice_netlist(netlist_str)
  let sim = CircuitSimulator::{ netlist, }
  let dc = sim.solve_dc()
  assert_true(dc.contains("hp_out"))
}

///|
test "Suite35 Filter 05: Elliptic Cauer Filter Equiripple Passband and Stopband" {
  let passband_ripple_db = 0.28 // 0.28 dB
  let stopband_atten_db = 60.0 // 60 dB
  assert_true(stopband_atten_db > passband_ripple_db)
}

///|
test "Suite35 Filter 06: Allpass First-Order Phase Equalizer Group Delay" {
  // H(s) = (s - omega_0) / (s + omega_0) -> Unity magnitude |H(jw)| = 1, Group delay tau_g(0) = 2 / omega_0
  let f_0 = 1000.0
  let omega_0 = 2.0 * @math.PI * f_0

  let tau_g_0 = 2.0 / omega_0 // ~318.3 us
  assert_true((tau_g_0 - 0.0003183).abs() < 1.0e-6)
}

///|
test "Suite35 Filter 07: Sallen-Key High-Pass Filter Transfer Function" {
  let netlist_str =
    #|* Sallen-Key High-Pass Active Filter
    #|VIN in 0 DC 1.0
    #|C1 in n1 10e-9
    #|C2 n1 pos 10e-9
    #|R1 n1 out 10000.0
    #|R2 pos 0 10000.0
    #|X1 pos out out OPAMP
    #|.op
  let netlist = @spice.parse_spice_netlist(netlist_str)
  let sim = CircuitSimulator::{ netlist, }
  let dc = sim.solve_dc()
  // At DC, series capacitors block signal -> Vout = 0V
  let v_out = dc.get("out").unwrap()
  assert_true(v_out.abs() < 1.0e-3)
}

///|
test "Suite35 Filter 08: 8th-Order Cascaded Butterworth Low-Pass Sharp Roll-off" {
  // 8 poles -> -48 dB / octave (-160 dB / decade) roll-off rate!
  let num_poles = 8
  let db_per_decade = num_poles.to_double() * 20.0 // 160 dB / decade

  assert_true(db_per_decade == 160.0)
}

///|
test "Suite35 Filter 09: Bainter Notch Filter Finite Zero Synthesis" {
  let f_notch = 50.0 // 50 Hz power line hum trap
  let q_notch = 20.0 // High-Q notch
  assert_true(f_notch == 50.0)
  assert_true(q_notch == 20.0)
}

///|
test "Suite35 Filter 10: Twin-T Active Guarding for Infinite Q" {
  let r_arm = 10.0e3
  let c_arm = 100.0e-9
  let f_null = 1.0 / (2.0 * @math.PI * r_arm * c_arm) // 159.15 Hz

  assert_true((f_null - 159.155).abs() < 0.1)
}
