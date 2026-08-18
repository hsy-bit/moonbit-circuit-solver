// Visualizer Module - Terminal ASCII Bode Plot Renderer
// MoonBit Circuit Solver Engine

///|
/// Renders a Bode Magnitude plot (dB vs frequency Hz) as ASCII art.
pub fn render_ascii_bode_plot(
  sweep_pts : Array[@mna.AcPoint],
  target_node : String,
) -> String {
  let len = sweep_pts.length()
  if len == 0 {
    return "No AC sweep data to render."
  }

  let data : Array[(Double, Double)] = []
  for pt in sweep_pts {
    let f = pt.freq
    let mag = match pt.magnitude.get(target_node) {
      Some(v) => v
      None => 0.0
    }
    let db = @mna.to_db(mag)
    data.push((f, db))
  }

  let config = AsciiChartConfig::{
    width: 70,
    height: 18,
    title: "Bode Magnitude Plot (dB) for node " + target_node,
  }
  render_ascii_chart(data, config)
}
