// Visualizer & Output Module - Terminal ASCII Waveform Plotter
// MoonBit Circuit Solver Engine

///|
/// Configuration parameters for ASCII chart rendering.
pub struct AsciiChartConfig {
  width : Int
  height : Int
  title : String
} derive(Debug, Eq)

///|
/// Creates default ASCII chart configuration (80 cols, 20 rows).
pub fn AsciiChartConfig::default() -> AsciiChartConfig {
  AsciiChartConfig::{
    width: 70,
    height: 18,
    title: "Transient Waveform Signal",
  }
}

///|
/// Renders a series of 2D data points (time, voltage) as an ASCII text chart.
pub fn render_ascii_chart(
  data : Array[(Double, Double)],
  config : AsciiChartConfig,
) -> String {
  let len = data.length()
  if len == 0 {
    return "No data to render."
  }

  let mut min_x = data[0].0
  let mut max_x = data[0].0
  let mut min_y = data[0].1
  let mut max_y = data[0].1

  for i = 1; i < len; i = i + 1 {
    let x = data[i].0
    let y = data[i].1
    if x < min_x {
      min_x = x
    }
    if x > max_x {
      max_x = x
    }
    if y < min_y {
      min_y = y
    }
    if y > max_y {
      max_y = y
    }
  }

  let y_range = if max_y == min_y { 1.0 } else { max_y - min_y }
  let x_range = if max_x == min_x { 1.0 } else { max_x - min_x }

  let grid = Array::make(config.height * config.width, ' ')

  // Draw plot points
  for i = 0; i < len; i = i + 1 {
    let x = data[i].0
    let y = data[i].1
    let col = ((x - min_x) / x_range * (config.width - 1).to_double()).to_int()
    let row = ((max_y - y) / y_range * (config.height - 1).to_double()).to_int()
    if col >= 0 && col < config.width && row >= 0 && row < config.height {
      grid[row * config.width + col] = '*'
    }
  }

  let mut sb = "=== " + config.title + " ===\n"
  for r = 0; r < config.height; r = r + 1 {
    sb = sb + "|"
    for c = 0; c < config.width; c = c + 1 {
      sb = sb + grid[r * config.width + c].to_string()
    }
    sb = sb + "|\n"
  }
  sb = sb + "+" + String::make(config.width, '-') + "+\n"
  sb = sb +
    "X-axis (Time): " +
    min_x.to_string() +
    "s to " +
    max_x.to_string() +
    "s\n"
  sb = sb +
    "Y-axis (Voltage): " +
    min_y.to_string() +
    "V to " +
    max_y.to_string() +
    "V\n"
  sb
}
