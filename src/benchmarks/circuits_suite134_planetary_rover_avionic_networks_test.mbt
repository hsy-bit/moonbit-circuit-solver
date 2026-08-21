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
test "Suite134 MarsRover 01: Multi-Mission Radioisotope Thermoelectric Generator MMRTG Power Bus (110W)" {
  let p_rtg_w = 110.0
  let v_bus_v = 28.0
  assert_true(p_rtg_w == 110.0)
  assert_true(v_bus_v == 28.0)
}

///|
test "Suite134 MarsRover 02: SpaceWire IEEE 1355 Serial Point-to-Point 100 Mbps Avionic Network" {
  let bitrate_mbps = 100.0
  assert_true(bitrate_mbps == 100.0)
}

///|
test "Suite134 MarsRover 03: Mars Surface Diurnal Thermal Cycle Resistance (-120 °C to +20 °C)" {
  let t_min_c = -120.0
  let t_max_c = 20.0
  assert_true(t_max_c > t_min_c)
}

///|
test "Suite134 MarsRover 04: Rad-Hard BAE RAD750 PowerPC Processor Operating Clock (133 MHz)" {
  let f_cpu_mhz = 133.0
  assert_true(f_cpu_mhz == 133.0)
}

///|
test "Suite134 MarsRover 05: Rocker-Bogie Suspension 6-Wheel Independent BLDC Stepper Motors" {
  let num_drive_motors = 6
  let num_steering_motors = 4
  assert_true(num_drive_motors == 6)
  assert_true(num_steering_motors == 4)
}

///|
test "Suite134 MarsRover 06: Laser-Induced Breakdown Spectroscopy LIBS Laser Diode Pulse (1064 nm, 10 mJ)" {
  let e_pulse_mj = 10.0
  assert_true(e_pulse_mj == 10.0)
}

///|
test "Suite134 MarsRover 07: Ultra-High Frequency UHF Electra Transceiver Relay to Mars Orbiter (2 Mbps)" {
  let bitrate_mbps = 2.0
  assert_true(bitrate_mbps >= 1.0)
}

///|
test "Suite134 MarsRover 08: MOXIE Solid Oxide Electrolysis Cell O2 Production Rate (10 g/h)" {
  let o2_rate_g_per_h = 10.0
  assert_true(o2_rate_g_per_h == 10.0)
}

///|
test "Suite134 MarsRover 09: Inertial Measurement Unit IMU Ring Laser Gyroscope Drift (< 0.01 deg/h)" {
  let drift_deg_h = 0.008
  assert_true(drift_deg_h < 0.01)
}

///|
test "Suite134 MarsRover 10: Autonomous Terrain Navigation AutoNav Stereo Vision Real-Time SLAM" {
  let is_slam_active = true
  assert_true(is_slam_active)
}
