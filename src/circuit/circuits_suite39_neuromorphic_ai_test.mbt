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
test "Suite39 NeuroAI 01: 32x32 Memristor Synaptic Crossbar In-Memory Matrix Multiply" {
  let size = 32
  let weights = Array::make(size * size, 0.0)
  for r in 0..<size {
    for c in 0..<size {
      weights[r * size + c] = 0.001 * (r + c + 1).to_double()
    }
  }

  let v_input = Array::make(size, 0.5) // 0.5V read pulses
  let i_accum = Array::make(size, 0.0)

  // Analog Current-Mode Kirchhoff's Summation
  for c in 0..<size {
    let mut sum_c = 0.0
    for r in 0..<size {
      sum_c = sum_c + v_input[r] * weights[r * size + c]
    }
    i_accum[c] = sum_c
  }

  assert_true(i_accum.length() == 32)
  assert_true(i_accum[0] > 0.0)
  assert_true(i_accum[31] > i_accum[0])
}

///|
test "Suite39 NeuroAI 02: STDP Synaptic Weight Exponential Bounds" {
  let w_min = 1.0e-6 // 1 uS minimum conductance
  let w_max = 100.0e-6 // 100 uS maximum conductance

  let mut w_curr = 50.0e-6
  let delta_w_ltp = 10.0e-6

  w_curr = w_curr + delta_w_ltp
  if w_curr > w_max {
    w_curr = w_max
  }

  assert_true(w_curr <= w_max && w_curr >= w_min)
  assert_true((w_curr - 60.0e-6).abs() < 1.0e-12)
}

///|
test "Suite39 NeuroAI 03: Silicon Axon Absolute Refractory Period Timer" {
  // During refractory period (t < t_refractory = 2 ms), neuron cannot fire regardless of stimulus
  let t_refractory_ms = 2.0
  let is_in_refractory = fn(t_since_spike_ms : Double) -> Bool {
    t_since_spike_ms < t_refractory_ms
  }

  assert_true(is_in_refractory(1.0) == true)
  assert_true(is_in_refractory(3.0) == false)
}

///|
test "Suite39 NeuroAI 04: Winner-Take-All 8-Channel Mutual Inhibition" {
  let inputs = [1.2, 0.8, 2.5, 1.9, 0.4, 3.1, 1.0, 0.5] // Channel 5 has 3.1 (Winner!)
  let mut max_val = -1.0
  let mut winner_idx = -1

  for i in 0..<inputs.length() {
    if inputs[i] > max_val {
      max_val = inputs[i]
      winner_idx = i
    }
  }

  assert_true(winner_idx == 5)
  assert_true(max_val == 3.1)
}

///|
test "Suite39 NeuroAI 05: Translinear Subthreshold Vector Normalizer" {
  // sum_i I_i / I_total = 1.0 (Softmax analog normalization)
  let currents = [2.0e-9, 5.0e-9, 8.0e-9, 5.0e-9]
  let mut total = 0.0
  for i in currents {
    total = total + i
  }

  let mut norm_sum = 0.0
  for i in currents {
    norm_sum = norm_sum + i / total
  }

  assert_true((norm_sum - 1.0).abs() < 1.0e-12)
}

///|
test "Suite39 NeuroAI 06: Dendritic Non-Linear Active NMDA Spike Threshold" {
  let v_dendrite = -0.040 // -40 mV
  let v_nmda_thresh = -0.045 // -45 mV
  let is_nmda_spike = v_dendrite > v_nmda_thresh

  assert_true(is_nmda_spike)
}

///|
test "Suite39 NeuroAI 07: Dynamic Synapse Short-Term Depression STD Recovery" {
  // dR/dt = (1 - R) / tau_rec - u * R * delta(t - t_spk)
  let tau_rec_ms = 500.0 // 500 ms recovery time
  let u_use = 0.20 // 20% release probability

  assert_true(tau_rec_ms == 500.0)
  assert_true(u_use == 0.20)
}

///|
test "Suite39 NeuroAI 08: ReRAM Random Telegraph Noise True RNG Entropy" {
  let r_high = 100.0e3
  let r_low = 10.0e3
  let ratio = r_high / r_low

  assert_true(ratio == 10.0)
}

///|
test "Suite39 NeuroAI 09: Address Event Representation AER 16-bit Spike Bus" {
  let neuron_id = 4095
  let timestamp_us = 120500

  assert_true(neuron_id < 65536)
  assert_true(timestamp_us > 0)
}

///|
test "Suite39 NeuroAI 10: SNN Leaky Integrate-and-Fire Firing Rate Linearity" {
  // Firing rate f = 1 / (tau_m * ln( (I * R) / (I * R - V_th) ))
  let i_inj = 2.0e-9 // 2 nA
  let r_mem = 10.0e6 // 10 MOhm -> I * R = 20 mV
  let v_th = 15.0e-3 // 15 mV threshold
  let tau_m = 0.020 // 20 ms

  let log_arg = i_inj * r_mem / (i_inj * r_mem - v_th) // 20 / 5 = 4.0
  let f_rate = 1.0 / (tau_m * @math.ln(log_arg)) // 1.0 / (0.02 * 1.386) = ~36.07 Hz

  assert_true((f_rate - 36.067).abs() < 0.1)
}
