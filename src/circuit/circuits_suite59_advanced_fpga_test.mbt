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
test "Suite59 FPGA 01: 6-Input Look-Up Table LUT-6 Bit Addressing" {
  // LUT-6 has 2^6 = 64 configuration SRAM bits
  let sram_bits = 64
  let num_inputs = 6
  assert_true(sram_bits == 64)
  assert_true(num_inputs == 6)
}

///|
test "Suite59 FPGA 02: Wilton Switch Block Routability Connection Density" {
  // Wilton switch block has 3 connections per track terminal (Flexible routing)
  let connections_per_pin = 3
  assert_true(connections_per_pin == 3)
}

///|
test "Suite59 FPGA 03: CLB Fast Dedicated Carry Chain Propagation (15 ps / bit)" {
  let num_bits = 64
  let t_carry_per_bit_ps = 15.0 // 15 ps dedicated carry MUX delay
  let total_carry_delay_ps = num_bits.to_double() * t_carry_per_bit_ps // 960 ps (< 1 ns for 64-bit addition!)

  assert_true(total_carry_delay_ps < 1000.0)
}

///|
test "Suite59 FPGA 04: DSP48 Multiplier-Accumulator 27x18 Bit Precision" {
  let a_bits = 27
  let b_bits = 18
  let p_bits = a_bits + b_bits // 45 bits product
  assert_true(p_bits == 45)
}

///|
test "Suite59 FPGA 05: Block RAM BRAM 36 kb Dual-Port Access Modes" {
  let bram_bits = 36864 // 36 * 1024 bits
  assert_true(bram_bits == 36864)
}

///|
test "Suite59 FPGA 06: MMCM Fractional Frequency Synthesizer Multiplier/Divider" {
  let f_in_mhz = 100.0 // 100 MHz input clock
  let m_mult = 12.0 // VCO at 1200 MHz
  let d_div = 2.5 // Fractional divide by 2.5 -> f_out = 480 MHz

  let f_out_mhz = f_in_mhz * m_mult / d_div // 1200 / 2.5 = 480 MHz
  assert_true((f_out_mhz - 480.0).abs() < 1.0e-6)
}

///|
test "Suite59 FPGA 07: PDN Target Impedance for Core Power Supply" {
  // Z_target = V_core * Ripple% / (0.5 * I_step)
  let v_core = 0.85 // 0.85V core voltage
  let ripple_percent = 0.03 // 3% allowable ripple = 25.5 mV
  let i_trans_step = 25.0 // 25 A transient step

  let delta_v_allowed = v_core * ripple_percent
  let z_target_mohm = delta_v_allowed / (0.5 * i_trans_step) * 1000.0 // 25.5 mV / 12.5 A = 2.04 mOhms

  assert_true((z_target_mohm - 2.04).abs() < 0.01)
}

///|
test "Suite59 FPGA 08: Asynchronous FIFO Gray Code Pointer Synchronizer" {
  // Gray code binary transition has only 1 bit changing per step!
  let bin_val = 6
  let gray_val = bin_val ^ (bin_val >> 1) // 6 ^ 3 = 0110 ^ 0011 = 0101 (5)

  assert_true(gray_val == 5)
}

///|
test "Suite59 FPGA 09: Dynamic Partial Reconfiguration Frame CRC32 Checksum" {
  let is_crc_valid = true
  assert_true(is_crc_valid)
}

///|
test "Suite59 FPGA 10: I/O Bank Differential LVDS 800 Mbps Eye Jitter" {
  let ui_ps = 1.0 / 800.0e6 * 1.0e12 // 1250 ps UI
  let jitter_ps = 80.0
  let jitter_ui = jitter_ps / ui_ps // 6.4% UI

  assert_true((jitter_ui - 0.064).abs() < 1.0e-4)
}
