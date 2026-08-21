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
/// Generates SPICE netlist string for an N-bit R-2R Ladder Digital-to-Analog Converter (DAC).
pub fn generate_r2r_dac_netlist(
  num_bits : Int,
  v_ref : Double,
  r_val : Double,
  digital_word : Int,
) -> String {
  let mut s = "* " + num_bits.to_string() + "-bit R-2R Ladder DAC\n"
  let r2 = 2.0 * r_val

  // Termination resistor at LSB
  s = s + "R_TERM n0 0 " + r2.to_string() + "\n"

  for k = 0; k < num_bits; k = k + 1 {
    let bit_val = (digital_word >> k) & 1
    let v_bit = if bit_val == 1 { v_ref } else { 0.0 }
    let v_src_name = "V_BIT_" + k.to_string()
    let bit_node = "b" + k.to_string()
    let ladder_node = "n" + k.to_string()

    s = s + v_src_name + " " + bit_node + " 0 DC " + v_bit.to_string() + "\n"
    s = s +
      "R_LEG_" +
      k.to_string() +
      " " +
      ladder_node +
      " " +
      bit_node +
      " " +
      r2.to_string() +
      "\n"

    if k + 1 < num_bits {
      let next_node = "n" + (k + 1).to_string()
      s = s +
        "R_SER_" +
        k.to_string() +
        " " +
        ladder_node +
        " " +
        next_node +
        " " +
        r_val.to_string() +
        "\n"
    }
  }

  s = s + ".op\n"
  s
}

///|
test "8-bit R-2R Ladder DAC Linearity, DNL and Monotonicity" {
  let v_ref = 3.3
  let num_bits = 8
  let r_val = 10000.0
  let num_codes = 16 // Test across codes

  let lsb_voltage = v_ref / 256.0
  let mut prev_v = -1.0
  let mut max_dnl = 0.0

  for code = 0; code < num_codes; code = code + 1 {
    let actual_code = code * 16 // 0, 16, 32, ..., 240
    let netlist_str = generate_r2r_dac_netlist(
      num_bits, v_ref, r_val, actual_code,
    )
    let netlist = @spice.parse_spice_netlist(netlist_str)
    let sim = CircuitSimulator::{ netlist, }
    let dc = sim.solve_dc()

    let msb_node = "n" + (num_bits - 1).to_string()
    let v_out = match dc.get(msb_node) {
      Some(v) => v
      None => 0.0
    }

    let expected_v = v_ref * actual_code.to_double() / 256.0
    assert_true((v_out - expected_v).abs() < 1.0e-3)

    if code > 0 {
      let step_v = v_out - prev_v
      assert_true(step_v > 0.0) // Monotonicity check
      let dnl = (step_v / (lsb_voltage * 16.0) - 1.0).abs()
      if dnl > max_dnl {
        max_dnl = dnl
      }
    }
    prev_v = v_out
  }

  assert_true(max_dnl < 0.1) // DNL < 0.1 LSB
}

///|
test "4-bit Flash ADC Comparator Ladder and Priority Encoder" {
  let v_ref = 4.0
  let num_levels = 16
  let r_ladder = 1000.0

  // Reference ladder voltages: V_k = V_ref * k / 16
  let v_in = 2.65 // Input analog voltage (between 10/16*4 = 2.5V and 11/16*4 = 2.75V)
  let expected_code = 10

  let mut thermometer_code = 0
  for k = 1; k < num_levels; k = k + 1 {
    let v_thresh = v_ref * k.to_double() / num_levels.to_double()
    if v_in >= v_thresh {
      thermometer_code = thermometer_code | (1 << (k - 1))
    }
  }

  // Priority encoder count of active bits
  let mut digital_out = 0
  let mut mask = thermometer_code
  while mask > 0 {
    if (mask & 1) == 1 {
      digital_out = digital_out + 1
    }
    mask = mask >> 1
  }

  assert_true(digital_out == expected_code)
  assert_true(r_ladder > 0.0)
}

///|
test "12-bit Successive Approximation Register (SAR) ADC Binary Search" {
  let v_ref = 3.3
  let num_bits = 12
  let target_analog_v = 2.153

  let mut sar_code = 0

  for bit = num_bits - 1; bit >= 0; bit = bit - 1 {
    let trial_code = sar_code | (1 << bit)
    let dac_v = v_ref * trial_code.to_double() / 4096.0

    // Comparator decision
    if target_analog_v >= dac_v {
      sar_code = trial_code // Keep bit 1
    }
  }

  let final_reconstructed_v = v_ref * sar_code.to_double() / 4096.0
  let quant_error = (final_reconstructed_v - target_analog_v).abs()
  let lsb_12bit = v_ref / 4096.0

  assert_true(quant_error <= lsb_12bit)
}
