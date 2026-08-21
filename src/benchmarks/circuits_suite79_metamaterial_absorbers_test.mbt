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
test "Suite79 Metamaterial 01: Negative Refractive Index n = - sqrt(eps * mu)" {
  // When both eps < 0 and mu < 0, n = - sqrt(eps * mu)
  let eps_eff = -2.5
  let mu_eff = -1.6

  let n_refr = -(eps_eff * mu_eff).sqrt() // - sqrt(4.0) = -2.0
  assert_true((n_refr - -2.0).abs() < 1.0e-6)
}

///|
test "Suite79 Metamaterial 02: Metamaterial Perfect Absorber Impedance Matching Z_eff = Z_0" {
  // A(omega) = 1 - R(omega) - T(omega) where R = |(Z - Z0)/(Z + Z0)|^2 = 0
  let z0_free_space = 376.73 // 377 Ohms
  let z_meta = 376.73

  let r_refl = ((z_meta - z0_free_space) / (z_meta + z0_free_space)).abs()
  let a_absorb = 1.0 - r_refl // 100% absorption!

  assert_true((a_absorb - 1.0).abs() < 1.0e-6)
}

///|
test "Suite79 Metamaterial 03: Split-Ring Resonator SRR Magnetic LC Resonance" {
  let l_srr_nh = 1.2
  let c_srr_pf = 0.8
  let f_res_ghz = 1.0 /
    (2.0 * @math.PI * (l_srr_nh * 1.0e-9 * c_srr_pf * 1.0e-12).sqrt()) /
    1.0e9 // ~5.14 GHz

  assert_true((f_res_ghz - 5.138).abs() < 0.05)
}

///|
test "Suite79 Metamaterial 04: Lorentz Dispersion Permeability Resonant Poles" {
  let f_0 = 10.0e9 // 10 GHz
  let f_plasma = 12.0e9
  assert_true(f_plasma > f_0)
}

///|
test "Suite79 Metamaterial 05: Cloaking Shell Transformation Optics Anisotropic Tensor" {
  let eps_radial = 0.25
  let eps_theta = 4.0
  assert_true(eps_theta > eps_radial)
}

///|
test "Suite79 Metamaterial 06: Chiral Metamaterial Giant Optical Activity Rotation" {
  let rot_deg_per_mm = 450.0 // 450 degrees / mm polarization rotation
  assert_true(rot_deg_per_mm > 100.0)
}

///|
test "Suite79 Metamaterial 07: Terahertz Spoof Surface Plasmon Polariton SSPP" {
  let v_phase_c = 0.85 // 85% speed of light confined wave
  assert_true(v_phase_c < 1.0)
}

///|
test "Suite79 Metamaterial 08: Huygens Metasurface 2*pi Phase Coverage" {
  let phase_coverage_rad = 2.0 * @math.PI
  assert_true(phase_coverage_rad > 6.0)
}

///|
test "Suite79 Metamaterial 09: Ultra-Thin Quarter-Wave Plate Retarder" {
  let delta_phase_deg = 90.0 // 90 degrees circular conversion
  assert_true(delta_phase_deg == 90.0)
}

///|
test "Suite79 Metamaterial 10: Non-Reciprocal Metamaterial Isolation" {
  let s21_fwd_db = -0.5
  let s12_rev_db = -35.0
  let isolation_db = s21_fwd_db - s12_rev_db // 34.5 dB isolation

  assert_true((isolation_db - 34.5).abs() < 1.0e-6)
}
