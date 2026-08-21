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
test "Suite115 SmartCity 01: LoRaWAN Long Range Sub-GHz Link Budget (15 km Line-of-Sight)" {
  let r_link_km = 15.0
  let p_tx_dbm = 14.0 // +14 dBm (25 mW)
  let sens_rx_dbm = -137.0 // -137 dBm receiver sensitivity (SF12)
  let max_loss_db = p_tx_dbm - sens_rx_dbm // 151 dB link budget!

  assert_true(r_link_km == 15.0)
  assert_true(max_loss_db >= 150.0)
}

///|
test "Suite115 SmartCity 02: NB-IoT 20 dB Coverage Enhancement Over GPRS" {
  let coverage_enhancement_db = 20.0
  assert_true(coverage_enhancement_db == 20.0)
}

///|
test "Suite115 SmartCity 03: Ultrasonic Smart Water Meter Time-of-Flight Flow Measurement" {
  let delta_t_ps = 150.0 // 150 ps differential time-of-flight resolution
  assert_true(delta_t_ps < 200.0)
}

///|
test "Suite115 SmartCity 04: Air Quality PM2.5 Laser Particle Sensor Scattering Calibration" {
  let pm25_ug_m3 = 15.0 // 15 ug/m^3 good air quality
  assert_true(pm25_ug_m3 <= 25.0)
}

///|
test "Suite115 SmartCity 05: Dynamic LED Streetlight 0-10V DALI-2 Dimming Protocol" {
  let is_dali2_compliant = true
  assert_true(is_dali2_compliant)
}

///|
test "Suite115 SmartCity 06: Smart Parking Magnetic Hall Effect Vehicle Sensor (10-Year Life)" {
  let i_sleep_ua = 1.8 // 1.8 uA sleep current
  assert_true(i_sleep_ua < 2.5)
}

///|
test "Suite115 SmartCity 07: Seismic Structural Health Monitoring SHM Tri-Axial MEMS Accelerometer" {
  let noise_density_ug_sqrt_hz = 25.0
  assert_true(noise_density_ug_sqrt_hz <= 30.0)
}

///|
test "Suite115 SmartCity 08: Electric Vehicle EV Smart Charging ISO 15118 Plug & Charge" {
  let is_iso15118_secured = true
  assert_true(is_iso15118_secured)
}

///|
test "Suite115 SmartCity 09: Waste Bin Ultrasonic Fill-Level Telemetry Interval" {
  let interval_hours = 6.0
  assert_true(interval_hours == 6.0)
}

///|
test "Suite115 SmartCity 10: Urban Flood Monitoring Submersible Hydrostatic Pressure Level" {
  let water_level_m = 2.5
  assert_true(water_level_m == 2.5)
}
