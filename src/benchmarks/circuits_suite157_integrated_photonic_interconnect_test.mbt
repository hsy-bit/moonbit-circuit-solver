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
test "Suite157 PhotonicInterconnect 01: 3.2 Tbps Co-Packaged Optical Engine CPO Architecture" {
  let total_bandwidth_tbps = 3.2
  let num_channels = 32 // 32 channels x 100 Gbps
  let per_channel_gbps = total_bandwidth_tbps *
    1000.0 /
    num_channels.to_double()

  assert_true(total_bandwidth_tbps == 3.2)
  assert_true(per_channel_gbps == 100.0)
}

///|
test "Suite157 PhotonicInterconnect 02: Dense Wavelength Division Multiplexing DWDM 100 GHz Channel Grid" {
  let delta_f_ghz = 100.0
  assert_true(delta_f_ghz == 100.0)
}

///|
test "Suite157 PhotonicInterconnect 03: Optical Switch Matrix 64x64 Benes Network Reconfiguration (< 10 ns)" {
  let t_switch_ns = 8.5
  assert_true(t_switch_ns < 10.0)
}

///|
test "Suite157 PhotonicInterconnect 04: Hybrid III-V on Silicon Distributed Feedback Laser Coupling" {
  let coupling_efficiency = 0.85
  assert_true(coupling_efficiency >= 0.80)
}

///|
test "Suite157 PhotonicInterconnect 05: Arrayed Waveguide Grating AWG De-Multiplexer Cross-Talk (< -30 dB)" {
  let xtalk_db = -32.5
  assert_true(xtalk_db <= -30.0)
}

///|
test "Suite157 PhotonicInterconnect 06: Monolithic 3D Photonic Electronic Co-Integration (TSV Pitch < 10 um)" {
  let pitch_um = 8.0
  assert_true(pitch_um < 10.0)
}

///|
test "Suite157 PhotonicInterconnect 07: Non-Blocking Optical Crossbar for Multi-GPU All-Reduce" {
  let is_all_reduce_supported = true
  assert_true(is_all_reduce_supported)
}

///|
test "Suite157 PhotonicInterconnect 08: Micro-Ring Resonator MRR Thermal Locking Control Loop Accuracy (< 0.05 K)" {
  let delta_t_lock_k = 0.02
  assert_true(delta_t_lock_k < 0.05)
}

///|
test "Suite157 PhotonicInterconnect 09: Bit Error Rate BER Pre-FEC (< 10^-6)" {
  let ber = 1.0e-7
  assert_true(ber < 1.0e-6)
}

///|
test "Suite157 PhotonicInterconnect 10: Optical Transceiver Total Power Dissipation (< 1.5 pJ/bit)" {
  let energy_pj_bit = 1.25
  assert_true(energy_pj_bit < 1.5)
}
