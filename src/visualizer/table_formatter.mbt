// Visualizer & Output Module - Tabular Reports & Output Formatting
// MoonBit Circuit Solver Engine

/// Formats DC Operating Point result into a clean terminal report table.
pub fn format_dc_op_table(dc_res : @mna.DcResult) -> String {
  let mut sb = "\n======================================================\n"
  sb = sb + "          DC OPERATING POINT SOLUTION REPORT          \n"
  sb = sb + "======================================================\n"
  sb = sb + " Node Name              Voltage (V)\n"
  sb = sb + "------------------------------------------------------\n"

  let n_nodes = dc_res.node_indexer.node_count()
  for i = 0; i < n_nodes; i = i + 1 {
    let name = dc_res.node_indexer.get_node_name(i)
    let v = match dc_res.node_voltages.get(name) { Some(val) => val, None => 0.0 }
    sb = sb + " " + name + String::make(22 - name.length(), ' ') + v.to_string() + "\n"
  }

  sb = sb + "\n------------------------------------------------------\n"
  sb = sb + " Branch Name            Current (A)\n"
  sb = sb + "------------------------------------------------------\n"

  let total = dc_res.node_indexer.total_size()
  for i = n_nodes; i < total; i = i + 1 {
    let name = dc_res.node_indexer.get_node_name(i)
    let cur = match dc_res.branch_currents.get(name) { Some(val) => val, None => 0.0 }
    sb = sb + " " + name + String::make(22 - name.length(), ' ') + cur.to_string() + "\n"
  }
  sb = sb + "======================================================\n\n"
  sb
}
