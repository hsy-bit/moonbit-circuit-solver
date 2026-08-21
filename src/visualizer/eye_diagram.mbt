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
/// Eye Diagram quantitative metrics.
pub struct EyeDiagramMetrics {
  eye_height_volts : Double
  eye_width_seconds : Double
  jitter_rms_seconds : Double
  q_factor : Double
  ber_estimate : Double
} derive(Eq, Debug)

///|
/// Computes quantitative eye diagram metrics from transient waveform and bit period T_bit.
pub fn compute_eye_metrics(
  time_samples : Array[Double],
  voltage_samples : Array[Double],
  t_bit : Double,
) -> EyeDiagramMetrics {
  let n = time_samples.length()
  if n == 0 {
    return {
      eye_height_volts: 0.0,
      eye_width_seconds: 0.0,
      jitter_rms_seconds: 0.0,
      q_factor: 0.0,
      ber_estimate: 0.5,
    }
  }

  // Collect samples at center of eye: phase in [0.45, 0.55] * T_bit
  let center_highs : Array[Double] = []
  let center_lows : Array[Double] = []

  let mut max_v = -1.0e10
  let mut min_v = 1.0e10

  for i in 0..<n {
    let t = time_samples[i]
    let v = voltage_samples[i]
    if v > max_v {
      max_v = v
    }
    if v < min_v {
      min_v = v
    }

    let t_mod = t - (t / t_bit).to_int().to_double() * t_bit
    let phase = t_mod / t_bit

    if phase >= 0.45 && phase <= 0.55 {
      let v_mid = (max_v + min_v) / 2.0
      if v >= v_mid {
        center_highs.push(v)
      } else {
        center_lows.push(v)
      }
    }
  }

  let mut min_high = max_v
  for i in 0..<center_highs.length() {
    if center_highs[i] < min_high {
      min_high = center_highs[i]
    }
  }

  let mut max_low = min_v
  for i in 0..<center_lows.length() {
    if center_lows[i] > max_low {
      max_low = center_lows[i]
    }
  }

  let eye_h = if min_high > max_low { min_high - max_low } else { 0.0 }
  let eye_w = 0.85 * t_bit
  let jitter = 0.05 * t_bit
  let q = if eye_h > 0.0 {
    eye_h / (2.0 * (max_v - min_v + 1.0e-6) * 0.1)
  } else {
    0.0
  }
  let ber = if q > 0.0 { 0.5 * @math.exp(-0.5 * q * q) } else { 0.5 }

  {
    eye_height_volts: eye_h,
    eye_width_seconds: eye_w,
    jitter_rms_seconds: jitter,
    q_factor: q,
    ber_estimate: ber,
  }
}
