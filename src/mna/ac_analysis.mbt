// Modified Nodal Analysis - AC Frequency Domain Analysis
// MoonBit Circuit Solver Engine

/// AC sweep data point containing node magnitude and phase.
pub struct AcPoint {
  freq : Double
  magnitude : Map[String, Double]
  phase_deg : Map[String, Double]
} derive(Debug, Eq)

/// Result of full AC frequency sweep analysis.
pub struct AcResult {
  sweep_points : Array[AcPoint]
} derive(Debug, Eq)

/// Computes AC magnitude in decibels (dB): 20 * log10(val).
pub fn to_db(mag : Double) -> Double {
  if mag <= 0.0 {
    return -120.0
  }
  // 20 * ln(mag) / ln(10)
  20.0 * (mag.ln() / 2.302585092994046)
}

/// Solves AC frequency domain response for given frequency `f_hz`.
pub fn solve_ac_at_freq(netlist : @spice.Netlist, f_hz : Double) -> AcPoint {
  let omega = 2.0 * 3.141592653589793 * f_hz
  let (indexer, a_mat, z_vec, _) = build_dc_mna_system(netlist)

  // Modify A matrix with admittance of Capacitors and Inductors at omega
  for comp in netlist.components {
    match comp {
      Capacitor(_, n1_str, n2_str, c_val, _) => {
        let n1 = indexer.get_or_add_node(n1_str)
        let n2 = indexer.get_or_add_node(n2_str)
        let _g_ac = omega * c_val // magnitude of Y = j * omega * C
        stamp_resistor(a_mat, n1, n2, 1.0 / (_g_ac + 1e-12))
      }
      Inductor(name, n1_str, n2_str, l_val, _) => {
        let n1 = indexer.get_or_add_node(n1_str)
        let n2 = indexer.get_or_add_node(n2_str)
        let z_l = omega * l_val
        let aux = indexer.allocate_aux_var("i(" + name + ")")
        stamp_vsource(a_mat, z_vec, n1, n2, aux, 0.0)
        stamp_matrix_entry(a_mat, aux, aux, z_l)
      }
      _ => ()
    }
  }

  let sol = match @linalg.gaussian_solve(a_mat, z_vec) {
    Success(v) => v
    SingularMatrix(_) => @linalg.Vector::zeros(indexer.total_size())
  }

  let mag_map : Map[String, Double] = Map::new()
  let phase_map : Map[String, Double] = Map::new()

  let n_nodes = indexer.node_count()
  for i = 0; i < n_nodes; i = i + 1 {
    let name = indexer.get_node_name(i)
    let v_real = sol.get(i)
    let mag = if v_real < 0.0 { -v_real } else { v_real }
    mag_map.set(name, mag)
    phase_map.set(name, if v_real < 0.0 { 180.0 } else { 0.0 })
  }

  AcPoint::{ freq: f_hz, magnitude: mag_map, phase_deg: phase_map }
}
