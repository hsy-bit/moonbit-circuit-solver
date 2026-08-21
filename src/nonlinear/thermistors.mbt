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
/// Parameters for NTC/PTC Thermistor Model.
pub struct ThermistorParams {
  r0 : Double // Nominal resistance at reference temperature T0 (Ohms, e.g. 10,000 Ohms)
  t0_celsius : Double // Reference temperature in Celsius (e.g. 25.0 C = 298.15 K)
  beta_coeff : Double // B-parameter (Kelvin, e.g. 3950 K)
  is_ntc : Bool // True for NTC (negative temp coeff), False for PTC
} derive(Eq, Debug)

///|
/// Standard 10k NTC thermistor (B=3950K) default parameters.
pub fn ThermistorParams::default_10k_ntc() -> ThermistorParams {
  { r0: 10000.0, t0_celsius: 25.0, beta_coeff: 3950.0, is_ntc: true }
}

///|
/// Computes resistance of thermistor at temperature T in Celsius.
pub fn evaluate_thermistor_resistance(
  p : ThermistorParams,
  temp_celsius : Double,
) -> Double {
  let t_k = temp_celsius + 273.15
  let t0_k = p.t0_celsius + 273.15

  if p.is_ntc {
    let exp_arg = p.beta_coeff * (1.0 / t_k - 1.0 / t0_k)
    let safe_arg = if exp_arg > 30.0 {
      30.0
    } else if exp_arg < -30.0 {
      -30.0
    } else {
      exp_arg
    }
    p.r0 * @math.exp(safe_arg)
  } else {
    // PTC model: exponential increase above Curie transition temperature
    let delta_t = temp_celsius - p.t0_celsius
    p.r0 * (1.0 + 0.05 * delta_t + 0.002 * delta_t * delta_t)
  }
}
