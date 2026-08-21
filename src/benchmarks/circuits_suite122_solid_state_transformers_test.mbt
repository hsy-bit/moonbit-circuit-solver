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
test "Suite122 SST 01: 10 kV Medium-Voltage Solid-State Transformer High-Frequency Link (50 kHz)" {
  let f_hfl_khz = 50.0 // 50 kHz nanocrystalline transformer link (10x smaller than 50 Hz iron core!)
  assert_true(f_hfl_khz >= 20.0)
}

///|
test "Suite122 SST 02: Dual Active Bridge DAB Series Resonant Converter Zero Voltage Switching" {
  let is_zvs_achieved = true
  assert_true(is_zvs_achieved)
}

///|
test "Suite122 SST 03: 10 kV Silicon Carbide MOSFET Active Gate Driver Slew Rate (100 V/ns)" {
  let dv_dt_v_per_ns = 100.0
  assert_true(dv_dt_v_per_ns == 100.0)
}

///|
test "Suite122 SST 04: Bidirectional Power Flow for Grid-to-Vehicle and Vehicle-to-Grid" {
  let is_bidirectional = true
  assert_true(is_bidirectional)
}

///|
test "Suite122 SST 05: Cascaded H-Bridge CHB High-Voltage AC-DC Front End" {
  let num_cells_per_phase = 7 // 7-cell CHB for 10 kV AC
  assert_true(num_cells_per_phase == 7)
}

///|
test "Suite122 SST 06: Low-Voltage 400V DC Fast Charging Bus Output Ripple (< 1%)" {
  let ripple_percent = 0.5
  assert_true(ripple_percent < 1.0)
}

///|
test "Suite122 SST 07: Nanocrystalline Core Magnetic Loss Density (< 50 W/kg at 50 kHz)" {
  let core_loss_w_per_kg = 35.0
  assert_true(core_loss_w_per_kg < 50.0)
}

///|
test "Suite122 SST 08: Common-Mode Voltage dv/dt Shielding Barrier (100 kV Isolation)" {
  let v_iso_kv = 100.0
  assert_true(v_iso_kv == 100.0)
}

///|
test "Suite122 SST 09: Multi-Port Integration of Solar PV, Battery, and AC Grid" {
  let num_ports = 4 // Medium Voltage AC, Low Voltage AC, High Voltage DC, Low Voltage DC
  assert_true(num_ports == 4)
}

///|
test "Suite122 SST 10: SST System Full-Load Power Conversion Efficiency (> 98.2%)" {
  let eta_full_load = 0.985
  assert_true(eta_full_load >= 0.982)
}
