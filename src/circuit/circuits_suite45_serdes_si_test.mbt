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
test "Suite45 SerDes 01: 4-Tap FFE Transmitter De-Emphasis" {
  // y[n] = c[-1]*x[n+1] + c[0]*x[n] + c[1]*x[n-1] + c[2]*x[n-2]
  // Normalized sum |c[-1]| + |c[0]| + |c[1]| + |c[2]| = 1.0
  let c_pre = -0.10
  let c_main = 0.70
  let c_post1 = -0.15
  let c_post2 = -0.05

  let sum_abs = c_pre.abs() + c_main.abs() + c_post1.abs() + c_post2.abs() // 1.00
  assert_true((sum_abs - 1.0).abs() < 1.0e-12)
}

///|
test "Suite45 SerDes 02: DFE Speculative 1-Tap Lookahead Decision" {
  // Speculative DFE resolves both assumptions (prev_bit = +1 and prev_bit = -1) in parallel before clock edge
  let v_in = 0.050 // 50 mV
  let h1_tap = 0.080 // 80 mV post-cursor ISI

  let v_hyp_pos = v_in - h1_tap // -30 mV -> Decides 0
  let v_hyp_neg = v_in + h1_tap // +130 mV -> Decides 1

  assert_true(v_hyp_pos < 0.0)
  assert_true(v_hyp_neg > 0.0)
}

///|
test "Suite45 SerDes 03: CTLE High-Frequency Peaking Zero-Pole Placement" {
  // Gain peak ratio = f_pole / f_zero
  let f_zero = 1.5e9 // 1.5 GHz
  let f_pole = 7.5e9 // 7.5 GHz

  let peak_ratio = f_pole / f_zero // 5.0
  let ln10 = @math.ln(10.0)
  let peak_db = 20.0 * (@math.ln(peak_ratio) / ln10) // ~13.98 dB boost at 8 GHz Nyquist

  assert_true((peak_db - 13.979).abs() < 0.02)
}

///|
test "Suite45 SerDes 04: PRBS-7 LFSR Polynomial Period (2^7 - 1 = 127)" {
  // x^7 + x^6 + 1
  let mut state = 0b0000001
  let mut count = 0

  for _i = 0; _i < 200; _i = _i + 1 {
    let b6 = (state >> 6) & 1
    let b5 = (state >> 5) & 1
    let feedback = b6 ^ b5
    state = ((state << 1) | feedback) & 0b1111111
    count = count + 1
    if state == 0b0000001 {
      break
    }
  }

  assert_true(count == 127) // Exact maximum-length sequence period!
}

///|
test "Suite45 SerDes 05: PAM-4 Eye Opening Height Multi-Level Thresholds" {
  // PAM-4 levels: -3, -1, +1, +3 -> Three eye openings (Upper, Middle, Lower)
  let v_levels = [-3.0, -1.0, 1.0, 3.0]
  let eye_height = v_levels[2] - v_levels[1] // 2.0 units

  assert_true(eye_height == 2.0)
  assert_true(v_levels.length() == 4)
}

///|
test "Suite45 SerDes 06: PCIe 5.0 32 GT/s Nyquist Channel Loss Budget (-28 dB)" {
  let f_nyquist_ghz = 16.0 // 16 GHz for 32 GT/s NRZ
  let max_loss_db = -28.0 // -28 dB standard budget

  assert_true(f_nyquist_ghz == 16.0)
  assert_true(max_loss_db == -28.0)
}

///|
test "Suite45 SerDes 07: Phase Interpolator 64-Step Quadrature Blending" {
  let step_code = 32 // Half-way between I (0 deg) and Q (90 deg)
  let angle_deg = step_code.to_double() / 64.0 * 90.0 // 45.0 degrees

  assert_true((angle_deg - 45.0).abs() < 1.0e-6)
}

///|
test "Suite45 SerDes 08: Sign-Sign LMS Adaptive Tap Update Convergence" {
  // c_new = c_old + mu * sgn(error) * sgn(data)
  let mut c_tap = 0.0
  let mu_step = 0.001
  let sgn_err = 1.0
  let sgn_data = 1.0

  for _k = 0; _k < 50; _k = _k + 1 {
    c_tap = c_tap + mu_step * sgn_err * sgn_data
  }

  assert_true((c_tap - 0.050).abs() < 1.0e-6)
}

///|
test "Suite45 SerDes 09: Total Jitter TJ at BER 10^-12 (TJ = DJ + 14.069 * RJ)" {
  let dj_ps = 5.0 // 5 ps deterministic jitter
  let rj_rms_ps = 0.8 // 0.8 ps RMS random jitter

  let tj_ps = dj_ps + 14.069 * rj_rms_ps // 5 + 11.255 = 16.255 ps
  assert_true((tj_ps - 16.255).abs() < 0.01)
}

///|
test "Suite45 SerDes 10: 112 Gbps PAM-4 Unit Interval (UI = 17.85 ps)" {
  let baud_rate_gbaud = 56.0 // 56 Gbaud PAM-4 = 112 Gbps
  let ui_ps = 1.0 / (baud_rate_gbaud * 1.0e9) * 1.0e12 // ~17.857 ps

  assert_true((ui_ps - 17.857).abs() < 0.01)
}
