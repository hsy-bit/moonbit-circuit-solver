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
/// Behavioral Charge-Pump Phase-Locked Loop (PLL) Simulator.
pub struct PllModel {
  f_ref : Double // Reference input frequency (Hz, e.g. 10 MHz)
  n_div : Int // Feedback divider ratio (e.g. 100 -> 1 GHz output)
  i_cp : Double // Charge pump current (A, e.g. 100 uA)
  r1 : Double // Loop filter series resistor (Ohms, e.g. 2000)
  c1 : Double // Loop filter main capacitor (F, e.g. 10 nF)
  c2 : Double // Loop filter ripple capacitor (F, e.g. 1 nF)
  k_vco : Double // VCO tuning gain (Hz/V, e.g. 100 MHz/V)
  f_vco_free : Double // Free-running VCO frequency at Vctrl=0 (Hz, e.g. 900 MHz)
} derive(Eq, Debug)

///|
/// Evaluates PLL closed-loop continuous phase response and lock acquisition.
pub fn simulate_pll_lock(
  pll : PllModel,
  sim_time : Double,
  dt : Double,
) -> (Double, Bool) {
  let f_target = pll.f_ref * pll.n_div.to_double()
  let mut phi_vco = 0.0
  let mut phi_ref = 0.0
  let mut v_ctrl = 0.0
  let mut t = 0.0
  let steps = (sim_time / dt).to_int()

  for _s = 0; _s < steps; _s = _s + 1 {
    t = t + dt
    phi_ref = 2.0 * @math.PI * pll.f_ref * t
    let phi_div = phi_vco / pll.n_div.to_double()

    // Phase error Delta phi = phi_ref - phi_div in [-pi, pi]
    let mut phi_err = phi_ref - phi_div
    while phi_err > @math.PI {
      phi_err = phi_err - 2.0 * @math.PI
    }
    while phi_err < -@math.PI {
      phi_err = phi_err + 2.0 * @math.PI
    }

    // Charge pump current into loop filter: I_cp * (Delta_phi / (2*pi))
    let i_out = pll.i_cp * (phi_err / (2.0 * @math.PI))
    // Loop filter voltage update: dv/dt = i / (C1 + C2)
    let dv = i_out / (pll.c1 + pll.c2) * dt
    v_ctrl = v_ctrl + dv

    // VCO instantaneous frequency: f_inst = f_free + K_vco * v_ctrl
    let f_inst = pll.f_vco_free + pll.k_vco * v_ctrl
    phi_vco = phi_vco + 2.0 * @math.PI * f_inst * dt
  }

  let f_final = pll.f_vco_free + pll.k_vco * v_ctrl
  let is_locked = (f_final - f_target).abs() < 0.01 * f_target

  (f_final, is_locked)
}

///|
test "Phase-Locked Loop (PLL) 1 GHz Frequency Synthesizer Locking" {
  let pll = PllModel::{
    f_ref: 10.0e6,
    n_div: 100,
    i_cp: 100.0e-6,
    r1: 2000.0,
    c1: 10.0e-9,
    c2: 1.0e-9,
    k_vco: 100.0e6,
    f_vco_free: 950.0e6,
  }

  let (f_out, _) = simulate_pll_lock(pll, 1.0e-4, 1.0e-8)
  assert_true(f_out > 900.0e6 && f_out < 1.2e9)
}

///|
test "Varactor-Tuned LC Voltage-Controlled Oscillator VCO" {
  let l_tank = 5.0e-9 // 5 nH
  let varactor = @nonlinear.VaractorParams::default_rf()

  // At Vctrl = 0V -> C = 20 pF -> f0 = 1 / (2*pi*sqrt(L*C)) approx 503 MHz
  let c0 = @nonlinear.evaluate_varactor_capacitance(varactor, 0.0)
  let f0 = 1.0 / (2.0 * @math.PI * (l_tank * c0).sqrt())
  assert_true((f0 - 503.0e6).abs() < 5.0e6)

  // At Vctrl = -3V -> C decreases -> frequency increases
  let c_rev = @nonlinear.evaluate_varactor_capacitance(varactor, -3.0)
  let f_high = 1.0 / (2.0 * @math.PI * (l_tank * c_rev).sqrt())
  assert_true(f_high > f0)
}
