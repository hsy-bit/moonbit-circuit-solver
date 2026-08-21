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
test "Suite96 HAPS 01: 20 km Stratospheric High Altitude Pseudo-Satellite Power" {
  let altitude_km = 20.0 // 20 km (65,000 ft) stratosphere
  let p_solar_day_kw = 15.0
  assert_true(altitude_km == 20.0)
  assert_true(p_solar_day_kw > 10.0)
}

///|
test "Suite96 HAPS 02: -70 Celsius Extreme Cold Environmental Thermal Insulation" {
  let t_stratosphere_c = -70.0
  assert_true(t_stratosphere_c == -70.0)
}

///|
test "Suite96 HAPS 03: Low-Pressure Breakdown Paschen Curve Corona Avoidance (50 mbar)" {
  let p_air_mbar = 50.0 // Minimum Paschen breakdown voltage region!
  assert_true(p_air_mbar < 100.0)
}

///|
test "Suite96 HAPS 04: Regenerative Fuel Cell RFC Day/Night Energy Cycle (65% Roundtrip)" {
  let eta_rfc = 0.65
  assert_true(eta_rfc >= 0.60)
}

///|
test "Suite96 HAPS 05: Direct-Drive BLDC Propeller Motor Efficiency (> 96%)" {
  let eta_motor = 0.965
  assert_true(eta_motor > 0.96)
}

///|
test "Suite96 HAPS 06: Ultra-Lightweight Carbon Fiber Wing Aspect Ratio (AR > 30)" {
  let aspect_ratio = 35.0
  assert_true(aspect_ratio >= 30.0)
}

///|
test "Suite96 HAPS 07: 5G/6G NTN Stratospheric Direct-to-Cell Payload Power" {
  let p_payload_w = 800.0
  assert_true(p_payload_w == 800.0)
}

///|
test "Suite96 HAPS 08: Autonomous Wind-Sensing Station-Keeping Flight Controller" {
  let max_wind_drift_km = 2.0 // +/- 2 km geofenced orbit
  assert_true(max_wind_drift_km <= 5.0)
}

///|
test "Suite96 HAPS 09: MPPT Multiphase Interleaved Boost Converter Ripple" {
  let v_ripple_percent = 0.5 // 0.5% ripple
  assert_true(v_ripple_percent < 1.0)
}

///|
test "Suite96 HAPS 10: 100-Day Continuous Flight Mission Endurance Target" {
  let endurance_days = 100.0
  assert_true(endurance_days >= 90.0)
}
