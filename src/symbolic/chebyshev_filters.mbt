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
/// Synthesizes complex poles of n-th order Chebyshev Type I low-pass filter.
pub fn synthesize_chebyshev1_poles(
  n : Int,
  ripple_db : Double,
) -> Array[@linalg.Complex] {
  let ln10 = @math.ln(10.0)
  // Ripple factor epsilon = sqrt(10^(ripple_db / 10) - 1)
  let eps = (@math.exp(ripple_db / 10.0 * ln10) - 1.0).sqrt()
  let safe_eps = if eps > 1.0e-5 { eps } else { 1.0e-5 }

  // gamma = (1/n) * asinh(1 / epsilon) = (1/n) * ln(1/eps + sqrt(1/eps^2 + 1))
  let inv_eps = 1.0 / safe_eps
  let gamma_param = 1.0 /
    n.to_double() *
    @math.ln(inv_eps + (inv_eps * inv_eps + 1.0).sqrt())

  let sinh_g = (@math.exp(gamma_param) - @math.exp(-gamma_param)) / 2.0
  let cosh_g = (@math.exp(gamma_param) + @math.exp(-gamma_param)) / 2.0

  let poles : Array[@linalg.Complex] = []

  for k = 1; k <= n; k = k + 1 {
    let phi_k = (2 * k - 1).to_double() * @math.PI / (2.0 * n.to_double())
    let sigma_k = -sinh_g * @math.sin(phi_k)
    let omega_k = cosh_g * @math.cos(phi_k)

    poles.push(@linalg.Complex::new(sigma_k, omega_k))
  }

  poles
}

///|
/// Generates n-th order Reverse Bessel Polynomial for linear-phase Thomson filters.
pub fn generate_bessel_polynomial(n : Int) -> Polynomial {
  if n <= 0 {
    return Polynomial::constant(1.0)
  }
  if n == 1 {
    return Polynomial::from_coeffs([1.0, 1.0])
  }

  // Recurrence relation: B_n(s) = (2n - 1) * B_{n-1}(s) + s^2 * B_{n-2}(s)
  let mut b_prev = Polynomial::constant(1.0)
  let mut b_curr = Polynomial::from_coeffs([1.0, 1.0])
  let s_sq = Polynomial::from_coeffs([0.0, 0.0, 1.0])

  for k = 2; k <= n; k = k + 1 {
    let factor = (2 * k - 1).to_double()
    let term1 = b_curr.scale(factor)
    let term2 = s_sq.mul(b_prev)
    let b_next = term1.add(term2)

    b_prev = b_curr
    b_curr = b_next
  }

  b_curr
}
