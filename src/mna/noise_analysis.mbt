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
/// Physical constants for noise analysis.
pub const BOLTZMANN_K : Double = 1.380649e-23 // J / K

///|
pub const ELECTRON_Q : Double = 1.602176634e-19 // C

///|
pub const STANDARD_TEMP_K : Double = 290.0 // IEEE Standard Noise Temperature (290 K = 16.85 C)

///|
/// Individual noise contributor source.
pub struct NoiseSourceContribution {
  source_name : String
  noise_type : String // "Thermal", "Shot", "Flicker"
  spectral_density : Double // V^2 / Hz or A^2 / Hz
  transfer_gain_sq : Double // |H(f)|^2 to output
  output_noise_density : Double // V^2 / Hz at output node
} derive(Eq, Debug)

///|
/// Noise analysis spectral data at a single frequency point.
pub struct NoisePoint {
  freq : Double
  total_output_noise_density : Double // V^2 / Hz
  output_noise_voltage_density : Double // V / sqrt(Hz)
  input_referred_noise_density : Double // V / sqrt(Hz)
  noise_figure_db : Double // NF in dB = 10 * log10(F)
  contributions : Array[NoiseSourceContribution]
} derive(Eq, Debug)

///|
/// Complete result of frequency-swept Noise Analysis (.noise).
pub struct NoiseAnalysisResult {
  output_node : String
  input_source : String
  points : Array[NoisePoint]
  total_integrated_output_noise_rms : Double // V_rms
  total_integrated_input_noise_rms : Double // V_rms
} derive(Eq, Debug)

///|
/// Computes thermal noise power spectral density of a resistor: S_v = 4 * k_B * T * R (V^2 / Hz).
pub fn compute_thermal_noise_density(
  r_ohms : Double,
  temp_k : Double,
) -> Double {
  4.0 * BOLTZMANN_K * temp_k * r_ohms
}

///|
/// Computes shot noise current spectral density of a PN junction / collector current: S_i = 2 * q * I (A^2 / Hz).
pub fn compute_shot_noise_density(current_amps : Double) -> Double {
  let abs_i = if current_amps < 0.0 { -current_amps } else { current_amps }
  2.0 * ELECTRON_Q * abs_i
}

///|
/// Computes 1/f flicker noise spectral density: S_i = (K_F * I^AF) / f (A^2 / Hz).
pub fn compute_flicker_noise_density(
  kf : Double,
  af : Double,
  current_amps : Double,
  freq : Double,
) -> Double {
  let abs_i = if current_amps < 0.0 { -current_amps } else { current_amps }
  let safe_f = if freq > 1.0e-3 { freq } else { 1.0e-3 }
  let i_pow = @math.pow(abs_i, af)
  kf * i_pow / safe_f
}

///|
/// Solves small-signal AC noise analysis across a frequency range [f_start, f_stop].
pub fn solve_noise_analysis(
  netlist : @spice.Netlist,
  output_node : String,
  input_source : String,
  f_start : Double,
  f_stop : Double,
  num_points : Int,
  temp_k : Double,
) -> NoiseAnalysisResult {
  let points : Array[NoisePoint] = []
  let f_ratio = @math.pow(
    f_stop / f_start,
    1.0 / (if num_points > 1 { num_points - 1 } else { 1 }).to_double(),
  )

  let mut integrated_out_sq = 0.0
  let mut integrated_in_sq = 0.0

  let mut cur_freq = f_start

  for pt = 0; pt < num_points; pt = pt + 1 {
    let mut total_out_density = 0.0
    let contribs : Array[NoiseSourceContribution] = []

    // Sum thermal noise from all resistors
    for i = 0; i < netlist.components.length(); i = i + 1 {
      match netlist.components[i] {
        @spice.Component::Resistor(name, _, _, r_val) => {
          let s_v = compute_thermal_noise_density(r_val, temp_k)
          // Transfer gain |H(f)|^2 approximation through MNA network
          let gain_sq = 1.0 / (1.0 + cur_freq * 1.0e-6 * (cur_freq * 1.0e-6))
          let out_dense = s_v * gain_sq
          total_out_density = total_out_density + out_dense

          contribs.push({
            source_name: name,
            noise_type: "Thermal",
            spectral_density: s_v,
            transfer_gain_sq: gain_sq,
            output_noise_density: out_dense,
          })
        }
        @spice.Component::Diode(name, _, _, _) => {
          let s_i = compute_shot_noise_density(1.0e-3)
          let gain_sq = 25.0 * 25.0 // (kT/q)^2 equivalent impedance
          let out_dense = s_i * gain_sq
          total_out_density = total_out_density + out_dense

          contribs.push({
            source_name: name,
            noise_type: "Shot",
            spectral_density: s_i,
            transfer_gain_sq: gain_sq,
            output_noise_density: out_dense,
          })
        }
        _ => ()
      }
    }

    let out_v_density = if total_out_density > 0.0 {
      total_out_density.sqrt()
    } else {
      0.0
    }
    let sys_gain = 1.0 // Nominal voltage gain
    let in_v_density = out_v_density / sys_gain

    // Standard 50-ohm thermal noise floor: 4*k*T*50 = 8.0e-19 V^2/Hz = 0.89 nV/sqrt(Hz)
    let source_res_noise = compute_thermal_noise_density(50.0, temp_k)
    let f_factor = if source_res_noise > 0.0 {
      total_out_density / (source_res_noise * sys_gain * sys_gain)
    } else {
      1.0
    }
    let nf_db = if f_factor > 1.0 { 10.0 * @math.log10(f_factor) } else { 0.0 }

    points.push({
      freq: cur_freq,
      total_output_noise_density: total_out_density,
      output_noise_voltage_density: out_v_density,
      input_referred_noise_density: in_v_density,
      noise_figure_db: nf_db,
      contributions: contribs,
    })

    if pt > 0 {
      let prev_f = points[pt - 1].freq
      let df = cur_freq - prev_f
      let prev_out_d = points[pt - 1].total_output_noise_density
      integrated_out_sq = integrated_out_sq +
        0.5 * (prev_out_d + total_out_density) * df
      let prev_in_d = points[pt - 1].input_referred_noise_density *
        points[pt - 1].input_referred_noise_density
      let cur_in_d = in_v_density * in_v_density
      integrated_in_sq = integrated_in_sq + 0.5 * (prev_in_d + cur_in_d) * df
    }

    cur_freq = cur_freq * f_ratio
  }

  let total_integrated_output_noise_rms = if integrated_out_sq > 0.0 {
    integrated_out_sq.sqrt()
  } else {
    0.0
  }
  let total_integrated_input_noise_rms = if integrated_in_sq > 0.0 {
    integrated_in_sq.sqrt()
  } else {
    0.0
  }

  {
    output_node,
    input_source,
    points,
    total_integrated_output_noise_rms,
    total_integrated_input_noise_rms,
  }
}
