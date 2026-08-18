// Modified Nodal Analysis - DC Operating Point & Sweep Analysis
// MoonBit Circuit Solver Engine

///|
/// Result of DC Operating Point analysis.
pub struct DcResult {
  node_indexer : NodeIndexer
  node_voltages : Map[String, Double]
  branch_currents : Map[String, Double]
  solution_vector : @linalg.Vector
} derive(Debug, Eq)

///|
/// Creates a new DcResult instance.
pub fn DcResult::new(
  node_indexer : NodeIndexer,
  node_voltages : Map[String, Double],
  branch_currents : Map[String, Double],
  solution_vector : @linalg.Vector,
) -> DcResult {
  DcResult::{ node_indexer, node_voltages, branch_currents, solution_vector }
}

///|
/// Point in a DC sweep curve.
pub struct DcSweepPoint {
  sweep_val : Double
  voltages : Map[String, Double]
} derive(Debug, Eq)

///|
/// Creates a new DcSweepPoint.
pub fn DcSweepPoint::new(
  sweep_val : Double,
  voltages : Map[String, Double],
) -> DcSweepPoint {
  DcSweepPoint::{ sweep_val, voltages }
}

///|
/// Full DC sweep analysis result.
pub struct DcSweepResult {
  src_name : String
  points : Array[DcSweepPoint]
} derive(Debug, Eq)

///|
/// Creates a new DcSweepResult.
pub fn DcSweepResult::new(
  src_name : String,
  points : Array[DcSweepPoint],
) -> DcSweepResult {
  DcSweepResult::{ src_name, points }
}

