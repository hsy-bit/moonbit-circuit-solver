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
/// Nyquist plot ASCII configuration.
pub struct NyquistPlotConfig {
  width : Int
  height : Int
  title : String
} derive(Eq, Debug)

///|
/// Default Nyquist plot configuration.
pub fn NyquistPlotConfig::default() -> NyquistPlotConfig {
  { width: 40, height: 20, title: "Nyquist Stability Diagram" }
}

///|
/// Renders Nyquist Diagram (Im(H) vs Re(H)) in terminal ASCII.
pub fn render_ascii_nyquist_plot(
  complex_points : Array[@linalg.Complex],
  cfg : NyquistPlotConfig,
) -> String {
  let w = cfg.width
  let h = cfg.height
  let grid = Array::make(w * h, " ")

  let mut max_re = -1.0e10
  let mut min_re = 1.0e10
  let mut max_im = -1.0e10
  let mut min_im = 1.0e10

  for i = 0; i < complex_points.length(); i = i + 1 {
    let pt = complex_points[i]
    if pt.re > max_re {
      max_re = pt.re
    }
    if pt.re < min_re {
      min_re = pt.re
    }
    if pt.im > max_im {
      max_im = pt.im
    }
    if pt.im < min_im {
      min_im = pt.im
    }
  }

  // Include critical point (-1, 0)
  if -1.0 < min_re {
    min_re = -1.5
  }
  if 1.0 > max_re {
    max_re = 1.5
  }
  if -1.0 < min_im {
    min_im = -1.5
  }
  if 1.0 > max_im {
    max_im = 1.5
  }

  let span_re = if max_re > min_re { max_re - min_re } else { 1.0 }
  let span_im = if max_im > min_im { max_im - min_im } else { 1.0 }

  // Draw axes
  let zero_col = (-min_re / span_re * (w - 1).to_double()).to_int()
  let zero_row = (max_im / span_im * (h - 1).to_double()).to_int()

  for r = 0; r < h; r = r + 1 {
    if zero_col >= 0 && zero_col < w {
      grid[r * w + zero_col] = "|"
    }
  }
  for c = 0; c < w; c = c + 1 {
    if zero_row >= 0 && zero_row < h {
      grid[zero_row * w + c] = "-"
    }
  }

  // Mark critical point (-1, 0)
  let crit_col = ((-1.0 - min_re) / span_re * (w - 1).to_double()).to_int()
  if crit_col >= 0 && crit_col < w && zero_row >= 0 && zero_row < h {
    grid[zero_row * w + crit_col] = "X"
  }

  // Plot response curve
  for i = 0; i < complex_points.length(); i = i + 1 {
    let pt = complex_points[i]
    let col = ((pt.re - min_re) / span_re * (w - 1).to_double()).to_int()
    let row = ((max_im - pt.im) / span_im * (h - 1).to_double()).to_int()

    if row >= 0 && row < h && col >= 0 && col < w {
      grid[row * w + col] = "*"
    }
  }

  let mut s = "=== " + cfg.title + " === (X = Critical Point -1+0j)\n"
  for r = 0; r < h; r = r + 1 {
    for c = 0; c < w; c = c + 1 {
      s = s + grid[r * w + c]
    }
    s = s + "\n"
  }

  s
}
