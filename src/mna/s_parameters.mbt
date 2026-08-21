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
/// 2-Port Scattering Parameters (S-matrix) at a single frequency.
pub struct TwoPortSParameters {
  freq : Double
  z0 : Double // Characteristic reference impedance (Ohms, typically 50.0)
  s11 : @linalg.Complex
  s12 : @linalg.Complex
  s21 : @linalg.Complex
  s22 : @linalg.Complex
} derive(Eq, Debug)

///|
/// RF 2-Port Network Metrics.
pub struct TwoPortMetrics {
  return_loss_port1_db : Double // RL1 = -20 * log10(|S11|)
  return_loss_port2_db : Double // RL2 = -20 * log10(|S22|)
  insertion_loss_db : Double // IL = -20 * log10(|S21|)
  vswr_port1 : Double // VSWR1 = (1 + |S11|) / (1 - |S11|)
  vswr_port2 : Double // VSWR2 = (1 + |S22|) / (1 - |S22|)
  rollett_k : Double // Rollett stability factor K
  is_unconditionally_stable : Bool
} derive(Eq, Debug)

///|
/// Computes 2-port RF metrics from S-parameter matrix.
pub fn TwoPortSParameters::compute_metrics(
  self : TwoPortSParameters,
) -> TwoPortMetrics {
  let mag_s11 = self.s11.abs()
  let mag_s12 = self.s12.abs()
  let mag_s21 = self.s21.abs()
  let mag_s22 = self.s22.abs()

  let rl1 = if mag_s11 > 1.0e-10 { -20.0 * @math.log10(mag_s11) } else { 200.0 }
  let rl2 = if mag_s22 > 1.0e-10 { -20.0 * @math.log10(mag_s22) } else { 200.0 }
  let il = if mag_s21 > 1.0e-10 { -20.0 * @math.log10(mag_s21) } else { 200.0 }

  let vswr1 = if mag_s11 < 0.9999 {
    (1.0 + mag_s11) / (1.0 - mag_s11)
  } else {
    10000.0
  }

  let vswr2 = if mag_s22 < 0.9999 {
    (1.0 + mag_s22) / (1.0 - mag_s22)
  } else {
    10000.0
  }

  // Delta determinant Delta = S11*S22 - S12*S21
  let delta = self.s11.mul(self.s22).sub(self.s12.mul(self.s21))
  let mag_delta_sq = delta.abs_sq()

  // Rollett stability factor K = (1 - |S11|^2 - |S22|^2 + |Delta|^2) / (2 * |S12 * S21|)
  let denom = 2.0 * mag_s12 * mag_s21
  let k_factor = if denom > 1.0e-12 {
    (1.0 - mag_s11 * mag_s11 - mag_s22 * mag_s22 + mag_delta_sq) / denom
  } else {
    100.0
  }

  let is_stable = k_factor > 1.0 && delta.abs() < 1.0

  {
    return_loss_port1_db: rl1,
    return_loss_port2_db: rl2,
    insertion_loss_db: il,
    vswr_port1: vswr1,
    vswr_port2: vswr2,
    rollett_k: k_factor,
    is_unconditionally_stable: is_stable,
  }
}

///|
/// Converts 2x2 Admittance matrix (Y-parameters) to Scattering matrix (S-parameters) with reference impedance Z0.
/// S = (I - Z0 * Y) * (I + Z0 * Y)^-1
pub fn y_to_s_parameters(
  y11 : @linalg.Complex,
  y12 : @linalg.Complex,
  y21 : @linalg.Complex,
  y22 : @linalg.Complex,
  z0 : Double,
  freq : Double,
) -> TwoPortSParameters {
  let z0_c = @linalg.Complex::new(z0, 0.0)

  // (I + Z0 * Y) elements
  let a11 = @linalg.Complex::one().add(z0_c.mul(y11))
  let a12 = z0_c.mul(y12)
  let a21 = z0_c.mul(y21)
  let a22 = @linalg.Complex::one().add(z0_c.mul(y22))

  // Det(I + Z0 * Y)
  let det = a11.mul(a22).sub(a12.mul(a21))
  let inv_det = det.recip()

  // Inverse (I + Z0 * Y)^-1
  let inv_a11 = a22.mul(inv_det)
  let inv_a12 = a12.scale(-1.0).mul(inv_det)
  let inv_a21 = a21.scale(-1.0).mul(inv_det)
  let inv_a22 = a11.mul(inv_det)

  // (I - Z0 * Y) elements
  let b11 = @linalg.Complex::one().sub(z0_c.mul(y11))
  let b12 = z0_c.scale(-1.0).mul(y12)
  let b21 = z0_c.scale(-1.0).mul(y21)
  let b22 = @linalg.Complex::one().sub(z0_c.mul(y22))

  // S = B * Inv_A
  let s11 = b11.mul(inv_a11).add(b12.mul(inv_a21))
  let s12 = b11.mul(inv_a12).add(b12.mul(inv_a22))
  let s21 = b21.mul(inv_a11).add(b22.mul(inv_a21))
  let s22 = b21.mul(inv_a12).add(b22.mul(inv_a22))

  { freq, z0, s11, s12, s21, s22 }
}
