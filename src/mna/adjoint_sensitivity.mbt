// Copyright 2026 hsy-bit
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

///|
/// Result of DC Adjoint Sensitivity Analysis for a specified target objective node.
pub struct AdjointSensitivityResult {
  target_node : String
  sensitivities : Map[String, Double] // Parameter name -> d(V_target) / d(Parameter)
  normalized_sens : Map[String, Double] // (p / V_target) * d(V_target)/d(p)
} derive(Eq, Debug)

///|
/// Computes DC Adjoint Sensitivities of a target node voltage with respect to all circuit components.
/// Uses Tellegen's Theorem / Adjoint Network approach: A^T * Psi = d(f)/d(x).
pub fn compute_dc_adjoint_sensitivities(
  netlist : @spice.Netlist,
  target_node : String,
) -> AdjointSensitivityResult {
  let (indexer, a_mat, z_vec, _) = build_dc_mna_system(netlist)
  let n = indexer.total_size()

  // 1. Solve Original System: A * x = z
  let x_sol = match @linalg.gaussian_solve(a_mat, z_vec) {
    Success(v) => v
    SingularMatrix(_) => @linalg.Vector::zeros(n)
  }

  // 2. Form Adjoint RHS d(f)/dx = [0 ... 1 ... 0]^T at target node index
  let target_idx = indexer.get_or_add_node(target_node)
  let adj_rhs = @linalg.Vector::zeros(n)
  if target_idx >= 0 && target_idx < n {
    adj_rhs.set(target_idx, 1.0)
  }

  // 3. Solve Adjoint System: A^T * Psi = adj_rhs
  let a_trans = a_mat.transpose()
  let psi = match @linalg.gaussian_solve(a_trans, adj_rhs) {
    Success(v) => v
    SingularMatrix(_) => @linalg.Vector::zeros(n)
  }

  let sens_map : Map[String, Double] = Map([])
  let norm_map : Map[String, Double] = Map([])

  let v_target = if target_idx >= 0 && target_idx < n {
    x_sol.get(target_idx)
  } else {
    1.0
  }
  let safe_v_target = if v_target.abs() > 1.0e-9 { v_target } else { 1.0e-9 }

  // 4. Compute sensitivities via inner products: d(V_target)/d(p) = - Psi^T * (dA/dp) * x + Psi^T * (dz/dp)
  for comp in netlist.components {
    match comp {
      @spice.Component::Resistor(name, n1_str, n2_str, r_val) => {
        let n1 = indexer.get_or_add_node(n1_str)
        let n2 = indexer.get_or_add_node(n2_str)

        let v1 = if n1 >= 0 { x_sol.get(n1) } else { 0.0 }
        let v2 = if n2 >= 0 { x_sol.get(n2) } else { 0.0 }
        let v_diff = v1 - v2

        let psi1 = if n1 >= 0 { psi.get(n1) } else { 0.0 }
        let psi2 = if n2 >= 0 { psi.get(n2) } else { 0.0 }
        let psi_diff = psi1 - psi2

        // dG/dR = -1 / R^2 -> d(V_target)/dR = (psi1 - psi2) * (v1 - v2) / R^2
        let sens = psi_diff * v_diff / (r_val * r_val)
        let norm_s = r_val / safe_v_target * sens

        sens_map.set(name, sens)
        norm_map.set(name, norm_s)
      }
      @spice.Component::VSource(name, _, _, _) => {
        // Voltage source sensitivity
        let aux = match indexer.node_to_idx.get("i(" + name.to_lower() + ")") {
          Some(idx) => idx
          None => -1
        }
        let sens = if aux >= 0 && aux < n { psi.get(aux) } else { 0.0 }
        sens_map.set(name, sens)
        norm_map.set(name, sens)
      }
      _ => ()
    }
  }

  { target_node, sensitivities: sens_map, normalized_sens: norm_map }
}
