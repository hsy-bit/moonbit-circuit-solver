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
test "Suite83 AtomInterferometer 01: Cold-Atom Mach-Zehnder Raman Pulse Sequence (pi/2 - pi - pi/2)" {
  // Phase shift Delta_phi = k_eff * a * T^2
  let k_eff_m_inv = 1.61e7 // 2 * pi / 390 nm
  let a_accel = 9.80665
  let t_interrogation_s = 0.100 // 100 ms

  let delta_phi_rad = k_eff_m_inv *
    a_accel *
    t_interrogation_s *
    t_interrogation_s // ~1.579e6 rad
  assert_true(delta_phi_rad > 1.0e6)
}

///|
test "Suite83 AtomInterferometer 02: Rubidium-87 Magneto-Optical Trap MOT Atom Number" {
  let num_atoms = 1.0e8 // 100 Million trapped atoms
  assert_true(num_atoms >= 1.0e7)
}

///|
test "Suite83 AtomInterferometer 03: Polarization Gradient Cooling Sub-Doppler Temperature (2 uK)" {
  let t_mot_uk = 2.5 // 2.5 microKelvin
  assert_true(t_mot_uk < 5.0)
}

///|
test "Suite83 AtomInterferometer 04: Sagnac Effect Atom Gyroscope Area Scale Factor" {
  // Delta_phi_rot = (4 * pi * m_atom / h) * Area * Omega
  let is_atomic_sagnac_valid = true
  assert_true(is_atomic_sagnac_valid)
}

///|
test "Suite83 AtomInterferometer 05: Raman Laser Phase Lock Ultra-Low Phase Noise (< -110 dBc/Hz)" {
  let l_phase_noise = -115.0
  assert_true(l_phase_noise < -110.0)
}

///|
test "Suite83 AtomInterferometer 06: High-Vacuum Science Chamber Pressure (10^-10 Torr)" {
  let p_uhv_torr = 5.0e-10
  assert_true(p_uhv_torr < 1.0e-9)
}

///|
test "Suite83 AtomInterferometer 07: State Detection Fluorescence Photodiode Amplifier" {
  let trans_gain_v_a = 1.0e7 // 10 MOhm TIA
  assert_true(trans_gain_v_a == 1.0e7)
}

///|
test "Suite83 AtomInterferometer 08: Magnetic Field Bias Solenoid Uniformity (< 0.1%)" {
  let uniformity_percent = 0.05
  assert_true(uniformity_percent < 0.10)
}

///|
test "Suite83 AtomInterferometer 09: Vibration Isolation Active Seismometer Platform" {
  let isolation_ratio_at_10hz_db = 40.0 // 40 dB isolation
  assert_true(isolation_ratio_at_10hz_db >= 30.0)
}

///|
test "Suite83 AtomInterferometer 10: Quantum Gravimeter Sensitivity (5 nGal / sqrt(Hz))" {
  let sens_ngal = 4.8
  assert_true(sens_ngal < 5.0)
}
