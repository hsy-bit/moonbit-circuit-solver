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
/// Advanced BSIM4 Nanometer MOSFET Parameters.
pub struct Bsim4ExtendedParams {
  vth0 : Double // Long-channel threshold voltage (V)
  k1 : Double // First-order body effect (V^0.5)
  k2 : Double // Second-order body effect
  dvt0 : Double // Short-channel threshold reduction coefficient
  dvt1 : Double // Short-channel exponent coefficient
  eta0 : Double // DIBL coefficient in subthreshold
  etab : Double // Body bias coefficient for DIBL
  u0 : Double // Low-field mobility (cm^2 / V*s)
  ua : Double // First-order mobility degradation (m/V)
  ub : Double // Second-order mobility degradation (m/V)^2
  vsat : Double // Saturation velocity (m/s)
  tox : Double // Gate oxide physical thickness (m)
  w : Double // Channel width (m)
  l : Double // Channel length (m)
} derive(Eq, Debug)

///|
/// Standard 28nm Low-Power (LP) NMOS BSIM4 parameter set.
pub fn Bsim4ExtendedParams::default_28nm() -> Bsim4ExtendedParams {
  {
    vth0: 0.35,
    k1: 0.45,
    k2: 0.02,
    dvt0: 2.2,
    dvt1: 0.53,
    eta0: 0.08,
    etab: -0.07,
    u0: 280.0,
    ua: 1.0e-9,
    ub: 1.2e-18,
    vsat: 1.0e5,
    tox: 1.2e-9, // 1.2 nm high-k oxide
    w: 1.0e-6,
    l: 28.0e-9,
  }
}

///|
/// BSIM4 Companion Calculation Output.
pub struct Bsim4ExtendedCompanion {
  vth_eff : Double // Effective threshold voltage including DIBL and body effect
  id : Double // Total drain current
  gm : Double // Transconductance dId/dVg
  gds : Double // Output conductance dId/dVd
  isub : Double // Substrate impact ionization current
} derive(Eq, Debug)

///|
/// Evaluates BSIM4 short-channel effects, DIBL, and impact ionization.
pub fn evaluate_bsim4_extended(
  p : Bsim4ExtendedParams,
  vgs : Double,
  vds : Double,
  vbs : Double,
) -> Bsim4ExtendedCompanion {
  let vds_pos = if vds > 0.0 { vds } else { 0.0 }
  let vbs_clamped = if vbs < 0.0 { vbs } else { 0.0 }

  // 1. Body Effect Delta Vth
  let phi_s = 0.70
  let body_sqrt = (phi_s - vbs_clamped).sqrt() - phi_s.sqrt()
  let delta_vth_body = p.k1 * body_sqrt - p.k2 * vbs_clamped

  // 2. DIBL Effect Delta Vth
  let dibl_factor = p.eta0 + p.etab * vbs_clamped
  let delta_vth_dibl = -dibl_factor * vds_pos

  // Effective threshold voltage
  let vth_eff = p.vth0 + delta_vth_body + delta_vth_dibl

  // 3. Effective Gate Overdrive
  let v_gst = vgs - vth_eff
  let (id, gm, gds) = if v_gst > 0.0 {
    // Strong Inversion
    let eps_ox = 3.9 * 8.854e-12
    let cox = eps_ox / p.tox
    let beta = p.u0 * 1.0e-4 * cox * (p.w / p.l)

    let vdsat = v_gst *
      (p.vsat * p.l) /
      (v_gst + p.vsat * p.l / (p.u0 * 1.0e-4))
    let safe_vdsat = if vdsat > 0.01 { vdsat } else { 0.01 }

    if vds_pos < safe_vdsat {
      // Linear Region
      let curr = beta * (v_gst * vds_pos - 0.5 * vds_pos * vds_pos)
      let trans_gm = beta * vds_pos
      let out_gds = beta * (v_gst - vds_pos)
      (curr, trans_gm, out_gds)
    } else {
      // Saturation Region with Early modulation
      let lambda_clm = 0.05
      let curr_sat = 0.5 *
        beta *
        safe_vdsat *
        safe_vdsat *
        (1.0 + lambda_clm * (vds_pos - safe_vdsat))
      let trans_gm = beta * safe_vdsat
      let out_gds = lambda_clm * curr_sat
      (curr_sat, trans_gm, out_gds)
    }
  } else {
    // Subthreshold Region: Exponential conduction
    let ut = 0.02585
    let n_sub = 1.35
    let isub_leak = 1.0e-15 * @math.exp(v_gst / (n_sub * ut))
    (isub_leak, isub_leak / (n_sub * ut), 1.0e-12)
  }

  // 4. Substrate Body Impact Ionization Current
  let vds_over_sat = if vds_pos > 0.8 { vds_pos - 0.8 } else { 0.0 }
  let isub = if vds_over_sat > 0.0 {
    id * 0.02 * @math.exp(-2.0 / vds_over_sat)
  } else {
    0.0
  }

  { vth_eff, id, gm, gds, isub }
}
