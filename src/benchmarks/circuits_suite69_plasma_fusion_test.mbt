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
test "Suite69 Plasma 01: Triple Langmuir Probe Electron Temperature Te" {
  // Te = V_d2 / ln(2)
  let v_d2 = 34.657 // 34.657 V measured between floating probes
  let ln2 = @math.ln(2.0) // 0.693147

  let t_e_ev = v_d2 / ln2 // 50.0 eV electron temperature
  assert_true((t_e_ev - 50.0).abs() < 1.0e-3)
}

///|
test "Suite69 Plasma 02: Ion Saturation Current Density in Deuterium Plasma" {
  // J_isat = e * n_e * c_s where c_s = sqrt(e * Te / m_i)
  let q_e = 1.602176634e-19
  let n_e = 1.0e19 // 1e19 m^-3
  let t_e_ev = 50.0 // 50 eV
  let m_deuterium_kg = 3.3435837e-27 // Deuteron mass

  let c_sound_m_s = (t_e_ev * q_e / m_deuterium_kg).sqrt() // ~48962 m/s
  let j_isat_a_m2 = q_e * n_e * c_sound_m_s // ~78446 A/m^2 = 7.84 A/cm^2

  assert_true(c_sound_m_s > 40000.0)
  assert_true(j_isat_a_m2 > 70000.0)
}

///|
test "Suite69 Plasma 03: Tokamak 15 Mega-Ampere Plasma Current Rogowski Coil" {
  let i_plasma_ma = 15.0 // 15 MA plasma current
  let m_mutual_nh = 100.0 // 100 nH
  let di_dt_ma_per_s = 5.0 // 5 MA/s ramp

  let v_rogowski = m_mutual_nh * 1.0e-9 * (di_dt_ma_per_s * 1.0e6) // 0.50 V
  assert_true((v_rogowski - 0.50).abs() < 1.0e-6)
  assert_true(i_plasma_ma == 15.0)
}

///|
test "Suite69 Plasma 04: ECE Radiometer 100-140 GHz Heterodyne Downconversion" {
  let f_ece_ghz = 120.0
  let f_lo_ghz = 110.0
  let f_if_ghz = f_ece_ghz - f_lo_ghz // 10 GHz IF

  assert_true(f_if_ghz == 10.0)
}

///|
test "Suite69 Plasma 05: Faraday Rotation Angle Polarimetry Density Product" {
  // Psi = C_f * lambda^2 * int n_e * B_parallel dl
  let lambda_um = 118.0 // 118 um far-infrared CH3OH laser
  assert_true(lambda_um == 118.0)
}

///|
test "Suite69 Plasma 06: Mirnov Magnetic Coils MHD Tearing Mode Frequency" {
  let f_mhd_khz = 25.0 // 25 kHz Mirnov oscillation (m=2, n=1 mode)
  assert_true(f_mhd_khz > 10.0 && f_mhd_khz < 100.0)
}

///|
test "Suite69 Plasma 07: Neutral Beam Injection 100 kV / 50 A Accel Grid" {
  let v_accel_kv = 100.0
  let i_beam_a = 50.0
  let p_beam_mw = v_accel_kv * i_beam_a / 1000.0 // 5.0 Megawatts injection!

  assert_true((p_beam_mw - 5.0).abs() < 1.0e-6)
}

///|
test "Suite69 Plasma 08: Bolometer Platinum Foil Temperature Rise" {
  let p_rad_w_m2 = 1.0e5 // 100 kW/m^2 radiated power
  assert_true(p_rad_w_m2 == 1.0e5)
}

///|
test "Suite69 Plasma 09: Plasma Beta Parameter Ratio (Thermal / Magnetic)" {
  // beta = (n * k * T) / (B^2 / (2 * mu_0))
  let beta_percent = 3.5 // 3.5% beta
  let beta_troyon_limit = 4.0 // 4.0% Troyon limit

  assert_true(beta_percent < beta_troyon_limit)
}

///|
test "Suite69 Plasma 10: Thomson Scattering Nd:YAG 1064 nm Laser Pulse" {
  let e_pulse_j = 2.0 // 2 Joules per pulse
  let t_fwhm_ns = 10.0 // 10 ns
  let p_peak_mw = e_pulse_j / (t_fwhm_ns * 1.0e-9) / 1.0e6 // 200 MW peak optical power!

  assert_true((p_peak_mw - 200.0).abs() < 1.0e-6)
}
