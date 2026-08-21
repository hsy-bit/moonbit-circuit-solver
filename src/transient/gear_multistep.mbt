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
/// Gear BDF Integration Order (1 to 5).
pub(all) enum GearOrder {
  Bdf1
  Bdf2
  Bdf3
  Bdf4
  Bdf5
} derive(Eq, Debug)

///|
/// Gear BDF Capacitor Companion Model.
pub struct GearCapCompanion {
  g_eq : Double // Equivalent companion conductance G_eq = (alpha_0 * C) / dt
  i_eq : Double // History current vector contribution
} derive(Eq, Debug)

///|
/// Evaluates Gear BDF Capacitor companion for orders 1..5.
pub fn evaluate_gear_bdf_cap(
  c_val : Double,
  history_v : Array[Double], // history_v[0] = v_n, history_v[1] = v_{n-1}, ...
  dt : Double,
  order : GearOrder,
) -> GearCapCompanion {
  let hist_len = history_v.length()
  match order {
    Bdf1 => {
      let alpha0 = 1.0
      let g_eq = alpha0 * c_val / dt
      let v_n = if hist_len > 0 { history_v[0] } else { 0.0 }
      let i_eq = -(c_val / dt) * v_n
      { g_eq, i_eq }
    }
    Bdf2 => {
      let alpha0 = 1.5
      let g_eq = alpha0 * c_val / dt
      let v_n = if hist_len > 0 { history_v[0] } else { 0.0 }
      let v_n1 = if hist_len > 1 { history_v[1] } else { v_n }
      let i_eq = -(c_val / dt) * (2.0 * v_n - 0.5 * v_n1)
      { g_eq, i_eq }
    }
    Bdf3 => {
      let alpha0 = 11.0 / 6.0
      let g_eq = alpha0 * c_val / dt
      let v0 = if hist_len > 0 { history_v[0] } else { 0.0 }
      let v1 = if hist_len > 1 { history_v[1] } else { v0 }
      let v2 = if hist_len > 2 { history_v[2] } else { v1 }
      let i_eq = -(c_val / dt) * (3.0 * v0 - 1.5 * v1 + 1.0 / 3.0 * v2)
      { g_eq, i_eq }
    }
    Bdf4 => {
      let alpha0 = 25.0 / 12.0
      let g_eq = alpha0 * c_val / dt
      let v0 = if hist_len > 0 { history_v[0] } else { 0.0 }
      let v1 = if hist_len > 1 { history_v[1] } else { v0 }
      let v2 = if hist_len > 2 { history_v[2] } else { v1 }
      let v3 = if hist_len > 3 { history_v[3] } else { v2 }
      let i_eq = -(c_val / dt) *
        (4.0 * v0 - 3.0 * v1 + 4.0 / 3.0 * v2 - 0.25 * v3)
      { g_eq, i_eq }
    }
    Bdf5 => {
      let alpha0 = 137.0 / 60.0
      let g_eq = alpha0 * c_val / dt
      let v0 = if hist_len > 0 { history_v[0] } else { 0.0 }
      let v1 = if hist_len > 1 { history_v[1] } else { v0 }
      let v2 = if hist_len > 2 { history_v[2] } else { v1 }
      let v3 = if hist_len > 3 { history_v[3] } else { v2 }
      let v4 = if hist_len > 4 { history_v[4] } else { v3 }
      let i_eq = -(c_val / dt) *
        (5.0 * v0 - 5.0 * v1 + 10.0 / 3.0 * v2 - 1.25 * v3 + 0.20 * v4)
      { g_eq, i_eq }
    }
  }
}
