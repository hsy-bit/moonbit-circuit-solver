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
/// Optimal stage balance parameter gamma = 2 - sqrt(2) approx 0.5857864376 for L-stability.
pub const TR_BDF2_GAMMA : Double = 0.585786437626905

///|
/// Companion model parameters for TR-BDF2 composite integration scheme.
pub struct TrBdf2Companion {
  stage1_req : Double
  stage1_ieq : Double
  stage2_req : Double
  stage2_ieq : Double
} derive(Eq, Debug)

///|
/// Evaluates TR-BDF2 companion parameters for reactive capacitor C:
/// Stage 1 (Trapezoidal on [t_n, t_n + gamma*h]):
///   x_{n+gamma} - x_n = (gamma*h / 2) * (f_{n+gamma} + f_n)
/// Stage 2 (BDF-2 on [t_n + gamma*h, t_n + h]):
///   x_{n+1} - (1/gamma/(2-gamma))*x_{n+gamma} + ((1-gamma)^2/gamma/(2-gamma))*x_n = ((1-gamma)/(2-gamma))*h * f_{n+1}
pub fn evaluate_tr_bdf2_cap(
  c_val : Double,
  v_n : Double,
  v_ngamma : Double,
  i_n : Double,
  dt : Double,
) -> TrBdf2Companion {
  let gamma = TR_BDF2_GAMMA
  let h = dt

  // Stage 1: Trapezoidal over gamma * h
  let h_tr = gamma * h
  let stage1_req = h_tr / (2.0 * c_val)
  let stage1_ieq = -(2.0 * c_val / h_tr) * v_n - i_n

  // Stage 2: BDF-2 coefficients
  let d_coeff = (1.0 - gamma) / (2.0 - gamma)
  let alpha = 1.0 / (gamma * (2.0 - gamma))
  let beta = (1.0 - gamma) * (1.0 - gamma) / (gamma * (2.0 - gamma))

  let stage2_req = d_coeff * h / c_val
  let stage2_ieq = -(c_val / (d_coeff * h)) * (alpha * v_ngamma - beta * v_n)

  { stage1_req, stage1_ieq, stage2_req, stage2_ieq }
}

///|
/// Evaluates Local Truncation Error (LTE) estimate for TR-BDF2 to adjust timestep adaptively:
/// LTE = 2 * h * |( (1-gamma)/gamma * f_{n+gamma} - (1/gamma) * f_{n+1} + f_n )|
pub fn estimate_tr_bdf2_lte(
  fn_val : Double,
  f_ngamma : Double,
  f_n1 : Double,
  dt : Double,
) -> Double {
  let gamma = TR_BDF2_GAMMA
  let term = (1.0 - gamma) / gamma * f_ngamma - 1.0 / gamma * f_n1 + fn_val
  let abs_term = if term < 0.0 { -term } else { term }
  2.0 * dt * abs_term
}
