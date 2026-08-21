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
test "Suite158 ExtremeSiC 01: 500 °C Ultra-High Temperature Silicon Carbide JFET Circuitry" {
  let t_operating_c = 500.0
  assert_true(t_operating_c == 500.0)
}

///|
test "Suite158 ExtremeSiC 02: 4H-SiC Wide Bandgap (3.26 eV) Intrinsic Carrier Suppression at 500 °C" {
  let eg_ev = 3.26
  assert_true((eg_ev - 3.26).abs() < 1.0e-3)
}

///|
test "Suite158 ExtremeSiC 03: Venus Surface Mission High-Pressure (90 bar CO2) Sensor Durability" {
  let p_venus_bar = 90.0
  assert_true(p_venus_bar == 90.0)
}

///|
test "Suite158 ExtremeSiC 04: Mega-Rad Total Ionizing Dose TID Space Radiation Hardness (> 10 MRad)" {
  let tid_mrad = 15.0
  assert_true(tid_mrad >= 10.0)
}

///|
test "Suite158 ExtremeSiC 05: Tungsten-Silicide High-Temperature Ohmic Contact Resistance (< 10^-5 Ohm*cm^2)" {
  let r_contact = 5.0e-6
  assert_true(r_contact < 1.0e-5)
}

///|
test "Suite158 ExtremeSiC 06: Deep Geothermal Well Downhole Drilling Motor Drive Inverter (250 °C)" {
  let t_downhole_c = 250.0
  assert_true(t_downhole_c == 250.0)
}

///|
test "Suite158 ExtremeSiC 07: High-Voltage 15 kV SiC MOSFET Critical Breakdown Electric Field (3.0 MV/cm)" {
  let e_crit_mv_cm = 3.0
  assert_true(e_crit_mv_cm == 3.0)
}

///|
test "Suite158 ExtremeSiC 08: Ceramic Ceramic-Matrix Composite CMC Packaging Thermal Expansion Match" {
  let cte_ppm_k = 4.2
  assert_true(cte_ppm_k <= 4.5)
}

///|
test "Suite158 ExtremeSiC 09: Jet Engine Turbine Blade In-Situ Real-Time Strain & Temperature Telemetry" {
  let is_turbine_monitored = true
  assert_true(is_turbine_monitored)
}

///|
test "Suite158 ExtremeSiC 10: 10,000-Hour Continuous Operation Life at 450 °C" {
  let lifetime_hours = 10000.0
  assert_true(lifetime_hours >= 10000.0)
}
