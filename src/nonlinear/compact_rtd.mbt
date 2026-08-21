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
/// Parameters for Resonant Tunneling Diode (RTD) Compact Model.
pub struct RtdModelParams {
  c1 : Double // Resonant peak amplitude scaling coefficient
  c2 : Double // Thermal thermionic excess current scaling coefficient
  v_p : Double // Peak resonant voltage (V)
  v_v : Double // Valley voltage (V)
  v1 : Double // Resonance width onset broadening (V)
  v2 : Double // Resonance cutoff broadening (V)
  m_power : Double // Excess power law exponent (typically 2 to 3)
  c_junction : Double // Quantum barrier capacitance (F)
} derive(Eq, Debug)

///|
/// Default InGaAs/AlAs High-Speed RTD parameter set with PVCR ~ 5.0.
pub fn RtdModelParams::default_ingaas() -> RtdModelParams {
  {
    c1: 0.05,
    c2: 0.002,
    v_p: 0.25,
    v_v: 0.45,
    v1: 0.05,
    v2: 0.08,
    m_power: 2.5,
    c_junction: 10.0e-15, // 10 fF ultra-low capacitance
  }
}

///|
/// Evaluates RTD current and small-signal dynamic conductance G(V) = dI/dV.
pub fn evaluate_rtd_current_and_conductance(
  p : RtdModelParams,
  v : Double,
) -> (Double, Double) {
  let v_pos = if v > 0.0 { v } else { 0.0 }

  // Resonant component: I_res = c1 * V * [atan((V - V_p)/V1) - atan((V - V_v)/V2)]
  let arg1 = (v_pos - p.v_p) / p.v1
  let arg2 = (v_pos - p.v_v) / p.v2
  let atan_diff = @math.atan(arg1) - @math.atan(arg2)
  let i_res = p.c1 * v_pos * (atan_diff + @math.PI / 2.0)

  // Thermal excess component: I_excess = c2 * V^m
  let i_excess = p.c2 * @math.pow(v_pos, p.m_power)

  let i_total = i_res + i_excess

  // Numerical derivative for accurate conductance across NDR region
  let delta_v = 1.0e-6
  let arg1_plus = (v_pos + delta_v - p.v_p) / p.v1
  let arg2_plus = (v_pos + delta_v - p.v_v) / p.v2
  let atan_diff_plus = @math.atan(arg1_plus) - @math.atan(arg2_plus)
  let i_res_plus = p.c1 * (v_pos + delta_v) * (atan_diff_plus + @math.PI / 2.0)
  let i_excess_plus = p.c2 * @math.pow(v_pos + delta_v, p.m_power)
  let i_total_plus = i_res_plus + i_excess_plus

  let g_dyn = (i_total_plus - i_total) / delta_v

  (i_total, g_dyn)
}
