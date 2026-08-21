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
/// Histogram ASCII Renderer for Monte Carlo distribution binning.
pub struct HistogramConfig {
  num_bins : Int
  bar_max_width : Int
  title : String
} derive(Eq, Debug)

///|
/// Default histogram configuration.
pub fn HistogramConfig::default() -> HistogramConfig {
  {
    num_bins: 10,
    bar_max_width: 30,
    title: "Monte Carlo Statistical Distribution",
  }
}

///|
/// Renders an ASCII Histogram for numerical samples.
pub fn render_ascii_histogram(
  samples : Array[Double],
  cfg : HistogramConfig,
) -> String {
  let n = samples.length()
  if n == 0 {
    return "Empty dataset.\n"
  }

  let mut min_val = samples[0]
  let mut max_val = samples[0]
  for i = 1; i < n; i = i + 1 {
    if samples[i] < min_val {
      min_val = samples[i]
    }
    if samples[i] > max_val {
      max_val = samples[i]
    }
  }

  let span = if max_val > min_val { max_val - min_val } else { 1.0 }
  let num_bins = cfg.num_bins
  let bin_counts = Array::make(num_bins, 0)

  for i = 0; i < n; i = i + 1 {
    let mut b = ((samples[i] - min_val) / span * num_bins.to_double()).to_int()
    if b >= num_bins {
      b = num_bins - 1
    }
    if b < 0 {
      b = 0
    }
    bin_counts[b] = bin_counts[b] + 1
  }

  let mut max_count = 0
  for b = 0; b < num_bins; b = b + 1 {
    if bin_counts[b] > max_count {
      max_count = bin_counts[b]
    }
  }

  let mut buf = "=== " + cfg.title + " === (N = " + n.to_string() + ")\n"
  let bin_width = span / num_bins.to_double()

  for b = 0; b < num_bins; b = b + 1 {
    let bin_start = min_val + b.to_double() * bin_width
    let bin_end = bin_start + bin_width
    let count = bin_counts[b]
    let bar_len = if max_count > 0 {
      (count.to_double() / max_count.to_double() * cfg.bar_max_width.to_double()).to_int()
    } else {
      0
    }

    let mut bar = ""
    for _k = 0; _k < bar_len; _k = _k + 1 {
      bar = bar + "#"
    }

    buf = buf +
      "[" +
      bin_start.to_string() +
      " .. " +
      bin_end.to_string() +
      "] | " +
      bar +
      " (" +
      count.to_string() +
      ")\n"
  }

  buf
}
