// Advanced Unit & Integration Tests for Circuit Simulator
// MoonBit Circuit Solver Engine

///|
test "5-stage resistor ladder network test" {
  let res = run_ladder_benchmark(5)
  assert_true(res.matrix_size == 6)
}

///|
test "Inverting OpAmp Amplifier test" {
  let netlist_str =
    #|* Inverting Amplifier Gain = -R2/R1 = -2
    #|Vin in 0 1.0
    #|R1 in feedback 10k
    #|R2 feedback out 20k
    #|X1 0 feedback out OPAMP
    #|.op
    #|.end

  let sim = CircuitSimulator::from_spice_string(netlist_str)
  let voltages = sim.solve_dc()

  let v_out = match voltages.get("out") {
    Some(v) => v
    None => 0.0
  }

  let diff = (v_out - -2.0).abs()
  assert_true(diff < 0.05)
}

///|
test "Half wave diode rectifier transient test" {
  let netlist_str =
    #|* Half Wave Diode Rectifier
    #|Vac in 0 12.0
    #|D1 in dc_pos D1N4001
    #|Rload dc_pos 0 1k
    #|Cfilter dc_pos 0 100u
    #|.tran 100u 40m
    #|.end

  let sim = CircuitSimulator::from_spice_string(netlist_str)
  let tran_res = sim.solve_transient(0.0001, 0.005)
  assert_true(tran_res.steps.length() > 5)
}

///|
test "BJT Resistor Divider Bias test" {
  let netlist_str =
    #|* BJT Bias Circuit
    #|Vcc vcc 0 12.0
    #|R1 vcc b 47k
    #|R2 b 0 10k
    #|Rc vcc c 2.2k
    #|Re e 0 1k
    #|.op
    #|.end

  let sim = CircuitSimulator::from_spice_string(netlist_str)
  let voltages = sim.solve_dc()

  let v_b = match voltages.get("b") {
    Some(v) => v
    None => 0.0
  }
  let v_c = match voltages.get("c") {
    Some(v) => v
    None => 0.0
  }

  assert_true(v_b > 1.5 && v_b < 3.0)
  assert_true(v_c > 0.0)
}

///|
test "Subcircuit Definition construction test" {
  let sub = @spice.SubcircuitDef::new("RC_FILTER", ["in", "out"], [])
  assert_eq(sub.name, "RC_FILTER")
}
