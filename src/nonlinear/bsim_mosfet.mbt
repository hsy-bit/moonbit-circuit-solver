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
/// MOSFET Operating Regime.
pub enum AdvancedMosfetRegion {
  CutoffRegion
  SubthresholdRegion
  TriodeLinearRegion
  SaturationVelocitySatRegion
} derive(Eq, Debug)

///|
/// Parameters for Advanced Short-Channel MOSFET model (Level 3 / BSIM-like).
pub struct AdvancedMosfetParams {
  vto : Double // Zero-bias threshold voltage (V)
  kp : Double // Transconductance parameter mu * Cox (A/V^2)
  gamma : Double // Bulk threshold parameter (V^0.5)
  phi : Double // Surface inversion potential 2*phi_F (V)
  lambda_val : Double // Channel length modulation parameter (1/V)
  theta : Double // Mobility degradation coefficient (1/V)
  eta : Double // DIBL (Drain Induced Barrier Lowering) coefficient
  tox : Double // Gate oxide thickness (m)
  w : Double // Channel width (m)
  l : Double // Channel length (m)
  cgso : Double // Gate-source overlap capacitance (F/m)
  cgdo : Double // Gate-drain overlap capacitance (F/m)
  cgbo : Double // Gate-bulk overlap capacitance (F/m)
  is_nmos : Bool // True for NMOS, False for PMOS
} derive(Eq, Debug)

///|
/// Standard 0.18um NMOS default parameter set.
pub fn AdvancedMosfetParams::default_nmos() -> AdvancedMosfetParams {
  {
    vto: 0.5,
    kp: 150.0e-6,
    gamma: 0.4,
    phi: 0.7,
    lambda_val: 0.05,
    theta: 0.05,
    eta: 0.02,
    tox: 4.0e-9,
    w: 10.0e-6,
    l: 0.18e-6,
    cgso: 0.2e-9,
    cgdo: 0.2e-9,
    cgbo: 0.1e-9,
    is_nmos: true,
  }
}

///|
/// Standard 0.18um PMOS default parameter set.
pub fn AdvancedMosfetParams::default_pmos() -> AdvancedMosfetParams {
  {
    vto: -0.5,
    kp: 50.0e-6,
    gamma: 0.45,
    phi: 0.7,
    lambda_val: 0.08,
    theta: 0.06,
    eta: 0.03,
    tox: 4.0e-9,
    w: 20.0e-6,
    l: 0.18e-6,
    cgso: 0.2e-9,
    cgdo: 0.2e-9,
    cgbo: 0.1e-9,
    is_nmos: false,
  }
}

///|
/// Linearized companion model outputs for Advanced MOSFET.
pub struct AdvancedMosfetCompanion {
  vgs : Double
  vds : Double
  vbs : Double
  ids : Double
  gm : Double // d(Ids) / d(Vgs) transconductance
  gds : Double // d(Ids) / d(Vds) channel conductance
  gmb : Double // d(Ids) / d(Vbs) body transconductance
  cgs : Double // Total gate-source capacitance
  cgd : Double // Total gate-drain capacitance
  cgb : Double // Total gate-bulk capacitance
  ieq : Double // Linearized RHS current: Ieq = Ids - gm*Vgs - gds*Vds - gmb*Vbs
  region : AdvancedMosfetRegion
} derive(Eq, Debug)

