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
/// Renders an SVG Smith Chart with complex reflection coefficient trajectory.
pub fn render_smith_chart_svg(
  gamma_points : Array[@linalg.Complex],
  size : Double,
  title : String,
) -> String {
  let cx = size / 2.0
  let cy = size / 2.0
  let r_unit = size * 0.40

  let mut svg = "<svg xmlns=\"http://www.w3.org/2000/svg\" width=\"" +
    size.to_string() +
    "\" height=\"" +
    size.to_string() +
    "\" viewBox=\"0 0 " +
    size.to_string() +
    " " +
    size.to_string() +
    "\">\n"

  // Background
  svg = svg + "  <rect width=\"100%\" height=\"100%\" fill=\"#181825\"/>\n"

  // Title
  svg = svg +
    "  <text x=\"" +
    cx.to_string() +
    "\" y=\"30\" font-family=\"sans-serif\" font-size=\"16\" font-weight=\"bold\" fill=\"#cdd6f4\" text-anchor=\"middle\">" +
    title +
    "</text>\n"

  // Outer Circle |Gamma| = 1
  svg = svg +
    "  <circle cx=\"" +
    cx.to_string() +
    "\" cy=\"" +
    cy.to_string() +
    "\" r=\"" +
    r_unit.to_string() +
    "\" fill=\"none\" stroke=\"#89b4fa\" stroke-width=\"2\"/>\n"

  // Real Axis (Horizontal Line)
  svg = svg +
    "  <line x1=\"" +
    (cx - r_unit).to_string() +
    "\" y1=\"" +
    cy.to_string() +
    "\" x2=\"" +
    (cx + r_unit).to_string() +
    "\" y2=\"" +
    cy.to_string() +
    "\" stroke=\"#45475a\" stroke-width=\"1.2\"/>\n"

  // Constant Resistance Circles: Center = (r/(1+r), 0), Radius = 1/(1+r)
  let r_values = [0.2, 0.5, 1.0, 2.0, 5.0]
  for r in r_values {
    let circle_r = 1.0 / (1.0 + r) * r_unit
    let circle_cx = cx + r / (1.0 + r) * r_unit
    svg = svg +
      "  <circle cx=\"" +
      circle_cx.to_string() +
      "\" cy=\"" +
      cy.to_string() +
      "\" r=\"" +
      circle_r.to_string() +
      "\" fill=\"none\" stroke=\"#313244\" stroke-width=\"1\"/>\n"
  }

  // Trajectory Plot
  let n = gamma_points.length()
  if n > 0 {
    svg = svg + "  <path d=\"M "
    for i in 0..<n {
      let g = gamma_points[i]
      let px = cx + g.re * r_unit
      let py = cy - g.im * r_unit // SVG y-axis is inverted
      if i > 0 {
        svg = svg + " L "
      }
      svg = svg + px.to_string() + " " + py.to_string()
    }
    svg = svg + "\" fill=\"none\" stroke=\"#f38ba8\" stroke-width=\"2.5\"/>\n"

    // Markers on start and end
    let start_px = cx + gamma_points[0].re * r_unit
    let start_py = cy - gamma_points[0].im * r_unit
    svg = svg +
      "  <circle cx=\"" +
      start_px.to_string() +
      "\" cy=\"" +
      start_py.to_string() +
      "\" r=\"4\" fill=\"#a6e3a1\"/>\n"

    let end_px = cx + gamma_points[n - 1].re * r_unit
    let end_py = cy - gamma_points[n - 1].im * r_unit
    svg = svg +
      "  <circle cx=\"" +
      end_px.to_string() +
      "\" cy=\"" +
      end_py.to_string() +
      "\" r=\"4\" fill=\"#f38ba8\"/>\n"
  }

  svg = svg + "</svg>\n"
  svg
}
