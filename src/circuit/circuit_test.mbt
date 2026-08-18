// Unit Tests for Circuit Simulation Engine
// MoonBit Circuit Solver Engine

///|
test "voltage divider DC analysis" {
  let netlist_str =
    #|* Simple Resistor Voltage Divider
    #|V1 1 0 10.0
    #|R1 1 2 10k
    #|R2 2 0 10k
    #|.op
    #|.end

  let sim = CircuitSimulator::from_spice_string(netlist_str)
  let voltages = sim.solve_dc()

  let v1 = match voltages.get("1") {
    Some(v) => v
    None => 0.0
  }
  let v2 = match voltages.get("2") {
    Some(v) => v
    None => 0.0
  }

  assert_eq(v1, 10.0)
  assert_eq(v2, 5.0)
}

///|
test "RC lowpass filter transient analysis" {
  let netlist_str =
    #|* RC Low Pass Filter Transient Step
    #|V1 in 0 5.0
    #|R1 in out 1k
    #|C1 out 0 1u
    #|.tran 10u 2m
    #|.end

  let sim = CircuitSimulator::from_spice_string(netlist_str)
  let tran_res = sim.solve_transient(0.00001, 0.002)

  assert_true(tran_res.steps.length() > 10)
  let last_pt = tran_res.steps[tran_res.steps.length() - 1]
  let v_out = match last_pt.node_voltages.get("out") {
    Some(v) => v
    None => 0.0
  }

  assert_true(v_out > 4.0)
}

///|
test "OpAmp non-inverting amplifier DC test" {
  let netlist_str =
    #|* OpAmp Non-Inverting Amplifier Gain = 1 + R2/R1 = 3
    #|Vin in 0 1.5
    #|R1 feedback 0 10k
    #|R2 out feedback 20k
    #|X1 in feedback out OPAMP
    #|.op
    #|.end

  let sim = CircuitSimulator::from_spice_string(netlist_str)
  let voltages = sim.solve_dc()

  let v_in = match voltages.get("in") {
    Some(v) => v
    None => 0.0
  }
  let v_out = match voltages.get("out") {
    Some(v) => v
    None => 0.0
  }

  assert_true((v_in - 1.5).abs() < 0.0001)
  let diff = (v_out - 4.5).abs()
  assert_true(diff < 0.01)
}
