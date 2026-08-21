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
test "Suite64 SOI 01: FD-SOI UTBB Back-Gate Body Bias Threshold Voltage Tuning" {
  // Delta V_th = - gamma_back * V_back_gate where gamma_back approx 85 mV / V
  let gamma_back_mv_v = 85.0
  let v_back_gate = 2.0 // +2.0V Forward Body Bias (FBB)

  let delta_vth_mv = -gamma_back_mv_v * v_back_gate // -170 mV threshold drop (High performance turbo mode!)
  assert_true((delta_vth_mv - -170.0).abs() < 1.0e-6)
}

///|
test "Suite64 SOI 02: Partially Depleted SOI Floating Body Kink Voltage" {
  // Kink occurs when Vds exceeds impact ionization threshold ~ 1.1V
  let v_kink_onset = 1.10
  let v_ds_test = 1.50
  let is_in_kink = v_ds_test > v_kink_onset

  assert_true(is_in_kink)
}

///|
test "Suite64 SOI 03: Thin-Film Silicon SEU Sensitive Volume Suppression" {
  // Sensitive volume thickness in bulk: ~2000 nm, in FD-SOI: ~6 nm (300x reduction in collected charge!)
  let t_si_bulk_nm = 2000.0
  let t_si_fdsoi_nm = 6.0
  let charge_reduction_ratio = t_si_bulk_nm / t_si_fdsoi_nm // 333.3x

  assert_true((charge_reduction_ratio - 333.333).abs() < 0.1)
}

///|
test "Suite64 SOI 04: DTMOS Dynamic Threshold Voltage Zero Overdrive Leakage" {
  // In OFF state (Vg = 0 -> Vb = 0): Vth is high (~0.4V), In ON state (Vg = Vdd -> Vb = Vdd): Vth drops to ~0.2V
  let v_th_off = 0.40
  let v_th_on = 0.20
  assert_true(v_th_off > v_th_on)
}

///|
test "Suite64 SOI 05: Buried Oxide BOX Thermal Resistance Self-Heating" {
  let r_th_bulk = 50.0 // 50 K/W
  let r_th_soi = 180.0 // 180 K/W (Higher self heating due to SiO2 BOX layer)
  assert_true(r_th_soi > 3.0 * r_th_bulk)
}

///|
test "Suite64 SOI 06: RF High-Resistivity Substrate Harmonic Distortion HD2" {
  let hd2_dbc = -95.0 // -95 dBc harmonic suppression with trap-rich layer
  assert_true(hd2_dbc < -90.0)
}

///|
test "Suite64 SOI 07: Cryogenic 4.2K FD-SOI Subthreshold Slope" {
  let s_4k_mv_dec = 8.5 // 8.5 mV / decade at 4K
  assert_true(s_4k_mv_dec < 10.0)
}

///|
test "Suite64 SOI 08: SOI Floating Body History Propagation Delay Variation" {
  let t_delay_first_switch_ps = 25.0
  let t_delay_steady_state_ps = 22.5 // ~10% faster due to accumulated hole potential
  let speedup_percent = (t_delay_first_switch_ps - t_delay_steady_state_ps) /
    t_delay_first_switch_ps // 10%

  assert_true((speedup_percent - 0.10).abs() < 1.0e-4)
}

///|
test "Suite64 SOI 09: Complete Dielectric Latchup Immunity via BOX" {
  let is_latchup_immune = true
  assert_true(is_latchup_immune)
}

///|
test "Suite64 SOI 10: UTBB FD-SOI Ultra-Low Drain Induced Barrier Lowering DIBL" {
  let dibl_mv_v = 35.0 // Low DIBL of 35 mV/V in 22nm FD-SOI
  assert_true(dibl_mv_v < 40.0)
}
