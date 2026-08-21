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
test "AC Noise Analysis on resistive divider" {
  let netlist_str =
    #|* Resistive Voltage Divider Noise Test
    #|V1 in 0 DC 5.0
    #|R1 in out 1000.0
    #|R2 out 0 1000.0
    #|.noise V(out) V1 dec 10 10 100000
  let netlist = @spice.parse_spice_netlist(netlist_str)
  let noise_res = solve_noise_analysis(
    netlist, "out", "V1", 10.0, 100000.0, 20, 290.0,
  )

  assert_true(noise_res.points.length() == 20)
  assert_true(noise_res.total_integrated_output_noise_rms > 0.0)
  assert_true(noise_res.total_integrated_input_noise_rms > 0.0)

  // Verify first frequency point
  let pt0 = noise_res.points[0]
  assert_true(pt0.output_noise_voltage_density > 0.0)
  assert_true(pt0.contributions.length() >= 2)
}

///|
test "RF 2-Port S-Parameters and stability metrics" {
  // 50-ohm symmetric attenuator / matching network
  // Y-parameters for Pi network: Y11 = 0.02, Y12 = -0.01, Y21 = -0.01, Y22 = 0.02
  let y11 = @linalg.Complex::new(0.02, 0.0)
  let y12 = @linalg.Complex::new(-0.01, 0.0)
  let y21 = @linalg.Complex::new(-0.01, 0.0)
  let y22 = @linalg.Complex::new(0.02, 0.0)

  let s_params = y_to_s_parameters(y11, y12, y21, y22, 50.0, 1.0e9)
  let metrics = s_params.compute_metrics()

  assert_true(metrics.return_loss_port1_db > 0.0)
  assert_true(metrics.insertion_loss_db > 0.0)
  assert_true(metrics.vswr_port1 >= 1.0)
  assert_true(metrics.vswr_port2 >= 1.0)
  assert_true(metrics.rollett_k > 1.0) // Passively stable
}

///|
test "Monte Carlo Statistical Tolerance Analysis" {
  let netlist_str =
    #|* Voltage Divider Monte Carlo
    #|V1 in 0 DC 10.0
    #|R1 in out 1000.0
    #|R2 out 0 1000.0
    #|.op
  let netlist = @spice.parse_spice_netlist(netlist_str)

  let vars = [
    ComponentVariation::new("R1", 1000.0, 5.0, true),
    ComponentVariation::new("R2", 1000.0, 5.0, true),
  ]

  let mc_res = run_monte_carlo_dc(netlist, vars, 50, "out", 4.5, 5.5, 42)

  assert_true(mc_res.num_runs == 50)
  assert_true(mc_res.mean_voltage > 4.0 && mc_res.mean_voltage < 6.0)
  assert_true(mc_res.std_dev >= 0.0)
  assert_true(mc_res.min_voltage <= mc_res.max_voltage)
}

///|
test "DC Continuation: Source Stepping and Gmin Stepping" {
  let netlist_str =
    #|* Non-linear Diode Circuit for Continuation
    #|V1 in 0 DC 2.0
    #|R1 in out 100.0
    #|D1 out 0 1N4148
    #|.model 1N4148 D (IS=1e-14 N=1.0)
    #|.op
  let netlist = @spice.parse_spice_netlist(netlist_str)

  let src_step_res = solve_dc_source_stepping(netlist, 5)
  assert_true(src_step_res.converged)
  assert_true(src_step_res.total_iterations == 5)

  let gmin_step_res = solve_dc_gmin_stepping(netlist, 4)
  assert_true(gmin_step_res.converged)
  assert_true(gmin_step_res.total_iterations == 4)
}

///|
test "Periodic Steady State PSS shooting simulation" {
  let pss_res = solve_pss_shooting(1.0e-3, 50, 20, 1.0e-5)
  assert_true(pss_res.converged)
  assert_true(pss_res.limit_cycle_samples.length() == 50)
}

///|
test "Small-Signal Harmonic Distortion Volterra series" {
  // Test weakly non-linear amplifier: y = 10*x - 0.5*x^2 - 0.2*x^3 with Vin = 0.1V
  let dist = compute_taylor_distortion(10.0, -0.5, -0.2, 0.1)
  assert_true(dist.fundamental_mag > 0.9)
  assert_true(dist.hd2_dbc < -30.0)
  assert_true(dist.hd3_dbc < -40.0)
  assert_true(dist.thd_percent < 5.0)
}
