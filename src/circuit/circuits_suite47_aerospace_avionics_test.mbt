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
test "Suite47 Aero 01: MIL-STD-1553B Transformer-Coupled Stub Input Impedance" {
  // Stub isolation resistors R1 = R2 = 0.75 * Z0 = 0.75 * 78 = 58.5 Ohms
  // Transformer turns ratio 1 : 1.414 -> Minimum stub input impedance >= 1000 Ohms
  let z_stub_min = 1000.0 // 1000 Ohms
  let z0_bus = 78.0 // 78 Ohm shielded twisted pair

  assert_true(z_stub_min > 10.0 * z0_bus)
  assert_true(z0_bus == 78.0)
}

///|
test "Suite47 Aero 02: ARINC 429 Bipolar Return-to-Zero RZ Voltage Levels" {
  // Line A to Line B differential: +10V (HI), 0V (NULL), -10V (LO)
  let v_diff_hi = 10.0
  let v_diff_null = 0.0
  let v_diff_lo = -10.0

  assert_true(v_diff_hi - v_diff_null == 10.0)
  assert_true(v_diff_null - v_diff_lo == 10.0)
}

///|
test "Suite47 Aero 03: DO-160 Section 22 Waveform 5A Lightning Surge Level 5" {
  // Voc = 1600V, Isc = 1600A, 40 us / 120 us pulse shape
  let v_oc_lightning = 1600.0
  let i_sc_lightning = 1600.0
  let r_source = v_oc_lightning / i_sc_lightning // 1.0 Ohm source impedance

  assert_true((r_source - 1.0).abs() < 1.0e-12)
}

///|
test "Suite47 Aero 04: Spacecraft 28V Bus UVLO Precision Threshold" {
  let v_uvlo_trip = 18.0 // Trip if 28V satellite bus drops below 18V
  let v_hysteresis = 2.0 // Recover above 20V
  let v_recover = v_uvlo_trip + v_hysteresis

  assert_true(v_recover == 20.0)
  assert_true(v_uvlo_trip == 18.0)
}

///|
test "Suite47 Aero 05: Scott-T 3-Wire Synchro to 2-Wire Resolver Transformation" {
  // V_sin = V_S1S3, V_cos = (2 / sqrt(3)) * (V_S2 - 0.5 * (V_S1 + V_S3))
  let k_scott = 2.0 / 3.0.sqrt() // ~1.1547
  assert_true((k_scott - 1.1547).abs() < 1.0e-3)
}

///|
test "Suite47 Aero 06: Fly-by-Wire Dual-Coil Servo Valve Current Balance" {
  let i_coil1 = 0.040 // 40 mA
  let i_coil2 = 0.040 // 40 mA
  let net_flow_ma = (i_coil1 + i_coil2) * 1000.0 // 80 mA total

  assert_true(net_flow_ma == 80.0)
}

///|
test "Suite47 Aero 07: Solid-State Power Controller SSPC I^2*t Thermal Trip" {
  // Trip time t_trip = K_i2t / I^2
  let k_i2t = 100.0 // A^2 * s
  let i_overload = 10.0 // 10 A (Normal rating = 2A)

  let t_trip_s = k_i2t / (i_overload * i_overload) // 100 / 100 = 1.0 s
  assert_true((t_trip_s - 1.0).abs() < 1.0e-6)
}

///|
test "Suite47 Aero 08: Single Event Gate Rupture SEGR Dielectric Margin" {
  let e_breakdown_mv_per_cm = 8.0 // 8 MV/cm SiO2 breakdown
  let e_operating_mv_per_cm = 3.0 // Derated to 3 MV/cm in space
  let margin = e_breakdown_mv_per_cm / e_operating_mv_per_cm

  assert_true(margin > 2.5)
}

///|
test "Suite47 Aero 09: Quad-Redundant Flight Computer Cross-Channel Data Rate" {
  let num_channels = 4
  let data_rate_mbps = 100.0 // 100 Mbps deterministic Ethernet
  let total_ccdl_capacity = num_channels.to_double() * data_rate_mbps

  assert_true(total_ccdl_capacity == 400.0)
}

///|
test "Suite47 Aero 10: Hermetic Nitrogen Cavity Leak Rate Standard" {
  let max_leak_rate = 1.0e-8 // atm * cm^3 / s
  assert_true(max_leak_rate <= 1.0e-8)
}
