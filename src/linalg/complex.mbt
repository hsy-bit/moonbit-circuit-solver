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
/// Complex number representation for AC frequency domain, RF S-parameters, and eigenvalue analysis.
pub struct Complex {
  re : Double
  im : Double
} derive(Eq, Debug)

///|
/// Creates a new complex number with given real and imaginary parts.
pub fn Complex::new(re : Double, im : Double) -> Complex {
  { re, im }
}

///|
/// Complex zero constant 0 + 0j.
pub fn Complex::zero() -> Complex {
  { re: 0.0, im: 0.0 }
}

///|
/// Complex one constant 1 + 0j.
pub fn Complex::one() -> Complex {
  { re: 1.0, im: 0.0 }
}

///|
/// Imaginary unit constant 0 + 1j.
pub fn Complex::i() -> Complex {
  { re: 0.0, im: 1.0 }
}

///|
/// Creates a complex number from polar coordinates (magnitude r and phase angle theta in radians).
pub fn Complex::from_polar(r : Double, theta : Double) -> Complex {
  let re = r * @math.cos(theta)
  let im = r * @math.sin(theta)
  { re, im }
}

///|
/// Complex addition.
pub fn Complex::add(self : Complex, other : Complex) -> Complex {
  { re: self.re + other.re, im: self.im + other.im }
}

///|
/// Complex subtraction.
pub fn Complex::sub(self : Complex, other : Complex) -> Complex {
  { re: self.re - other.re, im: self.im - other.im }
}

///|
/// Complex multiplication: (a + bi)(c + di) = (ac - bd) + (ad + bc)i.
pub fn Complex::mul(self : Complex, other : Complex) -> Complex {
  let re = self.re * other.re - self.im * other.im
  let im = self.re * other.im + self.im * other.re
  { re, im }
}

///|
/// Complex division: (a + bi) / (c + di).
pub fn Complex::div(self : Complex, other : Complex) -> Complex {
  let denom = other.re * other.re + other.im * other.im
  if denom == 0.0 {
    { re: 0.0, im: 0.0 }
  } else {
    let re = (self.re * other.re + self.im * other.im) / denom
    let im = (self.im * other.re - self.re * other.im) / denom
    { re, im }
  }
}

///|
/// Scalar multiplication.
pub fn Complex::scale(self : Complex, s : Double) -> Complex {
  { re: self.re * s, im: self.im * s }
}

///|
/// Complex conjugate: conj(a + bi) = a - bi.
pub fn Complex::conj(self : Complex) -> Complex {
  { re: self.re, im: -self.im }
}

///|
/// Magnitude (modulus / absolute value) |z| = sqrt(re^2 + im^2).
pub fn Complex::abs(self : Complex) -> Double {
  let r2 = self.re * self.re + self.im * self.im
  r2.sqrt()
}

///|
/// Squared magnitude |z|^2 = re^2 + im^2.
pub fn Complex::abs_sq(self : Complex) -> Double {
  self.re * self.re + self.im * self.im
}

///|
/// Phase angle (argument) in radians in range (-pi, pi].
pub fn Complex::arg(self : Complex) -> Double {
  @math.atan2(self.im, self.re)
}

///|
/// Complex exponential exp(z) = exp(re) * (cos(im) + i sin(im)).
pub fn Complex::exp(self : Complex) -> Complex {
  let exp_re = @math.exp(self.re)
  let re = exp_re * @math.cos(self.im)
  let im = exp_re * @math.sin(self.im)
  { re, im }
}

///|
/// Principal complex natural logarithm ln(z) = ln(|z|) + i arg(z).
pub fn Complex::ln(self : Complex) -> Complex {
  let r = self.abs()
  if r == 0.0 {
    { re: -1.0e10, im: 0.0 }
  } else {
    let re = @math.ln(r)
    let im = self.arg()
    { re, im }
  }
}

///|
/// Principal square root of complex number.
pub fn Complex::sqrt(self : Complex) -> Complex {
  let r = self.abs()
  let theta = self.arg()
  Complex::from_polar(r.sqrt(), theta / 2.0)
}

///|
/// Reciprocal 1 / z.
pub fn Complex::recip(self : Complex) -> Complex {
  let denom = self.re * self.re + self.im * self.im
  if denom == 0.0 {
    { re: 0.0, im: 0.0 }
  } else {
    { re: self.re / denom, im: -self.im / denom }
  }
}

///|
/// Complex power z^p = exp(p * ln(z)).
pub fn Complex::pow(self : Complex, p : Double) -> Complex {
  let r = self.abs()
  if r == 0.0 {
    Complex::zero()
  } else {
    let theta = self.arg()
    let r_p = @math.pow(r, p)
    Complex::from_polar(r_p, theta * p)
  }
}

