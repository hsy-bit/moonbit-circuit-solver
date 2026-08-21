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
test "Harness 01: Reverse Cuthill-McKee Bandwidth Reduction on RC Ladder" {
  let n = 20
  let builder = @linalg.SparseBuilder::new(n, n)
  for i in 0..<n {
    builder.add_entry(i, i, 2.0)
    if i > 0 {
      builder.add_entry(i, i - 1, -1.0)
    }
    if i + 1 < n {
      builder.add_entry(i, i + 1, -1.0)
    }
  }
  let csr = builder.to_csr()
  let rcm = @linalg.reverse_cuthill_mckee(csr)

  assert_true(rcm.length() == n)
  let band = @linalg.compute_matrix_bandwidth(csr, rcm)
  assert_true(band <= 2)
}

///|
test "Harness 02: Scalar Tridiagonal Thomas Algorithm Direct Solver" {
  let n = 10
  let a_sub = Array::make(n - 1, -1.0)
  let b_diag = Array::make(n, 2.0)
  let c_sup = Array::make(n - 1, -1.0)
  let d_rhs = Array::make(n, 1.0)

  let sol = @linalg.solve_scalar_tridiagonal(a_sub, b_diag, c_sup, d_rhs)
  assert_true(sol.length() == n)
  // Solution of -x_{i-1} + 2x_i - x_{i+1} = 1 with zero boundary conditions is a parabola x_i = 0.5 * i * (n + 1 - i)
  assert_true(sol[0] > 0.0)
  assert_true(sol[4] > sol[0]) // Center is higher
}

///|
test "Harness 03: VBIC Advanced BJT Model Evaluation" {
  let vbic_p = @nonlinear.VbicBjtParams::default_sige()
  let comp = @nonlinear.evaluate_vbic_bjt(vbic_p, 0.82, 2.0, 25.0)

  assert_true(comp.ic > 0.0)
  assert_true(comp.ib > 0.0)
  assert_true(comp.gm > 0.0)
  assert_true(comp.p_diss > 0.0)
}

///|
test "Harness 04: EKV 2.6 Charge-Based MOSFET Model Inversion Continua" {
  let ekv_p = @nonlinear.EkvMosfetParams::default_nmos()

  // 1. Weak Inversion (Subthreshold: Vg = 0.2V < Vto = 0.45V)
  let comp_weak = @nonlinear.evaluate_ekv_mosfet(ekv_p, 0.2, 1.0, 0.0, 0.0)
  // 2. Strong Inversion (Vg = 1.2V > Vto)
  let comp_strong = @nonlinear.evaluate_ekv_mosfet(ekv_p, 1.2, 1.0, 0.0, 0.0)

  assert_true(comp_weak.id > 0.0)
  assert_true(comp_strong.id > 100.0 * comp_weak.id)
  assert_true(comp_strong.gm > comp_weak.gm)
}

///|
test "Harness 05: Trench Power MOSFET Dynamic Non-Linear Miller Capacitance" {
  let mos_p = @nonlinear.TrenchPowerMosfetParams::default_100v()

  let state_low = @nonlinear.evaluate_trench_mosfet_dynamic(mos_p, 10.0, 1.0)
  let state_high = @nonlinear.evaluate_trench_mosfet_dynamic(mos_p, 10.0, 50.0)

  // Cgd drops drastically as Vds rises to 50V
  assert_true(state_high.c_gd < state_low.c_gd)
  assert_true(state_low.r_channel < 0.1) // Low on-resistance
}

///|
test "Harness 06: Gear BDF Orders 1 through 5 Capacitor Companion Stamping" {
  let c_val = 1.0e-6
  let dt = 1.0e-6
  let hist = [1.0, 0.9, 0.8, 0.7, 0.6]

  let bdf1 = @transient.evaluate_gear_bdf_cap(
    c_val,
    hist,
    dt,
    @transient.GearOrder::Bdf1,
  )
  let bdf2 = @transient.evaluate_gear_bdf_cap(
    c_val,
    hist,
    dt,
    @transient.GearOrder::Bdf2,
  )
  let bdf3 = @transient.evaluate_gear_bdf_cap(
    c_val,
    hist,
    dt,
    @transient.GearOrder::Bdf3,
  )
  let bdf4 = @transient.evaluate_gear_bdf_cap(
    c_val,
    hist,
    dt,
    @transient.GearOrder::Bdf4,
  )
  let bdf5 = @transient.evaluate_gear_bdf_cap(
    c_val,
    hist,
    dt,
    @transient.GearOrder::Bdf5,
  )

  assert_true(bdf1.g_eq == 1.0)
  assert_true(bdf2.g_eq == 1.5)
  assert_true((bdf3.g_eq - 11.0 / 6.0).abs() < 1.0e-12)
  assert_true((bdf4.g_eq - 25.0 / 12.0).abs() < 1.0e-12)
  assert_true((bdf5.g_eq - 137.0 / 60.0).abs() < 1.0e-12)
}

