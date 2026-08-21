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
/// Result of 1-Level Discrete Wavelet Transform (DWT) Decomposition.
pub struct DwtDecomposition {
  approx : Array[Double] // Low-frequency approximation coefficients cA
  detail : Array[Double] // High-frequency detail coefficients cD
} derive(Eq, Debug)

///|
/// Daubechies 4-Tap (DB4) Orthogonal Wavelet Filter Coefficients.
let db4_h0 : Double = 0.4829629131445341

///|
let db4_h1 : Double = 0.8365163037378077

///|
let db4_h2 : Double = 0.2241438680420134

///|
let db4_h3 : Double = -0.1294095225512603

///|
let db4_g0 : Double = -0.1294095225512603

///|
let db4_g1 : Double = -0.2241438680420134

///|
let db4_g2 : Double = 0.8365163037378077

///|
let db4_g3 : Double = -0.4829629131445341

///|
/// Performs 1-Level Forward DWT using Daubechies DB4 filter bank with downsampling by 2.
pub fn dwt_db4_forward(signal : Array[Double]) -> DwtDecomposition {
  let n = signal.length()
  let half_n = n / 2
  let approx = Array::make(half_n, 0.0)
  let detail = Array::make(half_n, 0.0)

  for i = 0; i < half_n; i = i + 1 {
    let idx0 = 2 * i
    let idx1 = (2 * i + 1) % n
    let idx2 = (2 * i + 2) % n
    let idx3 = (2 * i + 3) % n

    // Low-pass scaling filter
    approx[i] = db4_h0 * signal[idx0] +
      db4_h1 * signal[idx1] +
      db4_h2 * signal[idx2] +
      db4_h3 * signal[idx3]
    // High-pass wavelet filter
    detail[i] = db4_g0 * signal[idx0] +
      db4_g1 * signal[idx1] +
      db4_g2 * signal[idx2] +
      db4_g3 * signal[idx3]
  }

  { approx, detail }
}

///|
/// Evaluates Morlet complex continuous wavelet at time t and scale s.
pub fn morlet_wavelet(
  t : Double,
  scale : Double,
  omega0 : Double,
) -> @linalg.Complex {
  let tau = t / scale
  let pi_fourth = 1.0 / 3.141592653589793.sqrt().sqrt() // pi^(-1/4) ~ 0.7511
  let gaussian = @math.exp(-0.5 * tau * tau)
  let envelope = pi_fourth / scale.sqrt() * gaussian

  let phase = omega0 * tau
  let re = envelope * @math.cos(phase)
  let im = envelope * @math.sin(phase)

  @linalg.Complex::new(re, im)
}

///|
/// Computes Continuous Wavelet Transform (CWT) scalogram energy at a target scale.
pub fn compute_cwt_energy_at_scale(
  signal : Array[Double],
  scale : Double,
  omega0 : Double,
) -> Double {
  let n = signal.length()
  let mut total_energy = 0.0

  for i in 0..<n {
    let t = i.to_double() - n.to_double() / 2.0
    let w = morlet_wavelet(t, scale, omega0)
    let sample_val = signal[i]
    let re_part = sample_val * w.re
    let im_part = sample_val * w.im
    total_energy = total_energy + (re_part * re_part + im_part * im_part)
  }

  total_energy
}