///|
/// 1D Complex vector for frequency sweeps and RF multi-port calculations.
pub struct ComplexVector {
  data : Array[Complex]
} derive(Eq, Debug)

///|
/// Creates a new complex vector of size n filled with val.
pub fn ComplexVector::make(n : Int, val : Complex) -> ComplexVector {
  let arr = Array::make(n, val)
  { data: arr }
}

///|
/// Creates a complex vector of size n filled with zero (0 + 0j).
pub fn ComplexVector::zeros(n : Int) -> ComplexVector {
  ComplexVector::make(n, Complex::zero())
}

///|
/// Creates a complex vector from an array of Complex elements.
pub fn ComplexVector::from_array(arr : Array[Complex]) -> ComplexVector {
  let copy = Array::make(arr.length(), Complex::zero())
  for i in 0..<arr.length() {
    copy[i] = arr[i]
  }
  { data: copy }
}

///|
/// Gets the length of the vector.
pub fn ComplexVector::length(self : ComplexVector) -> Int {
  self.data.length()
}

///|
/// Gets the element at index i.
pub fn ComplexVector::get(self : ComplexVector, idx : Int) -> Complex {
  if idx >= 0 && idx < self.data.length() {
    self.data[idx]
  } else {
    Complex::zero()
  }
}

///|
/// Sets the element at index i.
pub fn ComplexVector::set(
  self : ComplexVector,
  idx : Int,
  val : Complex,
) -> Unit {
  if idx >= 0 && idx < self.data.length() {
    self.data[idx] = val
  }
}

///|
/// Adds two complex vectors elementwise.
pub fn ComplexVector::add(
  self : ComplexVector,
  other : ComplexVector,
) -> ComplexVector {
  let n = self.data.length()
  let result = ComplexVector::zeros(n)
  for i in 0..<n {
    result.set(i, self.get(i).add(other.get(i)))
  }
  result
}

///|
/// Subtracts two complex vectors elementwise.
pub fn ComplexVector::sub(
  self : ComplexVector,
  other : ComplexVector,
) -> ComplexVector {
  let n = self.data.length()
  let result = ComplexVector::zeros(n)
  for i in 0..<n {
    result.set(i, self.get(i).sub(other.get(i)))
  }
  result
}

///|
/// Scales complex vector by a complex scalar alpha.
pub fn ComplexVector::scale(
  self : ComplexVector,
  alpha : Complex,
) -> ComplexVector {
  let n = self.data.length()
  let result = ComplexVector::zeros(n)
  for i in 0..<n {
    result.set(i, self.get(i).mul(alpha))
  }
  result
}

///|
/// Scales complex vector by a real scalar.
pub fn ComplexVector::scale_real(
  self : ComplexVector,
  alpha : Double,
) -> ComplexVector {
  let n = self.data.length()
  let result = ComplexVector::zeros(n)
  for i in 0..<n {
    result.set(i, self.get(i).scale(alpha))
  }
  result
}

///|
/// Hermitian inner product: <u, v> = sum(conj(u_i) * v_i).
pub fn ComplexVector::dot_hermitian(
  self : ComplexVector,
  other : ComplexVector,
) -> Complex {
  let n = self.data.length()
  let mut sum = Complex::zero()
  for i in 0..<n {
    let term = self.get(i).conj().mul(other.get(i))
    sum = sum.add(term)
  }
  sum
}

///|
/// Standard dot product: sum(u_i * v_i).
pub fn ComplexVector::dot(
  self : ComplexVector,
  other : ComplexVector,
) -> Complex {
  let n = self.data.length()
  let mut sum = Complex::zero()
  for i in 0..<n {
    let term = self.get(i).mul(other.get(i))
    sum = sum.add(term)
  }
  sum
}

///|
/// Computes the Euclidean 2-norm sqrt(sum(|z_i|^2)).
pub fn ComplexVector::norm_l2(self : ComplexVector) -> Double {
  let mut sum_sq = 0.0
  for i in 0..<self.data.length() {
    sum_sq = sum_sq + self.get(i).abs_sq()
  }
  sum_sq.sqrt()
}

///|
/// Computes the infinity norm max(|z_i|).
pub fn ComplexVector::norm_inf(self : ComplexVector) -> Double {
  let mut max_val = 0.0
  for i in 0..<self.data.length() {
    let mag = self.get(i).abs()
    if mag > max_val {
      max_val = mag
    }
  }
  max_val
}

///|
/// In-place axpy: self = self + alpha * x.
pub fn ComplexVector::axpy_inplace(
  self : ComplexVector,
  alpha : Complex,
  x : ComplexVector,
) -> Unit {
  let n = self.data.length()
  for i in 0..<n {
    let updated = self.get(i).add(alpha.mul(x.get(i)))
    self.set(i, updated)
  }
}
