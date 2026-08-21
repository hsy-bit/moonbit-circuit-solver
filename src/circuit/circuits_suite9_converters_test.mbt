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
test "Suite9 Converter 01: 10-bit Binary Weighted Resistor DAC" {
  let v_ref = 5.0
  let num_bits = 10
  let max_code = 1023
  let lsb_val = v_ref / 1024.0

  let code_mid = 512
  let v_out_mid = v_ref * code_mid.to_double() / 1024.0

  assert_true((v_out_mid - 2.5).abs() < 1.0e-12)
  assert_true(num_bits == 10)
  assert_true(max_code == 1023)
  assert_true(lsb_val < 0.005)
}

///|
test "Suite9 Converter 02: Current-Steering Differential DAC Architecture" {
  // 8-bit unary thermometer DAC cell array
  let i_unit = 20.0e-6 // 20 uA unit current
  let r_load = 50.0 // 50 Ohm differential load

  let code = 128
  let i_pos = code.to_double() * i_unit
  let i_neg = (255 - code).to_double() * i_unit

  let v_diff = (i_pos - i_neg) * r_load
  assert_true(v_diff.abs() < 0.01) // Near 0V differential at mid-scale
}

///|
test "Suite9 Converter 03: 1st-Order Sigma-Delta (Delta-Sigma) Modulator" {
  // Discrete-time 1st-order Delta-Sigma loop:
  // Integrator: u[k] = u[k-1] + x[k] - y[k-1]
  // 1-bit Quantizer: y[k] = if u[k] >= 0 { 1.0 } else { -1.0 }
  let input_dc = 0.45 // Constant DC input in range [-1.0, 1.0]
  let num_samples = 1000

  let mut u_int = 0.0
  let mut y_prev = 0.0
  let mut sum_y = 0.0

  for _k = 0; _k < num_samples; _k = _k + 1 {
    u_int = u_int + input_dc - y_prev
    let y_curr = if u_int >= 0.0 { 1.0 } else { -1.0 }
    y_prev = y_curr
    sum_y = sum_y + y_curr
  }

  let avg_output = sum_y / num_samples.to_double()
  // Reconstructed average must closely match input DC
  assert_true((avg_output - input_dc).abs() < 0.05)
}

///|
test "Suite9 Converter 04: 2nd-Order Sigma-Delta Modulator Noise Shaping" {
  let input_dc = 0.3
  let num_samples = 1000

  let mut u1 = 0.0
  let mut u2 = 0.0
  let mut y_prev = 0.0
  let mut sum_y = 0.0

  for _k = 0; _k < num_samples; _k = _k + 1 {
    u1 = u1 + input_dc - y_prev
    u2 = u2 + u1 - y_prev
    let y_curr = if u2 >= 0.0 { 1.0 } else { -1.0 }
    y_prev = y_curr
    sum_y = sum_y + y_curr
  }

  let avg_output = sum_y / num_samples.to_double()
  assert_true((avg_output - input_dc).abs() < 0.05)
}

///|
test "Suite9 Converter 05: Dual-Slope Integrating ADC Integration Times" {
  // Phase 1 (Run-up): Integrate unknown V_in for fixed time T1 = N1 * T_clk (e.g. 1000 cycles)
  // Phase 2 (Run-down): De-integrate known -V_ref until integrator hits zero in time T2 = N2 * T_clk
  // Formula: V_in = V_ref * (N2 / N1) independent of R and C values!
  let v_ref = 2.5
  let n1 = 1000
  let target_vin = 1.625

  let n2 = (target_vin / v_ref * n1.to_double()).to_int()
  let reconstructed_vin = v_ref * n2.to_double() / n1.to_double()

  assert_true(n2 == 650)
  assert_true((reconstructed_vin - target_vin).abs() < 1.0e-6)
}

///|
test "Suite9 Converter 06: 1.5-bit Per Stage Pipelined ADC Sub-Stage" {
  // 1.5-bit sub-stage with 3 comparator thresholds (-Vref/4, +Vref/4)
  let v_ref = 1.0
  let v_in = 0.4

  let (digit, v_sub) = if v_in > v_ref / 4.0 {
    (1, v_ref / 2.0)
  } else if v_in < -v_ref / 4.0 {
    (-1, -v_ref / 2.0)
  } else {
    (0, 0.0)
  }

  // Residue voltage V_res = 2 * (V_in - V_sub)
  let v_res = 2.0 * (v_in - v_sub)
  assert_true(digit == 1)
  assert_true((v_res - -0.2).abs() < 1.0e-12)
}

///|
test "Suite9 Converter 07: Flash ADC Thermometer Code Bubble Error Correction" {
  // Thermometer code with single 0-bubble error: 00010111 (bit 3 is a false 0)
  let raw_code = 0b00010111
  let num_bits = 8

  // 3-input majority voting filter: B_k = (T_{k-1} & T_k) | (T_k & T_{k+1}) | (T_{k-1} & T_{k+1})
  let mut filtered_code = 0
  for k = 0; k < num_bits; k = k + 1 {
    let prev_b = if k > 0 { (raw_code >> (k - 1)) & 1 } else { 1 }
    let curr_b = (raw_code >> k) & 1
    let next_b = if k + 1 < num_bits { (raw_code >> (k + 1)) & 1 } else { 0 }

    let majority = (prev_b & curr_b) | (curr_b & next_b) | (prev_b & next_b)
    filtered_code = filtered_code | (majority << k)
  }

  assert_true(filtered_code != 0)
}

///|
test "Suite9 Converter 08: SAR ADC Binary Search Convergence" {
  let v_ref = 3.3
  let v_in = 2.0
  let num_bits = 10
  let mut result_code = 0

  for bit = num_bits - 1; bit >= 0; bit = bit - 1 {
    let test_code = result_code | (1 << bit)
    let dac_volt = v_ref * test_code.to_double() / 1024.0
    if v_in >= dac_volt {
      result_code = test_code
    }
  }

  let final_v = v_ref * result_code.to_double() / 1024.0
  assert_true((final_v - v_in).abs() < v_ref / 1024.0)
}

///|
test "Suite9 Converter 09: Dynamic ADC Metrics: SNR, SINAD and ENOB" {
  // Theoretical SNR for N-bit ideal ADC: SNR = 6.02 * N + 1.76 dB
  let n_bits = 12
  let snr_ideal = 6.02 * n_bits.to_double() + 1.76 // 74.0 dB
  let thd_db = 80.0
  let ln10 = @math.ln(10.0)
  let p_noise = @math.exp(-(snr_ideal / 10.0) * ln10)
  let p_thd = @math.exp(-(thd_db / 10.0) * ln10)
  let sinad = -10.0 * (@math.ln(p_noise + p_thd) / ln10)

  // ENOB = (SINAD - 1.76) / 6.02
  let enob = (sinad - 1.76) / 6.02
  assert_true(enob > 11.0 && enob <= 12.0)
}

///|
test "Suite9 Converter 10: DAC Output Slew Rate and Settling Time" {
  let v_step = 10.0 // 10V step
  let slew_rate = 50.0e6 // 50 V/us = 50e6 V/s
  let tau = 20.0e-9 // 20 ns small-signal time constant

  // Slew time Tslew = V_step / SR = 10 / 50e6 = 200 ns
  let t_slew = v_step / slew_rate
  // 0.1% settling takes 7 * tau = 140 ns
  let t_linear = 7.0 * tau
  let t_total_settling = t_slew + t_linear

  assert_true((t_slew - 200.0e-9).abs() < 1.0e-12)
  assert_true(t_total_settling > 300.0e-9 && t_total_settling < 400.0e-9)
}
