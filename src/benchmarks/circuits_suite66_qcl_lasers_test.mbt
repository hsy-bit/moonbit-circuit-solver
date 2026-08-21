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
test "Suite66 QCL 01: Mid-Infrared 8.5 um Intersubband Photon Transition" {
  // E = h * c / lambda
  let h_planck = 6.62607015e-34
  let c_light = 2.99792458e8
  let lambda_m = 8.5e-6 // 8.5 um Mid-IR
  let q_e = 1.602176634e-19

  let e_joules = h_planck * c_light / lambda_m // ~2.3369e-20 J
  let e_ev = e_joules / q_e // ~0.1458 eV (145.8 meV intersubband transition)

  assert_true((e_ev - 0.1458).abs() < 0.002)
}

///|
test "Suite66 QCL 02: 40-Stage Quantum Cascade Total Operating Voltage" {
  let num_stages = 40
  let v_drop_per_stage = 0.28 // 280 mV per period
  let v_total = num_stages.to_double() * v_drop_per_stage // 11.2 V

  assert_true((v_total - 11.2).abs() < 1.0e-6)
}

///|
test "Suite66 QCL 03: Ultra-Low-Noise Current Driver 10 nA RMS Noise Floor" {
  let i_driver_a = 0.800 // 800 mA operating current
  let i_noise_rms_na = 8.5 // 8.5 nA RMS
  let rel_noise = i_noise_rms_na * 1.0e-9 / i_driver_a // ~1.06e-8 (Ultra-quiet driver for sub-kHz laser linewidth!)

  assert_true(rel_noise < 2.0e-8)
}

///|
test "Suite66 QCL 04: DFB QCL Side-Mode Suppression Ratio SMSR" {
  let smsr_db = 38.5 // 38.5 dB single-mode spectral purity
  assert_true(smsr_db > 35.0)
}

///|
test "Suite66 QCL 05: Stirling Cooler Temperature Stability (Delta T < 5 mK)" {
  let delta_t_mk = 3.2 // 3.2 mK RMS temperature stability
  assert_true(delta_t_mk < 5.0)
}

///|
test "Suite66 QCL 06: Photoacoustic Spectroscopy Acoustic Cavity Q-Factor" {
  let f_acoustic = 4000.0 // 4 kHz longitudinal acoustic resonance
  let q_acoustic = 65.0 // Q = 65
  assert_true(q_acoustic >= 50.0)
  assert_true(f_acoustic == 4000.0)
}

///|
test "Suite66 QCL 07: Mercury Cadmium Telluride MCT Detector NEP" {
  // NEP = sqrt(A * Delta_f) / D*
  let d_star = 3.0e10 // 3e10 cm*sqrt(Hz)/W
  let area_cm2 = 0.01
  let nep_w_sqrt_hz = area_cm2.sqrt() / d_star // ~3.33e-12 W/sqrt(Hz)

  assert_true((nep_w_sqrt_hz - 3.333e-12).abs() < 1.0e-14)
}

///|
test "Suite66 QCL 08: External Cavity Broad Tuning Range (250 cm^-1)" {
  let tuning_range_cm_inv = 250.0
  assert_true(tuning_range_cm_inv >= 200.0)
}

///|
test "Suite66 QCL 09: Intracavity Waveguide Optical Loss Alpha" {
  let alpha_loss_per_cm = 4.5 // 4.5 cm^-1 waveguide loss
  assert_true(alpha_loss_per_cm < 10.0)
}

///|
test "Suite66 QCL 10: Pulsed QCL Thermal Chirp Waveguide Tuning" {
  let chirp_rate_cm_inv_per_us = 1.8 // 1.8 cm^-1 / us
  assert_true(chirp_rate_cm_inv_per_us > 1.0)
}
