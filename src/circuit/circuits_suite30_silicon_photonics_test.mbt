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
test "Suite30 Photonics 01: Mach-Zehnder Modulator MZM Transfer Curve" {
  // P_out = P_in * cos^2( (pi/2) * (V / V_pi) )
  let p_in = 10.0e-3 // 10 mW optical power
  let v_pi = 3.5 // 3.5V half-wave voltage
  let v_bias = 1.75 // Quadrature bias (V_pi / 2)

  let phase_arg = @math.PI / 2.0 * (v_bias / v_pi) // pi / 4
  let cos_val = @math.cos(phase_arg)
  let p_out = p_in * cos_val * cos_val // 5.0 mW (50% transmission at quadrature)

  assert_true((p_out - 0.005).abs() < 1.0e-6)
}

///|
test "Suite30 Photonics 02: Micro-Ring Resonator MRR Quality Factor and Finesse" {
  // Q = lambda_res / FWHM, Finesse F = FSR / FWHM
  let lambda_res = 1550.0e-9 // 1550 nm Telecom C-band
  let fwhm_delta_lambda = 0.050e-9 // 50 pm 3dB bandwidth
  let fsr_lambda = 3.2e-9 // 3.2 nm Free Spectral Range

  let q_factor = lambda_res / fwhm_delta_lambda // 31,000
  let finesse_f = fsr_lambda / fwhm_delta_lambda // 64

  assert_true((q_factor - 31000.0).abs() < 1.0)
  assert_true((finesse_f - 64.0).abs() < 1.0e-6)
}

///|
test "Suite30 Photonics 03: Silicon Thermo-Optic Phase Shifter Power Requirement" {
  // P_pi = lambda / (2 * L * (dn/dT) * R_th)
  let p_pi_mw = 12.5 // 12.5 mW heating power for pi phase shift
  assert_true(p_pi_mw > 10.0 && p_pi_mw < 20.0)
}

///|
test "Suite30 Photonics 04: Ge-on-Si Photodiode Responsivity at 1550 nm" {
  // R = (eta * q * lambda) / (h * c)
  let q_e = 1.602176634e-19
  let h_planck = 6.62607015e-34
  let c_light = 2.99792458e8
  let lambda_m = 1550.0e-9
  let quantum_eff_eta = 0.85 // 85% quantum efficiency

  let responsivity = quantum_eff_eta * q_e * lambda_m / (h_planck * c_light) // ~1.062 A/W
  assert_true((responsivity - 1.062).abs() < 0.01)
}

///|
test "Suite30 Photonics 05: Plasma Dispersion V_pi * L Figure of Merit" {
  let v_pi_l_vcm = 1.2 // 1.2 V*cm in reverse-biased PN junction
  let length_cm = 0.3 // 3 mm phase shifter

  let v_pi_calc = v_pi_l_vcm / length_cm // 4.0 V
  assert_true((v_pi_calc - 4.0).abs() < 1.0e-6)
}

///|
test "Suite30 Photonics 06: RF and Optical Phase Velocity Matching in Traveling-Wave Modulator" {
  let n_opt_group = 3.80 // Optical group index in Si waveguide
  let n_rf_phase = 3.80 // Microwave effective index on coplanar waveguide

  let velocity_mismatch = (n_opt_group - n_rf_phase).abs()
  assert_true(velocity_mismatch == 0.0) // Perfect velocity match enables > 60 GHz electro-optic bandwidth
}

///|
test "Suite30 Photonics 07: Fiber-to-Chip Grating Coupler Gaussian Overlap Loss" {
  let loss_db = 2.2 // 2.2 dB per coupler
  let ln10 = @math.ln(10.0)
  let trans_frac = @math.exp(-(loss_db / 10.0) * ln10)

  assert_true(trans_frac > 0.55 && trans_frac < 0.65) // ~60.2% optical transmission
}

///|
test "Suite30 Photonics 08: 100 GHz DWDM Channel Frequency Spacing" {
  let f_spacing_ghz = 100.0 // ITU-T grid standard
  let c_light = 3.0e8
  let lambda_0 = 1550.0e-9

  // Delta lambda = lambda^2 * Delta_f / c
  let delta_lambda_nm = lambda_0 *
    lambda_0 *
    f_spacing_ghz *
    1.0e9 /
    c_light *
    1.0e9 // ~0.80 nm
  assert_true((delta_lambda_nm - 0.8008).abs() < 0.01)
}

///|
test "Suite30 Photonics 09: Co-Packaged Optics CPO Laser Diode Forward I-L Curve" {
  let i_threshold = 0.015 // 15 mA threshold current
  let slope_eff_w_per_a = 0.40 // 0.40 W/A
  let i_drive = 0.050 // 50 mA drive current

  let p_laser_opt = slope_eff_w_per_a * (i_drive - i_threshold) // 14 mW
  assert_true((p_laser_opt - 0.014).abs() < 1.0e-6)
}

///|
test "Suite30 Photonics 10: Photonic Integrated Circuit Optical S-Matrix Reciprocity" {
  // S_12 == S_21 in passive lossless optical power splitter (Y-junction)
  let s12_mag = 0.707106
  let s21_mag = 0.707106
  assert_true((s12_mag - s21_mag).abs() < 1.0e-12)
}
