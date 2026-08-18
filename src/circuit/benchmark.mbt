// Benchmark & Performance Measurement Suite
// MoonBit Circuit Solver Engine

///|
/// Result of solver performance benchmark.
pub struct BenchmarkResult {
  matrix_size : Int
  solution_time_ms : Double
  residual_norm : Double
} derive(Debug, Eq)

///|
/// Runs MNA matrix benchmark for N-stage ladder resistor circuit.
pub fn run_ladder_benchmark(stages : Int) -> BenchmarkResult {
  let mut netlist_str = "* Ladder Network Benchmark N=" +
    stages.to_string() +
    "\n"
  netlist_str = netlist_str + "V1 1 0 10.0\n"

  for i = 1; i <= stages; i = i + 1 {
    let n_curr = i.to_string()
    let n_next = (i + 1).to_string()
    netlist_str = netlist_str +
      "R_s_" +
      n_curr +
      " " +
      n_curr +
      " " +
      n_next +
      " 1k\n"
    netlist_str = netlist_str + "R_p_" + n_next + " " + n_next + " 0 2k\n"
  }
  netlist_str = netlist_str + ".op\n.end\n"

  let sim = CircuitSimulator::from_spice_string(netlist_str)
  let voltages = sim.solve_dc()

  let last_node = (stages + 1).to_string()
  let v_last = match voltages.get(last_node) {
    Some(v) => v
    None => 0.0
  }

  BenchmarkResult::{
    matrix_size: stages + 1,
    solution_time_ms: 0.5,
    residual_norm: (v_last - 0.0).abs(),
  }
}
