// Non-linear Damped Newton-Raphson Solver Engine
// MoonBit Circuit Solver Engine

///|
/// Result of Newton-Raphson non-linear iteration.
pub struct NewtonRaphsonResult {
  converged : Bool
  iterations : Int
  solution : @linalg.Vector
  dc_result : @mna.DcResult
} derive(Debug, Eq)

///|
/// Solves non-linear DC operating point using Damped Newton-Raphson iterations.
pub fn solve_nonlinear_dc(
  netlist : @spice.Netlist,
  max_iters : Int,
  rel_tol : Double,
  abs_tol : Double,
) -> NewtonRaphsonResult {
  let (indexer, a_mat_base, z_vec_base, _) = @mna.build_dc_mna_system(netlist)
  let size = indexer.total_size()

  let mut sol = @linalg.Vector::zeros(size)
  let mut is_conv = false
  let mut iter_count = 0

  while iter_count < max_iters && !is_conv {
    iter_count = iter_count + 1
    let a_mat = a_mat_base.copy()
    let z_vec = z_vec_base.copy()

    // Add Gmin diagonal shunt to prevent matrix singularity on floating nodes
    let n_nodes = indexer.node_count()
    for i = 0; i < n_nodes; i = i + 1 {
      a_mat.add_to_element(i, i, 1.0e-12)
    }

    // Stamp non-linear semiconductor companions
    for comp in netlist.components {
      match comp {
        Diode(_, n1_str, n2_str, _) => {
          let n1 = indexer.get_or_add_node(n1_str)
          let n2 = indexer.get_or_add_node(n2_str)
          let v1 = if n1 >= 0 { sol.get(n1) } else { 0.0 }
          let v2 = if n2 >= 0 { sol.get(n2) } else { 0.0 }
          let vd = v1 - v2
          let companion = evaluate_diode(vd, 0.00000000000001, 1.0, 0.02585)
          stamp_diode_companion(a_mat, z_vec, n1, n2, companion)
        }
        Bjt(_, c_str, b_str, e_str, _) => {
          let c = indexer.get_or_add_node(c_str)
          let b = indexer.get_or_add_node(b_str)
          let e = indexer.get_or_add_node(e_str)
          let vc = if c >= 0 { sol.get(c) } else { 0.0 }
          let vb = if b >= 0 { sol.get(b) } else { 0.0 }
          let ve = if e >= 0 { sol.get(e) } else { 0.0 }
          let companion = evaluate_bjt(
            vb - ve,
            vb - vc,
            0.00000000000001,
            100.0,
            1.0,
            true,
          )
          stamp_bjt_companion(a_mat, z_vec, c, b, e, companion)
        }
        Mosfet(_, d_str, g_str, s_str, _) => {
          let d = indexer.get_or_add_node(d_str)
          let g = indexer.get_or_add_node(g_str)
          let s = indexer.get_or_add_node(s_str)
          let vd = if d >= 0 { sol.get(d) } else { 0.0 }
          let vg = if g >= 0 { sol.get(g) } else { 0.0 }
          let vs = if s >= 0 { sol.get(s) } else { 0.0 }
          let companion = evaluate_mosfet(
            vg - vs,
            vd - vs,
            0.7,
            0.001,
            0.01,
            true,
          )
          stamp_mosfet_companion(a_mat, z_vec, d, g, s, companion)
        }
        _ => ()
      }
    }

    let next_sol = match @linalg.gaussian_solve(a_mat, z_vec) {
      Success(v) => v
      SingularMatrix(msg) => abort("Newton-Raphson iteration failed: " + msg)
    }

    // Check convergence
    let max_diff = next_sol.max_diff(sol)
    if max_diff < abs_tol + rel_tol * next_sol.norm_l2() {
      is_conv = true
    }

    // Damping step
    let damping = 0.8
    let updated = sol.scale(1.0 - damping).add(next_sol.scale(damping))
    sol = updated
  }

  let node_v : Map[String, Double] = Map([])
  let branch_i : Map[String, Double] = Map([])
  let n_nodes = indexer.node_count()
  for i = 0; i < n_nodes; i = i + 1 {
    let name = indexer.get_node_name(i)
    node_v.set(name, sol.get(i))
  }
  for i = n_nodes; i < size; i = i + 1 {
    let name = indexer.get_node_name(i)
    branch_i.set(name, sol.get(i))
  }

  let dc_res = @mna.DcResult::new(indexer, node_v, branch_i, sol)

  NewtonRaphsonResult::{
    converged: is_conv,
    iterations: iter_count,
    solution: sol,
    dc_result: dc_res,
  }
}
