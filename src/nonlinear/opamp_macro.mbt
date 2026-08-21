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
/// Parameters for Real Operational Amplifier Macro-Model (e.g. LM741 / TL072 / OPA2134).
pub struct OpAmpMacroParams {
  a_vd : Double // DC open-loop differential gain (e.g. 200,000 V/V = 106 dB)
  gbw : Double // Gain Bandwidth Product (Hz, e.g. 1.0 MHz)
  slew_rate : Double // Slew rate (V/s, e.g. 0.5 V/us = 5.0e5 V/s)
  v_os : Double // Input offset voltage (V, e.g. 1.0 mV)
  i_b : Double // Input bias current (A, e.g. 80 nA)
  r_in_diff : Double // Differential input resistance (Ohms, e.g. 2.0 MOhm)
  r_in_cm : Double // Common-mode input resistance (Ohms, e.g. 1.0 GOhm)
  r_out : Double // Output resistance (Ohms, e.g. 75 Ohms)
  v_sat_pos : Double // Positive supply output saturation voltage (V, e.g. +13.5V)
  v_sat_neg : Double // Negative supply output saturation voltage (V, e.g. -13.5V)
  i_max_out : Double // Maximum output source/sink current (A, e.g. 25 mA)
} derive(Eq, Debug)

///|
/// Standard LM741 OpAmp macro-model parameters.
pub fn OpAmpMacroParams::default_lm741() -> OpAmpMacroParams {
  {
    a_vd: 200000.0,
    gbw: 1.0e6,
    slew_rate: 0.5e6,
    v_os: 1.0e-3,
    i_b: 80.0e-9,
    r_in_diff: 2.0e6,
    r_in_cm: 1.0e9,
    r_out: 75.0,
    v_sat_pos: 13.5,
    v_sat_neg: -13.5,
    i_max_out: 25.0e-3,
  }
}

///|
/// High-Speed Audio OPA2134 OpAmp macro-model parameters.
pub fn OpAmpMacroParams::default_opa2134() -> OpAmpMacroParams {
  {
    a_vd: 500000.0,
    gbw: 8.0e6,
    slew_rate: 20.0e6,
    v_os: 0.5e-3,
    i_b: 5.0e-12,
    r_in_diff: 1.0e13,
    r_in_cm: 1.0e13,
    r_out: 10.0,
    v_sat_pos: 14.0,
    v_sat_neg: -14.0,
    i_max_out: 35.0e-3,
  }
}

///|
/// Evaluates DC and non-linear saturation transfer characteristics of OpAmp.
pub fn evaluate_opamp_dc(
  p : OpAmpMacroParams,
  v_inp : Double,
  v_inm : Double,
) -> (Double, Double) {
  let v_diff = v_inp - v_inm + p.v_os
  let v_ideal = p.a_vd * v_diff

  // Smooth hyperbolic tangent output voltage clamping
  let v_span = (p.v_sat_pos - p.v_sat_neg) / 2.0
  let v_mid = (p.v_sat_pos + p.v_sat_neg) / 2.0
  let u = (v_ideal - v_mid) / (v_span + 1.0e-6)
  let safe_u = if u > 15.0 { 15.0 } else if u < -15.0 { -15.0 } else { u }

  let v_out = v_mid + v_span * @math.tanh(safe_u)
  let d_vout_d_vdiff = p.a_vd * (1.0 - @math.tanh(safe_u) * @math.tanh(safe_u))

  (v_out, d_vout_d_vdiff)
}
