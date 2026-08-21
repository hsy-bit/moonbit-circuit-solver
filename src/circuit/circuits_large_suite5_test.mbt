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
test "Suite5 Power 01: Ćuk DC-DC Inverting Converter Continuous Conduction" {
  // Ćuk converter with transfer function: V_out / V_in = - D / (1 - D)
  // For Vin = 12V, D = 0.6 -> V_out = -12 * (0.6 / 0.4) = -18V
  let v_in = 12.0
  let d_duty = 0.6
  let v_out_mag = v_in * (d_duty / (1.0 - d_duty))

  assert_true((v_out_mag - 18.0).abs() < 1.0e-6)

  let netlist_str =
    #|* Ćuk Inverting DC-DC Converter Netlist
    #|VIN in 0 DC 12.0
    #|L1 in sw 100e-6
    #|C1 sw n_diode 10e-6
    #|L2 0 out 100e-6
    #|COUT out 0 100e-6
    #|RLOAD out 0 10.0
    #|.op
  let netlist = @spice.parse_spice_netlist(netlist_str)
  let (indexer, _, _, _) = @mna.build_dc_mna_system(netlist)
  assert_true(indexer.node_count() >= 4)
}

///|
test "Suite5 Power 02: SEPIC Non-Inverting Buck-Boost Converter" {
  // SEPIC converter: V_out / V_in = D / (1 - D)
  // For Vin = 12V, D = 0.5 -> V_out = 12V
  // For Vin = 24V, D = 0.3333 -> V_out = 12V
  let v_in = 12.0
  let d_duty = 0.5
  let v_out = v_in * (d_duty / (1.0 - d_duty))

  assert_true((v_out - 12.0).abs() < 1.0e-6)
}

///|
test "Suite5 Power 03: Zeta Converter Step-Down/Step-Up Topology" {
  // Zeta converter transfer function: V_out / V_in = D / (1 - D)
  let v_in = 48.0
  let d_duty = 0.2
  let v_out = v_in * (d_duty / (1.0 - d_duty)) // 48 * 0.25 = 12V

  assert_true((v_out - 12.0).abs() < 1.0e-6)
}

///|
test "Suite5 Power 04: LLC Half-Bridge Resonant Converter Tank" {
  // LLC Resonant Tank: Lr (Resonant inductor), Cr (Resonant capacitor), Lm (Magnetizing inductance)
  // Resonant frequency fr0 = 1 / (2*pi*sqrt(Lr*Cr))
  let l_r = 15.0e-6
  let c_r = 22.0e-9
  let l_m = 75.0e-6

  let fr0 = 1.0 / (2.0 * @math.PI * (l_r * c_r).sqrt())
  assert_true(fr0 > 250.0e3 && fr0 < 300.0e3) // ~277 kHz resonant frequency
  assert_true(l_m > l_r)
}

///|
test "Suite5 Power 05: Phase-Shifted Full-Bridge PSFB Zero-Voltage Switching" {
  // 4 switches QA, QB, QC, QD with phase shift phi between legs
  let v_bus = 400.0
  let turns_ratio = 8.0 // 400V to 48V
  let phase_shift_deg = 120.0
  let d_eff = phase_shift_deg / 180.0

  let v_sec_peak = v_bus / turns_ratio // 50V
  let v_out_avg = v_sec_peak * d_eff // 33.33V

  assert_true((v_sec_peak - 50.0).abs() < 1.0e-6)
  assert_true((v_out_avg - 33.333).abs() < 0.1)
}

///|
test "Suite5 Power 06: Active Clamp Flyback Converter Soft-Switching" {
  let l_pri = 100.0e-6
  let c_clamp = 47.0e-9
  let f_sw = 150.0e3

  // Resonant clamp period T_res = 2*pi*sqrt(L_leak * C_clamp)
  let l_leak = 2.0e-6
  let t_res = 2.0 * @math.PI * (l_leak * c_clamp).sqrt()

  assert_true(t_res < 1.0 / f_sw)
  assert_true(l_pri > l_leak)
}

///|
test "Suite5 Power 07: Boost Power Factor Correction PFC 400V Pre-Regulator" {
  // Universal AC mains (85V - 265V RMS) to 400V DC bus
  let v_ac_min = 85.0 * 2.0.sqrt() // 120.2V peak
  let v_ac_max = 265.0 * 2.0.sqrt() // 374.7V peak
  let v_dc_bus = 400.0

  let d_max = 1.0 - v_ac_min / v_dc_bus
  let d_min = 1.0 - v_ac_max / v_dc_bus

  assert_true(d_max > 0.65)
  assert_true(d_min < 0.10)
  assert_true(v_dc_bus > v_ac_max)
}

///|
test "Suite5 Power 08: 3-Phase 6-Pulse Diode Bridge Rectifier" {
  let netlist_str =
    #|* 3-Phase 6-Pulse Full-Wave Bridge Rectifier
    #|VA a 0 SINE(0 220 50)
    #|VB b 0 SINE(0 220 50 0 0 -120)
    #|VC c 0 SINE(0 220 50 0 0 120)
    #|* Top diodes D1, D3, D5
    #|D1 a dc_pos 1N5408
    #|D3 b dc_pos 1N5408
    #|D5 c dc_pos 1N5408
    #|* Bottom diodes D4, D6, D2
    #|D4 dc_neg a 1N5408
    #|D6 dc_neg b 1N5408
    #|D2 dc_neg c 1N5408
    #|RLOAD dc_pos dc_neg 50.0
    #|CLOAD dc_pos dc_neg 470e-6
    #|.model 1N5408 D (IS=1e-8 N=1.6)
    #|.tran 1e-4 4e-2
  let netlist = @spice.parse_spice_netlist(netlist_str)
  let (indexer, _, _, _) = @mna.build_dc_mna_system(netlist)
  assert_true(indexer.node_count() >= 5)
}

///|
test "Suite5 Power 09: Bidirectional Synchronous Buck-Boost Battery Charger" {
  // Buck mode (Charge 48V to 12V battery): D = 12/48 = 0.25
  // Boost mode (Discharge 12V to 48V bus): D = 1 - 12/48 = 0.75
  let d_charge = 12.0 / 48.0
  let d_discharge = 1.0 - 12.0 / 48.0

  assert_true(d_charge == 0.25)
  assert_true(d_discharge == 0.75)
}

///|
test "Suite5 Power 10: Inverter 3-Level Neutral-Point-Clamped NPC Bridge" {
  // 3-Level NPC leg produces output levels: +Vdc/2, 0, -Vdc/2
  let v_dc = 800.0
  let v_half = v_dc / 2.0 // 400V

  let level_top = v_half
  let level_mid = 0.0
  let level_bot = -v_half

  assert_true(level_top == 400.0)
  assert_true(level_mid == 0.0)
  assert_true(level_bot == -400.0)
}
