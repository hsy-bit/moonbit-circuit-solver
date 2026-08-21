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
/// Univariate Polynomial in Laplace variable s: P(s) = a_n * s^n + ... + a_1 * s + a_0.
/// Coeffs array stored in ascending order: coeffs[k] is coefficient of s^k.
pub struct Polynomial {
  coeffs : Array[Double]
} derive(Eq, Debug)

///|
/// Creates polynomial from ascending coefficient array [a0, a1, ..., an].
pub fn Polynomial::from_coeffs(arr : Array[Double]) -> Polynomial {
  let mut deg = arr.length() - 1
  while deg > 0 && (if arr[deg] < 0.0 { -arr[deg] } else { arr[deg] }) < 1.0e-14 {
    deg = deg - 1
  }
  let trimmed = Array::make(deg + 1, 0.0)
  for i in 0..<=deg {
    trimmed[i] = arr[i]
  }
  { coeffs: trimmed }
}

///|
/// Constant polynomial P(s) = c.
pub fn Polynomial::constant(c : Double) -> Polynomial {
  Polynomial::from_coeffs([c])
}

///|
/// Monomial s^1.
pub fn Polynomial::s() -> Polynomial {
  Polynomial::from_coeffs([0.0, 1.0])
}

///|
/// Degree of polynomial.
pub fn Polynomial::degree(self : Polynomial) -> Int {
  self.coeffs.length() - 1
}

///|
/// Gets coefficient of s^k.
pub fn Polynomial::coeff(self : Polynomial, k : Int) -> Double {
  if k >= 0 && k < self.coeffs.length() {
    self.coeffs[k]
  } else {
    0.0
  }
}

///|
/// Evaluates polynomial at real value s.
pub fn Polynomial::eval_real(self : Polynomial, s_val : Double) -> Double {
  let deg = self.degree()
  let mut res = self.coeffs[deg]
  for i = deg - 1; i >= 0; i = i - 1 {
    res = res * s_val + self.coeffs[i]
  }
  res
}

///|
/// Evaluates polynomial at complex value s = sigma + j * omega using Horner's method.
pub fn Polynomial::eval_complex(
  self : Polynomial,
  s_val : @linalg.Complex,
) -> @linalg.Complex {
  let deg = self.degree()
  let mut res = @linalg.Complex::new(self.coeffs[deg], 0.0)
  for i = deg - 1; i >= 0; i = i - 1 {
    res = res.mul(s_val).add(@linalg.Complex::new(self.coeffs[i], 0.0))
  }
  res
}

///|
/// Adds two polynomials P1(s) + P2(s).
pub fn Polynomial::add(self : Polynomial, other : Polynomial) -> Polynomial {
  let max_len = if self.coeffs.length() > other.coeffs.length() {
    self.coeffs.length()
  } else {
    other.coeffs.length()
  }
  let res = Array::make(max_len, 0.0)
  for i in 0..<max_len {
    let c1 = self.coeff(i)
    let c2 = other.coeff(i)
    res[i] = c1 + c2
  }
  Polynomial::from_coeffs(res)
}

///|
/// Subtracts two polynomials P1(s) - P2(s).
pub fn Polynomial::sub(self : Polynomial, other : Polynomial) -> Polynomial {
  let max_len = if self.coeffs.length() > other.coeffs.length() {
    self.coeffs.length()
  } else {
    other.coeffs.length()
  }
  let res = Array::make(max_len, 0.0)
  for i in 0..<max_len {
    let c1 = self.coeff(i)
    let c2 = other.coeff(i)
    res[i] = c1 - c2
  }
  Polynomial::from_coeffs(res)
}

///|
/// Multiplies polynomial by scalar alpha.
pub fn Polynomial::scale(self : Polynomial, alpha : Double) -> Polynomial {
  let res = Array::make(self.coeffs.length(), 0.0)
  for i in 0..<self.coeffs.length() {
    res[i] = self.coeffs[i] * alpha
  }
  Polynomial::from_coeffs(res)
}

///|
/// Multiplies two polynomials P1(s) * P2(s) via convolution.
pub fn Polynomial::mul(self : Polynomial, other : Polynomial) -> Polynomial {
  let deg1 = self.degree()
  let deg2 = other.degree()
  let total_len = deg1 + deg2 + 1
  let res = Array::make(total_len, 0.0)

  for i in 0..<=deg1 {
    let a_i = self.coeffs[i]
    if (if a_i < 0.0 { -a_i } else { a_i }) > 1.0e-15 {
      for j in 0..<=deg2 {
        res[i + j] = res[i + j] + a_i * other.coeffs[j]
      }
    }
  }

  Polynomial::from_coeffs(res)
}

///|
/// Computes symbolic formal derivative dP(s)/ds.
pub fn Polynomial::derivative(self : Polynomial) -> Polynomial {
  let deg = self.degree()
  if deg <= 0 {
    return Polynomial::constant(0.0)
  }
  let res = Array::make(deg, 0.0)
  for i = 1; i <= deg; i = i + 1 {
    res[i - 1] = self.coeffs[i] * i.to_double()
  }
  Polynomial::from_coeffs(res)
}

///|
/// Finds all complex roots of polynomial using the Durand-Kerner iterative method.
pub fn Polynomial::find_roots(
  self : Polynomial,
  max_iters : Int,
  tol : Double,
) -> Array[@linalg.Complex] {
  let n = self.degree()
  if n <= 0 {
    return []
  }
  if n == 1 {
    let r0 = -self.coeffs[0] / self.coeffs[1]
    return [@linalg.Complex::new(r0, 0.0)]
  }
  if n == 2 {
    let c = self.coeffs[0]
    let b = self.coeffs[1]
    let a = self.coeffs[2]
    let disc = b * b - 4.0 * a * c
    if disc >= 0.0 {
      let sq = disc.sqrt()
      return [
        @linalg.Complex::new((-b + sq) / (2.0 * a), 0.0),
        @linalg.Complex::new((-b - sq) / (2.0 * a), 0.0),
      ]
    } else {
      let im = (-disc).sqrt() / (2.0 * a)
      return [
        @linalg.Complex::new(-b / (2.0 * a), im),
        @linalg.Complex::new(-b / (2.0 * a), -im),
      ]
    }
  }

  // Monic normalization P_monic(s) = P(s) / a_n
  let an = self.coeffs[n]
  let roots : Array[@linalg.Complex] = Array::make(n, @linalg.Complex::zero())

  // Initial root guesses distributed on complex circle
  let radius = 1.0 +
    (if self.coeffs[0] / an < 0.0 {
      -self.coeffs[0] / an
    } else {
      self.coeffs[0] / an
    })
  for k in 0..<n {
    let angle = 2.0 * @math.PI * k.to_double() / n.to_double() + 0.4
    roots[k] = @linalg.Complex::from_polar(radius, angle)
  }

  // Durand-Kerner iteration
  for _iter in 0..<max_iters {
    let mut max_shift = 0.0

    for i in 0..<n {
      let xi = roots[i]
      let p_val = self.eval_complex(xi).scale(1.0 / an)

      let mut denom = @linalg.Complex::one()
      for j in 0..<n {
        if j != i {
          denom = denom.mul(xi.sub(roots[j]))
        }
      }

      let delta = p_val.div(denom)
      let shift = delta.abs()
      if shift > max_shift {
        max_shift = shift
      }
      roots[i] = xi.sub(delta)
    }

    if max_shift < tol {
      break
    }
  }

  roots
}
