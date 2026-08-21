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
/// Windowing function type for FFT spectral leak suppression.
pub(all) enum FftWindow {
  Rectangular
  Hanning
  Hamming
  Blackman
} derive(Eq, Debug)

///|
/// Single spectral harmonic bin result.
pub struct FftHarmonicBin {
  harmonic_index : Int
  frequency_hz : Double
  magnitude : Double
  phase_deg : Double
  magnitude_db : Double
} derive(Eq, Debug)

///|
/// Result of Transient FFT Harmonic Spectral Analysis (.four).
pub struct FftAnalysisResult {
  fundamental_freq_hz : Double
  sampling_rate_hz : Double
  num_samples : Int
  thd_percent : Double
  snr_db : Double
  sinad_db : Double
  enob_bits : Double // Effective Number of Bits = (SINAD - 1.76) / 6.02
  harmonics : Array[FftHarmonicBin]
} derive(Eq, Debug)

///|
/// Applies windowing function to signal in-place.
pub fn apply_fft_window(
  signal : Array[Double],
  window : FftWindow,
) -> Array[Double] {
  let n = signal.length()
  let win_sig = Array::make(n, 0.0)

  for i in 0..<n {
    let w = match window {
      Rectangular => 1.0
      Hanning =>
        0.5 *
        (1.0 - @math.cos(2.0 * @math.PI * i.to_double() / (n - 1).to_double()))
      Hamming =>
        0.54 -
        0.46 * @math.cos(2.0 * @math.PI * i.to_double() / (n - 1).to_double())
      Blackman =>
        0.42 -
        0.5 * @math.cos(2.0 * @math.PI * i.to_double() / (n - 1).to_double()) +
        0.08 * @math.cos(4.0 * @math.PI * i.to_double() / (n - 1).to_double())
    }
    win_sig[i] = signal[i] * w
  }

  win_sig
}

///|
/// In-place Bit-Reversal Permutation for Radix-2 FFT.
fn bit_reverse_permute(data : Array[@linalg.Complex]) -> Unit {
  let n = data.length()
  let mut j = 0
  for i in 0..<(n - 1) {
    if i < j {
      let tmp = data[i]
      data[i] = data[j]
      data[j] = tmp
    }
    let mut k = n / 2
    while k <= j {
      j = j - k
      k = k / 2
    }
    j = j + k
  }
}

///|
/// Computes Cooley-Tukey Radix-2 Decimation-In-Time Fast Fourier Transform (FFT).
/// Array length must be a power of 2.
pub fn cooley_tukey_fft(
  input : Array[@linalg.Complex],
  inverse : Bool,
) -> Array[@linalg.Complex] {
  let n = input.length()
  let result = Array::make(n, @linalg.Complex::zero())
  for i in 0..<n {
    result[i] = input[i]
  }

  bit_reverse_permute(result)

  let sign = if inverse { 1.0 } else { -1.0 }

  let mut len = 2
  while len <= n {
    let angle = sign * 2.0 * @math.PI / len.to_double()
    let wlen = @linalg.Complex::from_polar(1.0, angle)

    let half = len / 2
    let mut i = 0
    while i < n {
      let mut w = @linalg.Complex::one()
      for j in 0..<half {
        let u = result[i + j]
        let v = result[i + j + half].mul(w)
        result[i + j] = u.add(v)
        result[i + j + half] = u.sub(v)
        w = w.mul(wlen)
      }
      i = i + len
    }
    len = len * 2
  }

  if inverse {
    let inv_n = 1.0 / n.to_double()
    for i in 0..<n {
      result[i] = result[i].scale(inv_n)
    }
  }

  result
}

///|
/// Computes FFT harmonic spectral analysis from transient time-voltage waveform samples.
pub fn compute_transient_fft_analysis(
  time_samples : Array[Double],
  voltage_samples : Array[Double],
  fundamental_freq_hz : Double,
  window : FftWindow,
) -> FftAnalysisResult {
  let raw_n = voltage_samples.length()
  // Round down to largest power of 2
  let mut n = 1
  while n * 2 <= raw_n {
    n = n * 2
  }

  let dt = if n > 1 {
    (time_samples[n - 1] - time_samples[0]) / (n - 1).to_double()
  } else {
    1.0e-6
  }
  let fs = 1.0 / dt

  let windowed_raw = Array::make(n, 0.0)
  for i in 0..<n {
    windowed_raw[i] = voltage_samples[i]
  }
  let windowed = apply_fft_window(windowed_raw, window)

  let complex_in = Array::make(n, @linalg.Complex::zero())
  for i in 0..<n {
    complex_in[i] = @linalg.Complex::new(windowed[i], 0.0)
  }

  let spectrum = cooley_tukey_fft(complex_in, false)

  let harmonics : Array[FftHarmonicBin] = []
  let bin_resolution = fs / n.to_double()

  let mut fund_mag = 0.0
  let mut harmonic_power_sum = 0.0

  for h = 1; h <= 10; h = h + 1 {
    let target_f = fundamental_freq_hz * h.to_double()
    let bin_idx = (target_f / bin_resolution + 0.5).to_int()

    if bin_idx < n / 2 {
      let raw_mag = spectrum[bin_idx].abs() * 2.0 / n.to_double()
      let phase_rad = spectrum[bin_idx].arg()
      let phase_deg = phase_rad * 180.0 / @math.PI
      let mag_db = if raw_mag > 1.0e-15 {
        20.0 * @math.log10(raw_mag)
      } else {
        -300.0
      }

      if h == 1 {
        fund_mag = raw_mag
      } else {
        harmonic_power_sum = harmonic_power_sum + raw_mag * raw_mag
      }

      harmonics.push({
        harmonic_index: h,
        frequency_hz: target_f,
        magnitude: raw_mag,
        phase_deg,
        magnitude_db: mag_db,
      })
    }
  }

  let thd = if fund_mag > 1.0e-15 {
    harmonic_power_sum.sqrt() / fund_mag * 100.0
  } else {
    0.0
  }

  let sinad = if thd > 1.0e-6 { 20.0 * @math.log10(100.0 / thd) } else { 120.0 }

  let enob = (sinad - 1.76) / 6.02

  {
    fundamental_freq_hz,
    sampling_rate_hz: fs,
    num_samples: n,
    thd_percent: thd,
    snr_db: sinad,
    sinad_db: sinad,
    enob_bits: enob,
    harmonics,
  }
}
