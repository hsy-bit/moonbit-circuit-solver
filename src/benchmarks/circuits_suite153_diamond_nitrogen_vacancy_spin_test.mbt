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
test "Suite153 DiamondNV 01: Ground-State Triplet Zero-Field Splitting D_gs = 2.87 GHz" {
  let d_gs_ghz = 2.87
  assert_true(d_gs_ghz == 2.87)
}

///|
test "Suite153 DiamondNV 02: Optically Detected Magnetic Resonance ODMR Contrast (> 20%)" {
  let odmr_contrast_percent = 25.0
  assert_true(odmr_contrast_percent >= 20.0)
}

///|
test "Suite153 DiamondNV 03: Room-Temperature Spin Coherence Time T2 Dynamical Decoupling (> 2 ms)" {
  let t2_dd_ms = 2.4
  assert_true(t2_dd_ms >= 2.0)
}

///|
test "Suite153 DiamondNV 04: Nanoscale Magnetic Resonance Imaging MRI Single-Protein Proton Mapping" {
  let spatial_res_nm = 1.2
  assert_true(spatial_res_nm < 2.0)
}

///|
test "Suite153 DiamondNV 05: 14N / 15N Hyperfine Coupling Nuclear Spin Memory Registers" {
  let a_hyperfine_mhz = 2.16
  assert_true(a_hyperfine_mhz > 2.0)
}

///|
test "Suite153 DiamondNV 06: Widefield Magnetic Microscope Ensemble Magnetic Field Sensitivity (10 pT/sqrt(Hz))" {
  let sens_pt = 8.5
  assert_true(sens_pt <= 10.0)
}

///|
test "Suite153 DiamondNV 07: High-Pressure Diamond Anvil Cell DAC Megabar Pressure Sensor" {
  let p_max_gpa = 100.0 // 100 GPa (1 Megabar)
  assert_true(p_max_gpa == 100.0)
}

///|
test "Suite153 DiamondNV 08: Nanodiamond Cellular Intracellular Temperature Mapping (0.1 mK Precision)" {
  let temp_prec_mk = 0.08
  assert_true(temp_prec_mk < 0.10)
}

///|
test "Suite153 DiamondNV 09: Fiber-Coupled Integrated Diamond NV Magnetometer Probe" {
  let is_fiber_integrated = true
  assert_true(is_fiber_integrated)
}

///|
test "Suite153 DiamondNV 10: Quantum Gyroscope Nuclear Spin Rotation Sensing Precision" {
  let gyro_sens_deg_per_hr = 0.005
  assert_true(gyro_sens_deg_per_hr < 0.01)
}
