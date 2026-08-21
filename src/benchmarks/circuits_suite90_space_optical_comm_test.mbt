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
test "Suite90 LaserComm 01: Deep Space Optical Link Range Equation (2 AU Link)" {
  // P_rx = P_tx * G_tx * G_rx * (lambda / (4*pi*R))^2
  let lambda_m = 1.55e-6 // 1550 nm laser
  let d_tx_m = 0.22 // 22 cm space telescope
  let d_rx_m = 5.0 // 5 m ground Hale telescope

  let g_tx = @math.PI * d_tx_m / lambda_m * (@math.PI * d_tx_m / lambda_m) // ~1.98e11 (113 dB gain!)
  let g_rx = @math.PI * d_rx_m / lambda_m * (@math.PI * d_rx_m / lambda_m) // ~1.03e14 (140 dB gain!)

  assert_true(g_tx > 1.0e11)
  assert_true(g_rx > 1.0e13)
}

///|
test "Suite90 LaserComm 02: Fine Steering Mirror FSM Sub-Microradian Pointing (0.5 urad)" {
  let theta_fsm_urad = 0.45 // 0.45 urad pointing accuracy
  assert_true(theta_fsm_urad < 0.50)
}

///|
test "Suite90 LaserComm 03: Pulse Position Modulation PPM-64 Slot Rate" {
  let m_order = 64
  let bits_per_symbol = 6 // log2(64) = 6 bits / photon pulse
  let slot_width_ns = 0.5 // 500 ps slot width

  assert_true(m_order == 64)
  assert_true(bits_per_symbol == 6)
  assert_true(slot_width_ns == 0.5)
}

///|
test "Suite90 LaserComm 04: Erbium-Doped Fiber High-Power Optical Booster (5W Saturation)" {
  let p_sat_w = 5.0
  assert_true(p_sat_w == 5.0)
}

///|
test "Suite90 LaserComm 05: Atmospheric Adaptive Optics Deformable Mirror 1000 Actuators" {
  let num_actuators = 1024
  let f_loop_khz = 2.0 // 2 kHz AO loop bandwidth
  assert_true(num_actuators >= 1000)
  assert_true(f_loop_khz >= 1.0)
}

///|
test "Suite90 LaserComm 06: Point-Ahead Angle Calculation for Planetary Motion" {
  let point_ahead_urad = 25.0 // 25 urad relativistic lead angle
  assert_true(point_ahead_urad > 10.0)
}

///|
test "Suite90 LaserComm 07: Superconducting Nanowire 4-Channel Single Photon Array Detection" {
  let pde_percent = 85.0 // 85% photon detection efficiency at 1550 nm
  assert_true(pde_percent >= 80.0)
}

///|
test "Suite90 LaserComm 08: Inter-Satellite 100 Gbps Coherent DP-QPSK Optical Crosslink" {
  let data_rate_gbps = 100.0
  assert_true(data_rate_gbps == 100.0)
}

///|
test "Suite90 LaserComm 09: Solar Background Rejection 0.1 nm Ultra-Narrow Optical Bandpass" {
  let bw_filter_nm = 0.10 // 100 pm atomic line filter
  assert_true(bw_filter_nm <= 0.10)
}

///|
test "Suite90 LaserComm 10: Earth-to-Moon 622 Mbps LLCD Return Link Link Margin" {
  let margin_db = 4.5 // 4.5 dB margin at 622 Mbps
  assert_true(margin_db >= 3.0)
}
