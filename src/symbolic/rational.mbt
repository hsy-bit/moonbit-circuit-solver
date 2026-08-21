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
/// Rational Laplace Transfer Function H(s) = Num(s) / Den(s).
pub struct TransferFunction {
  num : Polynomial
  den : Polynomial
} derive(Eq, Debug)

///|
/// Creates a transfer function from numerator and denominator polynomials.
pub fn TransferFunction::new(
  num : Polynomial,
  den : Polynomial,
) -> TransferFunction {
  { num, den }
}

///|
/// Creates a 1st-order Low-Pass Filter transfer function H(s) = K / (1 + s / omega_c).
pub fn TransferFunction::low_pass_1st(
  k_gain : Double,
  omega_c : Double,
) -> TransferFunction {
  let num = Polynomial::constant(k_gain * omega_c)
  let den = Polynomial::from_coeffs([omega_c, 1.0])
  { num, den }
}

///|
/// Creates a 1st-order High-Pass Filter transfer function H(s) = K * (s / omega_c) / (1 + s / omega_c).
pub fn TransferFunction::high_pass_1st(
  k_gain : Double,
  omega_c : Double,
) -> TransferFunction {
  let num = Polynomial::from_coeffs([0.0, k_gain])
  let den = Polynomial::from_coeffs([omega_c, 1.0])
  { num, den }
}

///|
/// Creates a 2nd-order Biquad Filter transfer function:
/// H(s) = K * omega_0^2 / (s^2 + (omega_0 / Q) * s + omega_0^2).
pub fn TransferFunction::biquad_low_pass(
  k_gain : Double,
  omega_0 : Double,
  q_factor : Double,
) -> TransferFunction {
  let num = Polynomial::constant(k_gain * omega_0 * omega_0)
  let den = Polynomial::from_coeffs([omega_0 * omega_0, omega_0 / q_factor, 1.0])
  { num, den }
}

///|
/// Creates a 2nd-order Band-Pass Filter transfer function:
/// H(s) = K * (omega_0 / Q) * s / (s^2 + (omega_0 / Q) * s + omega_0^2).
pub fn TransferFunction::biquad_band_pass(
  k_gain : Double,
  omega_0 : Double,
  q_factor : Double,
) -> TransferFunction {
  let num = Polynomial::from_coeffs([0.0, k_gain * omega_0 / q_factor])
  let den = Polynomial::from_coeffs([omega_0 * omega_0, omega_0 / q_factor, 1.0])
  { num, den }
}

///|
/// Evaluates complex frequency response H(j * omega) at angular frequency omega (rad/s).
pub fn TransferFunction::eval_frequency(
  self : TransferFunction,
  omega : Double,
) -> @linalg.Complex {
  let j_omega = @linalg.Complex::new(0.0, omega)
  let num_c = self.num.eval_complex(j_omega)
  let den_c = self.den.eval_complex(j_omega)
  num_c.div(den_c)
}

///|
/// Evaluates magnitude in decibels: |H(j*omega)|_dB = 20 * log10(|H(j*omega)|).
pub fn TransferFunction::magnitude_db(
  self : TransferFunction,
  omega : Double,
) -> Double {
  let resp = self.eval_frequency(omega)
  let mag = resp.abs()
  if mag > 1.0e-15 {
    20.0 * @math.log10(mag)
  } else {
    -300.0
  }
}

///|
/// Evaluates phase in degrees: arg(H(j*omega)) * (180 / pi).
pub fn TransferFunction::phase_deg(
  self : TransferFunction,
  omega : Double,
) -> Double {
  let resp = self.eval_frequency(omega)
  resp.arg() * 180.0 / @math.PI
}

///|
/// Computes DC gain H(0) = Num(0) / Den(0).
pub fn TransferFunction::dc_gain(self : TransferFunction) -> Double {
  let num0 = self.num.coeff(0)
  let den0 = self.den.coeff(0)
  if (if den0 < 0.0 { -den0 } else { den0 }) > 1.0e-15 {
    num0 / den0
  } else {
    0.0
  }
}

///|
/// Multiplies two transfer functions in series (cascade): H_total = H1 * H2.
pub fn TransferFunction::cascade(
  self : TransferFunction,
  other : TransferFunction,
) -> TransferFunction {
  let num = self.num.mul(other.num)
  let den = self.den.mul(other.den)
  { num, den }
}

///|
/// Adds two transfer functions in parallel: H_total = H1 + H2 = (N1*D2 + N2*D1) / (D1*D2).
pub fn TransferFunction::parallel(
  self : TransferFunction,
  other : TransferFunction,
) -> TransferFunction {
  let num = self.num.mul(other.den).add(other.num.mul(self.den))
  let den = self.den.mul(other.den)
  { num, den }
}

///|
/// Closed-loop negative feedback transfer function: H_cl(s) = H(s) / (1 + H(s) * G(s)).
pub fn TransferFunction::feedback(
  self : TransferFunction,
  feedback_g : TransferFunction,
) -> TransferFunction {
  // H_cl = (N_h * D_g) / (D_h * D_g + N_h * N_g)
  let num = self.num.mul(feedback_g.den)
  let den = self.den.mul(feedback_g.den).add(self.num.mul(feedback_g.num))
  { num, den }
}
