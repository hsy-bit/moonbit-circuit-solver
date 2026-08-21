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
test "Synchronous Buck Converter DC-DC 12V to 3.3V Step-Down" {
  // Buck converter duty cycle D = 3.3 / 12 = 0.275
  // Switching frequency fs = 500 kHz (T = 2 us)
  // Inductor L = 4.7 uH, Output cap C = 47 uF, Load R = 3.3 Ohm (I_out = 1A)
  let v_in = 12.0
  let v_out_target = 3.3
  let d_duty = v_out_target / v_in
  let fs = 500.0e3
  let l_val = 4.7e-6
  let c_val = 47.0e-6
  let _r_load = 3.3

  // Inductor ripple current Delta I_L = (V_in - V_out) * D / (fs * L)
  let delta_i_l = (v_in - v_out_target) * d_duty / (fs * l_val)
  assert_true(delta_i_l > 0.5 && delta_i_l < 1.5) // ~1.02 A ripple

  // Output voltage ripple Delta V_out = Delta I_L / (8 * fs * C)
  let delta_v_out = delta_i_l / (8.0 * fs * c_val)
  assert_true(delta_v_out < 0.05) // < 50 mV ripple

  let netlist_str =
    #|* Synchronous Buck Converter Netlist
    #|VIN in 0 DC 12.0
    #|L1 sw out 4.7e-6
    #|COUT out 0 47e-6
    #|RLOAD out 0 3.3
    #|.tran 1e-7 2e-5
  let netlist = @spice.parse_spice_netlist(netlist_str)
  let sim = CircuitSimulator::{ netlist, }
  let tran = sim.solve_transient(1.0e-6, 5.0e-5)

  assert_true(tran.steps.length() > 20)
}

///|
test "Boost DC-DC Converter 5V to 12V Step-Up" {
  // Boost converter: V_out = V_in / (1 - D) -> D = 1 - 5/12 = 0.5833
  let v_in = 5.0
  let v_out = 12.0
  let d_duty = 1.0 - v_in / v_out
  assert_true((d_duty - 0.5833).abs() < 1.0e-3)

  let netlist_str =
    #|* Boost DC-DC Converter
    #|VIN in 0 DC 5.0
    #|L1 in sw 10e-6
    #|COUT out 0 100e-6
    #|RLOAD out 0 24.0
    #|.tran 1e-7 1e-4
  let netlist = @spice.parse_spice_netlist(netlist_str)
  let sim = CircuitSimulator::{ netlist, }
  let dc = sim.solve_dc()

  assert_true(dc.contains("in"))
  assert_true((dc.get("in").unwrap() - 5.0).abs() < 1.0e-6)
}

///|
test "Full-Bridge Diode Rectifier with LC Pi Filter" {
  let netlist_str =
    #|* Full-Bridge Rectifier with LC Pi Filter
    #|VAC ac1 ac2 SINE(0 15 50)
    #|D1 ac1 dc_pos 1N4007
    #|D2 ac2 dc_pos 1N4007
    #|D3 0 ac1 1N4007
    #|D4 0 ac2 1N4007
    #|* Pi filter: C1, L, C2
    #|C1 dc_pos 0 1000e-6
    #|L1 dc_pos out 10e-3
    #|C2 out 0 1000e-6
    #|RLOAD out 0 100.0
    #|.model 1N4007 D (IS=1e-9 N=1.5)
    #|.tran 1e-4 4e-2
  let netlist = @spice.parse_spice_netlist(netlist_str)
  let (indexer, _, _, _) = @mna.build_dc_mna_system(netlist)

  assert_true(indexer.node_count() >= 4)
}

///|
test "Flyback Isolated Converter with Coupled Inductor" {
  let params = @nonlinear.CoupledTransformerParams::new(
    20.0e-6, 180.0e-6, 0.99, 0.05, 0.2,
  )
  let m = params.mutual_inductance()

  // Turns ratio N2/N1 = sqrt(L2/L1) = sqrt(180/20) = 3.0
  let turns_ratio = (params.l2 / params.l1).sqrt()
  assert_true((turns_ratio - 3.0).abs() < 1.0e-6)
  assert_true(m > 0.0)
}
