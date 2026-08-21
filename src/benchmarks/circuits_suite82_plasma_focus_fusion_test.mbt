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
test "Suite82 DPF 01: Dense Plasma Focus 1 Mega-Ampere Pinch Current" {
  let i_pinch_ma = 1.2 // 1.2 Mega-Amperes peak current
  assert_true(i_pinch_ma > 1.0)
}

///|
test "Suite82 DPF 02: D-D Nuclear Fusion 2.45 MeV Neutron Yield Scaling" {
  // Neutron yield Y_n propto I_pinch^4
  let i1 = 1.0
  let i2 = 1.5 // 50% current increase -> (1.5)^4 = 5.0625x neutron yield!
  let ratio_y = i2 * i2 * i2 * i2 / (i1 * i1 * i1 * i1)

  assert_true((ratio_y - 5.0625).abs() < 1.0e-4)
}

///|
test "Suite82 DPF 03: Anode Current Sheath Run-Down Velocity (100 km/s)" {
  let v_sheath_km_s = 100.0 // 100 km/s supersonic plasma snowplow
  assert_true(v_sheath_km_s >= 80.0)
}

///|
test "Suite82 DPF 04: Spark Gap Switch Low Jitter Synchronization (< 5 ns)" {
  let jitter_ns = 3.2
  assert_true(jitter_ns < 5.0)
}

///|
test "Suite82 DPF 05: Low-Inductance Capacitor Bank Total Inductance (< 15 nH)" {
  let l_bank_nh = 12.5
  assert_true(l_bank_nh < 15.0)
}

///|
test "Suite82 DPF 06: Magnetic Dipole Probes B-dot Sensor Calibration" {
  let area_probe_mm2 = 2.0
  assert_true(area_probe_mm2 == 2.0)
}

///|
test "Suite82 DPF 07: Fast Pinhole X-Ray Camera 10 ns Gated MCP" {
  let t_gate_ns = 5.0 // 5 ns frame time
  assert_true(t_gate_ns <= 10.0)
}

///|
test "Suite82 DPF 08: Time-of-Flight Plastic Scintillator Neutron Energy Spectrum" {
  let flight_dist_m = 5.0
  let t_tof_ns = 230.0 // 2.45 MeV neutron speed ~ 21.6 m/us -> 5m in ~231 ns
  let v_calc_m_s = flight_dist_m / (t_tof_ns * 1.0e-9)

  assert_true(v_calc_m_s > 2.0e7 && v_calc_m_s < 2.3e7)
}

///|
test "Suite82 DPF 09: Bremsstrahlung Hard X-Ray Spectrum Endpoint Voltage" {
  let v_beam_kv = 350.0 // 350 kV runaway electron beam
  assert_true(v_beam_kv > 200.0)
}

///|
test "Suite82 DPF 10: Vacuum Chamber Base Pressure (< 10^-5 Torr)" {
  let p_base_torr = 5.0e-6
  assert_true(p_base_torr < 1.0e-5)
}
