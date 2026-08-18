// Sweeps & Predictor Integration Unit Tests
// MoonBit Circuit Solver Engine

///|
test "2D DC Parameter Sweep test" {
  let netlist_str =
    #|* 2D Sweep Circuit
    #|V1 1 0 5.0
    #|V2 2 0 3.0
    #|R1 1 3 10k
    #|R2 2 3 10k
    #|R3 3 0 10k
    #|.op
    #|.end

  let netlist = @spice.parse_spice_netlist(netlist_str)
  let sweep_res = @mna.solve_dc_sweep_2d(
    netlist, "V1", 0.0, 5.0, 2.5, "V2", 0.0, 3.0, 1.5,
  )
  assert_true(sweep_res.grid.length() >= 6)
}

///|
test "Adams-Bashforth transient integration test" {
  let netlist_str =
    #|* RC Adams Step Response
    #|V1 in 0 5.0
    #|R1 in out 1k
    #|C1 out 0 1u
    #|.tran 10u 1m
    #|.end

  let netlist = @spice.parse_spice_netlist(netlist_str)
  let tran_res = @transient.solve_transient_adams(netlist, 0.00001, 0.001)
  assert_true(tran_res.steps.length() > 5)
}
