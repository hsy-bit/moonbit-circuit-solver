// Transient Simulation - Time Domain Solver Engine
// MoonBit Circuit Solver Engine

///|
/// Time step snapshot holding state of all circuit nodes at time t.
pub struct TransientStepPoint {
  time : Double
  node_voltages : Map[String, Double]
  branch_currents : Map[String, Double]
} derive(Debug, Eq)

///|
/// Result of complete transient analysis (.tran).
pub struct TransientResult {
  steps : Array[TransientStepPoint]
} derive(Debug, Eq)

///|
/// Evaluates waveform source value at time t.
pub fn evaluate_waveform_at_t(wave : @spice.Waveform, t : Double) -> Double {
  match wave {
    Dc(v) => v
    Pulse(v1, v2, delay, rise, fall, width, period) =>
      if t < delay {
        v1
      } else {
        let t_rel = t - delay - (t - delay) / period * period
        if t_rel < rise {
          v1 + (v2 - v1) * (t_rel / rise)
        } else if t_rel < rise + width {
          v2
        } else if t_rel < rise + width + fall {
          v2 - (v2 - v1) * ((t_rel - rise - width) / fall)
        } else {
          v1
        }
      }
    Sine(offset, amp, freq, delay, damping) =>
      if t < delay {
        offset
      } else {
        let t_rel = t - delay
        let pi = 3.141592653589793
        let damped_amp = amp * @math.exp(-damping * t_rel)
        offset + damped_amp * @math.sin(2.0 * pi * freq * t_rel)
      }
    Pwl(pts) => {
      let n = pts.length()
      if n == 0 {
        0.0
      } else if t <= pts[0].0 {
        pts[0].1
      } else if t >= pts[n - 1].0 {
        pts[n - 1].1
      } else {
        let mut val = pts[0].1
        for i = 0; i < n - 1; i = i + 1 {
          if t >= pts[i].0 && t <= pts[i + 1].0 {
            let t1 = pts[i].0
            let v1 = pts[i].1
            let t2 = pts[i + 1].0
            let v2 = pts[i + 1].1
            val = v1 + (v2 - v1) * ((t - t1) / (t2 - t1))
            break
          }
        }
        val
      }
    }
  }
}

///|
/// Solves transient analysis (.tran tstep tstop tstart).
pub fn solve_transient(
  netlist : @spice.Netlist,
  tstep : Double,
  tstop : Double,
  tstart : Double,
) -> TransientResult {
  let dc_init = @mna.solve_dc_op(netlist)
  let steps : Array[TransientStepPoint] = []

  let mut curr_t = 0.0
  let mut prev_v = dc_init.node_voltages
  let mut prev_i = dc_init.branch_currents

  if tstart == 0.0 {
    steps.push(TransientStepPoint::{
      time: 0.0,
      node_voltages: prev_v,
      branch_currents: prev_i,
    })
  }

  let (indexer, a_mat_base, z_vec_base, aux_vsource_map) = @mna.build_dc_mna_system(
    netlist,
  )
  let size = indexer.total_size()

  while curr_t < tstop {
    curr_t = curr_t + tstep

    let a_mat = a_mat_base.copy()
    let z_vec = z_vec_base.copy()

    // Update transient sources and reactive companion models
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
        ISource(_, n1_str, n2_str, wave) => {
          let n1 = indexer.get_or_add_node(n1_str)
          let n2 = indexer.get_or_add_node(n2_str)
          let i_now = evaluate_waveform_at_t(wave, curr_t)
          @mna.stamp_isource(z_vec, n1, n2, i_now)
        }
        Capacitor(_, n1_str, n2_str, c_val, _) => {
          let n1 = indexer.get_or_add_node(n1_str)
          let n2 = indexer.get_or_add_node(n2_str)
          let v1 = match prev_v.get(n1_str) {
            Some(v) => v
            None => 0.0
          }
          let v2 = match prev_v.get(n2_str) {
            Some(v) => v
            None => 0.0
          }
          let companion = get_cap_companion(
            Trapezoidal,
            c_val,
            tstep,
            v1 - v2,
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
        abort("Transient step failed at t = \{curr_t}: " + msg)
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

    if curr_t >= tstart {
      steps.push(TransientStepPoint::{
        time: curr_t,
        node_voltages: node_v,
        branch_currents: branch_i,
      })
    }
    prev_v = node_v
    prev_i = branch_i
  }

  TransientResult::{ steps, }
}
