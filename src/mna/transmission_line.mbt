// Modified Nodal Analysis - RLGC Transmission Line Discretization
// MoonBit Circuit Solver Engine

///|
/// Represents RLGC Transmission Line parameters per unit length.
pub struct RlgcTransmissionLine {
  r_per_len : Double
  l_per_len : Double
  g_per_len : Double
  c_per_len : Double
  length : Double
  sections : Int
} derive(Debug, Eq)

///|
/// Creates a new RlgcTransmissionLine definition.
pub fn RlgcTransmissionLine::new(
  r_per_len : Double,
  l_per_len : Double,
  g_per_len : Double,
  c_per_len : Double,
  length : Double,
  sections : Int,
) -> RlgcTransmissionLine {
  RlgcTransmissionLine::{
    r_per_len,
    l_per_len,
    g_per_len,
    c_per_len,
    length,
    sections,
  }
}

///|
/// Synthesizes lumped LC/RLGC cascade subcircuit for transmission line simulation.
pub fn synthesize_tline_lumped_cascade(
  line : RlgcTransmissionLine,
  in_node : String,
  out_node : String,
  ground_node : String,
) -> Array[@spice.Component] {
  let comps : Array[@spice.Component] = []
  let n_sec = if line.sections < 1 { 1 } else { line.sections }
  let dx = line.length / n_sec.to_double()

  let r_sec = line.r_per_len * dx
  let l_sec = line.l_per_len * dx
  let g_sec = line.g_per_len * dx
  let c_sec = line.c_per_len * dx

  let mut prev_n = in_node
  for i = 1; i <= n_sec; i = i + 1 {
    let next_n = if i == n_sec {
      out_node
    } else {
      "tline_node_" + i.to_string()
    }
    let r_name = "R_tl_" + i.to_string()
    let l_name = "L_tl_" + i.to_string()
    let c_name = "C_tl_" + i.to_string()
    let g_name = "G_tl_" + i.to_string()

    if r_sec > 0.0 {
      let mid_n = "tline_mid_" + i.to_string()
      comps.push(
        @spice.Component::create_resistor(r_name, prev_n, mid_n, r_sec),
      )
      comps.push(
        @spice.Component::create_inductor(l_name, mid_n, next_n, l_sec),
      )
    } else {
      comps.push(
        @spice.Component::create_inductor(l_name, prev_n, next_n, l_sec),
      )
    }

    if c_sec > 0.0 {
      comps.push(
        @spice.Component::create_capacitor(c_name, next_n, ground_node, c_sec),
      )
    }
    if g_sec > 0.0 {
      comps.push(
        @spice.Component::create_resistor(
          g_name,
          next_n,
          ground_node,
          1.0 / g_sec,
        ),
      )
    }

    prev_n = next_n
  }

  comps
}