///|
/// Evaluates Advanced MOSFET Level 3 / BSIM companion at given terminal voltages.
pub fn evaluate_advanced_mosfet(
  p : AdvancedMosfetParams,
  vgs_in : Double,
  vds_in : Double,
  vbs_in : Double,
  vt : Double,
) -> AdvancedMosfetCompanion {
  let polarity = if p.is_nmos { 1.0 } else { -1.0 }
  let mut vgs = vgs_in * polarity
  let mut vds = vds_in * polarity
  let mut vbs = vbs_in * polarity

  // Source-drain symmetry check: if Vds < 0, swap source and drain
  let is_reversed = vds < 0.0
  if is_reversed {
    vds = -vds
    vgs = vgs + vds
    vbs = vbs + vds
  }

  // Effective substrate bias
  let vbs_eff = if vbs > 0.0 { 0.0 } else { vbs }

  // Body effect threshold shift: Vth = Vto + gamma * (sqrt(phi - Vbs) - sqrt(phi)) - eta * Vds
  let phi_vbs = p.phi - vbs_eff
  let sqrt_phi_vbs = if phi_vbs > 0.0 { phi_vbs.sqrt() } else { 0.0 }
  let sqrt_phi = if p.phi > 0.0 { p.phi.sqrt() } else { 0.0 }
  let vth = p.vto * polarity + p.gamma * (sqrt_phi_vbs - sqrt_phi) - p.eta * vds

  // Overdrive voltage Vov = Vgs - Vth
  let vov = vgs - vth
  let beta_eff = p.kp *
    p.w /
    p.l /
    (1.0 + p.theta * (if vov > 0.0 { vov } else { 0.0 }))

  let mut ids = 0.0
  let mut gm = 0.0
  let mut gds = 0.0
  let mut gmb = 0.0
  let mut region = CutoffRegion

  // Oxide capacitance Cox
  let eps_ox = 3.9 * 8.854e-12
  let cox_total = eps_ox / p.tox * p.w * p.l

  let mut cgs_val = p.cgso * p.w
  let mut cgd_val = p.cgdo * p.w
  let mut cgb_val = p.cgbo * p.l

  if vov <= 0.0 {
    // Subthreshold / Weak Inversion regime: exponential current
    let n_sub = 1.0 +
      p.gamma / (2.0 * (if sqrt_phi_vbs > 0.1 { sqrt_phi_vbs } else { 0.1 }))
    let exp_arg = vov / (n_sub * vt)
    let safe_exp = @math.exp(if exp_arg < -40.0 { -40.0 } else { exp_arg })
    let i0 = beta_eff * (n_sub * vt) * (n_sub * vt)
    ids = i0 *
      safe_exp *
      (1.0 - @math.exp(if -vds / vt < -40.0 { -40.0 } else { -vds / vt }))
    gm = ids / (n_sub * vt)
    gds = ids * p.lambda_val + 1.0e-12
    gmb = gm *
      (p.gamma / (2.0 * (if sqrt_phi_vbs > 0.1 { sqrt_phi_vbs } else { 0.1 })))
    region = SubthresholdRegion
    cgb_val = cgb_val + cox_total
  } else {
    // Strong Inversion: Linear vs Saturation
    let vdsat = vov / (1.0 + (if p.theta > 0.0 { p.theta * vov } else { 0.0 }))

    if vds < vdsat {
      // Triode / Linear Region
      region = TriodeLinearRegion
      let factor = 1.0 + p.lambda_val * vds
      ids = beta_eff * (vov * vds - 0.5 * vds * vds) * factor
      gm = beta_eff * vds * factor
      gds = beta_eff * (vov - vds) * factor + ids * p.lambda_val
      gmb = gm *
        (
          p.gamma /
          (2.0 * (if sqrt_phi_vbs > 0.1 { sqrt_phi_vbs } else { 0.1 }))
        )

      // Meyer capacitances in Triode
      cgs_val = cgs_val +
        0.5 *
        cox_total *
        (1.0 - (vdsat - vds) * (vdsat - vds) / (3.0 * (vdsat + 1.0e-6)))
      cgd_val = cgd_val +
        0.5 * cox_total * (1.0 - vds / (3.0 * (vdsat + 1.0e-6)))
    } else {
      // Saturation / Velocity Saturation Region
      region = SaturationVelocitySatRegion
      let factor = 1.0 + p.lambda_val * (vds - vdsat)
      ids = 0.5 * beta_eff * (vdsat * vdsat) * factor
      gm = beta_eff * vdsat * factor
      gds = ids * p.lambda_val
      gmb = gm *
        (
          p.gamma /
          (2.0 * (if sqrt_phi_vbs > 0.1 { sqrt_phi_vbs } else { 0.1 }))
        )

      // Meyer capacitances in Saturation
      cgs_val = cgs_val + 2.0 / 3.0 * cox_total
      cgd_val = cgd_val + 0.0
    }
  }

  // Restore polarity
  ids = ids * polarity
  let ieq = ids - gm * vgs_in - gds * vds_in - gmb * vbs_in

  {
    vgs: vgs_in,
    vds: vds_in,
    vbs: vbs_in,
    ids,
    gm,
    gds,
    gmb,
    cgs: cgs_val,
    cgd: cgd_val,
    cgb: cgb_val,
    ieq,
    region,
  }
}

///|
/// Stamps 4-terminal Advanced MOSFET companion into MNA matrix and RHS vector.
pub fn stamp_advanced_mosfet_companion(
  a_mat : @linalg.Matrix,
  z_vec : @linalg.Vector,
  n_d : Int,
  n_g : Int,
  n_s : Int,
  n_b : Int,
  comp : AdvancedMosfetCompanion,
) -> Unit {
  let gm = comp.gm
  let gds = comp.gds
  let gmb = comp.gmb

  // Drain node stamping: Id = gm*(Vg - Vs) + gds*(Vd - Vs) + gmb*(Vb - Vs)
  @mna.stamp_matrix_entry(a_mat, n_d, n_d, gds)
  @mna.stamp_matrix_entry(a_mat, n_d, n_g, gm)
  @mna.stamp_matrix_entry(a_mat, n_d, n_s, -(gm + gds + gmb))
  @mna.stamp_matrix_entry(a_mat, n_d, n_b, gmb)

  // Source node stamping: Is = -Id
  @mna.stamp_matrix_entry(a_mat, n_s, n_s, gm + gds + gmb)
  @mna.stamp_matrix_entry(a_mat, n_s, n_d, -gds)
  @mna.stamp_matrix_entry(a_mat, n_s, n_g, -gm)
  @mna.stamp_matrix_entry(a_mat, n_s, n_b, -gmb)

  // RHS currents
  @mna.stamp_vector_entry(z_vec, n_d, -comp.ieq)
  @mna.stamp_vector_entry(z_vec, n_s, comp.ieq)
}
