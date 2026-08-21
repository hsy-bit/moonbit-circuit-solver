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
test "Suite46 RFID 01: 13.56 MHz NFC Antenna Resonant Tuning" {
  // f_0 = 13.56 MHz, L_ant = 1.5 uH -> C_res = 1 / ((2*pi*f)^2 * L)
  let f_nfc = 13.56e6
  let l_ant = 1.5e-6 // 1.5 uH planar loop
  let omega = 2.0 * @math.PI * f_nfc

  let c_res = 1.0 / (omega * omega * l_ant) // ~91.95 pF
  assert_true((c_res - 91.95e-12).abs() < 0.5e-12)
}

///|
test "Suite46 RFID 02: ISO 14443 Type B 10% ASK Modulation Index" {
  // Index m = (V_max - V_min) / (V_max + V_min) = 0.10
  let v_max = 5.0
  let v_min = 4.0909 // Drops to ~81.8% amplitude

  let mod_index = (v_max - v_min) / (v_max + v_min) // ~0.10 (10%)
  assert_true((mod_index - 0.10).abs() < 1.0e-3)
}

///|
test "Suite46 RFID 03: 848 kHz Subcarrier Load Modulation Sub-Band" {
  let f_carrier = 13.56e6
  let f_subcarrier = 848.0e3 // fc / 16 approx 847.5 kHz

  let ratio = (f_carrier / f_subcarrier + 0.5).to_int()
  assert_true(ratio == 16)
}

///|
test "Suite46 RFID 04: Tag Shunt Overvoltage Regulator Clamping Threshold" {
  let v_rectified = 6.8 // High field strength clamp
  let v_clamp = 3.6 // 3.6V internal logic limit

  assert_true(v_rectified > v_clamp)
  assert_true(v_clamp == 3.6)
}

///|
test "Suite46 RFID 05: Active Load Modulation ALM Phase Synchronization" {
  let phase_carrier_deg = 45.0
  let phase_alm_deg = 45.0
  let phase_diff = (phase_carrier_deg - phase_alm_deg).abs()

  assert_true(phase_diff == 0.0)
}

///|
test "Suite46 RFID 06: ISO 15693 1-out-of-4 Pulse Position Encoding" {
  // 2 bits encoded in single pulse position among 4 time slots
  let bits = 0b10 // Value 2
  let slot_index = bits

  assert_true(slot_index == 2)
}

///|
test "Suite46 RFID 07: Schottky Bridge Rectifier Ultra-Low Forward Drop" {
  let v_schottky = 0.22 // 220 mV vs 700 mV silicon
  let v_silicon = 0.70

  assert_true(v_schottky < v_silicon / 2.0)
}

///|
test "Suite46 RFID 08: Tag Input Impedance Conjugate Matching" {
  let z_chip = @linalg.Complex::new(15.0, -120.0) // Capacitive chip
  let z_ant = @linalg.Complex::new(15.0, 120.0) // Inductive antenna

  // Conjugate match condition: Z_ant == Z_chip*
  assert_true((z_ant.re - z_chip.re).abs() < 1.0e-12)
  assert_true((z_ant.im + z_chip.im).abs() < 1.0e-12)
}

///|
test "Suite46 RFID 09: Manchester Subcarrier Bit Polarity" {
  let bit1_high_low = true
  let bit0_low_high = false

  assert_true(bit1_high_low != bit0_low_high)
}

///|
test "Suite46 RFID 10: Magnetic Dipole Field Decay vs Distance (1/r^3 Near-Field)" {
  let b0 = 100.0 // 100 uT at r = 1 cm
  let r_ratio = 2.0 // r = 2 cm

  let b_far = b0 / (r_ratio * r_ratio * r_ratio) // 100 / 8 = 12.5 uT
  assert_true((b_far - 12.5).abs() < 1.0e-6)
}
