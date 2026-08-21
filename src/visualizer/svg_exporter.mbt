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
/// SVG Chart Configuration Options.
pub struct SvgPlotConfig {
  width : Double
  height : Double
  padding_left : Double
  padding_right : Double
  padding_top : Double
  padding_bottom : Double
  title : String
  x_label : String
  y_label : String
  grid_lines : Bool
  background_color : String
  stroke_color : String
  grid_color : String
  stroke_width : Double
} derive(Eq, Debug)

///|
/// Default configuration for technical EDA publication vector charts.
pub fn SvgPlotConfig::default() -> SvgPlotConfig {
  {
    width: 800.0,
    height: 500.0,
    padding_left: 70.0,
    padding_right: 40.0,
    padding_top: 50.0,
    padding_bottom: 60.0,
    title: "SPICE Simulation Waveform",
    x_label: "Time (s)",
    y_label: "Voltage (V)",
    grid_lines: true,
    background_color: "#1e1e2e",
    stroke_color: "#89b4fa",
    grid_color: "#313244",
    stroke_width: 2.0,
  }
}

///|
/// Renders 2D time-domain or frequency-domain data series into standalone W3C SVG vector xml string.
pub fn render_waveform_svg(
  cfg : SvgPlotConfig,
  time_points : Array[Double],
  val_points : Array[Double],
) -> String {
  let n = time_points.length()
  if n == 0 || n != val_points.length() {
    return "<svg width=\"800\" height=\"500\"></svg>"
  }

  // Find bounding box
  let mut x_min = time_points[0]
  let mut x_max = time_points[0]
  let mut y_min = val_points[0]
  let mut y_max = val_points[0]

  for i in 0..<n {
    let t = time_points[i]
    let v = val_points[i]
    if t < x_min {
      x_min = t
    }
    if t > x_max {
      x_max = t
    }
    if v < y_min {
      y_min = v
    }
    if v > y_max {
      y_max = v
    }
  }

  let x_span = if (x_max - x_min).abs() > 1.0e-15 { x_max - x_min } else { 1.0 }
  let y_span = if (y_max - y_min).abs() > 1.0e-15 { y_max - y_min } else { 1.0 }

  let plot_w = cfg.width - cfg.padding_left - cfg.padding_right
  let plot_h = cfg.height - cfg.padding_top - cfg.padding_bottom

  let mut svg = "<svg xmlns=\"http://www.w3.org/2000/svg\" width=\"" +
    cfg.width.to_string() +
    "\" height=\"" +
    cfg.height.to_string() +
    "\" viewBox=\"0 0 " +
    cfg.width.to_string() +
    " " +
    cfg.height.to_string() +
    "\">\n"

  // Background
  svg = svg +
    "  <rect width=\"100%\" height=\"100%\" fill=\"" +
    cfg.background_color +
    "\"/>\n"

  // Title
  svg = svg +
    "  <text x=\"" +
    (cfg.width / 2.0).to_string() +
    "\" y=\"30\" font-family=\"sans-serif\" font-size=\"18\" font-weight=\"bold\" fill=\"#cdd6f4\" text-anchor=\"middle\">" +
    cfg.title +
    "</text>\n"

  // Axis Labels
  svg = svg +
    "  <text x=\"" +
    (cfg.padding_left + plot_w / 2.0).to_string() +
    "\" y=\"" +
    (cfg.height - 15.0).to_string() +
    "\" font-family=\"sans-serif\" font-size=\"13\" fill=\"#a6adc8\" text-anchor=\"middle\">" +
    cfg.x_label +
    "</text>\n"
  svg = svg +
    "  <text x=\"20\" y=\"" +
    (cfg.padding_top + plot_h / 2.0).to_string() +
    "\" font-family=\"sans-serif\" font-size=\"13\" fill=\"#a6adc8\" text-anchor=\"middle\" transform=\"rotate(-90 20 " +
    (cfg.padding_top + plot_h / 2.0).to_string() +
    ")\">" +
    cfg.y_label +
    "</text>\n"

  // Grid Lines
  if cfg.grid_lines {
    let num_grid = 8
    for g = 0; g <= num_grid; g = g + 1 {
      let gx = cfg.padding_left + g.to_double() / num_grid.to_double() * plot_w
      let gy = cfg.padding_top + g.to_double() / num_grid.to_double() * plot_h
      // Vertical grid
      svg = svg +
        "  <line x1=\"" +
        gx.to_string() +
        "\" y1=\"" +
        cfg.padding_top.to_string() +
        "\" x2=\"" +
        gx.to_string() +
        "\" y2=\"" +
        (cfg.padding_top + plot_h).to_string() +
        "\" stroke=\"" +
        cfg.grid_color +
        "\" stroke-width=\"1\" stroke-dasharray=\"4 4\"/>\n"
      // Horizontal grid
      svg = svg +
        "  <line x1=\"" +
        cfg.padding_left.to_string() +
        "\" y1=\"" +
        gy.to_string() +
        "\" x2=\"" +
        (cfg.padding_left + plot_w).to_string() +
        "\" y2=\"" +
        gy.to_string() +
        "\" stroke=\"" +
        cfg.grid_color +
        "\" stroke-width=\"1\" stroke-dasharray=\"4 4\"/>\n"
    }
  }

  // Plot Border Box
  svg = svg +
    "  <rect x=\"" +
    cfg.padding_left.to_string() +
    "\" y=\"" +
    cfg.padding_top.to_string() +
    "\" width=\"" +
    plot_w.to_string() +
    "\" height=\"" +
    plot_h.to_string() +
    "\" fill=\"none\" stroke=\"#45475a\" stroke-width=\"1.5\"/>\n"

  // Polyline Path
  svg = svg + "  <path d=\"M "
  for i in 0..<n {
    let px = cfg.padding_left + (time_points[i] - x_min) / x_span * plot_w
    let py = cfg.padding_top +
      plot_h -
      (val_points[i] - y_min) / y_span * plot_h
    if i > 0 {
      svg = svg + " L "
    }
    svg = svg + px.to_string() + " " + py.to_string()
  }
  svg = svg +
    "\" fill=\"none\" stroke=\"" +
    cfg.stroke_color +
    "\" stroke-width=\"" +
    cfg.stroke_width.to_string() +
    "\"/>\n"

  svg = svg + "</svg>\n"
  svg
}
