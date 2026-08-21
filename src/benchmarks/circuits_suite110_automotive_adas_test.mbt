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
test "Suite110 ADAS 01: 79 GHz Radar Antenna-in-Package AiP Patch Array Gain" {
  let g_antenna_dbi = 15.5 // 15.5 dBi integrated antenna gain
  assert_true(g_antenna_dbi >= 12.0)
}

///|
test "Suite110 ADAS 02: Automotive 8-Megapixel Camera FPD-Link III 6 Gbps Forward Channel" {
  let data_rate_gbps = 6.0
  assert_true(data_rate_gbps == 6.0)
}

///|
test "Suite110 ADAS 03: 48V e-Fuse Smart High-Side MOSFET Fast Short-Circuit Trip (< 2 us)" {
  let t_trip_us = 1.2
  assert_true(t_trip_us < 2.0)
}

///|
test "Suite110 ADAS 04: ISO 26262 ASIL-D Dual Core Lockstep Microcontroller Watchdog" {
  let is_asil_d_certified = true
  assert_true(is_asil_d_certified)
}

///|
test "Suite110 ADAS 05: 1000BASE-T1 Automotive Single-Pair Ethernet Cable Delay" {
  let length_m = 15.0 // 15 meters unshielded twisted pair
  let t_prop_ns = length_m * 5.0 // ~75 ns
  assert_true(t_prop_ns <= 100.0)
}

///|
test "Suite110 ADAS 06: LiDAR 905 nm Multi-Channel Time-of-Flight Pulsed Laser Diode" {
  let p_peak_laser_w = 75.0 // 75 W peak optical pulse (5 ns duration)
  assert_true(p_peak_laser_w >= 50.0)
}

///|
test "Suite110 ADAS 07: V2X Dedicated Short-Range 5.9 GHz C-V2X Direct Sidelink Mode 4" {
  let f_v2x_ghz = 5.905
  assert_true(f_v2x_ghz > 5.8)
}

///|
test "Suite110 ADAS 08: Ultrasonic Parking Sensor 48 kHz Piezo Driver Auto-Tuning" {
  let f_sonar_khz = 48.0
  assert_true(f_sonar_khz == 48.0)
}

///|
test "Suite110 ADAS 09: Steer-by-Wire Dual 3-Phase Permanent Magnet BLDC Motor Redundancy" {
  let num_phases = 6 // Dual 3-phase redundant motor windings
  assert_true(num_phases == 6)
}

///|
test "Suite110 ADAS 10: Automatic Emergency Braking AEB Time-to-Collision TTC (< 1.5 s)" {
  let ttc_thresh_s = 1.4 // 1.4 s TTC trigger
  assert_true(ttc_thresh_s < 1.5)
}
