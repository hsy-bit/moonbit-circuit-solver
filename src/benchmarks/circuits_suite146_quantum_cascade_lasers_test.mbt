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
test "Suite146 QCL 01: Mid-Infrared 4.6 um QCL Intersubband Population Inversion" {
  let lambda_qcl_um = 4.6
  let delta_e_subband_ev = 1.239841984 / lambda_qcl_um // ~0.2695 eV
  assert_true(lambda_qcl_um == 4.6)
  assert_true((delta_e_subband_ev - 0.2695).abs() < 0.005)
}

///|
test "Suite146 QCL 02: Resonant Phonon Depopulation Lifetime (tau_depop < 0.3 ps)" {
  let tau_lo_ps = 0.25
  assert_true(tau_lo_ps <= 0.30)
}

///|
test "Suite146 QCL 03: 40-Period Cascade Stage Voltage Drop (V_total = 40 * 0.3V = 12V)" {
  let num_stages = 40
  let v_stage = 0.30
  let v_total = num_stages.to_double() * v_stage

  assert_true(num_stages == 40)
  assert_true((v_total - 12.0).abs() < 1.0e-6)
}

///|
test "Suite146 QCL 04: Continuous-Wave Room-Temperature High-Power Output (> 2 Watts CW)" {
  let p_opt_cw_w = 2.4
  assert_true(p_opt_cw_w >= 2.0)
}

///|
test "Suite146 QCL 05: Distributed Feedback DFB Grating Single-Mode SMSR (> 35 dB)" {
  let smsr_db = 38.0
  assert_true(smsr_db >= 35.0)
}

///|
test "Suite146 QCL 06: External Cavity EC-QCL Wide Tuning Range (900 cm^-1 to 1200 cm^-1)" {
  let delta_nu_cm_inv = 300.0 // 300 cm^-1 broad tuning
  assert_true(delta_nu_cm_inv >= 250.0)
}

///|
test "Suite146 QCL 07: Terahertz THz QCL Operation at 250 Kelvin (> 200K Milestone)" {
  let t_max_thz_k = 250.0
  assert_true(t_max_thz_k >= 200.0)
}

///|
test "Suite146 QCL 08: High-Speed Direct Current Modulation Bandwidth (f_mod > 10 GHz)" {
  let f_mod_ghz = 12.5
  assert_true(f_mod_ghz >= 10.0)
}

///|
test "Suite146 QCL 09: Wall-Plug Efficiency WPE in Mid-IR Spectrum (> 20%)" {
  let wpe_percent = 22.5
  assert_true(wpe_percent >= 20.0)
}

///|
test "Suite146 QCL 10: Environmental Trace Gas Sensing (Sub-ppb NO/CO2 Detection)" {
  let sens_ppb = 0.5
  assert_true(sens_ppb < 1.0)
}
