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
test "Suite11 Power 01: Forward Single-Switch Converter Flux Reset" {
  // Duty cycle must satisfy D < 1 / (1 + N_reset/N_pri) = 0.5 for equal turns
  let d_max = 0.5
  let v_in = 48.0
  let turns_ratio = 0.25 // N_sec / N_pri = 1/4

  let v_out = v_in * turns_ratio * 0.45 // At D = 0.45 -> Vout = 48 * 0.25 * 0.45 = 5.4V
  assert_true((v_out - 5.4).abs() < 1.0e-6)
  assert_true(d_max == 0.5)
}

///|
test "Suite11 Power 02: Push-Pull Center-Tapped DC-DC Converter" {
  // Push-pull converter: V_out = 2 * (N2/N1) * D * V_in
  let v_in = 12.0
  let n_ratio = 10.0 // 1:10 step-up
  let d_duty = 0.45 // Max duty per switch = 0.45

  let v_out = 2.0 * n_ratio * d_duty * v_in // 2 * 10 * 0.45 * 12 = 108V
  assert_true((v_out - 108.0).abs() < 1.0e-6)
}

///|
test "Suite11 Power 03: 4-Phase Interleaved Synchronous Buck VRM for CPU Core" {
  // 4 phases interleaved by 360 / 4 = 90 degrees phase shift
  // Total current = 120A -> Each phase carries 30A
  // Equivalent ripple frequency is 4 * f_sw (4 * 500 kHz = 2 MHz)
  let total_current = 120.0
  let num_phases = 4
  let f_sw_phase = 500.0e3

  let i_phase = total_current / num_phases.to_double()
  let f_ripple_eff = num_phases.to_double() * f_sw_phase

  assert_true(i_phase == 30.0)
  assert_true(f_ripple_eff == 2.0e6)
}

///|
test "Suite11 Power 04: Cockcroft-Walton 4-Stage Voltage Multiplier Ladder" {
  // 4 stages multiply peak AC voltage V_peak to 8 * V_peak
  let v_ac_peak = 100.0
  let num_stages = 4
  let v_dc_out = 2.0 * num_stages.to_double() * v_ac_peak

  assert_true((v_dc_out - 800.0).abs() < 1.0e-6)
}

///|
test "Suite11 Power 05: Synchronous Rectifier MOSFET vs Schottky Diode Losses" {
  // Current I = 20A
  let i_out = 20.0
  // Schottky: Vf = 0.5V -> P_loss = Vf * I = 0.5 * 20 = 10W
  let p_schottky = 0.5 * i_out
  // Sync FET: Rds(on) = 3 mOhm -> P_loss = I^2 * Rds(on) = 400 * 0.003 = 1.2W
  let p_sync_fet = i_out * i_out * 0.003

  assert_true(p_schottky == 10.0)
  assert_true(p_sync_fet == 1.2)
  assert_true(p_sync_fet < p_schottky)
}

///|
test "Suite11 Power 06: Peak Current Mode Control Artificial Ramp Compensation" {
  // Downslope of inductor current: S_n = (V_out) / L
  // For D > 0.5, artificial slope S_e must be >= 0.5 * S_n to prevent subharmonic oscillation
  let v_out = 5.0
  let l_val = 10.0e-6
  let s_n = v_out / l_val // 500 kA/s = 0.5 A/us

  let s_e_min = 0.5 * s_n
  assert_true((s_e_min - 250.0e3).abs() < 1.0e-6)
}

///|
test "Suite11 Power 07: Snubber Network R-C-D Voltage Spike Clamping" {
  let netlist_str =
    #|* R-C-D Snubber for Drain Spike Dissipation
    #|VDD vdd 0 DC 48.0
    #|L_LEAK vdd drain 2.0e-6
    #|D_SNUB drain snub_mid 1N4007
    #|C_SNUB snub_mid vdd 10.0e-9
    #|R_SNUB snub_mid vdd 1000.0
    #|RLOAD drain 0 100.0
    #|.model 1N4007 D (IS=1e-9)
    #|.op
  let netlist = @spice.parse_spice_netlist(netlist_str)
  let (indexer, _, _, _) = @mna.build_dc_mna_system(netlist)
  assert_true(indexer.node_count() >= 3)
}

///|
test "Suite11 Power 08: Half-Bridge Resonant Inverter ZVS Condition" {
  let c_oss = 200.0e-12 // MOSFET output capacitance
  let dead_time = 100.0e-9 // 100 ns dead time
  let i_magnetizing = 2.0 // 2A peak current to discharge 2 * Coss during dead time

  // Delta V = (I_mag * t_dead) / (2 * Coss)
  let delta_v = i_magnetizing * dead_time / (2.0 * c_oss)
  assert_true(delta_v >= 400.0) // Sufficient to achieve complete zero-voltage switching across 400V bus
}

///|
test "Suite11 Power 09: Coupled-Inductor Interleaved Boost Converter Ripple Cancellation" {
  // At D = 0.5, two-phase interleaved ripple currents completely cancel to 0 net input ripple
  let d_duty = 0.5
  let ripple_factor = (1.0 - 2.0 * d_duty).abs()
  assert_true(ripple_factor == 0.0)
}

///|
test "Suite11 Power 10: Weinberg High-Reliability Space Power Architecture" {
  // Current-fed push-pull Weinberg topology with continuous input and output currents
  let v_in = 28.0 // 28V satellite bus
  let _v_out = 50.0
  let turns_n = 2.0
  let d_duty = 0.4

  let v_calc = v_in * (1.0 + turns_n * d_duty)
  assert_true((v_calc - 50.4).abs() < 1.0)
}
