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
/// Result of Small-Signal Non-Linear Distortion Analysis (.disto).
pub struct DistortionResult {
  fundamental_mag : Double
  hd2_mag : Double
  hd3_mag : Double
  hd2_dbc : Double // 2nd Harmonic Distortion in dBc = 20 * log10(HD2 / HD1)
  hd3_dbc : Double // 3rd Harmonic Distortion in dBc = 20 * log10(HD3 / HD1)
  thd_percent : Double // THD = sqrt(HD2^2 + HD3^2) / HD1 * 100%
  imd3_dbc : Double // 3rd-order Two-Tone Intermodulation Distortion
} derive(Eq, Debug)

///|
/// Evaluates weakly non-linear Taylor/Volterra coefficients: y = k1*x + k2*x^2 + k3*x^3.
pub fn compute_taylor_distortion(
  k1 : Double,
  k2 : Double,
  k3 : Double,
  v_in_amp : Double,
) -> DistortionResult {
  // Fundamental amplitude: A_1 = k1 * Vin + (3/4) * k3 * Vin^3
  let a1 = (k1 * v_in_amp + 0.75 * k3 * v_in_amp * v_in_amp * v_in_amp).abs()

  // 2nd harmonic amplitude: A_2 = (1/2) * k2 * Vin^2
  let a2 = (0.5 * k2 * v_in_amp * v_in_amp).abs()

  // 3rd harmonic amplitude: A_3 = (1/4) * k3 * Vin^3
  let a3 = (0.25 * k3 * v_in_amp * v_in_amp * v_in_amp).abs()

  let safe_a1 = if a1 > 1.0e-15 { a1 } else { 1.0e-15 }

  let hd2_dbc = 20.0 *
    @math.log10(if a2 > 1.0e-15 { a2 / safe_a1 } else { 1.0e-15 })
  let hd3_dbc = 20.0 *
    @math.log10(if a3 > 1.0e-15 { a3 / safe_a1 } else { 1.0e-15 })

  let thd_pct = (a2 * a2 + a3 * a3).sqrt() / safe_a1 * 100.0
  let imd3_dbc = hd3_dbc + 6.02 // Theoretical relationship for equal-amplitude two-tone

  {
    fundamental_mag: a1,
    hd2_mag: a2,
    hd3_mag: a3,
    hd2_dbc,
    hd3_dbc,
    thd_percent: thd_pct,
    imd3_dbc,
  }
}
