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
/// Parameters for Esaki Tunnel Diode Model.
pub struct TunnelDiodeParams {
  ip : Double // Peak tunneling current (A, e.g. 5.0 mA)
  vp : Double // Peak voltage (V, e.g. 65 mV)
  iv : Double // Valley current (A, e.g. 0.5 mA)
  vv : Double // Valley voltage (V, e.g. 350 mV)
  is_val : Double // Excess forward diffusion saturation current (A, e.g. 1.0e-12)
  vt_val : Double // Thermal voltage (V, e.g. 26 mV)
  c0 : Double // Junction capacitance (F, e.g. 5.0 pF)
} derive(Eq, Debug)

///|
/// Standard 1N3716-like Germanium Tunnel Diode default parameters.
pub fn TunnelDiodeParams::default_ge() -> TunnelDiodeParams {
  {
    ip: 5.0e-3,
    vp: 0.065,
    iv: 0.5e-3,
    vv: 0.35,
    is_val: 1.0e-12,
    vt_val: 0.026,
    c0: 5.0e-12,
  }
}

///|
/// Evaluates total current and dynamic conductance of Tunnel Diode:
/// I(V) = I_tunnel(V) + I_excess(V) + I_thermal(V)
pub fn evaluate_tunnel_diode(
  p : TunnelDiodeParams,
  vd : Double,
) -> (Double, Double) {
  // 1. Quantum tunneling current: I_tun = Ip * (V / Vp) * exp(1 - V / Vp)
  let v_norm = vd / p.vp
  let exp_tun = @math.exp(1.0 - v_norm)
  let i_tun = p.ip * v_norm * exp_tun
  let g_tun = p.ip / p.vp * (1.0 - v_norm) * exp_tun

  // 2. Excess valley current: I_excess = Iv * exp(A * (V - Vv))
  let i_excess = p.iv *
    (if vd > p.vp {
      let u = (vd - p.vp) / (p.vv - p.vp)
      if u > 0.0 && u < 2.0 {
        u * u
      } else {
        1.0
      }
    } else {
      0.0
    })

  // 3. Thermal forward diffusion current: I_diff = Is * (exp(V / Vt) - 1)
  let exp_diff = @math.exp(
    if vd / p.vt_val > 30.0 {
      30.0
    } else if vd / p.vt_val < -30.0 {
      -30.0
    } else {
      vd / p.vt_val
    },
  )
  let i_diff = p.is_val * (exp_diff - 1.0)
  let g_diff = p.is_val * exp_diff / p.vt_val

  let total_i = i_tun + i_excess + i_diff
  let total_g = g_tun + g_diff

  (total_i, total_g)
}
