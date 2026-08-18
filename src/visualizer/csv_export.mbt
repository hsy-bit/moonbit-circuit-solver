// Visualizer & Output Module - CSV & Data Export
// MoonBit Circuit Solver Engine

///|
/// Exports transient analysis results into CSV formatted string.
pub fn export_transient_csv(
  tran_res : @transient.TransientResult,
  target_node : String,
) -> String {
  let mut sb = "time," + target_node + "\n"
  for pt in tran_res.steps {
    let t = pt.time
    let v = match pt.node_voltages.get(target_node) {
      Some(val) => val
      None => 0.0
    }
    sb = sb + t.to_string() + "," + v.to_string() + "\n"
  }
  sb
}
