// Modified Nodal Analysis - DC Sensitivity Analysis Engine
// MoonBit Circuit Solver Engine

///|
/// Result of DC sensitivity analysis for a component.
pub struct ComponentSensitivity {
  comp_name : String
  node_name : String
  sensitivity_v_per_unit : Double
} derive(Debug, Eq)

///|
/// Computes DC voltage sensitivity of node `target_node` with respect to resistor `res_name`.
pub fn compute_resistor_sensitivity(
  netlist : @spice.Netlist,
  res_name : String,
  target_node : String,
) -> ComponentSensitivity {
  let dc_base = solve_dc_op(netlist)
  let v_base = match dc_base.node_voltages.get(target_node) {
    Some(v) => v
    None => 0.0
  }

  // Perturb resistor by 1%
  let delta = 0.01
  let perturbed_components : Array[@spice.Component] = []

  for comp in netlist.components {
    match comp {
      Resistor(name, n1, n2, r_val) =>
        if name.to_lower() == res_name.to_lower() {
          perturbed_components.push(
            @spice.Component::create_resistor(
              name,
              n1,
              n2,
              r_val * (1.0 + delta),
            ),
          )
        } else {
          perturbed_components.push(comp)
        }
      _ => perturbed_components.push(comp)
    }
  }

  let perturbed_netlist = @spice.Netlist::new(netlist.title + " (Perturbed)")
  for c in perturbed_components {
    perturbed_netlist.add_component(c)
  }

  let dc_pert = solve_dc_op(perturbed_netlist)
  let v_pert = match dc_pert.node_voltages.get(target_node) {
    Some(v) => v
    None => 0.0
  }

  let sens = (v_pert - v_base) / delta
  ComponentSensitivity::{
    comp_name: res_name,
    node_name: target_node,
    sensitivity_v_per_unit: sens,
  }
}
