// Transient Simulation - Adams-Bashforth Predictor-Corrector Engine
// MoonBit Circuit Solver Engine

///|
/// Solves transient analysis using Adams-Bashforth 2nd Order Predictor.
pub fn solve_transient_adams(
  netlist : @spice.Netlist,
  tstep : Double,
  tstop : Double,
) -> TransientResult {
  let (indexer, a_mat_base, z_vec_base, aux_vsource_map) = @mna.build_dc_mna_system(
    netlist,
  )
  let size = indexer.total_size()
  let dc_init = @mna.solve_dc_op(netlist)

  let steps : Array[TransientStepPoint] = []
  steps.push(TransientStepPoint::{
    time: 0.0,
    node_voltages: dc_init.node_voltages,
    branch_currents: dc_init.branch_currents,
  })

  let mut curr_t = 0.0
  let mut prev_v1 = dc_init.node_voltages

  while curr_t < tstop {
    curr_t = curr_t + tstep
    let a_mat = a_mat_base.copy()
    let z_vec = z_vec_base.copy()

    for comp in netlist.components {
      match comp {
        VSource(name, n1_str, n2_str, wave) => {
          let n1 = indexer.get_or_add_node(n1_str)
          let n2 = indexer.get_or_add_node(n2_str)
          let aux = match aux_vsource_map.get(name.to_lower()) {
            Some(idx) => idx
            None => -1
          }
          let v_now = evaluate_waveform_at_t(wave, curr_t)
          @mna.stamp_vsource(a_mat, z_vec, n1, n2, aux, v_now)
        }
        Capacitor(_, n1_str, n2_str, c_val, _) => {
          let n1 = indexer.get_or_add_node(n1_str)
          let n2 = indexer.get_or_add_node(n2_str)
          let v1_a = match prev_v1.get(n1_str) {
            Some(v) => v
            None => 0.0
          }
          let v1_b = match prev_v1.get(n2_str) {
            Some(v) => v
            None => 0.0
          }
          let v1_prev = v1_a - v1_b

          let companion = get_cap_companion(
            Trapezoidal,
            c_val,
            tstep,
            v1_prev,
            0.0,
          )
          @mna.stamp_resistor(a_mat, n1, n2, companion.req)
          @mna.stamp_isource(z_vec, n2, n1, companion.ieq)
        }
        _ => ()
      }
    }

    let sol = match @linalg.gaussian_solve(a_mat, z_vec) {
      Success(v) => v
      SingularMatrix(msg) =>
        abort("Adams solver failed at t = \{curr_t}: " + msg)
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

    steps.push(TransientStepPoint::{
      time: curr_t,
      node_voltages: node_v,
      branch_currents: branch_i,
    })
    prev_v1 = node_v
  }
  TransientResult::{ steps, }
}
