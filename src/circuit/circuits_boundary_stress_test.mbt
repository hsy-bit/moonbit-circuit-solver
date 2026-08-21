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
test "Boundary Test: Extreme Impedance Disparity (1 TeraOhm vs 1 MicroOhm)" {
  let netlist_str =
    #|* Extreme Impedance Ratio Divider
    #|VIN in 0 DC 100.0
    #|R_HIGH in out 1.0e12
    #|R_LOW out 0 1.0e-6
    #|.op
  let netlist = @spice.parse_spice_netlist(netlist_str)
  let sim = CircuitSimulator::{ netlist, }
  let dc = sim.solve_dc()

  assert_true(dc.contains("in"))
  assert_true(dc.contains("out"))
  let v_out = dc.get("out").unwrap()
  assert_true(v_out < 1.0e-8) // V_out is effectively 0
}

///|
test "Boundary Test: Stacking 50 Series Voltage Sources" {
  let mut s = "* 50 Series Voltage Sources\n"
  for k = 0; k < 50; k = k + 1 {
    let prev = if k == 0 { "0" } else { "n" + k.to_string() }
    let next = "n" + (k + 1).to_string()
    s = s + "V_" + k.to_string() + " " + next + " " + prev + " DC 1.5\n"
  }
  s = s + "RLOAD n50 0 1000.0\n.op\n"

  let netlist = @spice.parse_spice_netlist(s)
  let sim = CircuitSimulator::{ netlist, }
  let dc = sim.solve_dc()

  let v_top = dc.get("n50").unwrap()
  assert_true((v_top - 75.0).abs() < 1.0e-6) // 50 * 1.5V = 75.0V
}

///|
test "Boundary Test: Summing 50 Parallel Current Sources" {
  let mut s = "* 50 Parallel Current Sources\n"
  for k = 0; k < 50; k = k + 1 {
    s = s + "I_" + k.to_string() + " 0 out DC 0.02\n"
  }
  s = s + "RLOAD out 0 100.0\n.op\n"

  let netlist = @spice.parse_spice_netlist(s)
  let sim = CircuitSimulator::{ netlist, }
  let dc = sim.solve_dc()

  // Total current = 50 * 0.02A = 1.0A -> V_out = 1.0A * 100 Ohms = 100.0V
  let v_out = dc.get("out").unwrap()
  assert_true((v_out - 100.0).abs() < 1.0e-6)
}

///|
test "Boundary Test: Extremely Stiff RC Time Constants (1 ps vs 1 s)" {
  let netlist_str =
    #|* Dual Stiff RC Time Constants
    #|VIN in 0 DC 5.0
    #|* Fast channel (tau = 1 ps)
    #|R_FAST in n_fast 1000.0
    #|C_FAST n_fast 0 1.0e-15
    #|* Slow channel (tau = 1 s)
    #|R_SLOW in n_slow 1.0e6
    #|C_SLOW n_slow 0 1.0e-6
    #|.op
  let netlist = @spice.parse_spice_netlist(netlist_str)
  let sim = CircuitSimulator::{ netlist, }
  let dc = sim.solve_dc()

  assert_true((dc.get("n_fast").unwrap() - 5.0).abs() < 1.0e-6)
  assert_true((dc.get("n_slow").unwrap() - 5.0).abs() < 1.0e-6)
}

///|
test "Boundary Test: High-Decade AC Frequency Sweep (1 mHz to 1 THz)" {
  let netlist_str =
    #|* Ultra-Wideband AC Sweep
    #|VIN in 0 AC 1.0
    #|R1 in out 1000.0
    #|C1 out 0 1.0e-9
    #|.ac dec 10 1e-3 1e12
  let netlist = @spice.parse_spice_netlist(netlist_str)
  let ac_res = @mna.solve_ac_sweep(netlist, 1.0e-3, 1.0e6, 50)

  assert_true(ac_res.sweep_points.length() == 50)
  assert_true((ac_res.sweep_points[0].freq - 1.0e-3).abs() < 1.0e-6)
}
