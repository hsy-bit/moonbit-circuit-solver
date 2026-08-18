// Non-linear Semiconductor Models - Shichman-Hodges LEVEL 1 MOSFET Model
// MoonBit Circuit Solver Engine

/// Operating region of MOSFET transistor.
pub enum MosfetRegion {
  Cutoff
  Linear
  Saturation
} derive(Debug, Eq)

/// Linearized companion model for MOSFET (NMOS/PMOS).
pub struct MosfetCompanion {
  vgs : Double
  vds : Double
  ids : Double
  gm : Double
  gds : Double
  ieq : Double
  region : MosfetRegion
} derive(Debug, Eq)

/// Evaluates Shichman-Hodges LEVEL 1 MOSFET model.
pub fn evaluate_mosfet(vgs : Double, vds : Double, vth : Double, kp : Double, lambda : Double, is_nmos : Bool) -> MosfetCompanion {
  let s = if is_nmos { 1.0 } else { -1.0 }
  let vgs_eff = s * vgs
  let vds_eff = s * vds

  if vgs_eff <= vth {
    // Cutoff region
    MosfetCompanion::{ vgs, vds, ids: 0.0, gm: 0.0, gds: 0.0, ieq: 0.0, region: Cutoff }
  } else {
    let vov = vgs_eff - vth
    if vds_eff < vov {
      // Linear region
      let ids = kp * (vov * vds_eff - 0.5 * vds_eff * vds_eff) * (1.0 + lambda * vds_eff)
      let gm = kp * vds_eff * (1.0 + lambda * vds_eff)
      let gds = kp * (vov - vds_eff) * (1.0 + lambda * vds_eff) + kp * (vov * vds_eff - 0.5 * vds_eff * vds_eff) * lambda
      let ieq = ids - gm * vgs_eff - gds * vds_eff
      MosfetCompanion::{ vgs, vds, ids, gm, gds, ieq, region: Linear }
    } else {
      // Saturation region
      let ids = 0.5 * kp * vov * vov * (1.0 + lambda * vds_eff)
      let gm = kp * vov * (1.0 + lambda * vds_eff)
      let gds = 0.5 * kp * vov * vov * lambda
      let ieq = ids - gm * vgs_eff - gds * vds_eff
      MosfetCompanion::{ vgs, vds, ids, gm, gds, ieq, region: Saturation }
    }
  }
}

/// Stamps MOSFET companion model into MNA system.
pub fn stamp_mosfet_companion(a_mat : @linalg.Matrix, z_vec : @linalg.Vector, d : Int, g : Int, s : Int, companion : MosfetCompanion) -> Unit {
  let gm = companion.gm
  let gds = companion.gds

  // Drain node
  @mna.stamp_matrix_entry(a_mat, d, g, gm)
  @mna.stamp_matrix_entry(a_mat, d, s, -gm - gds)
  @mna.stamp_matrix_entry(a_mat, d, d, gds)

  // Source node
  @mna.stamp_matrix_entry(a_mat, s, g, -gm)
  @mna.stamp_matrix_entry(a_mat, s, s, gm + gds)
  @mna.stamp_matrix_entry(a_mat, s, d, -gds)

  @mna.stamp_vector_entry(z_vec, d, -companion.ieq)
  @mna.stamp_vector_entry(z_vec, s, companion.ieq)
}
