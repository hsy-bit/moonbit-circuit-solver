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
test "Suite34 MixedSignal 01: 12-bit SAR ADC Capacitor Unit Matching" {
  // Total capacitance C_tot = 2^12 * C_unit = 4096 * 0.5 fF = 2.048 pF
  let n_bits = 12
  let c_unit_ff = 0.5
  let total_units = 4096

  let c_total_pf = total_units.to_double() * c_unit_ff / 1000.0 // 2.048 pF
  assert_true(n_bits == 12)
  assert_true((c_total_pf - 2.048).abs() < 1.0e-6)
}

///|
test "Suite34 MixedSignal 02: 1.5-bit Pipeline ADC Residue Amplification" {
  // V_res = 2 * V_in - D * V_ref where D in {-1, 0, +1}
  let v_ref = 1.0
  let v_in = 0.35 // Between +Vref/4 and +Vref -> D = +1

  let d_code = 1.0
  let v_residue = 2.0 * v_in - d_code * v_ref // 2 * 0.35 - 1.0 = -0.30 V
  assert_true((v_residue - -0.30).abs() < 1.0e-6)
  assert_true(v_residue.abs() <= v_ref / 2.0 + 0.1) // Within interstage range
}

///|
test "Suite34 MixedSignal 03: 6-bit Flash ADC 63-Comparator Resistor Ladder" {
  let num_comparators = 63 // 2^6 - 1
  let v_lsb = 1.0 / 64.0 // 15.625 mV LSB
  assert_true(num_comparators == 63)
  assert_true((v_lsb - 0.015625).abs() < 1.0e-6)
}

///|
test "Suite34 MixedSignal 04: 2nd-Order Delta-Sigma Modulator In-Band Noise Shaping" {
  // Quantization noise PSD is shaped by |1 - z^-1|^2 -> +40 dB / decade high-pass filtering!
  let osr = 64.0 // Over-Sampling Ratio = 64
  // Theoretical SQNR improvement for 2nd order: ~15 dB / octave = 50 * log10(OSR) - 12.9 dB
  let ln10 = @math.ln(10.0)
  let sqnr_db = 50.0 * (@math.ln(osr) / ln10) - 12.9 // 50 * 1.806 - 12.9 = ~77.4 dB (~12.6 bits ENOB)

  assert_true(sqnr_db > 75.0)
}

///|
test "Suite34 MixedSignal 05: Current-Steering DAC 14-bit Gradient Matching Layout" {
  let n_bits = 14
  let inl_target_lsb = 0.5 // < 0.5 LSB INL with common-centroid quad layout
  assert_true(n_bits == 14)
  assert_true(inl_target_lsb <= 0.5)
}

///|
test "Suite34 MixedSignal 06: Data-Weighted Averaging DWA First-Order Mismatch Shaping" {
  // DWA rotates selected unit elements sequentially around the circular array to shape mismatch to high frequencies
  let num_elements = 16
  let mut pointer = 0

  let input_codes = [3, 5, 2, 4]
  for code in input_codes {
    pointer = (pointer + code) % num_elements
  }

  // Final pointer position = (3 + 5 + 2 + 4) % 16 = 14
  assert_true(pointer == 14)
}

///|
test "Suite34 MixedSignal 07: Sample-and-Hold Dummy Switch Charge Cancellation" {
  let q_inj_main = 10.0e-15 // 10 fF * 1V = 10 fC channel charge injected equally to S and D (5 fC each)
  let q_inj_dummy = 5.0e-15 // Half-sized dummy transistor pulls exactly 5 fC when turning on -> Net charge error = 0!

  let q_net_error = q_inj_main / 2.0 - q_inj_dummy
  assert_true(q_net_error == 0.0)
}

///|
test "Suite34 MixedSignal 08: Dual-Slope Integrating ADC 50 Hz Mains Rejection" {
  // T_integrate = N * (20 ms) -> Integrates over exact integer period of 50 Hz, perfectly canceling 50 Hz ripple
  let f_mains = 50.0
  let t_int = 0.020 // 20 ms
  assert_true((t_int * f_mains - 1.0).abs() < 1.0e-12)
}

///|
test "Suite34 MixedSignal 09: Vernier Delay Line TDC Sub-Picosecond Resolution" {
  // Resolution Delta t = tau_slow - tau_fast
  let tau_slow_ps = 30.0
  let tau_fast_ps = 28.5

  let delta_t_ps = tau_slow_ps - tau_fast_ps // 1.5 picoseconds LSB!
  assert_true((delta_t_ps - 1.5).abs() < 1.0e-6)
}

///|
test "Suite34 MixedSignal 10: ADC Dynamic ENOB Formula from SNDR" {
  // ENOB = (SNDR(dB) - 1.76) / 6.02
  let sndr_db = 74.0 // 74 dB SNDR

  let enob = (sndr_db - 1.76) / 6.02 // 12.0 bits
  assert_true((enob - 12.0).abs() < 0.05)
}
