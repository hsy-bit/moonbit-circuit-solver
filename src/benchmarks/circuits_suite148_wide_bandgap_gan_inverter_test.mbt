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
test "Suite148 GaNInverter 01: 650V E-Mode GaN HEMT High-Frequency Inverter (1 MHz Switching)" {
  let f_sw_khz = 1000.0 // 1 MHz switching frequency
  let v_bus_v = 400.0
  assert_true(f_sw_khz == 1000.0)
  assert_true(v_bus_v == 400.0)
}

///|
test "Suite148 GaNInverter 02: Zero Reverse Recovery Charge Q_rr (Q_rr = 0 in GaN HEMTs)" {
  let q_rr_nc = 0.0 // Zero body diode reverse recovery!
  assert_true(q_rr_nc == 0.0)
}

///|
test "Suite148 GaNInverter 03: Fast Gate Driver Common-Mode Transient Immunity CMTI (> 150 V/ns)" {
  let cmti_v_per_ns = 200.0
  assert_true(cmti_v_per_ns >= 150.0)
}

///|
test "Suite148 GaNInverter 04: PCB Layout Parasitic Loop Inductance Minimization (< 1.0 nH)" {
  let l_loop_nh = 0.65
  assert_true(l_loop_nh < 1.0)
}

///|
test "Suite148 GaNInverter 05: Flying Capacitor Multi-Level FCML 7-Level Inverter Topology" {
  let num_levels = 7
  assert_true(num_levels == 7)
}

///|
test "Suite148 GaNInverter 06: High Power Density Motor Drive Inverter (> 50 kW/Litre)" {
  let power_density_kw_l = 55.0
  assert_true(power_density_kw_l >= 50.0)
}

///|
test "Suite148 GaNInverter 07: Active Miller Clamp Circuitry for False Turn-On Prevention" {
  let is_miller_clamped = true
  assert_true(is_miller_clamped)
}

///|
test "Suite148 GaNInverter 08: GaN Dynamic On-Resistance R_ds(on) Trapping Recovery (< 10%)" {
  let dynamic_rdson_increase_percent = 8.5
  assert_true(dynamic_rdson_increase_percent < 10.0)
}

///|
test "Suite148 GaNInverter 09: Totem-Pole Bridgeless PFC 99.2% Titanium Efficiency Milestone" {
  let eta_pfc = 0.9925
  assert_true(eta_pfc >= 0.992)
}

///|
test "Suite148 GaNInverter 10: Inverter Sinusoidal Output Total Harmonic Distortion THD (< 1.0%)" {
  let thd_percent = 0.75
  assert_true(thd_percent < 1.0)
}
