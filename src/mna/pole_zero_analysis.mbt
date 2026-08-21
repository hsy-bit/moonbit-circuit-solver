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
/// Result of Circuit Open-Circuit Time Constant (OCT) Dominant Pole Estimation.
pub struct OctPoleResult {
  sum_rc_seconds : Double
  dominant_pole_rad_s : Double
  dominant_pole_hz : Double
} derive(Eq, Debug)

///|
/// Computes dominant high-frequency cutoff pole using Zero-Value Time Constants (ZVT / OCT).
/// omega_p1 approx 1 / sum(R_i0 * C_i)
pub fn compute_oct_dominant_pole(
  resistances_seen : Array[Double],
  capacitances : Array[Double],
) -> OctPoleResult {
  let n = capacitances.length()
  let mut sum_rc = 0.0

  for i in 0..<n {
    let r_i = if i < resistances_seen.length() {
      resistances_seen[i]
    } else {
      0.0
    }
    let c_i = capacitances[i]
    sum_rc = sum_rc + r_i * c_i
  }

  let pole_rad = if sum_rc > 1.0e-20 { 1.0 / sum_rc } else { 1.0e12 }
  let pole_hz = pole_rad / (2.0 * @math.PI)

  {
    sum_rc_seconds: sum_rc,
    dominant_pole_rad_s: pole_rad,
    dominant_pole_hz: pole_hz,
  }
}

///|
/// Computes dominant low-frequency cutoff using Short-Circuit Time Constants (SCT).
/// omega_L approx sum(1 / (R_js * C_j))
pub fn compute_sct_lower_cutoff(
  resistances_short : Array[Double],
  capacitances : Array[Double],
) -> Double {
  let n = capacitances.length()
  let mut sum_inv_rc = 0.0

  for i in 0..<n {
    let r_j = if i < resistances_short.length() {
      resistances_short[i]
    } else {
      1.0
    }
    let c_j = capacitances[i]
    if r_j > 1.0e-12 && c_j > 1.0e-20 {
      sum_inv_rc = sum_inv_rc + 1.0 / (r_j * c_j)
    }
  }

  let f_low_hz = sum_inv_rc / (2.0 * @math.PI)
  f_low_hz
}
