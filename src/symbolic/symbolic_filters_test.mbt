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
test "Polynomial arithmetic and Durand-Kerner root finding" {
  // P(s) = (s - 2)(s - 3) = s^2 - 5s + 6
  let p1 = Polynomial::from_coeffs([-2.0, 1.0])
  let p2 = Polynomial::from_coeffs([-3.0, 1.0])
  let p_prod = p1.mul(p2)

  assert_true((p_prod.coeff(0) - 6.0).abs() < 1.0e-12)
  assert_true((p_prod.coeff(1) - -5.0).abs() < 1.0e-12)
  assert_true((p_prod.coeff(2) - 1.0).abs() < 1.0e-12)

  // Test derivative: d(s^2 - 5s + 6)/ds = 2s - 5
  let dp = p_prod.derivative()
  assert_true((dp.coeff(0) - -5.0).abs() < 1.0e-12)
  assert_true((dp.coeff(1) - 2.0).abs() < 1.0e-12)

  // Roots should be 2.0 and 3.0
  let roots = p_prod.find_roots(50, 1.0e-10)
  assert_true(roots.length() == 2)
  let r0 = roots[0].re
  let r1 = roots[1].re
  assert_true(
    ((r0 - 2.0).abs() < 1.0e-6 && (r1 - 3.0).abs() < 1.0e-6) ||
    ((r0 - 3.0).abs() < 1.0e-6 && (r1 - 2.0).abs() < 1.0e-6),
  )
}

///|
test "Rational TransferFunction Bode response and feedback" {
  // 2nd-order Biquad Low-Pass: fc = 1kHz, Q = 0.707 (Butterworth maximally flat)
  let fc = 1000.0
  let omega_0 = 2.0 * @math.PI * fc
  let tf = TransferFunction::biquad_low_pass(1.0, omega_0, 0.70710678)

  // DC gain H(0) == 1.0 (0 dB)
  let dc_g = tf.dc_gain()
  assert_true((dc_g - 1.0).abs() < 1.0e-12)

  // Magnitude at cutoff: -3 dB
  let mag_at_fc = tf.magnitude_db(omega_0)
  assert_true((mag_at_fc - -3.01).abs() < 0.1)

  // Magnitude at 10 * fc: -40 dB (40 dB/decade roll-off)
  let mag_high = tf.magnitude_db(omega_0 * 10.0)
  assert_true(mag_high < -35.0)

  // Phase at cutoff: -90 degrees
  let phase_at_fc = tf.phase_deg(omega_0)
  assert_true((phase_at_fc - -90.0).abs() < 1.0)
}

///|
test "PolyMatrix and symbolic Cramer's rule determinant solver" {
  let mat = PolyMatrix::zeros(2, 2)
  // [ s + 1    -1  ]
  // [  -1    s + 2 ]
  mat.set(0, 0, Polynomial::from_coeffs([1.0, 1.0]))
  mat.set(0, 1, Polynomial::from_coeffs([-1.0]))
  mat.set(1, 0, Polynomial::from_coeffs([-1.0]))
  mat.set(1, 1, Polynomial::from_coeffs([2.0, 1.0]))

  let det = mat.determinant()
  // Det = (s+1)(s+2) - 1 = s^2 + 3s + 1
  assert_true((det.coeff(0) - 1.0).abs() < 1.0e-12)
  assert_true((det.coeff(1) - 3.0).abs() < 1.0e-12)
  assert_true((det.coeff(2) - 1.0).abs() < 1.0e-12)

  let rhs = [Polynomial::constant(1.0), Polynomial::constant(0.0)]
  let tf = solve_symbolic_transfer_function(mat, rhs, 1)
  // V2(s) / V1(s) = 1 / (s^2 + 3s + 1)
  assert_true((tf.num.coeff(0) - 1.0).abs() < 1.0e-12)
  assert_true((tf.den.coeff(0) - 1.0).abs() < 1.0e-12)
}

///|
test "Active filter synthesis: Butterworth and Sallen-Key" {
  let b4 = synthesize_butterworth_polynomial(4)
  assert_true(b4.degree() == 4)
  assert_true((b4.coeff(0) - 1.0).abs() < 1.0e-12)
  assert_true((b4.coeff(4) - 1.0).abs() < 1.0e-12)

  let sk = design_sallen_key_low_pass(1000.0, 0.707, 10.0e-9)
  assert_true(sk.r1 > 0.0)
  assert_true(sk.r2 > 0.0)
  assert_true(sk.c1 > 0.0)
  assert_true(sk.c2 > 0.0)
}
