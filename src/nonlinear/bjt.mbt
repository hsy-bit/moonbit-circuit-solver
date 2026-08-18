// Non-linear Semiconductor Models - Ebers-Moll BJT Model
// MoonBit Circuit Solver Engine

///|
/// Linearized companion model for BJT transistor (NPN/PNP).
pub struct BjtCompanion {
  vbe : Double
  vbc : Double
  ib : Double
  ic : Double
  gpi : Double
  gm : Double
  gmu : Double
  go : Double
  ieq_b : Double
  ieq_c : Double
} derive(Debug, Eq)

///|
/// Evaluates Ebers-Moll BJT transistor model.
pub fn evaluate_bjt(
  vbe : Double,
  vbc : Double,
  is_val : Double,
  bf : Double,
  br : Double,
  is_npn : Bool,
) -> BjtCompanion {
  let vt = 0.02585
  let s = if is_npn { 1.0 } else { -1.0 }

  let vbe_eff = s * vbe
  let vbc_eff = s * vbc

  let exp_be = @math.exp(vbe_eff / vt)
  let exp_bc = @math.exp(vbc_eff / vt)

  let if_curr = is_val * (exp_be - 1.0)
  let ir_curr = is_val * (exp_bc - 1.0)

  let ib = if_curr / bf + ir_curr / br
  let ic = if_curr - ir_curr * (1.0 + 1.0 / br)

  let gpi = is_val * exp_be / (bf * vt)
  let gm = is_val * exp_be / vt
  let gmu = is_val * exp_bc / (br * vt)
  let go = is_val * exp_bc / vt

  let ieq_b = ib - gpi * vbe_eff - gmu * vbc_eff
  let ieq_c = ic - (gm - gmu) * vbe_eff - (go + gmu) * vbc_eff

  BjtCompanion::{ vbe, vbc, ib, ic, gpi, gm, gmu, go, ieq_b, ieq_c }
}

///|
/// Stamps BJT companion model into MNA system.
pub fn stamp_bjt_companion(
  a_mat : @linalg.Matrix,
  z_vec : @linalg.Vector,
  c : Int,
  b : Int,
  e : Int,
  companion : BjtCompanion,
) -> Unit {
  let gpi = companion.gpi
  let gm = companion.gm
  let gmu = companion.gmu
  let go = companion.go

  // Base node equations
  @mna.stamp_matrix_entry(a_mat, b, b, gpi + gmu)
  @mna.stamp_matrix_entry(a_mat, b, e, -gpi)
  @mna.stamp_matrix_entry(a_mat, b, c, -gmu)

  // Collector node equations
  @mna.stamp_matrix_entry(a_mat, c, b, gm - gmu)
  @mna.stamp_matrix_entry(a_mat, c, e, -gm)
  @mna.stamp_matrix_entry(a_mat, c, c, gmu + go)

  // Emitter node equations
  @mna.stamp_matrix_entry(a_mat, e, b, -gpi - gm)
  @mna.stamp_matrix_entry(a_mat, e, e, gpi + gm)
  @mna.stamp_matrix_entry(a_mat, e, c, -go)

  @mna.stamp_vector_entry(z_vec, b, -companion.ieq_b)
  @mna.stamp_vector_entry(z_vec, c, -companion.ieq_c)
  @mna.stamp_vector_entry(z_vec, e, companion.ieq_b + companion.ieq_c)
}
