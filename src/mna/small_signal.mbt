// Modified Nodal Analysis - Small-Signal AC Linearization
// MoonBit Circuit Solver Engine

///|
/// Represents AC Small-Signal parameters of a Diode.
pub struct DiodeSmallSignal {
  gd : Double
  cd : Double
} derive(Debug, Eq)

///|
/// Creates a new DiodeSmallSignal parameter.
pub fn DiodeSmallSignal::new(gd : Double, cd : Double) -> DiodeSmallSignal {
  DiodeSmallSignal::{ gd, cd }
}

///|
/// Evaluates small-signal AC parameters of a diode at DC bias Vd.
pub fn get_diode_small_signal(
  vd : Double,
  is_val : Double,
  n_val : Double,
  tt_val : Double,
) -> DiodeSmallSignal {
  let vt = 0.02585
  let nv_t = n_val * vt
  let exp_val = @math.exp(vd / nv_t)
  let gd = is_val * exp_val / nv_t
  let cd = gd * tt_val // Diffusion capacitance C_d = g_d * \tau_T
  DiodeSmallSignal::new(gd, cd)
}

///|
/// Represents AC Small-Signal parameters of a BJT Transistor.
pub struct BjtSmallSignal {
  gpi : Double
  gm : Double
  gmu : Double
  cbe : Double
  cbc : Double
} derive(Debug, Eq)

///|
/// Creates a new BjtSmallSignal parameter.
pub fn BjtSmallSignal::new(
  gpi : Double,
  gm : Double,
  gmu : Double,
  cbe : Double,
  cbc : Double,
) -> BjtSmallSignal {
  BjtSmallSignal::{ gpi, gm, gmu, cbe, cbc }
}

///|
/// Evaluates small-signal AC hybrid-pi parameters for a BJT at DC operating point (Vbe, Vbc).
pub fn get_bjt_small_signal(
  vbe : Double,
  _vbc : Double,
  is_val : Double,
  bf : Double,
  tf_val : Double,
) -> BjtSmallSignal {
  let vt = 0.02585
  let exp_be = @math.exp(vbe / vt)
  let gm = is_val * exp_be / vt
  let gpi = gm / bf
  let cbe = gm * tf_val
  let cbc = 0.000000000002
  BjtSmallSignal::new(gpi, gm, 0.0, cbe, cbc)
}
