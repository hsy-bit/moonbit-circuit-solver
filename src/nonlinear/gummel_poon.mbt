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
/// Comprehensive Gummel-Poon BJT Model Parameters.
pub struct GummelPoonParams {
  is_val : Double // Transport saturation current (A)
  bf : Double // Ideal maximum forward beta
  br : Double // Ideal maximum reverse beta
  vaf : Double // Forward Early voltage (V, 0 = infinite)
  va_r : Double // Reverse Early voltage (V, 0 = infinite)
  ikf : Double // Corner for forward beta high-current roll-off (A, 0 = infinite)
  ikr : Double // Corner for reverse beta high-current roll-off (A, 0 = infinite)
  ise : Double // Base-emitter leakage saturation current (A)
  ne : Double // Base-emitter leakage emission coefficient
  isc : Double // Base-collector leakage saturation current (A)
  nc : Double // Base-collector leakage emission coefficient
  rb : Double // Zero-bias base resistance (Ohms)
  rc : Double // Collector series resistance (Ohms)
  re : Double // Emitter series resistance (Ohms)
  cje : Double // Zero-bias B-E depletion capacitance (F)
  vje : Double // B-E built-in potential (V)
  mje : Double // B-E junction grading coefficient
  cjc : Double // Zero-bias B-C depletion capacitance (F)
  vjc : Double // B-C built-in potential (V)
  mjc : Double // B-C junction grading coefficient
  tf : Double // Ideal forward transit time (s)
  tr : Double // Ideal reverse transit time (s)
  is_npn : Bool // True for NPN, False for PNP
} derive(Eq, Debug)

///|
/// Returns standard default Gummel-Poon BJT parameters (e.g. 2N2222-like NPN).
pub fn GummelPoonParams::default_npn() -> GummelPoonParams {
  {
    is_val: 1.0e-14,
    bf: 200.0,
    br: 3.0,
    vaf: 100.0,
    va_r: 20.0,
    ikf: 0.2,
    ikr: 0.05,
    ise: 1.0e-15,
    ne: 1.5,
    isc: 1.0e-15,
    nc: 1.5,
    rb: 10.0,
    rc: 1.0,
    re: 0.1,
    cje: 25.0e-12,
    vje: 0.75,
    mje: 0.33,
    cjc: 8.0e-12,
    vjc: 0.75,
    mjc: 0.33,
    tf: 0.3e-9,
    tr: 6.0e-9,
    is_npn: true,
  }
}

///|
/// Returns standard default Gummel-Poon BJT parameters for PNP (e.g. 2N2907-like PNP).
pub fn GummelPoonParams::default_pnp() -> GummelPoonParams {
  let npn = GummelPoonParams::default_npn()
  {
    is_val: npn.is_val,
    bf: 150.0,
    br: 2.5,
    vaf: 80.0,
    va_r: 15.0,
    ikf: 0.15,
    ikr: 0.04,
    ise: npn.ise,
    ne: npn.ne,
    isc: npn.isc,
    nc: npn.nc,
    rb: npn.rb,
    rc: npn.rc,
    re: npn.re,
    cje: npn.cje,
    vje: npn.vje,
    mje: npn.mje,
    cjc: npn.cjc,
    vjc: npn.vjc,
    mjc: npn.mjc,
    tf: npn.tf,
    tr: npn.tr,
    is_npn: false,
  }
}

///|
/// Linearized Companion Operating Point for Gummel-Poon BJT Model.
pub struct GummelPoonCompanion {
  vbe : Double
  vbc : Double
  vce : Double
  ib : Double
  ic : Double
  ie : Double
  gpi : Double // d(Ib) / d(Vbe)
  gmu : Double // d(Ib) / d(Vbc)
  gm : Double // d(Ic) / d(Vbe) transconductance
  go : Double // d(Ic) / d(Vce) output conductance
  cbe_total : Double // Total B-E capacitance (depletion + diffusion)
  cbc_total : Double // Total B-C capacitance (depletion + diffusion)
  ieq_b : Double // Equivalent RHS current at base node
  ieq_c : Double // Equivalent RHS current at collector node
} derive(Eq, Debug)

