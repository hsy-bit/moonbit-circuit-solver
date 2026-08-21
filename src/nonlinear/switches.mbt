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
/// Voltage-Controlled Switch (SPICE 'S' model) parameters.
pub struct VcSwitchParams {
  vt : Double // Threshold control voltage (V)
  vh : Double // Hysteresis / Transition smoothing voltage width (V)
  ron : Double // On resistance (Ohms)
  roff : Double // Off resistance (Ohms)
} derive(Eq, Debug)

///|
/// Default smooth VC switch parameters.
pub fn VcSwitchParams::default() -> VcSwitchParams {
  { vt: 2.5, vh: 0.2, ron: 0.01, roff: 1.0e8 }
}

///|
/// Linearized companion model for smooth Voltage-Controlled Switch.
pub struct VcSwitchCompanion {
  g_switch : Double // Conductance between switch terminals
  d_g_d_vc : Double // Derivative of conductance with respect to control voltage Vc
  i_switch : Double // Current flowing through switch
  ieq_s : Double // Linearized RHS current
} derive(Eq, Debug)

///|
/// Evaluates smooth tanh-based Voltage-Controlled Switch.
pub fn evaluate_vc_switch(
  p : VcSwitchParams,
  v_ctrl : Double,
  v_switch : Double,
) -> VcSwitchCompanion {
  let gon = 1.0 / (if p.ron > 1.0e-7 { p.ron } else { 1.0e-7 })
  let goff = 1.0 / (if p.roff > 1.0 { p.roff } else { 1.0 })
  let vh = if p.vh > 1.0e-4 { p.vh } else { 1.0e-4 }

  let u = (v_ctrl - p.vt) / vh
  // Clamp u for tanh stability
  let safe_u = if u > 20.0 { 20.0 } else if u < -20.0 { -20.0 } else { u }
  let tanh_u = @math.tanh(safe_u)

  // Smooth conductance: G = Goff + 0.5 * (Gon - Goff) * (1 + tanh(u))
  let g_switch = goff + 0.5 * (gon - goff) * (1.0 + tanh_u)

  // Derivative: dG/dVc = 0.5 * (Gon - Goff) * (1 - tanh(u)^2) / Vh
  let sech2_u = 1.0 - tanh_u * tanh_u
  let d_g_d_vc = 0.5 * (gon - goff) * sech2_u / vh

  let i_switch = g_switch * v_switch
  let ieq_s = i_switch - g_switch * v_switch - d_g_d_vc * v_switch * v_ctrl

  { g_switch, d_g_d_vc, i_switch, ieq_s }
}

///|
/// Stamps Voltage-Controlled Switch companion into MNA matrix and RHS vector.
pub fn stamp_vc_switch_companion(
  a_mat : @linalg.Matrix,
  z_vec : @linalg.Vector,
  n_pos : Int,
  n_neg : Int,
  n_cpos : Int,
  n_cneg : Int,
  v_switch : Double,
  comp : VcSwitchCompanion,
) -> Unit {
  let g = comp.g_switch
  let d_g = comp.d_g_d_vc * v_switch

  // Switch terminal self/mutual conductances
  @mna.stamp_matrix_entry(a_mat, n_pos, n_pos, g)
  @mna.stamp_matrix_entry(a_mat, n_neg, n_neg, g)
  @mna.stamp_matrix_entry(a_mat, n_pos, n_neg, -g)
  @mna.stamp_matrix_entry(a_mat, n_neg, n_pos, -g)

  // Transconductance from control nodes
  @mna.stamp_matrix_entry(a_mat, n_pos, n_cpos, d_g)
  @mna.stamp_matrix_entry(a_mat, n_pos, n_cneg, -d_g)
  @mna.stamp_matrix_entry(a_mat, n_neg, n_cpos, -d_g)
  @mna.stamp_matrix_entry(a_mat, n_neg, n_cneg, d_g)

  // RHS currents
  @mna.stamp_vector_entry(z_vec, n_pos, -comp.ieq_s)
  @mna.stamp_vector_entry(z_vec, n_neg, comp.ieq_s)
}
