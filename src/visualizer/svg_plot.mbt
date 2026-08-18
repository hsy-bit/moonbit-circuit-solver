// Visualizer Module - Vector SVG Plot Renderer
// MoonBit Circuit Solver Engine

/// Renders a 2D dataset as a standalone SVG graphic string.
pub fn render_svg_waveform(data : Array[(Double, Double)], width : Int, height : Int, title : String) -> String {
  let len = data.length()
  if len == 0 {
    return "<svg width=\"100\" height=\"100\"></svg>"
  }

  let mut min_x = data[0].0
  let mut max_x = data[0].0
  let mut min_y = data[0].1
  let mut max_y = data[0].1

  for i = 1; i < len; i = i + 1 {
    let x = data[i].0
    let y = data[i].1
    if x < min_x { min_x = x }
    if x > max_x { max_x = x }
    if y < min_y { min_y = y }
    if y > max_y { max_y = y }
  }

  let margin = 50.0
  let w_draw = width.to_double() - 2.0 * margin
  let h_draw = height.to_double() - 2.0 * margin

  let x_range = if max_x == min_x { 1.0 } else { max_x - min_x }
  let y_range = if max_y == min_y { 1.0 } else { max_y - min_y }

  let mut points_str = ""
  for i = 0; i < len; i = i + 1 {
    let x = data[i].0
    let y = data[i].1
    let px = margin + (x - min_x) / x_range * w_draw
    let py = margin + (max_y - y) / y_range * h_draw
    if i > 0 {
      points_str = points_str + " "
    }
    points_str = points_str + px.to_string() + "," + py.to_string()
  }

  let mut svg = "<svg xmlns=\"http://www.w3.org/2000/svg\" width=\"" + width.to_string() + "\" height=\"" + height.to_string() + "\">\n"
  svg = svg + "<rect width=\"100%\" height=\"100%\" fill=\"#1e1e2e\"/>\n"
  svg = svg + "<text x=\"" + (width / 2).to_string() + "\" y=\"30\" fill=\"#cdd6f4\" font-family=\"monospace\" font-size=\"16\" text-anchor=\"middle\">" + title + "</text>\n"
  svg = svg + "<polyline fill=\"none\" stroke=\"#89b4fa\" stroke-width=\"2\" points=\"" + points_str + "\"/>\n"
  svg = svg + "</svg>\n"
  svg
}
