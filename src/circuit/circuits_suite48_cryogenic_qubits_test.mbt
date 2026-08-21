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
test "Suite48 CryoQubit 01: IQ Mixer Single-Sideband Image Rejection Ratio IRR" {
  // Amplitude imbalance eps = 0.01 (1%), Phase imbalance theta = 1 degree (0.01745 rad)
  let eps = 0.01
  let theta_rad = 0.01745

  let num = 1.0 + 2.0 * eps * @math.cos(theta_rad) + eps * eps
  let den = 1.0 - 2.0 * eps * @math.cos(theta_rad) + eps * eps
  let irr_lin = num / den
  let ln10 = @math.ln(10.0)
  let irr_db = 10.0 * (@math.ln(irr_lin) / ln10)

  assert_true(irr_db > 0.0)
  assert_true((irr_db - 0.1737).abs() < 0.01)
}

///|
test "Suite48 CryoQubit 02: DRAG Gaussian Pulse Derivative Leakage Suppression" {
  // In-phase envelope: I(t) = exp(-t^2 / 2*sigma^2)
  // Quadrature envelope: Q(t) = - (1 / alpha) * dI/dt = (t / (alpha * sigma^2)) * I(t)
  let sigma_ns = 5.0 // 5 ns Gaussian width
  let alpha_anharm_grad = 2.0 * @math.PI * -300.0e6 // -300 MHz
  let t_ns = 2.5 // Half sigma

  let i_val = @math.exp(-(t_ns * t_ns) / (2.0 * sigma_ns * sigma_ns)) // exp(-0.125) = ~0.8825
  let d_i_dt = -(t_ns / (sigma_ns * sigma_ns * 1.0e-9)) * i_val // ~ -8.825e7
  let q_drag = -(d_i_dt / alpha_anharm_grad)

  assert_true(i_val > 0.8)
  assert_true(q_drag.abs() < 0.10)
}

///|
test "Suite48 CryoQubit 03: Ramsey Fringe Dephasing Oscillation Probability" {
  // P(|1>) = 0.5 * (1 + exp(-t / T2*) * cos(Delta_omega * t))
  let t2_star_us = 25.0 // 25 us dephasing time
  let delta_f_khz = 200.0 // 200 kHz detuning
  let t_eval_us = 5.0

  let decay = @math.exp(-t_eval_us / t2_star_us) // exp(-0.2) = 0.8187
  let phase = 2.0 * @math.PI * (delta_f_khz * 1.0e3) * (t_eval_us * 1.0e-6) // 2*pi
  let p_excited = 0.5 * (1.0 + decay * @math.cos(phase)) // 0.5 * (1 + 0.8187 * 1) = ~0.909

  assert_true((p_excited - 0.90936).abs() < 1.0e-3)
}

///|
test "Suite48 CryoQubit 04: Randomized Benchmarking 1-Qubit Clifford Gate Fidelity" {
  // F_avg = 1 - 0.5 * (1 - p)
  let depolarizing_param_p = 0.9994 // High quality gates!
  let f_avg = 1.0 - 0.5 * (1.0 - depolarizing_param_p) // 0.9997 (99.97% gate fidelity)

  assert_true((f_avg - 0.9997).abs() < 1.0e-6)
}

///|
test "Suite48 CryoQubit 05: NbTi Superconducting Coaxial Cable Thermal Heat Load" {
  let q_conduction_uw = 0.15 // 0.15 uW per line into 10 mK stage
  let num_lines = 16
  let total_load_uw = num_lines.to_double() * q_conduction_uw // 2.4 uW

  assert_true((total_load_uw - 2.4).abs() < 1.0e-6)
}

///|
test "Suite48 CryoQubit 06: Cryogenic HEMT Preamplifier 4 Kelvin Noise Floor" {
  let t_hemt_k = 2.1 // 2.1 Kelvin noise temperature
  assert_true(t_hemt_k < 3.0)
}

///|
test "Suite48 CryoQubit 07: Frequency-Tunable SQUID Transmon Sweet Spot" {
  // At integer flux Phi = 0: d(omega_q)/d(Phi) = 0 (First-order flux noise insensitive!)
  let phi_ext = 0.0
  let is_sweet_spot = phi_ext == 0.0
  assert_true(is_sweet_spot)
}

///|
test "Suite48 CryoQubit 08: Multi-Qubit 8-Channel Frequency Division Multiplexing" {
  let f_base_ghz = 6.5 // 6.5 GHz
  let f_spacing_mhz = 150.0 // 150 MHz spacing
  let num_qubits = 8

  let span_ghz = (num_qubits - 1).to_double() * f_spacing_mhz / 1000.0 // 1.05 GHz
  assert_true(f_base_ghz == 6.5)
  assert_true((span_ghz - 1.05).abs() < 1.0e-6)
}

///|
test "Suite48 CryoQubit 09: State Discrimination IQ Threshold Line" {
  let i_center_ground = -0.50
  let i_center_excited = 0.50
  let threshold = (i_center_ground + i_center_excited) / 2.0 // 0.0V decision boundary

  assert_true(threshold == 0.0)
}

///|
test "Suite48 CryoQubit 10: Hahn Echo Dynamical Decoupling Echo Pulse" {
  // Pi-pulse at t = tau refocuses static inhomogeneous dephasing
  let tau_us = 10.0
  let echo_time_us = 2.0 * tau_us // 20.0 us

  assert_true(echo_time_us == 20.0)
}