///|
test "Harness 07: Sallen-Key Low-Pass Active Filter Direct SPICE Synthesis" {
  let sk = @symbolic.design_sallen_key_low_pass(2000.0, 0.7071, 10.0e-9)

  let s = "* Sallen-Key 2 kHz Active Filter\n" +
    "VIN in 0 DC 1.0\n" +
    "R1 in n1 " +
    sk.r1.to_string() +
    "\n" +
    "R2 n1 pos " +
    sk.r2.to_string() +
    "\n" +
    "C1 n1 out " +
    sk.c1.to_string() +
    "\n" +
    "C2 pos 0 " +
    sk.c2.to_string() +
    "\n" +
    "X1 pos out out OPAMP\n" +
    ".op\n"

  let netlist = @spice.parse_spice_netlist(s)
  let sim = CircuitSimulator::{ netlist, }
  let dc = sim.solve_dc()

  let v_out = dc.get("out").unwrap()
  assert_true((v_out - 1.0).abs() < 1.0e-3)
}

///|
test "Harness 08: Multi-Frequency AC Sweep on Sallen-Key Filter" {
  let sk = @symbolic.design_sallen_key_low_pass(1000.0, 0.7071, 10.0e-9)
  let s = "* Sallen-Key AC Response\n" +
    "VIN in 0 AC 1.0\n" +
    "R1 in n1 " +
    sk.r1.to_string() +
    "\n" +
    "R2 n1 pos " +
    sk.r2.to_string() +
    "\n" +
    "C1 n1 out " +
    sk.c1.to_string() +
    "\n" +
    "C2 pos 0 " +
    sk.c2.to_string() +
    "\n" +
    "X1 pos out out OPAMP\n" +
    ".ac dec 10 10 100000\n"

  let netlist = @spice.parse_spice_netlist(s)
  let ac_res = @mna.solve_ac_sweep(netlist, 10.0, 100000.0, 20)
  assert_true(ac_res.sweep_points.length() == 20)
}

///|
test "Harness 09: Full Monte Carlo Yield Statistics on 4-Resistor Bridge" {
  let s = "* Bridge Monte Carlo\n" +
    "V1 in 0 DC 10.0\n" +
    "R1 in out1 1000.0\n" +
    "R2 out1 0 1000.0\n" +
    "R3 in out2 1000.0\n" +
    "R4 out2 0 1000.0\n" +
    ".op\n"
  let netlist = @spice.parse_spice_netlist(s)
  let vars = [
    @mna.ComponentVariation::new("R1", 1000.0, 1.0, true),
    @mna.ComponentVariation::new("R2", 1000.0, 1.0, true),
  ]

  let mc_res = @mna.run_monte_carlo_dc(netlist, vars, 25, "out1", 4.9, 5.1, 42)
  assert_true(mc_res.num_runs == 25)
  assert_true(mc_res.yield_percent >= 90.0)
}

///|
test "Harness 10: Complete EDA End-to-End Suite Acceptance Pass" {
  let s = "* Final Suite Integration Acceptance\n" +
    "VDD vdd 0 DC 5.0\n" +
    "VIN in 0 DC 2.5\n" +
    "R1 in inv 1000.0\n" +
    "RF inv out 1000.0\n" +
    "X1 0 inv out OPAMP\n" +
    ".op\n"
  let netlist = @spice.parse_spice_netlist(s)
  let sim = CircuitSimulator::{ netlist, }
  let dc = sim.solve_dc()

  let v_out = dc.get("out").unwrap()
  assert_true((v_out - -2.5).abs() < 1.0e-3)
}
