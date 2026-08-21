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
/// Coupled Inductor Pair / Transformer Parameters.
pub(all) struct CoupledTransformerParams {
  l1 : Double // Primary self-inductance (H)
  l2 : Double // Secondary self-inductance (H)
  k_coupling : Double // Coupling coefficient k in range [0.0, 1.0)
  r1_series : Double // Primary winding DC resistance (Ohms)
  r2_series : Double // Secondary winding DC resistance (Ohms)
} derive(Eq, Debug)

///|
/// Creates a new CoupledTransformerParams.
pub fn CoupledTransformerParams::new(
  l1 : Double,
  l2 : Double,
  k_coupling : Double,
  r1_series : Double,
  r2_series : Double,
) -> CoupledTransformerParams {
  { l1, l2, k_coupling, r1_series, r2_series }
}

///|
/// Default 1:1 coupled RF / power transformer.
pub fn CoupledTransformerParams::default_1to1() -> CoupledTransformerParams {
  {
    l1: 10.0e-3,
    l2: 10.0e-3,
    k_coupling: 0.995,
    r1_series: 0.05,
    r2_series: 0.05,
  }
}

///|
/// Computes mutual inductance M = k * sqrt(L1 * L2).
pub fn CoupledTransformerParams::mutual_inductance(
  self : CoupledTransformerParams,
) -> Double {
  self.k_coupling * (self.l1 * self.l2).sqrt()
}

///|
/// Transient companion model for Coupled Transformer pair at timestep dt using Trapezoidal integration.
/// Inductance matrix:
/// [ v1 ] = [ L1  M  ] [ d(i1)/dt ]
/// [ v2 ]   [ M   L2 ] [ d(i2)/dt ]
pub struct TransformerTransientCompanion {
  g11 : Double
  g12 : Double
  g21 : Double
  g22 : Double
  ieq1 : Double
  ieq2 : Double
} derive(Eq, Debug)

///|
/// Evaluates coupled transformer transient companion model.
pub fn evaluate_transformer_transient(
  p : CoupledTransformerParams,
  i1_prev : Double,
  i2_prev : Double,
  v1_prev : Double,
  v2_prev : Double,
  dt : Double,
) -> TransformerTransientCompanion {
  let m = p.mutual_inductance()
  let l1 = p.l1
  let l2 = p.l2
  let det_l = l1 * l2 - m * m
  let safe_det = if det_l > 1.0e-18 { det_l } else { 1.0e-18 }

  // Inverse inductance matrix L^-1:
  // L^-1 = (1/det) * [  L2  -M ]
  //                  [ -M   L1 ]
  let inv_l11 = l2 / safe_det
  let inv_l12 = -m / safe_det
  let inv_l21 = -m / safe_det
  let inv_l22 = l1 / safe_det

  // Trapezoidal conductance factors G_eq = (dt / 2) * L^-1
  let dt_half = dt / 2.0
  let g11 = dt_half * inv_l11
  let g12 = dt_half * inv_l12
  let g21 = dt_half * inv_l21
  let g22 = dt_half * inv_l22

  // Equivalent RHS currents
  let ieq1 = -i1_prev - g11 * v1_prev - g12 * v2_prev
  let ieq2 = -i2_prev - g21 * v1_prev - g22 * v2_prev

  { g11, g12, g21, g22, ieq1, ieq2 }
}
