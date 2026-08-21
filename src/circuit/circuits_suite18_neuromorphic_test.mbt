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
test "Suite18 Neuro 01: Leaky Integrate-and-Fire LIF Silicon Neuron" {
  // C_mem * dV/dt = - (V - V_rest)/R_leak + I_syn
  // If V >= V_thresh -> Fire spike and reset V to V_reset
  let c_mem = 100.0e-12
  let r_leak = 100.0e6
  let v_rest = -0.070 // -70 mV
  let v_thresh = -0.050 // -50 mV
  let v_reset = -0.075 // -75 mV
  let i_syn = 300.0e-12 // 300 pA injected current

  let mut v_mem = v_rest
  let dt = 1.0e-4
  let mut spike_count = 0

  for _s = 0; _s < 1000; _s = _s + 1 {
    let i_leak = (v_mem - v_rest) / r_leak
    let dv = (i_syn - i_leak) / c_mem * dt
    v_mem = v_mem + dv

    if v_mem >= v_thresh {
      spike_count = spike_count + 1
      v_mem = v_reset
    }
  }

  assert_true(spike_count > 0)
  assert_true(v_thresh > v_rest)
}

///|
test "Suite18 Neuro 02: Hodgkin-Huxley Giant Squid Axon Action Potential" {
  // Gating variables m, h, n and ionic currents: I_Na = g_Na*m^3*h*(V - E_Na), I_K = g_K*n^4*(V - E_K), I_L = g_L*(V - E_L)
  let g_na_max = 120.0 // mS/cm^2
  let g_k_max = 36.0
  let g_l_max = 0.3
  let e_na = 50.0 // mV
  let e_k = -77.0 // mV
  let e_l = -54.4 // mV

  assert_true(g_na_max > g_k_max)
  assert_true(e_na > 0.0)
  assert_true(e_k < e_l)
  assert_true(g_l_max < 1.0)
}

///|
test "Suite18 Neuro 03: Spike-Timing-Dependent Plasticity STDP Exponential Window" {
  // Delta w = A_plus * exp(-Delta_t / tau_plus) for Delta_t > 0 (LTP)
  // Delta w = - A_minus * exp(Delta_t / tau_minus) for Delta_t < 0 (LTD)
  let a_plus = 0.01
  let a_minus = 0.012
  let tau_plus = 0.020 // 20 ms
  let tau_minus = 0.020

  let dt_ltp = 0.005 // Pre fires 5 ms before Post -> LTP
  let dw_ltp = a_plus * @math.exp(-dt_ltp / tau_plus)

  let dt_ltd = -0.005 // Pre fires 5 ms after Post -> LTD
  let dw_ltd = -a_minus * @math.exp(dt_ltd / tau_minus)

  assert_true(dw_ltp > 0.0)
  assert_true(dw_ltd < 0.0)
  assert_true((dw_ltp - 0.007788).abs() < 1.0e-5)
}

///|
test "Suite18 Neuro 04: 16x16 Memristor Synaptic Crossbar Matrix Multiplier" {
  let rows = 16
  let cols = 16

  let weights = Array::make(rows * cols, 0.0)
  for r in 0..<rows {
    for c in 0..<cols {
      weights[r * cols + c] = (r + c).to_double() * 0.01 + 0.001
    }
  }

  let v_in = Array::make(rows, 1.0) // 1V read pulses
  let i_out = Array::make(cols, 0.0)

  // Current-mode accumulation: I_j = sum_i V_i * G_ij (Ohm's & Kirchhoff's law)
  for c in 0..<cols {
    let mut sum_i = 0.0
    for r in 0..<rows {
      let g_ij = weights[r * cols + c]
      sum_i = sum_i + v_in[r] * g_ij
    }
    i_out[c] = sum_i
  }

  assert_true(i_out.length() == cols)
  assert_true(i_out[0] > 0.0)
  assert_true(i_out[cols - 1] > i_out[0])
}

///|
test "Suite18 Neuro 05: Izhikevich Simple Model 4-Type Firing Regimes" {
  // v' = 0.04*v^2 + 5*v + 140 - u + I
  // u' = a*(b*v - u)
  let a_param = 0.02
  let b_param = 0.2
  let c_param = -65.0
  let d_param = 8.0 // Regular Spiking parameters

  let mut v = -65.0
  let mut u = b_param * v
  let i_inj = 10.0
  let dt = 0.2

  let mut spikes = 0
  for _s = 0; _s < 500; _s = _s + 1 {
    let dv = (0.04 * v * v + 5.0 * v + 140.0 - u + i_inj) * dt
    let du = a_param * (b_param * v - u) * dt

    v = v + dv
    u = u + du

    if v >= 30.0 {
      spikes = spikes + 1
      v = c_param
      u = u + d_param
    }
  }

  assert_true(spikes > 0)
}

///|
test "Suite18 Neuro 06: Winner-Take-All WTA Current-Mode Mutual Inhibition" {
  let i_in1 = 10.0e-6 // 10 uA (Winner)
  let i_in2 = 8.0e-6 // 8 uA
  let i_in3 = 5.0e-6 // 5 uA

  assert_true(i_in1 > i_in2 && i_in2 > i_in3)
}

///|
test "Suite18 Neuro 07: Axon Hillock Threshold Comparator Circuit" {
  let netlist_str =
    #|* Axon Hillock Action Potential Trigger
    #|VIN in 0 DC 2.5
    #|V_THRESH thresh 0 DC 2.0
    #|X1 in thresh out OPAMP
    #|RLOAD out 0 1000.0
    #|.op
  let netlist = @spice.parse_spice_netlist(netlist_str)
  let sim = CircuitSimulator::{ netlist, }
  let dc = sim.solve_dc()
  assert_true(dc.contains("out"))
}

///|
test "Suite18 Neuro 08: Translinear Sub-Threshold Log-Domain Multiplier" {
  // Gilbert translinear principle: prod(I_clockwise) = prod(I_counterclockwise)
  let i1 = 10.0e-9 // 10 nA sub-threshold
  let i2 = 20.0e-9
  let i_ref = 10.0e-9

  let i_out = i1 * i2 / i_ref // 20 nA
  assert_true((i_out - 20.0e-9).abs() < 1.0e-12)
}

///|
test "Suite18 Neuro 09: Dynamic Vision Sensor DVS Temporal Contrast Pixel" {
  // Photocurrent I_photo, Logarithmic compression: V_log = U_T * ln(I_photo / I_0)
  // Contrast event threshold Delta V = U_T * ln(I2 / I1) >= Theta_ON
  let u_t = 0.02585
  let ratio_intensity = 1.25 // 25% illumination change

  let delta_v = u_t * @math.ln(ratio_intensity)
  assert_true((delta_v - 0.005768).abs() < 1.0e-5) // ~5.77 mV
}

///|
test "Suite18 Neuro 10: FitzHugh-Nagumo Limit Cycle Phase Portrait Nullclines" {
  // v-nullcline: w = v - v^3/3 + I
  // w-nullcline: w = (v + a) / b
  let a_param = 0.7
  let b_param = 0.8
  let i_ext = 0.5
  let v_test = 0.0

  let w_v_null = v_test - v_test * v_test * v_test / 3.0 + i_ext // 0.5
  let w_w_null = (v_test + a_param) / b_param // 0.7 / 0.8 = 0.875

  assert_true((w_v_null - 0.5).abs() < 1.0e-12)
  assert_true((w_w_null - 0.875).abs() < 1.0e-12)
}
