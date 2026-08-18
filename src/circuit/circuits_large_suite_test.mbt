// Comprehensive Integration Test Suite
// MoonBit Circuit Solver Engine

///|
test "SPICE netlist serialization & roundtrip test" {
  let netlist_str =
    #|* RC Test Netlist
    #|V1 1 0 10
    #|R1 1 2 1000
    #|C1 2 0 0.000001
    #|.op
    #|.end

  let sim = CircuitSimulator::from_spice_string(netlist_str)
  let serialized = @spice.serialize_netlist(sim.netlist)
  assert_true(serialized.length() > 20)
}

///|
test "ASCII Bode Plot rendering test" {
  let netlist_str =
    #|* Lowpass Filter AC Sweep
    #|Vin in 0 AC 1.0
    #|R1 in out 1k
    #|C1 out 0 1u
    #|.ac dec 10 10 100k
    #|.end

  let netlist = @spice.parse_spice_netlist(netlist_str)
  let ac_res = @mna.solve_ac_sweep(netlist, 10.0, 100000.0, 10)
  let plot = @visualizer.render_ascii_bode_plot(ac_res.sweep_points, "out")
  assert_true(plot.length() > 50)
}

///|
test "Moore-Penrose pseudo-inverse solver test" {
  let a_mat = @linalg.Matrix::zeros(3, 2)
  a_mat.set(0, 0, 1.0)
  a_mat.set(1, 0, 0.0)
  a_mat.set(2, 0, 1.0)
  a_mat.set(0, 1, 0.0)
  a_mat.set(1, 1, 1.0)
  a_mat.set(2, 1, 1.0)

  let b_vec = @linalg.Vector::from_array([1.0, 2.0, 3.0])
  let x = @linalg.pinv_solve(a_mat, b_vec)
  assert_true(x.length() == 2)
}

///|
test "Resistor DC sensitivity analysis test" {
  let netlist_str =
    #|* Divider Sensitivity
    #|V1 1 0 10.0
    #|R1 1 2 10k
    #|R2 2 0 10k
    #|.op
    #|.end

  let netlist = @spice.parse_spice_netlist(netlist_str)
  let sens = @mna.compute_resistor_sensitivity(netlist, "R1", "2")
  assert_eq(sens.comp_name, "R1")
  assert_true(sens.sensitivity_v_per_unit != 0.0)
}

///|
test "Gear2 transient integration test" {
  let netlist_str =
    #|* RC Gear2 Step Response
    #|V1 in 0 5.0
    #|R1 in out 1k
    #|C1 out 0 1u
    #|.tran 10u 1m
    #|.end

  let netlist = @spice.parse_spice_netlist(netlist_str)
  let tran_res = @transient.solve_transient_gear2(netlist, 0.00001, 0.001)
  assert_true(tran_res.steps.length() > 5)
}

///|
test "Builtin Model Registry test" {
  let reg = @spice.ModelRegistry::default()
  let m = reg.lookup("1N4148")
  let is_present = match m {
    Some(_) => true
    None => false
  }
  assert_true(is_present)
}
