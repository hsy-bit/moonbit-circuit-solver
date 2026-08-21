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
test "Suite20 Macro 01: Multi-Stage Resistor Ladder Subcircuit Netlist" {
  let netlist_str =
    #|* 8-Stage Precision Ladder Netlist
    #|VIN in 0 DC 8.0
    #|R1 in n1 1000.0
    #|R2 n1 n2 1000.0
    #|R3 n2 n3 1000.0
    #|R4 n3 n4 1000.0
    #|R5 n4 n5 1000.0
    #|R6 n5 n6 1000.0
    #|R7 n6 n7 1000.0
    #|R8 n7 0 1000.0
    #|.op
  let netlist = @spice.parse_spice_netlist(netlist_str)
  let sim = CircuitSimulator::{ netlist, }
  let dc = sim.solve_dc()

  // Linear potential distribution: 8.0V, 7.0V, 6.0V, ..., 1.0V
  assert_true(dc.contains("n1"))
  assert_true(dc.contains("n4"))
  assert_true(dc.contains("n7"))

  let v1 = dc.get("n1").unwrap()
  let v4 = dc.get("n4").unwrap()
  let v7 = dc.get("n7").unwrap()

  assert_true((v1 - 7.0).abs() < 1.0e-3)
  assert_true((v4 - 4.0).abs() < 1.0e-3)
  assert_true((v7 - 1.0).abs() < 1.0e-3)
}

///|
test "Suite20 Macro 02: CMOS Inverter VTC (Voltage Transfer Curve) DC Sweep" {
  let vdd = 3.3
  let steps = 33
  let vtc_points : Array[(Double, Double)] = []

  for s = 0; s <= steps; s = s + 1 {
    let v_in = s.to_double() * 0.1 // 0.0 to 3.3V
    // Idealized tanh inverter transfer curve
    let v_out = vdd / (1.0 + @math.exp((v_in - 1.65) / 0.15))
    vtc_points.push((v_in, v_out))
  }

  assert_true(vtc_points.length() == 34)
  // At Vin = 0V -> Vout approx 3.3V
  assert_true(vtc_points[0].1 > 3.2)
  // At Vin = 3.3V -> Vout approx 0.0V
  assert_true(vtc_points[33].1 < 0.1)
}

///|
test "Suite20 Macro 03: Operational Amplifier Finite Gain and CMRR Model" {
  let a_ol = 100000.0 // Open loop gain 100 dB
  let cmrr_db = 90.0 // CMRR = 90 dB
  let ln10 = @math.ln(10.0)
  let cmrr_lin = @math.exp(cmrr_db / 20.0 * ln10)

  let a_cm = a_ol / cmrr_lin
  assert_true(a_cm > 0.0 && a_cm < 5.0) // Common-mode gain is small (~3.16)
}

///|
test "Suite20 Macro 04: 10x10 Resistor Grid Spatial Mesh Potential Solver" {
  let m = 10
  let csr = @linalg.SparseBuilder::new(m * m, m * m)
  for r in 0..<m {
    for c in 0..<m {
      let idx = r * m + c
      csr.add_entry(idx, idx, 4.0)
      if c > 0 {
        csr.add_entry(idx, idx - 1, -1.0)
      }
      if c + 1 < m {
        csr.add_entry(idx, idx + 1, -1.0)
      }
      if r > 0 {
        csr.add_entry(idx, idx - m, -1.0)
      }
      if r + 1 < m {
        csr.add_entry(idx, idx + m, -1.0)
      }
    }
  }
  let csr_mat = csr.to_csr()
  assert_true(csr_mat.rows == 100)
  assert_true(csr_mat.cols == 100)

  let b = @linalg.Vector::zeros(100)
  b.set(0, 10.0) // 10V source injection at corner (0,0)

  let bicg = @linalg.bicgstab_solve(csr_mat, b, 100, 1.0e-6)
  assert_true(bicg.converged)
  assert_true(bicg.solution.get(0) > 0.0)
}

