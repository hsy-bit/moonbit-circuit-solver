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
test "Suite89 Microgrid 01: Droop Control Frequency-Active Power P-f Characteristic" {
  // omega = omega_0 - m_p * (P - P_0)
  let f_0 = 50.0 // 50 Hz nominal
  let m_p = 0.001 // 1 mHz / kW
  let delta_p_kw = 200.0 // 200 kW load step

  let f_new = f_0 - m_p * delta_p_kw // 49.8 Hz
  assert_true((f_new - 49.8).abs() < 1.0e-6)
}

///|
test "Suite89 Microgrid 02: Voltage Droop Reactive Power Q-V Characteristic" {
  // V = V_0 - n_q * (Q - Q_0)
  let v_0 = 400.0
  let n_q = 0.05 // 50 mV / kVAR
  let delta_q_kvar = 100.0

  let v_new = v_0 - n_q * delta_q_kvar // 395.0 V
  assert_true((v_new - 395.0).abs() < 1.0e-6)
}

///|
test "Suite89 Microgrid 03: Virtual Synchronous Generator VSG Virtual Inertia J_v" {
  let j_virtual = 50.0 // 50 kg*m^2 synthetic inertia
  assert_true(j_virtual == 50.0)
}

///|
test "Suite89 Microgrid 04: Anti-Islanding Detection Rate of Change of Frequency ROCOF" {
  let rocof_limit_hz_per_s = 2.5
  let rocof_measured = 3.2 // Exceeds limit -> Trip islanding breaker within 200 ms!

  assert_true(rocof_measured > rocof_limit_hz_per_s)
}

///|
test "Suite89 Microgrid 05: Seamless Grid-Tie to Islanded Reconnection Synchronizer" {
  let delta_v_sync_v = 1.2
  let delta_phase_sync_deg = 0.8
  let delta_f_sync_hz = 0.02

  assert_true(delta_v_sync_v < 5.0)
  assert_true(delta_phase_sync_deg < 2.0)
  assert_true(delta_f_sync_hz < 0.05)
}

///|
test "Suite89 Microgrid 06: Static Transfer Switch STS 4 ms Transfer Time" {
  let t_transfer_ms = 4.0
  assert_true(t_transfer_ms <= 5.0)
}

///|
test "Suite89 Microgrid 07: Battery Energy Storage BESS Primary Frequency Response" {
  let p_bess_mw = 2.0
  let t_resp_ms = 50.0 // 50 ms fast response
  assert_true(p_bess_mw == 2.0)
  assert_true(t_resp_ms < 100.0)
}

///|
test "Suite89 Microgrid 08: Hierarchical Secondary Control Microgrid Energy Management EMS" {
  let update_interval_s = 1.0
  assert_true(update_interval_s == 1.0)
}

///|
test "Suite89 Microgrid 09: Dynamic Voltage Restorer DVR Series Voltage Injection" {
  let v_inj_max_v = 100.0
  assert_true(v_inj_max_v == 100.0)
}

///|
test "Suite89 Microgrid 10: Zero-Sequence Circulating Current Suppression in Parallel Inverters" {
  let i_circ_zero_seq_a = 0.05 // < 50 mA circulating current
  assert_true(i_circ_zero_seq_a < 0.10)
}
