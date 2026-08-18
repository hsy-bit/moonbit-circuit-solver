// Non-linear Semiconductor Models - Shockley Diode Model
// MoonBit Circuit Solver Engine

///|
/// Represents the linearized companion model of a diode at operating voltage Vd.
pub struct DiodeCompanion {
  vd : Double
  id : Double
  gd : Double
  ieq : Double
} derive(Debug, Eq)

///|
/// Voltage limiting for diode junction to prevent numerical overflow in exp().
pub fn pnjlim(
  v_new : Double,
  v_old : Double,
  vt : Double,
  vcrit : Double,
) -> Double {
  if v_new > vcrit && (v_new - v_old).abs() > 2.0 * vt {
    if v_old > 0.0 {
      let arg = 1.0 + (v_new - v_old) / vt
      if arg > 0.0 {
        v_old + vt * (@math.log10(arg) * 2.302585092994046)
      } else {
        vcrit
      }
    } else {
      vt * (@math.log10(v_new / vt) * 2.302585092994046)
    }
  } else {
    v_new
  }
}

///|
/// Evaluates Shockley diode model and returns linearized companion model (gd, ieq).
pub fn evaluate_diode(
  vd : Double,
  is_val : Double,
  n_val : Double,
  vt_val : Double,
) -> DiodeCompanion {
  let nv_t = n_val * vt_val
  let exp_arg = vd / nv_t
  // Clamp exponent to avoid floating point overflow
  let safe_exp_arg = if exp_arg > 40.0 {
    40.0
  } else if exp_arg < -40.0 {
    -40.0
  } else {
    exp_arg
  }

  let exp_val = @math.exp(safe_exp_arg)
  let id = is_val * (exp_val - 1.0)
  let gd = is_val * exp_val / nv_t
  let ieq = id - gd * vd

  DiodeCompanion::{ vd, id, gd, ieq }
}

///|
/// Stamps linearized diode companion model into MNA matrix and RHS vector.
pub fn stamp_diode_companion(
  a_mat : @linalg.Matrix,
  z_vec : @linalg.Vector,
  n1 : Int,
  n2 : Int,
  companion : DiodeCompanion,
) -> Unit {
  let g = companion.gd
  let ieq = companion.ieq
  @mna.stamp_matrix_entry(a_mat, n1, n1, g)
  @mna.stamp_matrix_entry(a_mat, n2, n2, g)
  @mna.stamp_matrix_entry(a_mat, n1, n2, -g)
  @mna.stamp_matrix_entry(a_mat, n2, n1, -g)

  @mna.stamp_vector_entry(z_vec, n1, -ieq)
  @mna.stamp_vector_entry(z_vec, n2, ieq)
}
