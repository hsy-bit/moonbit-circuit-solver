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
/// VBIC (Vertical Bipolar Inter-Company) Advanced BJT Parameters.
pub struct VbicBjtParams {
  is_val : Double // Transport saturation current (A)
  nf : Double // Forward emission coefficient
  nr : Double // Reverse emission coefficient
  bf : Double // Ideal forward current gain
  br : Double // Ideal reverse current gain
  vef : Double // Forward Early voltage (V)
  ver : Double // Reverse Early voltage (V)
  ikf : Double // High-injection forward knee current (A)
  ikr : Double // High-injection reverse knee current (A)
  rci : Double // Intrinsic collector epilayer resistance (Ohms)
  vo : Double // Epilayer drift saturation voltage (V)
  gamm : Double // Epilayer doping parameter
  rth : Double // Thermal resistance (°C/W)
  cth : Double // Thermal capacitance (J/°C)
} derive(Eq, Debug)

///|
/// Standard VBIC parameter set for RF SiGe HBT.
pub fn VbicBjtParams::default_sige() -> VbicBjtParams {
  {
    is_val: 1.0e-16,
    nf: 1.0,
    nr: 1.0,
    bf: 350.0,
    br: 10.0,
    vef: 80.0,
    ver: 15.0,
    ikf: 0.05,
    ikr: 0.01,
    rci: 25.0,
    vo: 1.5,
    gamm: 1.0e-11,
    rth: 120.0,
    cth: 1.0e-9,
  }
}

///|
/// Linearized companion values for VBIC transistor model.
pub struct VbicCompanion {
  ic : Double
  ib : Double
  it : Double
  gm : Double
  gpi : Double
  gmu : Double
  go : Double
  p_diss : Double
  delta_temp : Double
} derive(Eq, Debug)

///|
/// Evaluates VBIC intrinsic currents, Early modulation, and self-heating.
pub fn evaluate_vbic_bjt(
  p : VbicBjtParams,
  vbe : Double,
  vce : Double,
  t_ambient : Double,
) -> VbicCompanion {
  let vt = 0.02585 * ((t_ambient + 273.15) / 300.15)
  let vbc = vbe - vce

  let safe_be = if vbe / (p.nf * vt) > 35.0 { 35.0 } else { vbe / (p.nf * vt) }
  let safe_bc = if vbc / (p.nr * vt) > 35.0 { 35.0 } else { vbc / (p.nr * vt) }

  let exp_be = @math.exp(safe_be)
  let exp_bc = @math.exp(safe_bc)

  let if_curr = p.is_val * (exp_be - 1.0)
  let ir_curr = p.is_val * (exp_bc - 1.0)

  // Early effect normalized factor q1 = 1 + vbc/VER + vbe/VEF
  let q1 = 1.0 + vbc / p.ver + vbe / p.vef
  let safe_q1 = if q1 > 0.1 { q1 } else { 0.1 }

  // High injection factor q2 = if_curr / IKF + ir_curr / IKR
  let q2 = if_curr / p.ikf + ir_curr / p.ikr
  let qb = 0.5 * safe_q1 * (1.0 + (1.0 + 4.0 * q2).sqrt())

  // Main transport current
  let it = (if_curr - ir_curr) / qb
  let ib = if_curr / p.bf + ir_curr / p.br
  let ic = it - ir_curr / p.br

  // Transconductances
  let gm = if_curr / (qb * p.nf * vt)
  let gpi = if_curr / (p.bf * p.nf * vt)
  let gmu = ir_curr / (p.br * p.nr * vt)
  let go = it / p.vef

  // Power dissipation and self-heating
  let p_diss = (ic * vce + ib * vbe).abs()
  let delta_temp = p_diss * p.rth

  { ic, ib, it, gm, gpi, gmu, go, p_diss, delta_temp }
}
