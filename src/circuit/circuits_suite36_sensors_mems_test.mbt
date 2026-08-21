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
test "Suite36 MEMS 01: Piezoresistive Pressure Sensor Span Temperature Compensation" {
  // Span(T) = Span_0 * (1 + alpha_s * (T - T0))
  let span_0 = 100.0 // 100 mV full-scale at 25 °C
  let alpha_s = -0.0018 // -0.18% / °C
  let t_celsius = 75.0 // 50 °C rise

  let span_hot = span_0 * (1.0 + alpha_s * (t_celsius - 25.0)) // 100 * (1 - 0.09) = 91.0 mV
  assert_true((span_hot - 91.0).abs() < 1.0e-6)
}

///|
test "Suite36 MEMS 02: Differential Capacitive Accelerometer Sense Output" {
  // V_out = V_bias * (Delta_C / (2 * C_0))
  let v_bias = 5.0
  let c_0 = 1.0e-12 // 1 pF nominal
  let delta_c = 0.05e-12 // 50 fF change at 1g

  let v_sense = v_bias * (delta_c / (2.0 * c_0)) // 5 * (0.05 / 2) = 125 mV / g
  assert_true((v_sense - 0.125).abs() < 1.0e-6)
}

///|
test "Suite36 MEMS 03: Vibratory Gyroscope Coriolis Acceleration Demodulation" {
  // a_coriolis = 2 * (v_drive x Omega_sense)
  let v_drive_m_s = 2.5 // 2.5 m/s proof mass drive velocity
  let omega_deg_s = 100.0 // 100 deg/s
  let omega_rad_s = omega_deg_s * @math.PI / 180.0

  let a_coriolis = 2.0 * v_drive_m_s * omega_rad_s // 2 * 2.5 * 1.745 = 8.726 m/s^2
  assert_true((a_coriolis - 8.7266).abs() < 0.01)
}

///|
test "Suite36 MEMS 04: Optical Quadrature Encoder 4x State Transitions" {
  // Quadrature state sequence: 00 -> 01 -> 11 -> 10 -> 00
  let states = [0b00, 0b01, 0b11, 0b10]
  assert_true(states.length() == 4)
  assert_true(states[0] == 0)
  assert_true(states[2] == 3)
}

///|
test "Suite36 MEMS 05: Thermocouple Cold-Junction PT100 Kelvin Correction" {
  let v_raw = 0.01250 // 12.50 mV measured across junction
  let v_cjc = 0.00103 // 1.03 mV equivalent cold junction voltage at 25 °C

  let v_corrected = v_raw + v_cjc // 13.53 mV actual hot temperature potential
  assert_true((v_corrected - 0.01353).abs() < 1.0e-6)
}

///|
test "Suite36 MEMS 06: Magnetic Hall Sensor Offset Cancellation by Spinning Current" {
  // 4-phase spinning current rotates bias by 90 deg every phase to cancel piezoresistive offset:
  // V_hall = (V_phase0 - V_phase90 + V_phase180 - V_phase270) / 4
  let v_offset = 0.020 // 20 mV static offset
  let v_sig = 0.005 // 5 mV magnetic signal

  let p0 = v_sig + v_offset
  let p90 = -v_sig + v_offset
  let p180 = v_sig + v_offset
  let p270 = -v_sig + v_offset

  let v_extracted = (p0 - p90 + p180 - p270) / 4.0 // Exactly 5 mV!
  assert_true((v_extracted - 0.005).abs() < 1.0e-12)
}

///|
test "Suite36 MEMS 07: Electrochemical 3-Electrode Potentiostat Compliance Voltage" {
  let v_ref = 0.50
  let v_working = 0.0
  let v_error = (v_ref - v_working).abs()
  assert_true(v_error == 0.50)
}

///|
test "Suite36 MEMS 08: Ultrasonic Transducer 40 kHz Resonant LC Matching" {
  let f_res = 40.0e3 // 40 kHz
  let c_transducer = 2.2e-9 // 2.2 nF piezo cap

  // L_match = 1 / ( (2*pi*f)^2 * C )
  let omega = 2.0 * @math.PI * f_res
  let l_match = 1.0 / (omega * omega * c_transducer) // ~7.19 mH

  assert_true((l_match - 0.007198).abs() < 1.0e-4)
}

///|
test "Suite36 MEMS 09: Capacitive Relative Humidity Sensor Bridge Linearity" {
  let rh_50_cap = 180.0e-12
  let rh_60_cap = 185.4e-12
  let sensitivity_pf_per_rh = (rh_60_cap - rh_50_cap) / 10.0 // 0.54 pF / %RH

  assert_true((sensitivity_pf_per_rh - 0.54e-12).abs() < 1.0e-15)
}

///|
test "Suite36 MEMS 10: MEMS Microphone 100 GigaOhm Bias Resistor Johnson Noise" {
  let r_bias = 100.0e9 // 100 GOhm bias resistor
  let c_mic = 1.0e-12 // 1 pF microphone element

  // Noise corner frequency f_corner = 1 / (2*pi * R * C) = 1 / (2*pi * 100G * 1p) = 1.59 mHz (Sub-audible!)
  let f_corner = 1.0 / (2.0 * @math.PI * r_bias * c_mic)
  assert_true(f_corner > 1.0 && f_corner < 2.0) // ~1.59 Hz
}
