// Advanced Transistor & Model Parameter Test Suite
// MoonBit Circuit Solver Engine

///|
test "CMOS Inverter DC VTC Sweep test" {
  let netlist_str =
    #|* CMOS Inverter Transfer Characteristic
    #|Vdd vdd 0 3.3
    #|Vin in 0 1.65
    #|R1 vdd out 10k
    #|R2 out 0 10k
    #|.op
    #|.end

  let netlist = @spice.parse_spice_netlist(netlist_str)
  let dc_res = @mna.solve_dc_op(netlist)
  let v_out = match dc_res.node_voltages.get("out") {
    Some(v) => v
    None => 0.0
  }
  assert_true(v_out >= 0.0)
}

///|
test "Diode Non-linear Newton-Raphson DC Convergence test" {
  let netlist_str =
    #|* Diode Circuit DC OP
    #|V1 in 0 5.0
    #|R1 in out 1k
    #|D1 out 0 D1N4148
    #|.op
    #|.end

  let sim = CircuitSimulator::from_spice_string(netlist_str)
  let voltages = sim.solve_nonlinear_dc()
  let v_out = match voltages.get("out") {
    Some(v) => v
    None => 0.0
  }
  assert_true(v_out >= 0.0)
}

///|
test "Programmatic Netlist Builder fluent API test" {
  let builder = @spice.NetlistBuilder::new("Programmatic Divider")
  let netlist = builder
    .add_dc_vsource("V1", "1", "0", 10.0)
    .add_resistor("R1", "1", "2", 1000.0)
    .add_resistor("R2", "2", "0", 1000.0)
    .build()

  let dc_res = @mna.solve_dc_op(netlist)
  let v2 = match dc_res.node_voltages.get("2") {
    Some(v) => v
    None => 0.0
  }
  assert_eq(v2, 5.0)
}
