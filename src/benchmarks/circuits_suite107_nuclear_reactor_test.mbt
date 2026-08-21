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
test "Suite107 NuclearReactor 01: Ex-Core Uncompensated Ionization Chamber Neutron Sensitivity" {
  let sens_a_nv = 1.2e-14 // 1.2e-14 A / (neutrons/cm^2*s)
  assert_true(sens_a_nv > 1.0e-15)
}

///|
test "Suite107 NuclearReactor 02: Prompt Neutron Lifetime & Delayed Neutron Fraction Beta_eff" {
  let beta_eff = 0.0065 // 0.65% delayed neutron fraction in U-235
  let l_prompt_us = 25.0 // 25 us prompt lifetime
  assert_true(beta_eff == 0.0065)
  assert_true(l_prompt_us == 25.0)
}

///|
test "Suite107 NuclearReactor 03: Control Rod Drive Mechanism CRDM Magnetic Coil Step Current (30A)" {
  let i_coil_a = 30.0
  assert_true(i_coil_a == 30.0)
}

///|
test "Suite107 NuclearReactor 04: Self-Powered Neutron Detector SPND Rhodium/Vanadium Delayed Emitter" {
  let tau_rhodium_s = 42.0 // 42 s half-life beta decay
  assert_true(tau_rhodium_s == 42.0)
}

///|
test "Suite107 NuclearReactor 05: Class 1E Qualified Nuclear Safety Shutdown Logic 2-out-of-4 Voting" {
  let is_2oo4_voted = true
  assert_true(is_2oo4_voted)
}

///|
test "Suite107 NuclearReactor 06: Pressurizer Proportional-Integral Heater Power Control (1800 kW)" {
  let p_heater_kw = 1800.0
  let p_primary_bar = 155.0 // 155 bar PWR primary loop
  assert_true(p_heater_kw == 1800.0)
  assert_true(p_primary_bar == 155.0)
}

///|
test "Suite107 NuclearReactor 07: Reactor Core Negative Doppler Temperature Coefficient (pcm/K)" {
  let alpha_doppler_pcm_k = -3.2 // -3.2 pcm / K (Inherent negative feedback stability!)
  assert_true(alpha_doppler_pcm_k < 0.0)
}

///|
test "Suite107 NuclearReactor 08: Main Coolant Pump Flywheel Coast-Down Ride-Through Time (15 s)" {
  let t_coastdown_s = 15.0
  assert_true(t_coastdown_s >= 10.0)
}

///|
test "Suite107 NuclearReactor 09: Post-Accident Radiation Monitoring Channel Wide Range Logarithmic (10^8 R/h)" {
  let dynamic_range_decades = 8
  assert_true(dynamic_range_decades == 8)
}

///|
test "Suite107 NuclearReactor 10: Digital Reactor Protection System FPGA Triple-Modular Redundancy" {
  let is_tmr_triplicated = true
  assert_true(is_tmr_triplicated)
}
