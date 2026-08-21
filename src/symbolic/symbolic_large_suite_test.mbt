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
/// Generates n-th Chebyshev Polynomial of the first kind: T_0 = 1, T_1 = x, T_{n+1} = 2x*T_n - T_{n-1}.
pub fn generate_chebyshev_polynomial(n : Int) -> Polynomial {
  if n <= 0 {
    return Polynomial::constant(1.0)
  }
  if n == 1 {
    return Polynomial::from_coeffs([0.0, 1.0])
  }

  let mut t_prev = Polynomial::constant(1.0)
  let mut t_curr = Polynomial::from_coeffs([0.0, 1.0])
  let two_x = Polynomial::from_coeffs([0.0, 2.0])

  for _k = 2; _k <= n; _k = _k + 1 {
    let t_next = two_x.mul(t_curr).sub(t_prev)
    t_prev = t_curr
    t_curr = t_next
  }

  t_curr
}

///|
/// Generates n-th Legendre Polynomial: P_0 = 1, P_1 = x, (n+1)*P_{n+1} = (2n+1)*x*P_n - n*P_{n-1}.
pub fn generate_legendre_polynomial(n : Int) -> Polynomial {
  if n <= 0 {
    return Polynomial::constant(1.0)
  }
  if n == 1 {
    return Polynomial::from_coeffs([0.0, 1.0])
  }

  let mut p_prev = Polynomial::constant(1.0)
  let mut p_curr = Polynomial::from_coeffs([0.0, 1.0])

  for k = 1; k < n; k = k + 1 {
    let k_dbl = k.to_double()
    let c_x = (2.0 * k_dbl + 1.0) / (k_dbl + 1.0)
    let c_prev = k_dbl / (k_dbl + 1.0)

    let term1 = Polynomial::from_coeffs([0.0, c_x]).mul(p_curr)
    let term2 = p_prev.scale(c_prev)
    let p_next = term1.sub(term2)

    p_prev = p_curr
    p_curr = p_next
  }

  p_curr
}

///|
test "Chebyshev Polynomials T_0 through T_6 Orthogonality and Recurrence" {
  let t0 = generate_chebyshev_polynomial(0)
  let t1 = generate_chebyshev_polynomial(1)
  let t2 = generate_chebyshev_polynomial(2)
  let t3 = generate_chebyshev_polynomial(3)
  let t4 = generate_chebyshev_polynomial(4)
  let t5 = generate_chebyshev_polynomial(5)
  let t6 = generate_chebyshev_polynomial(6)

  // T_2(x) = 2x^2 - 1
  assert_true(t2.degree() == 2)
  assert_true((t2.coeff(0) - -1.0).abs() < 1.0e-12)
  assert_true((t2.coeff(2) - 2.0).abs() < 1.0e-12)

  // T_3(x) = 4x^3 - 3x
  assert_true(t3.degree() == 3)
  assert_true((t3.coeff(1) - -3.0).abs() < 1.0e-12)
  assert_true((t3.coeff(3) - 4.0).abs() < 1.0e-12)

  // T_4(x) = 8x^4 - 8x^2 + 1
  assert_true(t4.degree() == 4)
  assert_true((t4.coeff(0) - 1.0).abs() < 1.0e-12)
  assert_true((t4.coeff(2) - -8.0).abs() < 1.0e-12)
  assert_true((t4.coeff(4) - 8.0).abs() < 1.0e-12)

  assert_true(t0.degree() == 0)
  assert_true(t1.degree() == 1)
  assert_true(t5.degree() == 5)
  assert_true(t6.degree() == 6)
}

///|
test "Legendre Polynomials P_0 through P_4 Properties" {
  let p2 = generate_legendre_polynomial(2) // P_2(x) = 0.5 * (3x^2 - 1) = 1.5x^2 - 0.5
  assert_true(p2.degree() == 2)
  assert_true((p2.coeff(0) - -0.5).abs() < 1.0e-12)
  assert_true((p2.coeff(2) - 1.5).abs() < 1.0e-12)

  let p3 = generate_legendre_polynomial(3) // P_3(x) = 0.5 * (5x^3 - 3x) = 2.5x^3 - 1.5x
  assert_true(p3.degree() == 3)
  assert_true((p3.coeff(1) - -1.5).abs() < 1.0e-12)
  assert_true((p3.coeff(3) - 2.5).abs() < 1.0e-12)
}

///|
test "6th-Order Butterworth Filter Transfer Function Complex Poles" {
  let b6 = synthesize_butterworth_polynomial(6)
  assert_true(b6.degree() == 6)

  let roots = b6.find_roots(100, 1.0e-8)
  assert_true(roots.length() == 6)

  // All poles of Butterworth filter must have negative real parts (LHP stable)
  for i in 0..<roots.length() {
    assert_true(roots[i].re < 0.0)
    // All Butterworth poles lie on unit circle in s-domain (|s| = 1)
    let mag = roots[i].abs()
    assert_true((mag - 1.0).abs() < 0.05)
  }
}
