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
/// Zener Diode Parameters.
pub struct ZenerParams {
  is_val : Double // Forward saturation current (A)
  n_val : Double // Emission coefficient
  vz : Double // Zener breakdown voltage (V, positive number, e.g. 5.1V)
  izk : Double // Zener knee current (A, e.g. 1mA)
  rz : Double // Dynamic Zener resistance (Ohms, e.g. 10 Ohms)
  cj0 : Double // Zero-bias capacitance (F)
} derive(Eq, Debug)

///|
/// Default 5.1V Zener diode parameters (e.g. 1N4733A).
pub fn ZenerParams::default_5v1() -> ZenerParams {
  { is_val: 1.0e-14, n_val: 1.0, vz: 5.1, izk: 1.0e-3, rz: 7.0, cj0: 50.0e-12 }
}

///|
/// Linearized Zener Diode companion model.
pub struct ZenerCompanion {
  vd : Double
  id : Double
  gd : Double
  ieq : Double
  is_breakdown : Bool
} derive(Eq, Debug)

///|
/// Evaluates Zener diode I-V characteristic with forward exponential and reverse breakdown.
pub fn evaluate_zener_diode(
  p : ZenerParams,
  vd : Double,
  vt : Double,
) -> ZenerCompanion {
  let nv_t = p.n_val * vt

  if vd >= -p.vz {
    // Forward / Reverse normal region
    let exp_arg = vd / nv_t
    let safe_arg = if exp_arg > 35.0 {
      35.0
    } else if exp_arg < -35.0 {
      -35.0
    } else {
      exp_arg
    }
    let exp_val = @math.exp(safe_arg)
    let id = p.is_val * (exp_val - 1.0)
    let gd = p.is_val * exp_val / nv_t + 1.0e-12
    let ieq = id - gd * vd
    { vd, id, gd, ieq, is_breakdown: false }
  } else {
    // Reverse Zener Breakdown region: Vd < -Vz
    let v_over = -vd - p.vz
    let g_break = 1.0 / (if p.rz > 0.0 { p.rz } else { 1.0 })
    let id = -(p.izk + g_break * v_over)
    let gd = g_break
    let ieq = id - gd * vd
    { vd, id, gd, ieq, is_breakdown: true }
  }
}

///|
/// Stamps Zener diode companion into MNA matrix and RHS vector.
pub fn stamp_zener_companion(
  a_mat : @linalg.Matrix,
  z_vec : @linalg.Vector,
  n_anode : Int,
  n_cathode : Int,
  comp : ZenerCompanion,
) -> Unit {
  let gd = comp.gd
  let ieq = comp.ieq

  @mna.stamp_matrix_entry(a_mat, n_anode, n_anode, gd)
  @mna.stamp_matrix_entry(a_mat, n_cathode, n_cathode, gd)
  @mna.stamp_matrix_entry(a_mat, n_anode, n_cathode, -gd)
  @mna.stamp_matrix_entry(a_mat, n_cathode, n_anode, -gd)

  @mna.stamp_vector_entry(z_vec, n_anode, -ieq)
  @mna.stamp_vector_entry(z_vec, n_cathode, ieq)
}
