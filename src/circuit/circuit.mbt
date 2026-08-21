// High-Level Circuit Simulator Engine Facade
// MoonBit Circuit Solver Engine

///|
/// Primary Circuit Simulator class wrapping parser, solvers, and visualizers.
pub(all) struct CircuitSimulator {
  netlist : @spice.Netlist
} derive(Debug, Eq)

///|
/// Creates a new CircuitSimulator from parsed Netlist.
pub fn CircuitSimulator::new(netlist : @spice.Netlist) -> CircuitSimulator {
  CircuitSimulator::{ netlist, }
}

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

///|
/// Runs Small-Signal AC Noise Analysis (.noise).
pub fn CircuitSimulator::solve_noise(
  self : CircuitSimulator,
  output_node : String,
  input_source : String,
  f_start : Double,
  f_stop : Double,
  points : Int,
) -> @mna.NoiseAnalysisResult {
  @mna.solve_noise_analysis(
    self.netlist,
    output_node,
    input_source,
    f_start,
    f_stop,
    points,
    300.0,
  )
}

///|
/// Runs Monte Carlo statistical tolerance analysis (.mc).
pub fn CircuitSimulator::run_monte_carlo(
  self : CircuitSimulator,
  variations : Array[@mna.ComponentVariation],
  num_runs : Int,
  output_node : String,
  spec_min : Double,
  spec_max : Double,
  seed : Int,
) -> @mna.MonteCarloSummary {
  @mna.run_monte_carlo_dc(
    self.netlist,
    variations,
    num_runs,
    output_node,
    spec_min,
    spec_max,
    seed,
  )
}

///|
/// Computes FFT Harmonic Distortion analysis (.four) from transient waveform.
pub fn CircuitSimulator::compute_fft(
  self : CircuitSimulator,
  tstep : Double,
  tstop : Double,
  target_node : String,
  fund_freq : Double,
) -> @transient.FftAnalysisResult {
  let tran_res = self.solve_transient(tstep, tstop)
  let t_pts : Array[Double] = []
  let v_pts : Array[Double] = []

  for pt in tran_res.steps {
    t_pts.push(pt.time)
    let v = match pt.node_voltages.get(target_node) {
      Some(val) => val
      None => 0.0
    }
    v_pts.push(v)
  }

  @transient.compute_transient_fft_analysis(
    t_pts,
    v_pts,
    fund_freq,
    @transient.FftWindow::Hanning,
  )
}

///|
/// Designs Sallen-Key Active Low-Pass Filter using symbolic engine.
pub fn CircuitSimulator::design_sallen_key(
  _self : CircuitSimulator,
  fc_hz : Double,
  q_factor : Double,
) -> @symbolic.SallenKeyLowPassDesign {
  @symbolic.design_sallen_key_low_pass(fc_hz, q_factor, 10.0e-9)
}

///|
/// Solves arbitrary matrix system A * x = b using least squares pseudo-inverse.
pub fn CircuitSimulator::solve_least_squares(
  self : CircuitSimulator,
  a_mat : @linalg.Matrix,
  b_vec : @linalg.Vector,
) -> @linalg.Vector {
  let _ = self.netlist.title
  @linalg.pinv_solve(a_mat, b_vec)
}
