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
/// EKV v2.6 Charge-Based MOSFET Model Parameters.
pub struct EkvMosfetParams {
  vto : Double // Long-channel threshold voltage (V)
  gamma : Double // Body effect parameter (V^0.5)
  phi : Double // Bulk Fermi potential (V)
  kp : Double // Transconductance parameter (A/V^2)
  theta : Double // Mobility reduction coefficient (1/V)
  lambda_ch : Double // Channel length modulation (1/V)
  w_width : Double // Channel width (m)
  l_length : Double // Channel length (m)
} derive(Eq, Debug)

///|
/// Default 0.18 um EKV NMOS parameters.
pub fn EkvMosfetParams::default_nmos() -> EkvMosfetParams {
  {
    vto: 0.45,
    gamma: 0.65,
    phi: 0.70,
    kp: 150.0e-6,
    theta: 0.05,
    lambda_ch: 0.02,
    w_width: 10.0e-6,
    l_length: 0.18e-6,
  }
}

///|
/// EKV Evaluation Result.
pub struct EkvCompanion {
  id : Double // Drain current
  gm : Double // Gate transconductance dId/dVg
  gms : Double // Source transconductance dId/dVs
  gds : Double // Drain output conductance dId/dVd
  q_gate : Double // Total gate charge
} derive(Eq, Debug)

///|
/// Evaluates EKV 2.6 continuous charge interpolation.
pub fn evaluate_ekv_mosfet(
  p : EkvMosfetParams,
  vg : Double,
  vd : Double,
  vs : Double,
  vb : Double,
) -> EkvCompanion {
  let ut = 0.02585
  let vgb = vg - vb
  let vdb = vd - vb
  let vsb = vs - vb

  // Pinch-off voltage Vp
  let vgb_eff = if vgb > 0.0 { vgb } else { 0.0 }
  let n_sub = 1.0 + p.gamma / (2.0 * (p.phi + vgb_eff).sqrt())
  let vp = (vgb - p.vto) / n_sub

  // Normalized forward and reverse drive terms
  let zf = (vp - vsb) / (2.0 * ut)
  let zr = (vp - vdb) / (2.0 * ut)

  let safe_zf = if zf > 30.0 { 30.0 } else if zf < -30.0 { -30.0 } else { zf }
  let safe_zr = if zr > 30.0 { 30.0 } else if zr < -30.0 { -30.0 } else { zr }

  let exp_zf = @math.exp(safe_zf)
  let exp_zr = @math.exp(safe_zr)

  let ln_f = @math.ln(1.0 + exp_zf)
  let ln_r = @math.ln(1.0 + exp_zr)

  let i_f = ln_f * ln_f
  let i_r = ln_r * ln_r

  // Specific current I_S = 2 * n * KP * (W/L) * U_T^2
  let w_over_l = p.w_width / p.l_length
  let i_spec = 2.0 * n_sub * p.kp * w_over_l * ut * ut

  let id_base = i_spec * (i_f - i_r)
  let id = id_base * (1.0 + p.lambda_ch * (vd - vs).abs())

  let gm = i_spec /
    (n_sub * ut) *
    (ln_f / (1.0 + 1.0 / exp_zf) - ln_r / (1.0 + 1.0 / exp_zr))
  let gms = i_spec / ut * (ln_f / (1.0 + 1.0 / exp_zf))
  let gds = p.lambda_ch * id_base.abs()

  let q_gate = p.w_width * p.l_length * 1.0e-15 * vgb

  { id, gm, gms, gds, q_gate }
}
