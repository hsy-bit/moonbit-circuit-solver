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
test "TR-BDF2 composite integration companion and LTE estimation" {
  let c_val = 1.0e-6
  let comp = evaluate_tr_bdf2_cap(c_val, 1.0, 1.2, 0.01, 1.0e-6)

  assert_true(comp.stage1_req > 0.0)
  assert_true(comp.stage2_req > 0.0)

  let lte = estimate_tr_bdf2_lte(1.0, 1.1, 1.2, 1.0e-6)
  assert_true(lte >= 0.0)
}

///|
test "State-Space Model simulation and Padé Matrix Exponential" {
  // 2nd-order RLC state space system:
  // dx1/dt = x2
  // dx2/dt = -omega0^2 * x1 - 2*zeta*omega0 * x2 + omega0^2 * u
  let a_mat = @linalg.Matrix::zeros(2, 2)
  a_mat.set(0, 0, 0.0)
  a_mat.set(0, 1, 1.0)
  a_mat.set(1, 0, -100.0)
  a_mat.set(1, 1, -2.0)

  let b_mat = @linalg.Matrix::zeros(2, 1)
  b_mat.set(0, 0, 0.0)
  b_mat.set(1, 0, 100.0)

  let c_mat = @linalg.Matrix::zeros(1, 2)
  c_mat.set(0, 0, 1.0)
  c_mat.set(0, 1, 0.0)

  let d_mat = @linalg.Matrix::zeros(1, 1)
  d_mat.set(0, 0, 0.0)

  let model = StateSpaceModel::new(a_mat, b_mat, c_mat, d_mat)
  let exp_a = compute_matrix_exp(a_mat.scale(0.01))
  assert_true(exp_a.num_rows() == 2)
  assert_true(exp_a.num_cols() == 2)

  let x0 = @linalg.Vector::zeros(2)
  let u_traj : Array[@linalg.Vector] = []
  for _k = 0; _k < 50; _k = _k + 1 {
    let u = @linalg.Vector::zeros(1)
    u.set(0, 1.0) // Unit step input
    u_traj.push(u)
  }

  let y_out = simulate_state_space(model, x0, u_traj, 0.01)
  assert_true(y_out.length() == 50)
  // Step response converges towards 1.0
  let y_end = y_out[49].get(0)
  assert_true(y_end > 0.0)
}

///|
test "Cooley-Tukey Radix-2 FFT and THD Harmonic Analysis" {
  let num_samples = 64
  let f_fund = 1000.0
  let fs = 64000.0
  let dt = 1.0 / fs

  let t_arr : Array[Double] = []
  let v_arr : Array[Double] = []

  for i in 0..<num_samples {
    let t = i.to_double() * dt
    // Signal: Fundamental 1.0V at 1kHz + 2nd harmonic 0.1V at 2kHz
    let v = 1.0 * @math.sin(2.0 * @math.PI * f_fund * t) +
      0.1 * @math.sin(2.0 * @math.PI * 2.0 * f_fund * t)
    t_arr.push(t)
    v_arr.push(v)
  }

  let fft_res = compute_transient_fft_analysis(
    t_arr,
    v_arr,
    f_fund,
    FftWindow::Rectangular,
  )
  assert_true(fft_res.num_samples == 64)
  assert_true(fft_res.harmonics.length() >= 2)
  assert_true(fft_res.thd_percent > 5.0 && fft_res.thd_percent < 15.0)
  assert_true(fft_res.enob_bits > 2.0)
}

///|
test "Mixed-Signal discrete event queue scheduler" {
  let engine = MixedSignalEngine::new(0.8, 2.0)

  engine.schedule_event(1.0e-9, "clk", Logic1)
  engine.schedule_event(3.0e-9, "clk", Logic0)
  engine.schedule_event(2.0e-9, "data", Logic1)

  let processed = engine.process_until(2.5e-9)
  assert_true(processed.length() == 2)
  assert_true(engine.signal_states.get("clk") == Some(Logic1))
  assert_true(engine.signal_states.get("data") == Some(Logic1))

  let processed2 = engine.process_until(5.0e-9)
  assert_true(processed2.length() == 1)
  assert_true(engine.signal_states.get("clk") == Some(Logic0))
}
