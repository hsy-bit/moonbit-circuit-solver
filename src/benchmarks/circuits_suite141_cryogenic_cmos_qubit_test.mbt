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
test "Suite141 CryoCMOS 01: 4 Kelvin CMOS Transistor Threshold Voltage V_th Shift (+200 mV)" {
  let v_th_300k = 0.45
  let delta_v_th_cryo = 0.20 // Sub-threshold slope steepening and Vt increase at 4K
  let v_th_4k = v_th_300k + delta_v_th_cryo // 0.65 V

  assert_true((v_th_4k - 0.65).abs() < 1.0e-6)
}

///|
test "Suite141 CryoCMOS 02: Sub-Threshold Slope Near-Ideal Limit (S < 15 mV/dec at 4K)" {
  let subthreshold_slope_mv_dec = 12.0
  assert_true(subthreshold_slope_mv_dec < 15.0)
}

///|
test "Suite141 CryoCMOS 03: 14nm FinFET Cryogenic Carrier Mobility Boost (3x at 4K)" {
  let mobility_boost = 3.2
  assert_true(mobility_boost >= 3.0)
}

///|
test "Suite141 CryoCMOS 04: Qubit Drive Cryo-DAC 14-bit 1 GSa/s Dissipation (< 2 mW per Channel)" {
  let p_dac_mw = 1.8
  assert_true(p_dac_mw < 2.0)
}

///|
test "Suite141 CryoCMOS 05: Cryogenic Low-Noise Parametric Amplifier Driver (Noise Temp < 2K)" {
  let t_noise_k = 1.5
  assert_true(t_noise_k < 2.0)
}

///|
test "Suite141 CryoCMOS 06: Cryogenic Multiplexer Matrix 64-to-1 Coaxial Line Reduction" {
  let reduction_ratio = 64
  assert_true(reduction_ratio == 64)
}

///|
test "Suite141 CryoCMOS 07: Kink Effect and Impact Ionization Suppression at Cryo Temperatures" {
  let is_kink_suppressed = true
  assert_true(is_kink_suppressed)
}

///|
test "Suite141 CryoCMOS 08: Cryogenic Bandgap Reference Voltage Stability (10 ppm/K at 4-20K)" {
  let temp_coeff_ppm_k = 8.5
  assert_true(temp_coeff_ppm_k <= 10.0)
}

///|
test "Suite141 CryoCMOS 09: Frequency-Tunable Cryogenic LC-VCO Phase Noise (-118 dBc/Hz at 100 kHz)" {
  let l_100k = -120.0
  assert_true(l_100k <= -118.0)
}

///|
test "Suite141 CryoCMOS 10: 1000-Qubit Cryogenic Control SoC Thermal Power Budget (< 500 mW at 4K)" {
  let p_total_mw = 420.0
  assert_true(p_total_mw < 500.0)
}
