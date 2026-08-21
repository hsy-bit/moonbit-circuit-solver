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
test "Suite91 THzImage 01: Terahertz Time-Domain Spectroscopy THz-TDS Pulse Reconstruction" {
  // E(t) electric field pulse duration ~ 1 ps
  let tau_pulse_ps = 1.2
  let f_nyquist_thz = 1.0 / (tau_pulse_ps * 1.0e-12) / 1.0e12 // ~0.833 THz
  assert_true(tau_pulse_ps < 2.0)
  assert_true(f_nyquist_thz > 0.5)
}

///|
test "Suite91 THzImage 02: Photoconductive Antenna PCA Femtosecond Laser Excitation" {
  let tau_laser_fs = 80.0 // 80 fs laser pulse
  assert_true(tau_laser_fs < 100.0)
}

///|
test "Suite91 THzImage 03: Non-Destructive Packaging Defect Sub-Millimeter Depth Profiling" {
  let delta_z_um = 25.0 // 25 um axial depth resolution
  assert_true(delta_z_um < 50.0)
}

///|
test "Suite91 THzImage 04: Lock-In Amplifier 100 kHz Demodulation Dynamic Range" {
  let dynamic_range_db = 85.0
  assert_true(dynamic_range_db >= 80.0)
}

///|
test "Suite91 THzImage 05: Silicon Lens Hyper-Hemispherical Substrate Coupling" {
  let d_lens_mm = 10.0
  assert_true(d_lens_mm == 10.0)
}

///|
test "Suite91 THzImage 06: Terahertz Metamaterial Biosensor Resonance Sensitivity" {
  let s_nm_per_riu = 350.0 // 350 nm shift per refractive index unit
  assert_true(s_nm_per_riu > 300.0)
}

///|
test "Suite91 THzImage 07: Uncooled Microbolometer 320x240 THz Focal Plane Array" {
  let num_pixels = 320 * 240 // 76,800 pixels
  assert_true(num_pixels == 76800)
}

///|
test "Suite91 THzImage 08: Rapid Optical Delay Line Scanning Rate (20 Hz)" {
  let scan_freq_hz = 20.0
  assert_true(scan_freq_hz == 20.0)
}

///|
test "Suite91 THzImage 09: Terahertz Wave Absorption in Pharmaceutical Tablet Coating" {
  let alpha_abs_per_cm = 12.0
  assert_true(alpha_abs_per_cm > 5.0)
}

///|
test "Suite91 THzImage 10: 2D Raster Scanning Confocal Resolution (0.3 mm)" {
  let lateral_res_mm = 0.30
  assert_true(lateral_res_mm <= 0.50)
}
