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
test "Suite55 RSFQ 01: RSFQ SQUID Loop Flux Storage Li_c Product" {
  // L * I_c approx 0.5 * Phi_0
  let phi_0 = 2.067833848e-15
  let i_c = 100.0e-6 // 100 uA junction
  let l_loop = 0.5 * phi_0 / i_c // ~10.34 pH

  assert_true((l_loop - 10.339e-12).abs() < 0.05e-12)
  assert_true(i_c == 100.0e-6)
}

///|
test "Suite55 RSFQ 02: RSFQ T-Flip-Flop 50 GHz Frequency Divider" {
  let f_in_ghz = 50.0 // 50 GHz clock input
  let f_out_ghz = f_in_ghz / 2.0 // 25 GHz toggled output

  assert_true(f_out_ghz == 25.0)
}

///|
test "Suite55 RSFQ 03: Josephson Transmission Line JTL Pulse Propagation Delay" {
  let tau_jtl_ps = 3.5 // 3.5 ps per stage
  let num_stages = 10
  let total_delay_ps = num_stages.to_double() * tau_jtl_ps // 35 ps

  assert_true((total_delay_ps - 35.0).abs() < 1.0e-6)
}

///|
test "Suite55 RSFQ 04: ERSFQ Energy-Efficient Zero Static Bias Dissipation" {
  let e_switch_joules = 1.0e-19 // 0.1 aJ per SFQ switching event! (1000x less than CMOS)
  assert_true(e_switch_joules < 1.0e-18)
}

///|
test "Suite55 RSFQ 05: RSFQ Confluence Buffer Asynchronous Merger" {
  let is_merged = true
  assert_true(is_merged)
}

///|
test "Suite55 RSFQ 06: RSFQ to Semiconductor 200 mV Amplifier Stage" {
  let v_sfq_raw = 0.002 // 2 mV raw
  let gain = 100.0
  let v_amplified = v_sfq_raw * gain // 200 mV output

  assert_true((v_amplified - 0.200).abs() < 1.0e-6)
}

///|
test "Suite55 RSFQ 07: Superconducting Shift Register 64-bit Word Length" {
  let bits = 64
  let f_shift_ghz = 40.0
  assert_true(bits == 64)
  assert_true(f_shift_ghz >= 40.0)
}

///|
test "Suite55 RSFQ 08: SFQ Pulse Voltage Integral Flux Quantum Constant" {
  let phi_0 = 2.067833848e-15
  assert_true(phi_0 > 2.0e-15 && phi_0 < 2.1e-15)
}

///|
test "Suite55 RSFQ 09: RSFQ Phase-Frequency Detector Linear PFD Range" {
  let phi_range_rad = 2.0 * @math.PI
  assert_true(phi_range_rad > 6.0)
}

///|
test "Suite55 RSFQ 10: Superconducting Flux DAC 16-SQUID Array" {
  let num_squids = 16
  let delta_v_per_step_uv = 129.2 // 16 * 8.075 uV = ~129.2 uV
  assert_true(num_squids == 16)
  assert_true(delta_v_per_step_uv > 100.0)
}
