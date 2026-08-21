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
/// Varactor Diode Parameters for RF Tuning & VCO simulation.
pub struct VaractorParams {
  c0 : Double // Zero-bias capacitance C_j0 (F)
  vj : Double // Junction built-in potential (V)
  m_coeff : Double // Grading coefficient (typically 0.33 to 0.5)
  rs : Double // Series resistance (Ohms)
  is_val : Double // Saturation leakage current (A)
} derive(Eq, Debug)

///|
/// Default RF Varactor Diode parameters (e.g. BB139 / 1SV149).
pub fn VaractorParams::default_rf() -> VaractorParams {
  { c0: 20.0e-12, vj: 0.7, m_coeff: 0.5, rs: 0.5, is_val: 1.0e-14 }
}

///|
/// Evaluates capacitance of varactor diode at bias voltage Vd (V_anode - V_cathode).
pub fn evaluate_varactor_capacitance(p : VaractorParams, vd : Double) -> Double {
  if vd < 0.8 * p.vj {
    let base = 1.0 - vd / p.vj
    p.c0 / @math.pow(base, p.m_coeff)
  } else {
    // Linear extrapolation beyond 0.8*Vj to prevent singularity
    let v_thresh = 0.8 * p.vj
    let c_thresh = p.c0 / @math.pow(1.0 - v_thresh / p.vj, p.m_coeff)
    let dcdv = p.m_coeff * c_thresh / (p.vj * (1.0 - v_thresh / p.vj))
    c_thresh + dcdv * (vd - v_thresh)
  }
}

///|
/// Companion model for Varactor in transient time-domain simulation.
pub struct VaractorCompanion {
  cap_val : Double
  req : Double
  ieq : Double
} derive(Eq, Debug)

///|
/// Evaluates Varactor companion model for transient numerical integration at timestep dt.
pub fn evaluate_varactor_transient(
  p : VaractorParams,
  vd_curr : Double,
  vd_prev : Double,
  i_prev : Double,
  dt : Double,
) -> VaractorCompanion {
  let c_eff = evaluate_varactor_capacitance(p, vd_curr)
  // Trapezoidal companion rule: Req = dt / (2*C), Ieq = -(2*C/dt)*Vd_prev - I_prev
  let req = dt / (2.0 * c_eff)
  let ieq = -(2.0 * c_eff / dt) * vd_prev - i_prev

  { cap_val: c_eff, req, ieq }
}
