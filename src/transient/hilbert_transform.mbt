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
/// Analytic Signal representation containing instantaneous envelope and phase.
pub struct AnalyticSignal {
  envelope : Array[Double]
  phase : Array[Double]
  analytic_complex : Array[@linalg.Complex]
} derive(Eq, Debug)

///|
/// Computes the Discrete Hilbert Transform of a real signal using FFT.
pub fn compute_hilbert_transform(signal : Array[Double]) -> Array[Double] {
  let raw_n = signal.length()
  let mut n = 1
  while n * 2 <= raw_n {
    n = n * 2
  }

  let complex_in = Array::make(n, @linalg.Complex::zero())
  for i in 0..<n {
    complex_in[i] = @linalg.Complex::new(signal[i], 0.0)
  }

  let spectrum = cooley_tukey_fft(complex_in, false)

  // Frequency-domain Hilbert multiplier: H[0]=0, H[N/2]=0, H[k]=-j for 0<k<N/2, H[k]=+j for N/2<k<N
  let hilbert_spec = Array::make(n, @linalg.Complex::zero())
  for k = 1; k < n / 2; k = k + 1 {
    // multiply by -j: (re + j*im)*(-j) = im - j*re
    let orig = spectrum[k]
    hilbert_spec[k] = @linalg.Complex::new(orig.im, -orig.re)
  }
  for k = n / 2 + 1; k < n; k = k + 1 {
    // multiply by +j: (re + j*im)*(+j) = -im + j*re
    let orig = spectrum[k]
    hilbert_spec[k] = @linalg.Complex::new(-orig.im, orig.re)
  }

  let time_hilbert = cooley_tukey_fft(hilbert_spec, true)
  let result = Array::make(n, 0.0)
  for i in 0..<n {
    result[i] = time_hilbert[i].re
  }

  result
}

///|
/// Extracts analytic signal, instantaneous amplitude envelope, and instantaneous phase.
pub fn extract_analytic_signal(signal : Array[Double]) -> AnalyticSignal {
  let raw_n = signal.length()
  let mut n = 1
  while n * 2 <= raw_n {
    n = n * 2
  }

  let hilbert_imag = compute_hilbert_transform(signal)
  let envelope = Array::make(n, 0.0)
  let phase = Array::make(n, 0.0)
  let analytic_complex = Array::make(n, @linalg.Complex::zero())

  for i in 0..<n {
    let re = signal[i]
    let im = hilbert_imag[i]
    let env = (re * re + im * im).sqrt()
    let ph = @math.atan2(im, re)

    envelope[i] = env
    phase[i] = ph
    analytic_complex[i] = @linalg.Complex::new(re, im)
  }

  { envelope, phase, analytic_complex }
}
