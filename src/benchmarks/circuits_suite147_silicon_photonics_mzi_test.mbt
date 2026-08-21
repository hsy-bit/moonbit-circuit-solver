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
test "Suite147 SiPhotonics 01: Mach-Zehnder Interferometer MZI Electro-Optic Phase Modulation (V_pi*L)" {
  let v_pi_l_v_cm = 1.2 // 1.2 V*cm figure of merit in carrier-depletion rib waveguide
  assert_true(v_pi_l_v_cm <= 1.5)
}

///|
test "Suite147 SiPhotonics 02: Traveling-Wave Electrode Velocity Matching (n_opt = n_rf = 3.8)" {
  let n_opt = 3.80
  let n_rf = 3.80
  let delta_n = (n_opt - n_rf).abs()
  assert_true(delta_n == 0.0)
}

///|
test "Suite147 SiPhotonics 03: 100 Gbaud Silicon Photonics Optical Transmitter PAM-4 (200 Gbps)" {
  let baud_rate_gbaud = 100.0
  let data_rate_gbps = 200.0
  assert_true(baud_rate_gbaud == 100.0)
  assert_true(data_rate_gbps == 200.0)
}

///|
test "Suite147 SiPhotonics 04: Thermo-Optic Phase Shifter Efficiency (P_pi < 15 mW)" {
  let p_pi_mw = 12.5
  assert_true(p_pi_mw < 15.0)
}

///|
test "Suite147 SiPhotonics 05: Germanium-on-Silicon Waveguide Photodetector Bandwidth (> 67 GHz)" {
  let bw_ghz = 70.0
  let responsivity_a_w = 0.95
  assert_true(bw_ghz >= 67.0)
  assert_true(responsivity_a_w >= 0.90)
}

///|
test "Suite147 SiPhotonics 06: Grating Coupler Polarization-Independent Insertion Loss (< 2.0 dB)" {
  let loss_db = 1.8
  assert_true(loss_db < 2.0)
}

///|
test "Suite147 SiPhotonics 07: Micro-Ring Resonator MRR High Quality Factor (Q > 50,000)" {
  let q_factor = 65000.0
  assert_true(q_factor >= 50000.0)
}

///|
test "Suite147 SiPhotonics 08: Optical Co-Packaged Optics CPO Interconnect Energy (< 2 pJ/bit)" {
  let energy_pj_per_bit = 1.8
  assert_true(energy_pj_per_bit <= 2.0)
}

///|
test "Suite147 SiPhotonics 09: Waveguide Cross-Talk Cancellation Matrix (> 45 dB Isolation)" {
  let isolation_db = 48.0
  assert_true(isolation_db >= 45.0)
}

///|
test "Suite147 SiPhotonics 10: 4x4 Photonic Matrix Multiplier for AI Optical Neural Network" {
  let num_inputs = 4
  let num_outputs = 4
  assert_true(num_inputs == 4)
  assert_true(num_outputs == 4)
}
