// High-Level Circuit Simulator Engine Facade
// MoonBit Circuit Solver Engine

///|
/// Primary Circuit Simulator class wrapping parser, solvers, and visualizers.
pub struct CircuitSimulator {
  netlist : @spice.Netlist
} derive(Debug, Eq)

///|
/// Creates a new CircuitSimulator from SPICE netlist string.
pub fn CircuitSimulator::from_spice_string(
  spice_text : String,
) -> CircuitSimulator {
  let netlist = @spice.parse_spice_netlist(spice_text)
  CircuitSimulator::{ netlist, }
}

///|
/// Runs DC Operating Point analysis and returns formatted report table string.
pub fn CircuitSimulator::run_dc_op_report(self : CircuitSimulator) -> String {
  let dc_res = @mna.solve_dc_op(self.netlist)
  @visualizer.format_dc_op_table(dc_res)
}

///|
/// Runs DC Operating Point analysis and returns Node Voltage map.
pub fn CircuitSimulator::solve_dc(
  self : CircuitSimulator,
) -> Map[String, Double] {
  let dc_res = @mna.solve_dc_op(self.netlist)
  dc_res.node_voltages
}

///|
/// Runs Transient simulation (.tran) and returns time-series step points.
pub fn CircuitSimulator::solve_transient(
  self : CircuitSimulator,
  tstep : Double,
  tstop : Double,
) -> @transient.TransientResult {
  @transient.solve_transient(self.netlist, tstep, tstop, 0.0)
}

///|
/// Runs Transient simulation and renders terminal ASCII waveform chart for given target node.
pub fn CircuitSimulator::render_transient_chart(
  self : CircuitSimulator,
  tstep : Double,
  tstop : Double,
  target_node : String,
) -> String {
  let tran_res = self.solve_transient(tstep, tstop)
  let pts : Array[(Double, Double)] = []
  for pt in tran_res.steps {
    let t = pt.time
    let v = match pt.node_voltages.get(target_node) {
      Some(val) => val
      None => 0.0
    }
    pts.push((t, v))
  }
  let config = @visualizer.AsciiChartConfig::default()
  @visualizer.render_ascii_chart(pts, config)
}

///|
/// Runs Non-linear DC simulation using Newton-Raphson iteration.
pub fn CircuitSimulator::solve_nonlinear_dc(
  self : CircuitSimulator,
) -> Map[String, Double] {
  let res = @nonlinear.solve_nonlinear_dc(self.netlist, 50, 0.0001, 0.000001)
  res.dc_result.node_voltages
}
