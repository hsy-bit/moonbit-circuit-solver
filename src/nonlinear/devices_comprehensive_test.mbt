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
test "Gummel-Poon BJT model high-injection and Early effect" {
  let params = GummelPoonParams::default_npn()
  let comp = evaluate_gummel_poon(params, 0.65, 0.0, 0.026)

  assert_true(comp.ic > 0.0)
  assert_true(comp.ib > 0.0)
  assert_true(comp.ic > comp.ib) // Positive current gain beta > 1
  assert_true(comp.gm > 0.0)
  assert_true(comp.gpi > 0.0)
  assert_true(comp.go > 0.0) // Non-zero Early conductance
  assert_true(comp.gmu >= 0.0)
}

///|
test "BSIM / Level-3 MOSFET model subthreshold and velocity saturation" {
  let params = AdvancedMosfetParams::default_nmos()

  // 1. Cutoff / Subthreshold region (Vgs < Vth)
  let comp_sub = evaluate_advanced_mosfet(params, 0.2, 1.8, 0.0, 0.026)
  assert_true(comp_sub.ids > 0.0)
  assert_true(comp_sub.ids < 1.0e-6) // Extremely low subthreshold leakage
  assert_true(comp_sub.gm > 0.0)

  // 2. Strong Inversion Saturation region (Vgs = 1.8V, Vds = 1.8V)
  let comp_sat = evaluate_advanced_mosfet(params, 1.8, 1.8, 0.0, 0.026)
  assert_true(comp_sat.ids > 1.0e-4)
  assert_true(comp_sat.gm > comp_sub.gm)
  assert_true(comp_sat.gds > 0.0) // DIBL / channel length modulation
}

///|
test "JFET Shockley and Curtice quadratic model" {
  let params = JfetParams::default_njfet()

  // Cutoff when Vgs < Vto (e.g. Vgs = -3.0V < -2.0V)
  let comp_cut = evaluate_jfet(params, -3.0, 5.0, 0.026)
  assert_true(comp_cut.ids == 0.0)
  assert_true(comp_cut.gm == 0.0)

  // Saturation when Vgs = 0V, Vds = 5V
  let comp_sat = evaluate_jfet(params, 0.0, 5.0, 0.026)
  assert_true(comp_sat.ids > 1.0e-3)
  assert_true(comp_sat.gm > 0.0)
  assert_true(comp_sat.gds > 0.0)
}

///|
test "Zener diode avalanche breakdown and dynamic resistance" {
  let params = ZenerParams::default_5v1()

  // Forward bias (Vd = 0.7V)
  let comp_fwd = evaluate_zener_diode(params, 0.7, 0.026)
  assert_true(comp_fwd.id > 0.0)
  assert_true(comp_fwd.gd > 0.0)

  // Reverse breakdown (Vd = -5.5V < -5.1V)
  let comp_rev = evaluate_zener_diode(params, -5.5, 0.026)
  assert_true(comp_rev.id < -1.0e-3)
  assert_true(comp_rev.gd > 0.01) // Steep avalanche conductance
}

///|
test "Varactor voltage-dependent junction capacitance" {
  let params = VaractorParams::default_rf()

  // Zero-bias capacitance C0 = 20 pF
  let c_zero = evaluate_varactor_capacitance(params, 0.0)
  assert_true((c_zero - 20.0e-12).abs() < 1.0e-14)

  // Reverse bias (Vd = -4.0V) decreases capacitance
  let c_rev = evaluate_varactor_capacitance(params, -4.0)
  assert_true(c_rev < c_zero)
  assert_true(c_rev > 1.0e-12)
}

///|
test "Voltage-controlled switch smooth tanh transition" {
  let params = VcSwitchParams::default()

  // OFF state (Vctrl = 0.0V < Von)
  let comp_off = evaluate_vc_switch(params, 0.0, 5.0)
  assert_true(comp_off.g_switch < 1.0e-4)

  // ON state (Vctrl = 5.0V > Von)
  let comp_on = evaluate_vc_switch(params, 5.0, 5.0)
  assert_true(comp_on.g_switch > 0.1)

  // Mid-threshold smooth transition
  let comp_mid = evaluate_vc_switch(params, 2.5, 5.0)
  assert_true(
    comp_mid.g_switch > comp_off.g_switch &&
    comp_mid.g_switch < comp_on.g_switch,
  )
}

