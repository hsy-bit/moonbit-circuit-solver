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
/// JFET Operating Region.
pub enum JfetRegion {
  JfetCutoff
  JfetLinear
  JfetSaturation
} derive(Eq, Debug)

///|
/// JFET Device Parameters.
pub struct JfetParams {
  vto : Double // Pinch-off / Threshold voltage (V, negative for NJFET, positive for PJFET)
  beta_val : Double // Transconductance parameter (A/V^2)
  lambda_val : Double // Channel length modulation (1/V)
  is_gate : Double // Gate junction saturation current (A)
  cgs0 : Double // Zero-bias G-S junction capacitance (F)
  cgd0 : Double // Zero-bias G-D junction capacitance (F)
  pb : Double // Gate junction potential (V)
  is_n_channel : Bool // True for N-channel JFET (2N5457, BF245), False for P-channel (2N5460)
} derive(Eq, Debug)

///|
/// Default 2N5457-like N-channel JFET parameters.
pub fn JfetParams::default_njfet() -> JfetParams {
  {
    vto: -2.0,
    beta_val: 1.2e-3,
    lambda_val: 0.01,
    is_gate: 1.0e-14,
    cgs0: 5.0e-12,
    cgd0: 4.0e-12,
    pb: 0.75,
    is_n_channel: true,
  }
}

///|
/// Default 2N5460-like P-channel JFET parameters.
pub fn JfetParams::default_pjfet() -> JfetParams {
  {
    vto: 2.0,
    beta_val: 1.0e-3,
    lambda_val: 0.015,
    is_gate: 1.0e-14,
    cgs0: 6.0e-12,
    cgd0: 5.0e-12,
    pb: 0.75,
    is_n_channel: false,
  }
}

///|
/// Linearized JFET companion model output.
pub struct JfetCompanion {
  vgs : Double
  vds : Double
  ids : Double
  ig : Double
  gm : Double // d(Ids) / d(Vgs)
  gds : Double // d(Ids) / d(Vds)
  ggs : Double // Gate-Source diode conductance
  ggd : Double // Gate-Drain diode conductance
  cgs : Double // Total G-S capacitance
  cgd : Double // Total G-D capacitance
  ieq_d : Double // RHS equivalent current at drain
  ieq_g : Double // RHS equivalent current at gate
  region : JfetRegion
} derive(Eq, Debug)

///|
/// Evaluates JFET companion model at given junction voltages Vgs and Vds.
pub fn evaluate_jfet(
  p : JfetParams,
  vgs_in : Double,
  vds_in : Double,
  vt : Double,
) -> JfetCompanion {
  let polarity = if p.is_n_channel { 1.0 } else { -1.0 }
  let mut vgs = vgs_in * polarity
  let mut vds = vds_in * polarity
  let vto = p.vto * polarity

  // Symmetry handling if Vds < 0
  let is_reversed = vds < 0.0
  if is_reversed {
    vds = -vds
    vgs = vgs + vds
  }

  let mut ids = 0.0
  let mut gm = 0.0
  let mut gds = 0.0
  let mut region = JfetCutoff

  let vgst = vgs - vto

  if vgst <= 0.0 {
    // Cutoff regime
    ids = 0.0
    gm = 0.0
    gds = 1.0e-12
    region = JfetCutoff
  } else if vds < vgst {
    // Linear / Triode regime: Ids = beta * (2*vgst*vds - vds^2) * (1 + lambda*vds)
    region = JfetLinear
    let factor = 1.0 + p.lambda_val * vds
    ids = p.beta_val * (2.0 * vgst * vds - vds * vds) * factor
    gm = 2.0 * p.beta_val * vds * factor
    gds = 2.0 * p.beta_val * (vgst - vds) * factor +
      ids * p.lambda_val +
      1.0e-12
  } else {
    // Saturation / Pinch-off regime: Ids = beta * vgst^2 * (1 + lambda*vds)
    region = JfetSaturation
    let factor = 1.0 + p.lambda_val * vds
    ids = p.beta_val * (vgst * vgst) * factor
    gm = 2.0 * p.beta_val * vgst * factor
    gds = ids * p.lambda_val + 1.0e-12
  }

  // Gate junction diode leakage evaluation: Vgs and Vgd
  let exp_vgs = @math.exp(
    if vgs / vt > 30.0 {
      30.0
    } else if vgs / vt < -30.0 {
      -30.0
    } else {
      vgs / vt
    },
  )
  let igs = p.is_gate * (exp_vgs - 1.0)
  let ggs = p.is_gate * exp_vgs / vt + 1.0e-12

  let vgd = vgs - vds
  let exp_vgd = @math.exp(
    if vgd / vt > 30.0 {
      30.0
    } else if vgd / vt < -30.0 {
      -30.0
    } else {
      vgd / vt
    },
  )
  let igd = p.is_gate * (exp_vgd - 1.0)
  let ggd = p.is_gate * exp_vgd / vt + 1.0e-12

  let ig = (igs + igd) * polarity
  ids = ids * polarity

  // Gate junction capacitances
  let cgs = if vgs < 0.5 * p.pb {
    p.cgs0 / @math.pow(1.0 - vgs / p.pb, 0.5)
  } else {
    p.cgs0 * 2.0
  }

  let cgd = if vgd < 0.5 * p.pb {
    p.cgd0 / @math.pow(1.0 - vgd / p.pb, 0.5)
  } else {
    p.cgd0 * 2.0
  }

  let ieq_d = ids - gm * vgs_in - gds * vds_in
  let ieq_g = ig - ggs * vgs_in - ggd * (vgs_in - vds_in)

  {
    vgs: vgs_in,
    vds: vds_in,
    ids,
    ig,
    gm,
    gds,
    ggs,
    ggd,
    cgs,
    cgd,
    ieq_d,
    ieq_g,
    region,
  }
}

///|
/// Stamps 3-terminal JFET companion into MNA matrix and RHS vector.
pub fn stamp_jfet_companion(
  a_mat : @linalg.Matrix,
  z_vec : @linalg.Vector,
  n_d : Int,
  n_g : Int,
  n_s : Int,
  comp : JfetCompanion,
) -> Unit {
  let gm = comp.gm
  let gds = comp.gds
  let ggs = comp.ggs
  let ggd = comp.ggd

  // Drain node stamping
  @mna.stamp_matrix_entry(a_mat, n_d, n_d, gds + ggd)
  @mna.stamp_matrix_entry(a_mat, n_d, n_g, gm - ggd)
  @mna.stamp_matrix_entry(a_mat, n_d, n_s, -(gm + gds))

  // Gate node stamping
  @mna.stamp_matrix_entry(a_mat, n_g, n_g, ggs + ggd)
  @mna.stamp_matrix_entry(a_mat, n_g, n_s, -ggs)
  @mna.stamp_matrix_entry(a_mat, n_g, n_d, -ggd)

  // Source node stamping
  @mna.stamp_matrix_entry(a_mat, n_s, n_s, gm + gds + ggs)
  @mna.stamp_matrix_entry(a_mat, n_s, n_d, -gds)
  @mna.stamp_matrix_entry(a_mat, n_s, n_g, -(gm + ggs))

  // RHS currents
  @mna.stamp_vector_entry(z_vec, n_d, -comp.ieq_d)
  @mna.stamp_vector_entry(z_vec, n_g, -comp.ieq_g)
  @mna.stamp_vector_entry(z_vec, n_s, comp.ieq_d + comp.ieq_g)
}
