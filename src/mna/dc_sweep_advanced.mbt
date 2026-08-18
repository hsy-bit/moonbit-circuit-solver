// Modified Nodal Analysis - 2D Multi-Parameter DC Sweep Engine
// MoonBit Circuit Solver Engine

///|
/// Grid cell in 2D DC Parameter Sweep.
pub struct DcSweep2DCell {
  v1_val : Double
  v2_val : Double
  node_voltages : Map[String, Double]
} derive(Debug, Eq)

///|
/// Result of 2D DC Parameter Sweep (.dc src1 start1 stop1 step1 src2 start2 stop2 step2).
pub struct DcSweep2DResult {
  src1_name : String
  src2_name : String
  grid : Array[DcSweep2DCell]
} derive(Debug, Eq)

///|
/// Solves 2D DC parameter sweep across two voltage sources.
pub fn solve_dc_sweep_2d(
  netlist : @spice.Netlist,
  src1 : String,
  start1 : Double,
  stop1 : Double,
  step1 : Double,
  src2 : String,
  start2 : Double,
  stop2 : Double,
  step2 : Double,
) -> DcSweep2DResult {
  let grid : Array[DcSweep2DCell] = []
  let mut v1 = start1
  let eps = 0.000000001
  while v1 <= stop1 + eps {
    let mut v2 = start2
    while v2 <= stop2 + eps {
      // Create modified components array
      let mod_comps : Array[@spice.Component] = []
      for comp in netlist.components {
        match comp {
          VSource(name, n1, n2, _) =>
            if name.to_lower() == src1.to_lower() {
              mod_comps.push(
                @spice.Component::create_dc_vsource(name, n1, n2, v1),
              )
            } else if name.to_lower() == src2.to_lower() {
              mod_comps.push(
                @spice.Component::create_dc_vsource(name, n1, n2, v2),
              )
            } else {
              mod_comps.push(comp)
            }
          _ => mod_comps.push(comp)
        }
      }

      let sub_netlist = @spice.Netlist::new(netlist.title + " (2D Sweep)")
      for c in mod_comps {
        sub_netlist.add_component(c)
      }

      let dc_res = solve_dc_op(sub_netlist)
      grid.push(DcSweep2DCell::{
        v1_val: v1,
        v2_val: v2,
        node_voltages: dc_res.node_voltages,
      })
      v2 = v2 + step2
    }
    v1 = v1 + step1
  }

  DcSweep2DResult::{ src1_name: src1, src2_name: src2, grid }
}