///|
test "Coupled Inductor Transformer companion model" {
  let params = CoupledTransformerParams::default_1to1()
  assert_true(params.mutual_inductance() > 0.0)

  let comp = evaluate_transformer_transient(params, 0.0, 0.0, 0.0, 0.0, 1.0e-6)
  assert_true(comp.g11 > 0.0)
  assert_true(comp.g22 > 0.0)
}

///|
test "Operational Amplifier macro-model non-idealities" {
  let params = OpAmpMacroParams::default_lm741()

  // Small differential input compensating Vos -> Linear range
  let (vo_lin, gm_lin) = evaluate_opamp_dc(params, -1.0e-3 + 1.0e-6, 0.0)
  assert_true(vo_lin > 0.0 && vo_lin < 5.0)
  assert_true(gm_lin > 1000.0)

  // Large differential input (1.0 V) -> Clamped to supply rail
  let (vo_sat, _) = evaluate_opamp_dc(params, 1.0, 0.0)
  assert_true(vo_sat > 13.0)
  assert_true(vo_sat < 14.0)
}

///|
test "HP Memristor state drift and boundary window" {
  let params = MemristorParams::default()

  // Initial step at w = 5 nm
  let (w_next, r_mem) = evaluate_memristor_step(params, 5.0e-9, 1.0e-3, 1.0e-6)
  assert_true(r_mem > params.r_on && r_mem < params.r_off)
  assert_true(w_next > 5.0e-9) // Drift towards R_on
}

///|
test "Esaki Tunnel Diode negative differential resistance (NDR)" {
  let params = TunnelDiodeParams::default_ge()

  // Point in peak region (V = 65 mV)
  let (i_peak, _) = evaluate_tunnel_diode(params, params.vp)
  assert_true(i_peak > 1.0e-3)

  // Point in NDR region (V = 150 mV, between Vp and Vv)
  let (i_ndr, g_ndr) = evaluate_tunnel_diode(params, 0.15)
  assert_true(i_ndr > 0.0)
  assert_true(g_ndr < 0.0) // Negative conductance!
}

///|
test "NTC and PTC Thermistors Steinhart-Hart temperature scaling" {
  let ntc = ThermistorParams::default_10k_ntc()

  // Room temp (25 C) -> 10k Ohms
  let r_25 = evaluate_thermistor_resistance(ntc, 25.0)
  assert_true((r_25 - 10000.0).abs() < 1.0)

  // High temp (85 C) -> Lower resistance
  let r_85 = evaluate_thermistor_resistance(ntc, 85.0)
  assert_true(r_85 < 2000.0)
  assert_true(r_85 > 500.0)
}

///|
test "Photodiode optical photocurrent and dark current" {
  let params = PhotodiodeParams::default_pin()

  // Zero-bias with illumination produces negative short-circuit photocurrent
  let (i_zero, _) = evaluate_photodiode(params, 0.0, 0.026)
  assert_true(i_zero < 0.0)
  assert_true((i_zero - -50.0e-6).abs() < 1.0e-6)
}

///|
test "Behavioral CMOS logic gates transfer characteristics" {
  let params = LogicGateParams::default_3v3()

  // Inverter logic 0 input -> output approx 3.3V
  let (v_out0, _) = evaluate_cmos_inverter(params, 0.0)
  assert_true(v_out0 > 3.0)

  // Inverter logic 1 input -> output approx 0.0V
  let (v_out1, _) = evaluate_cmos_inverter(params, 3.3)
  assert_true(v_out1 < 0.3)

  // NAND2: 0, 0 -> 1; 1, 1 -> 0
  let nand_00 = evaluate_cmos_nand2(params, 0.0, 0.0)
  assert_true(nand_00 > 3.0)
  let nand_11 = evaluate_cmos_nand2(params, 3.3, 3.3)
  assert_true(nand_11 < 0.3)

  // XOR2: 0, 1 -> 1; 1, 1 -> 0
  let xor_01 = evaluate_cmos_xor2(params, 0.0, 3.3)
  assert_true(xor_01 > 3.0)
  let xor_11 = evaluate_cmos_xor2(params, 3.3, 3.3)
  assert_true(xor_11 < 0.1)
}
