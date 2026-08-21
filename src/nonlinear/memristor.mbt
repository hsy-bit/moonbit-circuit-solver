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
/// Parameters for HP TiO2 Thin-Film Memristor Model.
pub struct MemristorParams {
  r_on : Double // Minimum resistance in fully doped state (Ohms, e.g. 100)
  r_off : Double // Maximum resistance in undoped state (Ohms, e.g. 16,000)
  d_film : Double // Thin film thickness D (m, e.g. 10 nm = 10.0e-9)
  mu_v : Double // Average ion mobility (m^2 / (V * s), e.g. 1.0e-14)
  p_window : Int // Joglekar / Biolek window parameter exponent p
} derive(Eq, Debug)

///|
/// Default HP Memristor parameters.
pub fn MemristorParams::default() -> MemristorParams {
  { r_on: 100.0, r_off: 16000.0, d_film: 10.0e-9, mu_v: 1.0e-14, p_window: 10 }
}

///|
/// Evaluates Joglekar nonlinear boundary window function f(x) = 1 - (2x - 1)^(2p).
pub fn joglekar_window(x : Double, p : Int) -> Double {
  let u = 2.0 * x - 1.0
  let u2 = u * u
  let mut up = 1.0
  for _i in 0..<p {
    up = up * u2
  }
  let f = 1.0 - up
  if f < 0.0 {
    0.0
  } else {
    f
  }
}

///|
/// Evaluates Memristor state update and instantaneous resistance R(w) = R_on * (w/D) + R_off * (1 - w/D).
pub fn evaluate_memristor_step(
  p : MemristorParams,
  w_curr : Double,
  i_curr : Double,
  dt : Double,
) -> (Double, Double) {
  let x = w_curr / p.d_film
  let safe_x = if x < 0.0 { 0.0 } else if x > 1.0 { 1.0 } else { x }

  let f_win = joglekar_window(safe_x, p.p_window)
  // State derivative: dw/dt = mu_v * (R_on / D) * i(t) * f(w/D)
  let dw_dt = p.mu_v * (p.r_on / p.d_film) * i_curr * f_win
  let w_next_raw = w_curr + dw_dt * dt
  let w_next = if w_next_raw < 0.0 {
    0.0
  } else if w_next_raw > p.d_film {
    p.d_film
  } else {
    w_next_raw
  }

  let x_next = w_next / p.d_film
  let r_mem = p.r_on * x_next + p.r_off * (1.0 - x_next)

  (w_next, r_mem)
}
