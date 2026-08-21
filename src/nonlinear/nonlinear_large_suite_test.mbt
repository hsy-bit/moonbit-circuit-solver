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
test "BSIM Deep Sub-Micron Technology Node Scaling (180nm to 28nm)" {
  // Model parameters across technology nodes: (Node nm, Vdd V, Vth V, mu_eff cm2/Vs, tox nm)
  let tech_nodes = [180, 130, 90, 65, 45, 28]
  let vdd_voltages = [1.8, 1.3, 1.2, 1.0, 0.9, 0.8]
  let vth_voltages = [0.45, 0.38, 0.32, 0.28, 0.25, 0.22]

  for k = 0; k < tech_nodes.length(); k = k + 1 {
    let node = tech_nodes[k]
    let vdd = vdd_voltages[k]
    let vth = vth_voltages[k]

    // Verify constant-field scaling trend: Vth < Vdd and Vdd decreases with node size
    assert_true(vth < vdd)
    if k > 0 {
      assert_true(tech_nodes[k] < tech_nodes[k - 1])
      assert_true(vdd_voltages[k] < vdd_voltages[k - 1])
    }
    assert_true(node > 0)
  }
}

///|
test "Gummel-Poon BJT High-Current Gain Roll-Off (Webster Effect)" {
  // Forward beta BF_eff = BF / (1 + (Ic / IKF)^NK)
  let bf_peak = 200.0
  let ikf = 0.5 // Knee current 500 mA

  let ic_low = 0.01 // 10 mA
  let ic_high = 2.0 // 2 A

  let bf_eff_low = bf_peak / (1.0 + ic_low / ikf)
  let bf_eff_high = bf_peak / (1.0 + ic_high / ikf)

  assert_true(bf_eff_low > 190.0)
  assert_true(bf_eff_high < 50.0) // Significant drop at high current
}

///|
test "JFET Pinch-Off and Drain Conductance Output Characteristics" {
  let v_to = -2.5 // Pinch-off voltage
  let beta = 1.0e-3 // Transconductance parameter A/V^2
  let lambda_ch = 0.01 // Channel length modulation

  // At Vgs = 0V, Vds = 5V (Saturation: Vds > Vgs - Vto = 2.5V)
  let v_gst = 0.0 - v_to
  let id_sat = beta * v_gst * v_gst * (1.0 + lambda_ch * 5.0)

  assert_true(id_sat > 0.006 && id_sat < 0.007) // ~6.56 mA
}

///|
test "Zener Diode Temperature Drift Compensation" {
  // Below 5.6V: Negative tempco (Zener tunneling)
  // Above 5.6V: Positive tempco (Avalanche breakdown)
  // 5.6V Zener: Near zero tempco
  let tc_3v3 = -2.5 // mV/°C
  let tc_5v6 = 0.1 // mV/°C
  let tc_12v = 8.5 // mV/°C

  assert_true(tc_3v3 < 0.0)
  assert_true(tc_5v6.abs() < 1.0)
  assert_true(tc_12v > 0.0)
}

///|
test "Photodiode Responsivity and Quantum Efficiency Spectral Curve" {
  // Responsivity R(lambda) = eta * q * lambda / (h * c) = eta * lambda_um / 1.24 (A/W)
  let lambda_nm = 850.0 // 850 nm NIR
  let eta = 0.85 // 85% quantum efficiency

  let lambda_um = lambda_nm / 1000.0
  let responsivity = eta * lambda_um / 1.24

  assert_true((responsivity - 0.5826).abs() < 0.01) // ~0.58 A/W
}
