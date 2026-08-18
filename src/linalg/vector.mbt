// Linear Algebra Module - Vector Operations
// MoonBit Circuit Solver Engine

/// Represents a dense 1D vector of double-precision floating-point numbers.
pub struct Vector {
  data : Array[Double]
} derive(Debug, Eq)

/// Creates a new vector of given dimension initialized with initial value.
pub fn Vector::make(dim : Int, init_val : Double) -> Vector {
  let data = Array::make(dim, init_val)
  Vector::{ data, }
}

/// Creates a zero vector of given dimension.
pub fn Vector::zeros(dim : Int) -> Vector {
  Vector::make(dim, 0.0)
}

/// Creates a vector from an existing array.
pub fn Vector::from_array(arr : Array[Double]) -> Vector {
  let data = arr.copy()
  Vector::{ data, }
}

/// Returns the dimension (length) of the vector.
pub fn Vector::length(self : Vector) -> Int {
  self.data.length()
}

/// Gets element at 0-based index.
pub fn Vector::get(self : Vector, idx : Int) -> Double {
  self.data[idx]
}

/// Sets element at 0-based index.
pub fn Vector::set(self : Vector, idx : Int, val : Double) -> Unit {
  self.data[idx] = val
}

/// Returns a deep copy of the vector.
pub fn Vector::copy(self : Vector) -> Vector {
  let data = self.data.copy()
  Vector::{ data, }
}

/// Adds another vector element-wise and returns a new vector.
pub fn Vector::add(self : Vector, other : Vector) -> Vector {
  let len = self.length()
  if len != other.length() {
    abort("Vector dimension mismatch in add")
  }
  let res = Array::make(len, 0.0)
  for i = 0; i < len; i = i + 1 {
    res[i] = self.data[i] + other.data[i]
  }
  Vector::{ data: res }
}

/// Subtracts another vector element-wise and returns a new vector.
pub fn Vector::sub(self : Vector, other : Vector) -> Vector {
  let len = self.length()
  if len != other.length() {
    abort("Vector dimension mismatch in sub")
  }
  let res = Array::make(len, 0.0)
  for i = 0; i < len; i = i + 1 {
    res[i] = self.data[i] - other.data[i]
  }
  Vector::{ data: res }
}

/// Scales the vector by a scalar value in-place.
pub fn Vector::scale_inplace(self : Vector, scalar : Double) -> Unit {
  let len = self.length()
  for i = 0; i < len; i = i + 1 {
    self.data[i] = self.data[i] * scalar
  }
}

/// Returns a new vector scaled by scalar.
pub fn Vector::scale(self : Vector, scalar : Double) -> Vector {
  let c = self.copy()
  c.scale_inplace(scalar)
  c
}

/// Computes the dot product with another vector.
pub fn Vector::dot(self : Vector, other : Vector) -> Double {
  let len = self.length()
  if len != other.length() {
    abort("Vector dimension mismatch in dot product")
  }
  let mut acc = 0.0
  for i = 0; i < len; i = i + 1 {
    acc = acc + self.data[i] * other.data[i]
  }
  acc
}

/// Computes L1 norm (sum of absolute values).
pub fn Vector::norm_l1(self : Vector) -> Double {
  let len = self.length()
  let mut sum = 0.0
  for i = 0; i < len; i = i + 1 {
    let val = self.data[i]
    sum = sum + (if val < 0.0 { -val } else { val })
  }
  sum
}

/// Computes L2 norm (Euclidean norm).
pub fn Vector::norm_l2(self : Vector) -> Double {
  let sq_sum = self.dot(self)
  sq_sum.sqrt()
}

/// Computes L-infinity norm (maximum absolute value).
pub fn Vector::norm_linf(self : Vector) -> Double {
  let len = self.length()
  let mut max_val = 0.0
  for i = 0; i < len; i = i + 1 {
    let val = self.data[i]
    let abs_val = if val < 0.0 { -val } else { val }
    if abs_val > max_val {
      max_val = abs_val
    }
  }
  max_val
}

/// Computes a linear combination self = self + alpha * v in-place.
pub fn Vector::axpy_inplace(self : Vector, alpha : Double, v : Vector) -> Unit {
  let len = self.length()
  if len != v.length() {
    abort("Vector dimension mismatch in axpy")
  }
  for i = 0; i < len; i = i + 1 {
    self.data[i] = self.data[i] + alpha * v.data[i]
  }
}

/// Maximum absolute difference between self and other vector.
pub fn Vector::max_diff(self : Vector, other : Vector) -> Double {
  let len = self.length()
  if len != other.length() {
    abort("Vector dimension mismatch in max_diff")
  }
  let mut max_d = 0.0
  for i = 0; i < len; i = i + 1 {
    let d = self.data[i] - other.data[i]
    let abs_d = if d < 0.0 { -d } else { d }
    if abs_d > max_d {
      max_d = abs_d
    }
  }
  max_d
}
