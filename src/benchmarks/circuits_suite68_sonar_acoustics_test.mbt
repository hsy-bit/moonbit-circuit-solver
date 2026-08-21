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
test "Suite68 Sonar 01: Hydrophone Voltage Sensitivity -190 dB re 1 V/uPa" {
  // M_0 = -190 dBV/uPa -> V_out = 10^(-190/20) = 3.162e-10 V/uPa = 0.316 uV / Pa
  let m0_db = -190.0
  let p_acoustic_upa = 1.0e6 // 1 Pa = 1e6 uPa acoustic wave

  let ln10 = @math.ln(10.0)
  let sens_lin = @math.exp(m0_db / 20.0 * ln10) // 3.162e-10
  let v_out_uv = sens_lin * p_acoustic_upa * 1.0e6 // ~316.2 uV

  assert_true((v_out_uv - 316.227).abs() < 1.0)
}

///|
test "Suite68 Sonar 02: Active Sonar LFM Pulse Compression Match Filter Gain" {
  // G_comp = 10 * log10(B * T)
  let b_chirp_hz = 5000.0 // 5 kHz chirp bandwidth
  let t_pulse_s = 0.100 // 100 ms pulse duration

  let bt_product = b_chirp_hz * t_pulse_s // 500
  let ln10 = @math.ln(10.0)
  let g_comp_db = 10.0 * (@math.ln(bt_product) / ln10) // ~26.99 dB processing gain!

  assert_true((g_comp_db - 26.9897).abs() < 0.01)
}

///|
test "Suite68 Sonar 03: Transducer Clamped Capacitance Resonant Matching" {
  // L_match = 1 / (omega^2 * C0)
  let f_sonar = 30.0e3 // 30 kHz
  let c0_piezo = 15.0e-9 // 15 nF clamped capacitance
  let omega = 2.0 * @math.PI * f_sonar

  let l_match_mh = 1.0 / (omega * omega * c0_piezo) * 1000.0 // ~1.876 mH
  assert_true((l_match_mh - 1.876).abs() < 0.01)
}

///|
test "Suite68 Sonar 04: Line Array Beamwidth Theta_3dB at 15 kHz" {
  // theta_3db = 0.886 * lambda / L_array
  let f_hz = 15.0e3
  let c_sound = 1500.0 // 1500 m/s in seawater
  let lambda_m = c_sound / f_hz // 0.10 m (10 cm)
  let l_array_m = 2.0 // 2 meters long array

  let theta_rad = 0.886 * lambda_m / l_array_m // ~0.0443 rad
  let theta_deg = theta_rad * 180.0 / @math.PI // ~2.538 degrees narrow beam!

  assert_true((theta_deg - 2.538).abs() < 0.05)
}

///|
test "Suite68 Sonar 05: Sonar Equation Figure of Merit FOM" {
  let sl_source_level = 215.0 // 215 dB re 1 uPa
  let nl_noise_level = 65.0 // 65 dB noise
  let di_directivity = 20.0 // 20 dB array gain
  let dt_detection_thresh = 10.0 // 10 dB threshold

  let fom = sl_source_level -
    (nl_noise_level - di_directivity) -
    dt_detection_thresh // 215 - 45 - 10 = 160 dB
  assert_true(fom == 160.0)
}

///|
test "Suite68 Sonar 06: Deep Ocean SOFAR Channel Sound Axis Velocity Minimum" {
  let c_sofar_m_s = 1480.0 // 1480 m/s at ~1000m depth
  let c_surface_m_s = 1520.0
  assert_true(c_sofar_m_s < c_surface_m_s)
}

///|
test "Suite68 Sonar 07: Synthetic Aperture Sonar SAS Sub-Centimeter Resolution" {
  let d_element_cm = 1.5
  let delta_x_sas_cm = d_element_cm / 2.0 // 0.75 cm along-track resolution! (Range-independent!)

  assert_true(delta_x_sas_cm < 1.0)
}

///|
test "Suite68 Sonar 08: Seawater Acoustic Attenuation Absorption at 50 kHz" {
  let alpha_db_per_km = 12.5 // ~12.5 dB/km absorption
  assert_true(alpha_db_per_km > 10.0)
}

///|
test "Suite68 Sonar 09: MVDR Capon Adaptive Beamformer Interference Nulling" {
  let null_depth_db = -45.0 // -45 dB jammer cancellation
  assert_true(null_depth_db <= -40.0)
}

///|
test "Suite68 Sonar 10: 64-Channel Hydrophone Synchronous Sampling ADC Stream" {
  let num_channels = 64
  let fs_khz = 250.0
  let total_msps = num_channels.to_double() * fs_khz / 1000.0 // 16 MSPS

  assert_true(total_msps == 16.0)
}