///|
/// Builds MNA system matrix A and RHS vector z for DC analysis.
pub fn build_dc_mna_system(
  netlist : @spice.Netlist,
) -> (NodeIndexer, @linalg.Matrix, @linalg.Vector, Map[String, Int]) {
  let indexer = NodeIndexer::new()
  let aux_vsource_map : Map[String, Int] = Map([])

  // Pass 1: Register all circuit nodes so node_count is fixed
  for comp in netlist.components {
    match comp {
      Resistor(_, n1, n2, _) => {
        let _ = indexer.get_or_add_node(n1)
        let _ = indexer.get_or_add_node(n2)
      }
      Capacitor(_, n1, n2, _, _) => {
        let _ = indexer.get_or_add_node(n1)
        let _ = indexer.get_or_add_node(n2)
      }
      Inductor(_, n1, n2, _, _) => {
        let _ = indexer.get_or_add_node(n1)
        let _ = indexer.get_or_add_node(n2)
      }
      VSource(_, n1, n2, _) => {
        let _ = indexer.get_or_add_node(n1)
        let _ = indexer.get_or_add_node(n2)
      }
      ISource(_, n1, n2, _) => {
        let _ = indexer.get_or_add_node(n1)
        let _ = indexer.get_or_add_node(n2)
      }
      Diode(_, n1, n2, _) => {
        let _ = indexer.get_or_add_node(n1)
        let _ = indexer.get_or_add_node(n2)
      }
      Bjt(_, c, b, e, _) => {
        let _ = indexer.get_or_add_node(c)
        let _ = indexer.get_or_add_node(b)
        let _ = indexer.get_or_add_node(e)
      }
      Mosfet(_, d, g, s, _) => {
        let _ = indexer.get_or_add_node(d)
        let _ = indexer.get_or_add_node(g)
        let _ = indexer.get_or_add_node(s)
      }
      Vcvs(_, n1, n2, nc1, nc2, _) => {
        let _ = indexer.get_or_add_node(n1)
        let _ = indexer.get_or_add_node(n2)
        let _ = indexer.get_or_add_node(nc1)
        let _ = indexer.get_or_add_node(nc2)
      }
      Vccs(_, n1, n2, nc1, nc2, _) => {
        let _ = indexer.get_or_add_node(n1)
        let _ = indexer.get_or_add_node(n2)
        let _ = indexer.get_or_add_node(nc1)
        let _ = indexer.get_or_add_node(nc2)
      }
      Cccs(_, n1, n2, _, _) => {
        let _ = indexer.get_or_add_node(n1)
        let _ = indexer.get_or_add_node(n2)
      }
      Ccvs(_, n1, n2, _, _) => {
        let _ = indexer.get_or_add_node(n1)
        let _ = indexer.get_or_add_node(n2)
      }
      OpAmp(_, np, nn, out, _) => {
        let _ = indexer.get_or_add_node(np)
        let _ = indexer.get_or_add_node(nn)
        let _ = indexer.get_or_add_node(out)
      }
    }
  }

  // Pass 2: Allocate aux branch current variables
  for comp in netlist.components {
    match comp {
      Inductor(name, _, _, _, _) => {
        let aux = indexer.allocate_aux_var("i(" + name.to_lower() + ")")
        aux_vsource_map.set(name.to_lower(), aux)
      }
      VSource(name, _, _, _) => {
        let aux = indexer.allocate_aux_var("i(" + name.to_lower() + ")")
        aux_vsource_map.set(name.to_lower(), aux)
      }
      Vcvs(name, _, _, _, _, _) => {
        let aux = indexer.allocate_aux_var("i(" + name.to_lower() + ")")
        aux_vsource_map.set(name.to_lower(), aux)
      }
      Ccvs(name, _, _, _, _) => {
        let aux = indexer.allocate_aux_var("i(" + name.to_lower() + ")")
        aux_vsource_map.set(name.to_lower(), aux)
      }
      OpAmp(name, _, _, _, _) => {
        let aux = indexer.allocate_aux_var("i(" + name.to_lower() + ")")
        aux_vsource_map.set(name.to_lower(), aux)
      }
      _ => ()
    }
  }

  let size = indexer.total_size()
  let a_mat = @linalg.Matrix::zeros(size, size)
  let z_vec = @linalg.Vector::zeros(size)

  // Pass 3: Stamp passive linear components & linear sources
  for comp in netlist.components {
    match comp {
      Resistor(_, n1_str, n2_str, r_val) => {
        let n1 = indexer.get_or_add_node(n1_str)
        let n2 = indexer.get_or_add_node(n2_str)
        stamp_resistor(a_mat, n1, n2, r_val)
      }
      Capacitor(_, _, _, _, _) => () // DC open circuit
      Inductor(name, n1_str, n2_str, _, _) => {
        // DC short circuit: V_n1 - V_n2 = 0
        let n1 = indexer.get_or_add_node(n1_str)
        let n2 = indexer.get_or_add_node(n2_str)
        let aux = match aux_vsource_map.get(name.to_lower()) {
          Some(idx) => idx
          None => -1
        }
        stamp_vsource(a_mat, z_vec, n1, n2, aux, 0.0)
      }
      VSource(name, n1_str, n2_str, wave) => {
        let n1 = indexer.get_or_add_node(n1_str)
        let n2 = indexer.get_or_add_node(n2_str)
        let aux = match aux_vsource_map.get(name.to_lower()) {
          Some(idx) => idx
          None => -1
        }
        let dc_val = match wave {
          Dc(v) => v
          Pulse(v1, _, _, _, _, _, _) => v1
          Sine(offset, _, _, _, _) => offset
          Pwl(pts) => if pts.length() > 0 { pts[0].1 } else { 0.0 }
        }
        stamp_vsource(a_mat, z_vec, n1, n2, aux, dc_val)
      }
      ISource(_, n1_str, n2_str, wave) => {
        let n1 = indexer.get_or_add_node(n1_str)
        let n2 = indexer.get_or_add_node(n2_str)
        let dc_val = match wave {
          Dc(v) => v
          Pulse(v1, _, _, _, _, _, _) => v1
          Sine(offset, _, _, _, _) => offset
          Pwl(pts) => if pts.length() > 0 { pts[0].1 } else { 0.0 }
        }
        stamp_isource(z_vec, n1, n2, dc_val)
      }
      Vcvs(name, n1_str, n2_str, nc1_str, nc2_str, gain) => {
        let n1 = indexer.get_or_add_node(n1_str)
        let n2 = indexer.get_or_add_node(n2_str)
        let nc1 = indexer.get_or_add_node(nc1_str)
        let nc2 = indexer.get_or_add_node(nc2_str)
        let aux = match aux_vsource_map.get(name.to_lower()) {
          Some(idx) => idx
          None => -1
        }
        stamp_vcvs(a_mat, n1, n2, nc1, nc2, aux, gain)
      }
      Vccs(_, n1_str, n2_str, nc1_str, nc2_str, gm) => {
        let n1 = indexer.get_or_add_node(n1_str)
        let n2 = indexer.get_or_add_node(n2_str)
        let nc1 = indexer.get_or_add_node(nc1_str)
        let nc2 = indexer.get_or_add_node(nc2_str)
        stamp_vccs(a_mat, n1, n2, nc1, nc2, gm)
      }
      OpAmp(name, np_str, nn_str, out_str, gain) => {
        let np = indexer.get_or_add_node(np_str)
        let nn = indexer.get_or_add_node(nn_str)
        let out = indexer.get_or_add_node(out_str)
        let aux = match aux_vsource_map.get(name.to_lower()) {
          Some(idx) => idx
          None => -1
        }
        stamp_opamp(a_mat, np, nn, out, aux, gain)
      }
      _ => ()
    }
  }

  (indexer, a_mat, z_vec, aux_vsource_map)
}

///|
/// Solves linear DC Operating Point for linear circuits.
pub fn solve_dc_op(netlist : @spice.Netlist) -> DcResult {
  let (indexer, a_mat, z_vec, _) = build_dc_mna_system(netlist)
  let sol = match @linalg.gaussian_solve(a_mat, z_vec) {
    Success(v) => v
    SingularMatrix(msg) => abort("DC analysis failed: " + msg)
  }

  let node_v : Map[String, Double] = Map([])
  let branch_i : Map[String, Double] = Map([])

  let n_nodes = indexer.node_count()
  for i = 0; i < n_nodes; i = i + 1 {
    let name = indexer.get_node_name(i)
    node_v.set(name, sol.get(i))
  }
  let total = indexer.total_size()
  for i = n_nodes; i < total; i = i + 1 {
    let name = indexer.get_node_name(i)
    branch_i.set(name, sol.get(i))
  }

  DcResult::new(indexer, node_v, branch_i, sol)
}
