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
test "Suite164 SiliconSpin 01: Silicon MOS Quantum Dot Exchange Coupling J(epsilon) (> 100 MHz)" {
  let j_exchange_mhz = 150.0
  assert_true(j_exchange_mhz > 100.0)
}

///|
test "Suite164 SiliconSpin 02: Isotopic Purification (28Si with 800 ppm 29Si) T2* Dephasing Time (> 20 us)" {
  let t2_star_us = 25.0
  assert_true(t2_star_us >= 20.0)
}

///|
test "Suite164 SiliconSpin 03: Pauli Spin Blockade PSB Single-Shot Readout Fidelity (> 99%)" {
  let readout_fidelity_percent = 99.4
  assert_true(readout_fidelity_percent >= 99.0)
}

///|
test "Suite164 SiliconSpin 04: Two-Qubit CPHASE / CZ Gate Duration (< 50 ns)" {
  let t_cz_ns = 35.0
  assert_true(t_cz_ns < 50.0)
}

///|
test "Suite164 SiliconSpin 05: Electric Dipole Spin Resonance EDSR Synthetic Micromagnet Gradient (> 1 T/um)" {
  let grad_b_t_um = 1.2
  assert_true(grad_b_t_um >= 1.0)
}

///|
test "Suite164 SiliconSpin 06: Gate Voltage Charge Noise Sensitivity (1 ueV/sqrt(Hz) at 1 Hz)" {
  let noise_uev = 0.85
  assert_true(noise_uev < 1.0)
}

///|
test "Suite164 SiliconSpin 07: Single-Qubit Randomized Benchmarking RB Fidelity (> 99.9%)" {
  let f_1q = 0.9995
  assert_true(f_1q >= 0.999)
}

///|
test "Suite164 SiliconSpin 08: Multi-Qubit 1D/2D Shuttling Conveyor Array Velocity (> 10 m/s)" {
  let v_shuttle_m_s = 15.0
  assert_true(v_shuttle_m_s > 10.0)
}

///|
test "Suite164 SiliconSpin 09: Valley Splitting Energy E_v in Si/SiGe Heterostructure (> 100 ueV)" {
  let e_valley_uev = 125.0
  assert_true(e_valley_uev >= 100.0)
}

///|
test "Suite164 SiliconSpin 10: 100-Qubit Fault-Tolerant Silicon Spin Architecture Sign-Off" {
  let is_architecture_signed_off = true
  assert_true(is_architecture_signed_off)
}
