// Command Line Interface Application Entry Point
// MoonBit Circuit Solver Engine

///|
fn main {
  println("=====================================================")
  println("  MoonBit SPICE Circuit Engine & Matrix Solver v0.1.0")
  println("=====================================================")

  let sample_netlist =
    #|* SPICE RC Low-Pass Filter Circuit Simulation
    #|V1 in 0 5.0
    #|R1 in out 1k
    #|C1 out 0 1u
    #|.op
    #|.tran 10u 2m
    #|.end

  let sim = @circuit.CircuitSimulator::from_spice_string(sample_netlist)

  println("\n[1] Running DC Operating Point Analysis...")
  let report = sim.run_dc_op_report()
  println(report)

  println("\n[2] Running Transient Simulation & Terminal Waveform Chart...")
  let chart = sim.render_transient_chart(0.00001, 0.002, "out")
  println(chart)

  println("Simulation complete successfully.")
}
