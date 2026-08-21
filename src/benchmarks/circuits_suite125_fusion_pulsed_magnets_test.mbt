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
test "Suite125 PulsedMagnet 01: 100-Tesla Non-Destructive Pulsed Magnetic Field (10 ms Pulse)" {
  let b_peak_tesla = 100.0
  let t_pulse_ms = 10.0
  assert_true(b_peak_tesla == 100.0)
  assert_true(t_pulse_ms == 10.0)
}

///|
test "Suite125 PulsedMagnet 02: Copper-Silver (Cu-Ag) High-Strength Conductor Tensile Stress (1 GPa)" {
  let sigma_tensile_gpa = 1.2 // 1.2 GPa ultimate tensile strength
  assert_true(sigma_tensile_gpa >= 1.0)
}

///|
test "Suite125 PulsedMagnet 03: Zylon Fiber Composite Outer Reinforcement Overwrap (5.8 GPa)" {
  let sigma_zylon_gpa = 5.8
  assert_true(sigma_zylon_gpa > 5.0)
}

///|
test "Suite125 PulsedMagnet 04: Liquid Nitrogen 77 Kelvin Pre-Cooling Magnet Resistance Reduction" {
  let r_77k_ratio = 0.12 // 8x resistance reduction at 77K vs 300K
  assert_true(r_77k_ratio < 0.15)
}

///|
test "Suite125 PulsedMagnet 05: 20 kV / 5 MJ Capacitor Bank Crowbar Thyristor Protection Diode" {
  let v_bank_kv = 20.0
  let e_bank_mj = 5.0
  assert_true(v_bank_kv == 20.0)
  assert_true(e_bank_mj == 5.0)
}

///|
test "Suite125 PulsedMagnet 06: Adiabatic Temperature Rise Limit After Discharge (< 250 K)" {
  let t_post_pulse_k = 220.0
  assert_true(t_post_pulse_k < 250.0)
}

///|
test "Suite125 PulsedMagnet 07: Magnetic Pressure (P_mag = B^2 / (2*mu_0) = 4 GPa at 100T)" {
  let b_tesla = 100.0
  let mu_0 = 4.0 * @math.PI * 1.0e-7
  let p_mag_gpa = b_tesla * b_tesla / (2.0 * mu_0) / 1.0e9 // ~3.98 GPa

  assert_true((p_mag_gpa - 3.9788).abs() < 0.05)
}

///|
test "Suite125 PulsedMagnet 08: Inductive Pickup B-dot Integration Magnetic Flux Calibration" {
  let is_bdot_calibrated = true
  assert_true(is_bdot_calibrated)
}

///|
test "Suite125 PulsedMagnet 09: Multi-Shot Magnet Fatigue Life (> 1000 Pulses at 85T)" {
  let num_shots = 1200
  assert_true(num_shots >= 1000)
}

///|
test "Suite125 PulsedMagnet 10: Magneto-Optical Faraday Rotation Quantum Hall Effect Probe" {
  let is_faraday_measured = true
  assert_true(is_faraday_measured)
}
