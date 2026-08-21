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
/// Split-Gate Trench Power MOSFET Parameters.
pub struct TrenchPowerMosfetParams {
  v_th : Double // Threshold voltage (V)
  r_ds_on : Double // Channel + Drift On-Resistance (Ohms)
  bvdss : Double // Drain-source breakdown voltage (V)
  c_iss : Double // Input capacitance Ciss = Cgs + Cgd (F)
  c_oss_0 : Double // Output capacitance Coss at 0V (F)
  c_rss_0 : Double // Reverse transfer capacitance Crss at 0V (F)
  q_g_total : Double // Total gate charge at 10V (C)
  q_rr_diode : Double // Body diode reverse recovery charge (C)
  t_rr_diode : Double // Body diode reverse recovery time (s)
} derive(Eq, Debug)

///|
/// Standard 100V / 50A Power MOSFET parameter set.
pub fn TrenchPowerMosfetParams::default_100v() -> TrenchPowerMosfetParams {
  {
    v_th: 3.0,
    r_ds_on: 0.008,
    bvdss: 100.0,
    c_iss: 2.5e-9,
    c_oss_0: 800.0e-12,
    c_rss_0: 150.0e-12,
    q_g_total: 45.0e-9,
    q_rr_diode: 80.0e-9,
    t_rr_diode: 35.0e-9,
  }
}

///|
/// Dynamic non-linear capacitances and companion values for Power MOSFET.
pub struct TrenchMosfetDynamicState {
  c_gd : Double // Voltage-dependent Miller capacitance
  c_ds : Double // Depletion output capacitance
  i_drain : Double // Active channel current
  r_channel : Double // Instantaneous channel resistance
} derive(Eq, Debug)

///|
/// Evaluates non-linear Miller capacitance and switching conduction.
pub fn evaluate_trench_mosfet_dynamic(
  p : TrenchPowerMosfetParams,
  v_gs : Double,
  v_ds : Double,
) -> TrenchMosfetDynamicState {
  // Non-linear Cgd Miller cliff: drops by 50x as Vds rises above 10V
  let vds_pos = if v_ds > 0.0 { v_ds } else { 0.0 }
  let c_gd = p.c_rss_0 / (1.0 + vds_pos / 4.0).sqrt()
  let c_ds = p.c_oss_0 / (1.0 + vds_pos / 10.0).sqrt()

  // Conduction state
  let (i_drain, r_channel) = if v_gs > p.v_th {
    let v_overdrive = v_gs - p.v_th
    let r_eff = p.r_ds_on * (10.0 / (v_overdrive + 0.1))
    let safe_r = if r_eff > p.r_ds_on { r_eff } else { p.r_ds_on }
    let id = vds_pos / safe_r
    (id, safe_r)
  } else {
    (1.0e-9, 1.0e9) // Sub-threshold leakage
  }

  { c_gd, c_ds, i_drain, r_channel }
}