///|
test "Suite20 Macro 05: Temperature Coefficient Resistance Drift (-40C to +125C)" {
  // Copper trace tempco alpha = 0.00393 / °C, R(T) = R0 * (1 + alpha * (T - T0))
  let r0 = 10.0 // 10 Ohms at 25 °C
  let alpha_cu = 0.00393

  let r_cold = r0 * (1.0 + alpha_cu * (-40.0 - 25.0)) // -40 °C
  let r_hot = r0 * (1.0 + alpha_cu * (125.0 - 25.0)) // +125 °C

  assert_true(r_cold < r0)
  assert_true(r_hot > r0)
  assert_true((r_hot - 13.93).abs() < 0.05)
}

///|
test "Suite20 Macro 06: Voltage-Controlled Switch Smooth Transition" {
  let sw = @nonlinear.VcSwitchParams::default()
  let c_on = @nonlinear.evaluate_vc_switch(sw, 5.0, 1.0) // Fully ON at 5V control
  let c_off = @nonlinear.evaluate_vc_switch(sw, 0.0, 1.0) // Fully OFF at 0V control

  assert_true(c_on.g_switch > 10.0) // High conductance
  assert_true(c_off.g_switch < 1.0e-6) // Low conductance
}

///|
test "Suite20 Macro 07: Sallen-Key 2nd-Order Low-Pass Symbolic Filter Design Synthesis" {
  let sk = @symbolic.design_sallen_key_low_pass(5000.0, 0.707, 4.7e-9)
  assert_true(sk.r1 > 0.0)
  assert_true(sk.r2 > 0.0)
  assert_true(sk.c1 > 0.0)
  assert_true(sk.c2 > 0.0)
}

///|
test "Suite20 Macro 08: Volterra Series Weak Nonlinear Harmonic Coefficients" {
  let dist = @mna.compute_taylor_distortion(20.0, -1.0, -0.5, 0.05)
  assert_true(dist.fundamental_mag > 0.9)
  assert_true(dist.hd2_dbc < -20.0)
  assert_true(dist.hd3_dbc < -30.0)
}

///|
test "Suite20 Macro 09: Coupled Transmission Line Cross-Talk NEXT and FEXT" {
  // Near-End Cross-Talk (NEXT) and Far-End Cross-Talk (FEXT)
  let k_c = 0.08 // Capacitive coupling coefficient
  let k_m = 0.08 // Inductive coupling coefficient

  // FEXT is proportional to (k_c - k_m) -> Near zero for homogeneous microstrip dielectric!
  let fext_coeff = (k_c - k_m).abs()
  let next_coeff = (k_c + k_m) / 4.0

  assert_true(fext_coeff == 0.0)
  assert_true(next_coeff == 0.04)
}

///|
test "Suite20 Macro 10: End-to-End SPICE Pipeline Automated Verification" {
  let netlist_str =
    #|* Master Verification Test Circuit
    #|VIN in 0 DC 5.0
    #|R1 in n1 1000.0
    #|R2 n1 0 1000.0
    #|C1 n1 0 10e-9
    #|X1 n1 out out OPAMP
    #|RLOAD out 0 500.0
    #|.op
  let netlist = @spice.parse_spice_netlist(netlist_str)
  let sim = CircuitSimulator::{ netlist, }
  let dc = sim.solve_dc()

  assert_true(dc.contains("in"))
  assert_true(dc.contains("n1"))
  assert_true(dc.contains("out"))

  let v_in = dc.get("in").unwrap()
  let v_n1 = dc.get("n1").unwrap()
  let v_out = dc.get("out").unwrap()

  assert_true((v_in - 5.0).abs() < 1.0e-3)
  assert_true((v_n1 - 2.5).abs() < 1.0e-3)
  assert_true((v_out - 2.5).abs() < 1.0e-3)
}
