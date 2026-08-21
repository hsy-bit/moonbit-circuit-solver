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
test "Smith Chart renderer and impedance reflection mapping" {
  // 50 Ohm matched load -> Gamma = 0
  let z_matched = @linalg.Complex::new(1.0, 0.0) // Normalized
  let gamma_match = impedance_to_gamma(z_matched)
  assert_true(gamma_match.abs() < 1.0e-12)

  // Short circuit -> Gamma = -1
  let z_short = @linalg.Complex::new(0.0, 0.0)
  let gamma_short = impedance_to_gamma(z_short)
  assert_true((gamma_short.re - -1.0).abs() < 1.0e-12)

  // Render ASCII Smith Chart
  let cfg = SmithChartConfig::default()
  let chart_str = render_ascii_smith_chart([gamma_match, gamma_short], cfg)
  assert_true(chart_str.length() > 50)
  assert_true(chart_str.contains("RF Impedance Smith Chart"))
}

///|
test "Digital Eye Diagram quantitative metrics" {
  let t_bit = 1.0e-9 // 1 Gbps
  let t_pts : Array[Double] = []
  let v_pts : Array[Double] = []

  for i in 0..<100 {
    let t = i.to_double() * 0.1e-9
    let bit = i / 10 % 2
    let v = if bit == 1 { 3.3 } else { 0.0 }
    t_pts.push(t)
    v_pts.push(v)
  }

  let eye = compute_eye_metrics(t_pts, v_pts, t_bit)
  assert_true(eye.eye_width_seconds > 0.0)
  assert_true(eye.jitter_rms_seconds > 0.0)
}

///|
test "Nyquist Stability Diagram ASCII renderer" {
  let cfg = NyquistPlotConfig::default()
  let points = [
    @linalg.Complex::new(1.0, 0.0),
    @linalg.Complex::new(0.5, -0.5),
    @linalg.Complex::new(0.0, -1.0),
    @linalg.Complex::new(-0.5, -0.5),
  ]

  let nyq_str = render_ascii_nyquist_plot(points, cfg)
  assert_true(nyq_str.length() > 50)
  assert_true(nyq_str.contains("Nyquist Stability Diagram"))
}

///|
test "Monte Carlo Statistical Histogram ASCII renderer" {
  let cfg = HistogramConfig::default()
  let samples = [4.8, 4.9, 5.0, 5.0, 5.0, 5.1, 5.1, 5.2]

  let hist_str = render_ascii_histogram(samples, cfg)
  assert_true(hist_str.length() > 30)
  assert_true(hist_str.contains("Monte Carlo Statistical Distribution"))
}
