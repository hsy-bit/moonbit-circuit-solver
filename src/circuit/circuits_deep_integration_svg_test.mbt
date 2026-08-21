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
test "SVG Test 01: Waveform SVG Rendering Validation" {
  let times = [0.0, 0.001, 0.002, 0.003, 0.004, 0.005]
  let voltages = [0.0, 2.5, 5.0, 2.5, 0.0, -2.5]
  let cfg = @visualizer.SvgPlotConfig::default()

  let svg_str = @visualizer.render_waveform_svg(cfg, times, voltages)
  assert_true(svg_str.contains("<svg"))
  assert_true(svg_str.contains("</svg>"))
  assert_true(svg_str.contains("SPICE Simulation Waveform"))
}

///|
test "SVG Test 02: Smith Chart SVG Rendering Validation" {
  let gamma_pts = [
    @linalg.Complex::new(0.0, 0.0),
    @linalg.Complex::new(0.2, 0.3),
    @linalg.Complex::new(0.5, 0.1),
    @linalg.Complex::new(0.8, -0.2),
  ]

  let svg_chart = @visualizer.render_smith_chart_svg(
    gamma_pts, 600.0, "RF Amplifier S11 Locus",
  )
  assert_true(svg_chart.contains("<svg"))
  assert_true(svg_chart.contains("RF Amplifier S11 Locus"))
  assert_true(svg_chart.contains("<circle"))
}
