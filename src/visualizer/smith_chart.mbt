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
/// Config for Smith Chart ASCII rendering.
pub struct SmithChartConfig {
  radius : Int
  title : String
} derive(Eq, Debug)

///|
/// Default Smith chart configuration.
pub fn SmithChartConfig::default() -> SmithChartConfig {
  { radius: 12, title: "RF Impedance Smith Chart" }
}

///|
/// Converts normalized complex impedance z = r + j*x to complex reflection coefficient Gamma = (z - 1) / (z + 1).
pub fn impedance_to_gamma(z : @linalg.Complex) -> @linalg.Complex {
  let num = z.sub(@linalg.Complex::one())
  let den = z.add(@linalg.Complex::one())
  num.div(den)
}

///|
/// Renders an ASCII Smith Chart with reflection coefficient points plotted.
pub fn render_ascii_smith_chart(
  gamma_points : Array[@linalg.Complex],
  cfg : SmithChartConfig,
) -> String {
  let r = cfg.radius
  let size = 2 * r + 1
  let grid = Array::make(size * size, " ")

  // Draw unit circle perimeter
  for y = -r; y <= r; y = y + 1 {
    for x = -r; x <= r; x = x + 1 {
      let d_sq = x * x + y * y
      let row = r - y
      let col = x + r
      if d_sq == r * r || d_sq == (r - 1) * (r - 1) {
        grid[row * size + col] = "o"
      } else if y == 0 && d_sq <= r * r {
        grid[row * size + col] = "-" // Real axis
      } else if x == 0 && d_sq <= r * r {
        grid[row * size + col] = "|" // Center imaginary line
      }
    }
  }

  // Plot Gamma points
  for i = 0; i < gamma_points.length(); i = i + 1 {
    let g = gamma_points[i]
    let gx = (g.re * r.to_double() + 0.5).to_int()
    let gy = (g.im * r.to_double() + 0.5).to_int()

    let row = r - gy
    let col = gx + r

    if row >= 0 && row < size && col >= 0 && col < size {
      grid[row * size + col] = "*"
    }
  }

  let mut buf = "=== " + cfg.title + " ===\n"
  for row = 0; row < size; row = row + 1 {
    for col = 0; col < size; col = col + 1 {
      buf = buf + grid[row * size + col]
    }
    buf = buf + "\n"
  }

  buf
}
