// Linear Algebra Module - Signal Vector Utilities & Signal Processing
// MoonBit Circuit Solver Engine

///|
/// Signal statistics of a 1D vector (mean, std_dev, min, max, rms, peak_to_peak).
pub struct VectorStats {
  mean : Double
  std_dev : Double
  min_val : Double
  max_val : Double
  rms : Double
  peak_to_peak : Double
} derive(Debug, Eq)

///|
/// Computes comprehensive statistical properties of a vector.
pub fn VectorStats::compute(v : Vector) -> VectorStats {
  let len = v.length()
  if len == 0 {
    return VectorStats::{
      mean: 0.0,
      std_dev: 0.0,
      min_val: 0.0,
      max_val: 0.0,
      rms: 0.0,
      peak_to_peak: 0.0,
    }
  }

  let mut sum = 0.0
  let mut sq_sum = 0.0
  let mut min_v = v.get(0)
  let mut max_v = v.get(0)

  for i = 0; i < len; i = i + 1 {
    let val = v.get(i)
    sum = sum + val
    sq_sum = sq_sum + val * val
    if val < min_v {
      min_v = val
    }
    if val > max_v {
      max_v = val
    }
  }

  let mean = sum / len.to_double()
  let rms = (sq_sum / len.to_double()).sqrt()

  let mut var_sum = 0.0
  for i = 0; i < len; i = i + 1 {
    let d = v.get(i) - mean
    var_sum = var_sum + d * d
  }
  let std_dev = (var_sum / len.to_double()).sqrt()
  let peak_to_peak = max_v - min_v

  VectorStats::{
    mean,
    std_dev,
    min_val: min_v,
    max_val: max_v,
    rms,
    peak_to_peak,
  }
}

///|
/// Applies moving average smoothing filter of window size `window_size` to a vector.
pub fn moving_average_filter(v : Vector, window_size : Int) -> Vector {
  let len = v.length()
  if len == 0 || window_size <= 1 {
    return v.copy()
  }

  let res = Array::make(len, 0.0)
  let half = window_size / 2

  for i = 0; i < len; i = i + 1 {
    let mut sum = 0.0
    let mut count = 0
    for j = i - half; j <= i + half; j = j + 1 {
      if j >= 0 && j < len {
        sum = sum + v.get(j)
        count = count + 1
      }
    }
    if count > 0 {
      res[i] = sum / count.to_double()
    }
  }

  Vector::from_array(res)
}
