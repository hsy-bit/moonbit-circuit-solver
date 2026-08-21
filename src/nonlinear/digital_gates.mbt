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
/// Parameters for Mixed-Signal Behavioral CMOS Logic Gates.
pub struct LogicGateParams {
  vdd : Double // Logic supply voltage (V, e.g. 3.3V or 5.0V)
  vth : Double // Switching threshold voltage (V, e.g. Vdd / 2 = 1.65V)
  gain_slope : Double // Transition gain slope dVout/dVin (e.g. 50.0)
  r_out : Double // Output drive resistance (Ohms, e.g. 50 Ohms)
  c_in : Double // Input gate capacitance (F, e.g. 1.0 pF)
  t_delay : Double // Propagation delay (s, e.g. 2.0 ns)
} derive(Eq, Debug)

///|
/// Standard 3.3V CMOS Logic Gate default parameters.
pub fn LogicGateParams::default_3v3() -> LogicGateParams {
  {
    vdd: 3.3,
    vth: 1.65,
    gain_slope: 40.0,
    r_out: 50.0,
    c_in: 1.5e-12,
    t_delay: 2.0e-9,
  }
}

///|
/// Smooth continuous logic inverter transfer function: Vout = Vdd / 2 * (1 - tanh(gain * (Vin - Vth))).
pub fn evaluate_cmos_inverter(
  p : LogicGateParams,
  v_in : Double,
) -> (Double, Double) {
  let u = p.gain_slope * (v_in - p.vth) / p.vdd
  let safe_u = if u > 15.0 { 15.0 } else if u < -15.0 { -15.0 } else { u }
  let tanh_u = @math.tanh(safe_u)

  let v_out = p.vdd / 2.0 * (1.0 - tanh_u)
  let d_vout_d_vin = -(p.gain_slope / 2.0) * (1.0 - tanh_u * tanh_u)

  (v_out, d_vout_d_vin)
}

///|
/// Evaluates 2-input NAND gate transfer function.
pub fn evaluate_cmos_nand2(
  p : LogicGateParams,
  va : Double,
  vb : Double,
) -> Double {
  let (out_a, _) = evaluate_cmos_inverter(p, va)
  let (out_b, _) = evaluate_cmos_inverter(p, vb)
  // De Morgan: NAND(A, B) = NOT(A AND B) = (NOT A) OR (NOT B)
  // Smooth soft-max between (Vdd - Va) and (Vdd - Vb)
  let val = if out_a > out_b { out_a } else { out_b }
  val
}

///|
/// Evaluates 2-input NOR gate transfer function.
pub fn evaluate_cmos_nor2(
  p : LogicGateParams,
  va : Double,
  vb : Double,
) -> Double {
  let (out_a, _) = evaluate_cmos_inverter(p, va)
  let (out_b, _) = evaluate_cmos_inverter(p, vb)
  let val = if out_a < out_b { out_a } else { out_b }
  val
}

///|
/// Evaluates 2-input XOR gate transfer function.
pub fn evaluate_cmos_xor2(
  p : LogicGateParams,
  va : Double,
  vb : Double,
) -> Double {
  let a_high = va > p.vth
  let b_high = vb > p.vth
  let out_high = (a_high && !b_high) || (!a_high && b_high)
  if out_high {
    p.vdd
  } else {
    0.0
  }
}
