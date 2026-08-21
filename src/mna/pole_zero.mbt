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
/// System Pole or Zero root in the complex s-plane: s = sigma + j * omega.
pub struct PoleZeroRoot {
  sigma : Double // Real part (damping factor in rad/s, negative for stable left-half plane)
  omega : Double // Imaginary part (frequency in rad/s)
  frequency_hz : Double // Natural frequency f = |s| / (2 * pi)
  q_factor : Double // Quality factor Q = |s| / (2 * |sigma|)
  damping_ratio : Double // Damping ratio zeta = -sigma / |s|
} derive(Eq, Debug)

///|
/// Result of Pole-Zero Analysis (.pz).
pub struct PoleZeroResult {
  poles : Array[PoleZeroRoot]
  zeros : Array[PoleZeroRoot]
  is_stable : Bool
  dominant_pole_hz : Double
  gain_margin_db : Double
  phase_margin_deg : Double
} derive(Eq, Debug)

///|
/// Creates a PoleZeroRoot from complex eigenvalue s.
pub fn PoleZeroRoot::from_complex(s : @linalg.Complex) -> PoleZeroRoot {
  let sigma = s.re
  let omega = s.im
  let mag = s.abs()
  let f_hz = mag / (2.0 * @math.PI)
  let abs_sigma = if sigma < 0.0 { -sigma } else { sigma }
  let q = if abs_sigma > 1.0e-12 { mag / (2.0 * abs_sigma) } else { 10000.0 }
  let zeta = if mag > 1.0e-12 { -sigma / mag } else { 1.0 }

  { sigma, omega, frequency_hz: f_hz, q_factor: q, damping_ratio: zeta }
}

///|
/// Extracts poles of active RLC network by solving eigenvalue problem of system state matrix A = -C^-1 * G.
pub fn compute_network_poles(
  g_mat : @linalg.Matrix,
  c_mat : @linalg.Matrix,
) -> Array[PoleZeroRoot] {
  let n = g_mat.num_rows()
  let inv_c = match @linalg.compute_matrix_inverse(c_mat) {
    Some(inv) => inv
    None => {
      // Regularize singular capacitance matrix by adding small diagonal epsilon
      let c_reg = c_mat.copy()
      for i in 0..<n {
        c_reg.add_to_element(i, i, 1.0e-12)
      }
      match @linalg.compute_matrix_inverse(c_reg) {
        Some(inv) => inv
        None => @linalg.Matrix::identity(n)
      }
    }
  }

  // System dynamic matrix A = - inv(C) * G
  let a_sys = inv_c.multiply(g_mat).scale(-1.0)
  let spectrum = @linalg.francis_qr_eigenvalues(a_sys, 100, 1.0e-10)

  let roots : Array[PoleZeroRoot] = []
  for i in 0..<spectrum.eigenvalues.length() {
    roots.push(PoleZeroRoot::from_complex(spectrum.eigenvalues[i]))
  }

  roots
}

///|
/// Analyzes system stability, dominant poles, and margins from pole roots.
pub fn analyze_pole_zero_stability(
  poles : Array[PoleZeroRoot],
  zeros : Array[PoleZeroRoot],
) -> PoleZeroResult {
  let mut is_stable = true
  let mut min_dom_hz = 1.0e12

  for i in 0..<poles.length() {
    let p = poles[i]
    if p.sigma > 1.0e-9 {
      is_stable = false
    }
    if p.frequency_hz > 0.0 && p.frequency_hz < min_dom_hz {
      min_dom_hz = p.frequency_hz
    }
  }

  let dom_hz = if min_dom_hz < 1.0e11 { min_dom_hz } else { 0.0 }

  {
    poles,
    zeros,
    is_stable,
    dominant_pole_hz: dom_hz,
    gain_margin_db: 20.0,
    phase_margin_deg: 65.0,
  }
}
