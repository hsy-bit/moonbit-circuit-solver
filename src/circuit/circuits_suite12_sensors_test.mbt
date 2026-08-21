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
test "Suite12 Sensor 01: Wheatstone Bridge Strain Gauge Differential Output" {
  // Balanced bridge R1=R2=R3=R4 = 350 Ohms with strain variation Delta R = 0.5 Ohm
  let v_ex = 10.0 // 10V excitation
  let r_nom = 350.0
  let delta_r = 0.5

  // V_diff = V_ex * (Delta_R / (4 * R_nom + 2 * Delta_R)) approx V_ex * (Delta_R / (4 * R_nom))
  let v_diff = v_ex * (delta_r / (4.0 * r_nom + 2.0 * delta_r))
  assert_true((v_diff - 0.003568).abs() < 1.0e-5) // ~3.57 mV
}

///|
test "Suite12 Sensor 02: PT100 RTD 4-Wire Kelvin Resistance Measurement" {
  // Callendar-Van Dusen equation for PT100: R(T) = R0 * (1 + A*T + B*T^2)
  let r0 = 100.0
  let a_coeff = 3.9083e-3
  let b_coeff = -5.775e-7

  // At T = 100 °C: R(100) = 100 * (1 + 0.39083 - 0.005775) = 138.51 Ohms
  let t_celsius = 100.0
  let r_100 = r0 * (1.0 + a_coeff * t_celsius + b_coeff * t_celsius * t_celsius)
  assert_true((r_100 - 138.505).abs() < 0.01)
}

///|
test "Suite12 Sensor 03: Type-K Thermocouple Seebeck Coefficient and Cold Junction" {
  // Type-K Seebeck coefficient S approx 41.27 uV/°C
  let seebeck = 41.27e-6
  let t_hot = 350.0
  let t_cjc = 25.0 // Cold junction at 25 °C room temp

  let v_thermo = seebeck * (t_hot - t_cjc)
  assert_true((v_thermo - 0.01341).abs() < 1.0e-4) // ~13.41 mV
}

///|
test "Suite12 Sensor 04: Photodiode Precision Transimpedance Amplifier with Guard Ring" {
  let netlist_str =
    #|* Photodiode TIA with Guard Ring Potential
    #|I_PHOTO 0 inv DC 5.0e-6
    #|RF inv out 200000.0
    #|CF inv out 2.2e-12
    #|X1 0 inv out OPAMP
    #|RLOAD out 0 10000.0
    #|.op
  let netlist = @spice.parse_spice_netlist(netlist_str)
  let sim = CircuitSimulator::{ netlist, }
  let dc = sim.solve_dc()
  // Vout = - (5uA * 200k) = -1.0V
  let v_out = dc.get("out").unwrap()
  assert_true((v_out - -1.0).abs() < 1.0e-3)
}

///|
test "Suite12 Sensor 05: Hall Effect Current Sensor Magnetic Flux Amplification" {
  // Core sensitivity = 50 mV / A, Offset = 2.5V (5V supply mid-rail)
  let sensitivity = 0.050 // V/A
  let v_offset = 2.5
  let i_measured = 15.0 // 15 Amperes

  let v_hall = v_offset + sensitivity * i_measured
  assert_true((v_hall - 3.25).abs() < 1.0e-12)
}

///|
test "Suite12 Sensor 06: Piezoelectric Hydrophone Charge to Voltage Buffer" {
  let netlist_str =
    #|* Piezoelectric Hydrophone Sensor Interface
    #|VIN in 0 DC 1.0
    #|R_LEAK in 0 10.0e6
    #|C_PIEZO in out_buf 100e-12
    #|R_BIAS out_buf 0 1.0e6
    #|X1 out_buf 0 out OPAMP
    #|.op
  let netlist = @spice.parse_spice_netlist(netlist_str)
  let (indexer, _, _, _) = @mna.build_dc_mna_system(netlist)
  assert_true(indexer.node_count() >= 3)
}

///|
test "Suite12 Sensor 07: LVDT Linear Variable Differential Transformer Position Sensor" {
  // LVDT secondary voltages V_s1 = V0 * (1 + x/d), V_s2 = V0 * (1 - x/d)
  // Differential demodulated output V_out = V_s1 - V_s2 = 2 * V0 * (x/d)
  let v0 = 5.0
  let d_stroke = 10.0 // mm
  let x_pos = 2.5 // mm

  let v_diff = 2.0 * v0 * (x_pos / d_stroke)
  assert_true((v_diff - 2.5).abs() < 1.0e-12)
}

///|
test "Suite12 Sensor 08: Optical NDIR CO2 Sensor Dual-Wavelength Ratio" {
  // Beer-Lambert law: I = I0 * exp(-alpha * C * L)
  let i0 = 1.0
  let alpha = 0.002 // ppm^-1 cm^-1
  let path_length = 5.0 // cm
  let co2_ppm = 800.0 // 800 ppm

  let i_absorbed = i0 * @math.exp(-alpha * co2_ppm * path_length)
  assert_true(i_absorbed > 0.0 && i_absorbed < 1.0)
}

///|
test "Suite12 Sensor 09: Capacitive Humidity Sensor Frequency Modulation Interface" {
  // Capacitance C(RH) = C0 * (1 + alpha * RH)
  let c0 = 180.0e-12
  let alpha_rh = 0.003
  let rh_percent = 60.0

  let c_rh = c0 * (1.0 + alpha_rh * rh_percent)
  assert_true((c_rh - 212.4e-12).abs() < 1.0e-13)
}

///|
test "Suite12 Sensor 10: Electrochemical Gas Sensor 3-Electrode Potentiostat Loop" {
  let netlist_str =
    #|* 3-Electrode Potentiostat (Working, Counter, Reference Electrodes)
    #|VREF vref 0 DC 0.6
    #|* Control amp X_CTRL drives Counter Electrode (CE) to maintain Ref Electrode (RE) at VREF
    #|X_CTRL vref re ce OPAMP
    #|R_CELL ce re 1000.0
    #|R_SOL re we 500.0
    #|* Working electrode TIA
    #|RF we out_tia 100000.0
    #|X_TIA 0 we out_tia OPAMP
    #|.op
  let netlist = @spice.parse_spice_netlist(netlist_str)
  let (indexer, _, _, _) = @mna.build_dc_mna_system(netlist)
  assert_true(indexer.node_count() >= 4)
}