///|
/// Evaluates the Gummel-Poon BJT model at given junction voltages Vbe and Vbc.
pub fn evaluate_gummel_poon(
  p : GummelPoonParams,
  vbe_in : Double,
  vbc_in : Double,
  vt : Double,
) -> GummelPoonCompanion {
  let polarity = if p.is_npn { 1.0 } else { -1.0 }
  let vbe = vbe_in * polarity
  let vbc = vbc_in * polarity

  // Safe exponential calculation for forward and reverse diode junctions
  let exp_vbe = @math.exp(
    if vbe / vt > 40.0 {
      40.0
    } else if vbe / vt < -40.0 {
      -40.0
    } else {
      vbe / vt
    },
  )
  let exp_vbc = @math.exp(
    if vbc / vt > 40.0 {
      40.0
    } else if vbc / vt < -40.0 {
      -40.0
    } else {
      vbc / vt
    },
  )

  // Ideal forward and reverse transport currents
  let if_ideal = p.is_val * (exp_vbe - 1.0)
  let ir_ideal = p.is_val * (exp_vbc - 1.0)

  // Early effect base pushout factors q1 and q2
  let q1 = 1.0 +
    (if p.vaf > 0.0 { vbc / p.vaf } else { 0.0 }) +
    (if p.va_r > 0.0 { vbe / p.va_r } else { 0.0 })
  let q2 = (if p.ikf > 0.0 { if_ideal / p.ikf } else { 0.0 }) +
    (if p.ikr > 0.0 { ir_ideal / p.ikr } else { 0.0 })
  let qb = if q2 > 0.0 {
    q1 / 2.0 * (1.0 + (1.0 + 4.0 * q2).sqrt())
  } else if q1 > 1.0e-4 {
    q1
  } else {
    1.0e-4
  }

  // Main collector transport current
  let ict = (if_ideal - ir_ideal) / qb

  // Base-emitter recombination current
  let exp_vbe_ne = @math.exp(
    if vbe / (p.ne * vt) > 40.0 {
      40.0
    } else if vbe / (p.ne * vt) < -40.0 {
      -40.0
    } else {
      vbe / (p.ne * vt)
    },
  )
  let ibe = if_ideal / p.bf + p.ise * (exp_vbe_ne - 1.0)

  // Base-collector recombination current
  let exp_vbc_nc = @math.exp(
    if vbc / (p.nc * vt) > 40.0 {
      40.0
    } else if vbc / (p.nc * vt) < -40.0 {
      -40.0
    } else {
      vbc / (p.nc * vt)
    },
  )
  let ibc = ir_ideal / p.br + p.isc * (exp_vbc_nc - 1.0)

  // Terminal currents
  let ic_val = (ict - ibc) * polarity
  let ib_val = (ibe + ibc) * polarity
  let ie_val = -(ic_val + ib_val)

  // Conductances (derivatives)
  let gm_raw = p.is_val * exp_vbe / (vt * qb)
  let go_raw = if p.vaf > 0.0 { if_ideal / (qb * p.vaf) } else { 1.0e-6 }
  let gpi_raw = p.is_val * exp_vbe / (p.bf * vt) +
    p.ise * exp_vbe_ne / (p.ne * vt)
  let gmu_raw = p.is_val * exp_vbc / (p.br * vt) +
    p.isc * exp_vbc_nc / (p.nc * vt)

  let gm = if gm_raw < 1.0e-12 { 1.0e-12 } else { gm_raw }
  let go = if go_raw < 1.0e-12 { 1.0e-12 } else { go_raw }
  let gpi = if gpi_raw < 1.0e-12 { 1.0e-12 } else { gpi_raw }
  let gmu = if gmu_raw < 1.0e-12 { 1.0e-12 } else { gmu_raw }

  // Depletion and diffusion capacitances
  let cje_dep = if vbe < 0.5 * p.vje {
    p.cje / @math.pow(1.0 - vbe / p.vje, p.mje)
  } else {
    p.cje * 2.0
  }
  let cbe_diff = p.tf * gm_raw
  let cbe_total = cje_dep + cbe_diff

  let cjc_dep = if vbc < 0.5 * p.vjc {
    p.cjc / @math.pow(1.0 - vbc / p.vjc, p.mjc)
  } else {
    p.cjc * 2.0
  }
  let cbc_diff = p.tr * (p.is_val * exp_vbc / (vt * qb))
  let cbc_total = cjc_dep + cbc_diff

  // Equivalent linearized RHS currents for Newton-Raphson
  let ieq_b = ib_val - gpi * vbe_in - gmu * vbc_in
  let ieq_c = ic_val - gm * vbe_in - go * (vbe_in - vbc_in)

  {
    vbe: vbe_in,
    vbc: vbc_in,
    vce: vbe_in - vbc_in,
    ib: ib_val,
    ic: ic_val,
    ie: ie_val,
    gpi,
    gmu,
    gm,
    go,
    cbe_total,
    cbc_total,
    ieq_b,
    ieq_c,
  }
}

///|
/// Stamps Gummel-Poon BJT companion into MNA matrix and RHS vector.
pub fn stamp_gummel_poon_companion(
  a_mat : @linalg.Matrix,
  z_vec : @linalg.Vector,
  n_c : Int,
  n_b : Int,
  n_e : Int,
  comp : GummelPoonCompanion,
) -> Unit {
  let gm = comp.gm
  let go = comp.go
  let gpi = comp.gpi
  let gmu = comp.gmu

  // Base node stamping: Ib = gpi*(Vb - Ve) + gmu*(Vb - Vc)
  @mna.stamp_matrix_entry(a_mat, n_b, n_b, gpi + gmu)
  @mna.stamp_matrix_entry(a_mat, n_b, n_e, -gpi)
  @mna.stamp_matrix_entry(a_mat, n_b, n_c, -gmu)

  // Collector node stamping: Ic = gm*(Vb - Ve) + go*(Vc - Ve) - gmu*(Vb - Vc)
  @mna.stamp_matrix_entry(a_mat, n_c, n_c, go + gmu)
  @mna.stamp_matrix_entry(a_mat, n_c, n_e, -(gm + go))
  @mna.stamp_matrix_entry(a_mat, n_c, n_b, gm - gmu)

  // Emitter node stamping: Ie = -(Ib + Ic)
  @mna.stamp_matrix_entry(a_mat, n_e, n_e, gpi + gm + go)
  @mna.stamp_matrix_entry(a_mat, n_e, n_b, -(gpi + gm))
  @mna.stamp_matrix_entry(a_mat, n_e, n_c, -go)

  // RHS equivalent currents
  @mna.stamp_vector_entry(z_vec, n_b, -comp.ieq_b)
  @mna.stamp_vector_entry(z_vec, n_c, -comp.ieq_c)
  @mna.stamp_vector_entry(z_vec, n_e, comp.ieq_b + comp.ieq_c)
}
