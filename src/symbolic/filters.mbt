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
/// Filter Approximation Type.
pub(all) enum FilterType {
  Butterworth
  Chebyshev1(Double) // Passband ripple in dB (e.g. 0.5 dB)
  Bessel
} derive(Eq, Debug)

///|
/// Synthesizes normalized Butterworth denominator polynomial of order n: B_n(s).
pub fn synthesize_butterworth_polynomial(order : Int) -> Polynomial {
  if order <= 0 {
    return Polynomial::constant(1.0)
  }
  if order == 1 {
    return Polynomial::from_coeffs([1.0, 1.0])
  }
  if order == 2 {
    let sqrt2 = 2.0.sqrt()
    return Polynomial::from_coeffs([1.0, sqrt2, 1.0])
  }
  if order == 3 {
    return Polynomial::from_coeffs([1.0, 2.0, 2.0, 1.0])
  }
  if order == 4 {
    // (s^2 + 0.765367 s + 1) * (s^2 + 1.847759 s + 1)
    let p1 = Polynomial::from_coeffs([1.0, 0.765367, 1.0])
    let p2 = Polynomial::from_coeffs([1.0, 1.847759, 1.0])
    return p1.mul(p2)
  }

  // General product of 2nd-order quadratic factors
  let mut p_total = if order % 2 == 1 {
    Polynomial::from_coeffs([1.0, 1.0])
  } else {
    Polynomial::constant(1.0)
  }

  let num_quads = order / 2
  for k = 1; k <= num_quads; k = k + 1 {
    let theta_k = (2.0 * k.to_double() + order.to_double() - 1.0) *
      @math.PI /
      (2.0 * order.to_double())
    let gamma_k = -2.0 * @math.cos(theta_k)
    let quad = Polynomial::from_coeffs([1.0, gamma_k, 1.0])
    p_total = p_total.mul(quad)
  }

  p_total
}

///|
/// Sallen-Key 2nd-order Low-Pass Filter Design Synthesis:
/// Component values: R1, R2, C1, C2, K = 1 + Ra / Rb.
/// Cutoff angular frequency omega_0 = 1 / sqrt(R1 * R2 * C1 * C2)
/// Quality factor Q = sqrt(R1 * R2 * C1 * C2) / (C2*(R1 + R2) + R1*C1*(1 - K))
pub struct SallenKeyLowPassDesign {
  r1 : Double
  r2 : Double
  c1 : Double
  c2 : Double
  fc_hz : Double
  q_factor : Double
  tf : TransferFunction
} derive(Eq, Debug)

///|
/// Synthesizes Sallen-Key 2nd-order low-pass active filter given target cutoff frequency fc and Q.
pub fn design_sallen_key_low_pass(
  fc_hz : Double,
  q_factor : Double,
  c_nominal : Double,
) -> SallenKeyLowPassDesign {
  let omega_0 = 2.0 * @math.PI * fc_hz
  let c1 = 2.0 * q_factor * c_nominal
  let c2 = c_nominal / (2.0 * q_factor)
  let r_val = 1.0 / (omega_0 * c_nominal)

  let tf = TransferFunction::biquad_low_pass(1.0, omega_0, q_factor)

  { r1: r_val, r2: r_val, c1, c2, fc_hz, q_factor, tf }
}
