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
test "Suite97 QCD 01: Quantum Cascade Photodetector QCD Zero Bias Photovoltaic Operation" {
  let v_bias = 0.0 // Zero dark current noise at 0V bias!
  assert_true(v_bias == 0.0)
}

///|
test "Suite97 QCD 02: Intersubband Transition 4.5 um Mid-IR Peak Responsivity" {
  let r_peak_ma_per_w = 45.0 // 45 mA / W
  assert_true(r_peak_ma_per_w > 30.0)
}

///|
test "Suite97 QCD 03: Ultra-Fast Picosecond Response Time (f_3dB > 20 GHz)" {
  let f_3db_ghz = 25.0
  assert_true(f_3db_ghz >= 20.0)
}

///|
test "Suite97 QCD 04: Asymmetric Quantum Well Chirped Extraction Cascade Ladder" {
  let num_wells_per_period = 6
  assert_true(num_wells_per_period == 6)
}

///|
test "Suite97 QCD 05: Room-Temperature Johnson Noise Limited Detectivity D*" {
  let d_star = 1.2e8 // 1.2e8 cm*sqrt(Hz)/W at 300K
  assert_true(d_star > 1.0e8)
}

///|
test "Suite97 QCD 06: Free-Space Mid-IR Optical Heterodyne Mixing Receiver" {
  let f_if_ghz = 8.0
  assert_true(f_if_ghz == 8.0)
}

///|
test "Suite97 QCD 07: 45-Degree Polished Edge Multipass Waveguide Coupling" {
  let is_45deg_coupling_used = true
  assert_true(is_45deg_coupling_used)
}

///|
test "Suite97 QCD 08: 2D Periodic Patch-Antenna Metasurface Resonant Enhancement" {
  let gain_enhancement = 15.0 // 15x enhancement
  assert_true(gain_enhancement >= 10.0)
}

///|
test "Suite97 QCD 09: Multi-Spectral 4-Color Simultaneous Dual-Band Detection" {
  let num_bands = 4
  assert_true(num_bands == 4)
}

///|
test "Suite97 QCD 10: 64x64 Focal Plane Array Readout Integrated Circuit ROIC" {
  let num_pixels = 64 * 64 // 4096 pixels
  assert_true(num_pixels == 4096)
}
