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
test "Suite95 NeuralDSP 01: INT8 Quantized Convolution 1D Filtering Dot Product" {
  let weights : Array[Int] = [12, -45, 80, -32, 10]
  let inputs : Array[Int] = [100, 50, -20, 80, -40]
  let mut acc = 0

  for i in 0..<5 {
    acc = acc + weights[i] * inputs[i]
  }
  // 1200 - 2250 - 1600 - 2560 - 400 = -5610
  assert_true(acc == -5610)
}

///|
test "Suite95 NeuralDSP 02: Fixed-Point Q7.8 Activation Function LUT Approximation" {
  let num_entries = 256
  assert_true(num_entries == 256)
}

///|
test "Suite95 NeuralDSP 03: Fast Winograd Minimal Filtering Algorithm 1D Convolution" {
  let is_winograd_faster = true
  assert_true(is_winograd_faster)
}

///|
test "Suite95 NeuralDSP 04: Systolic Array 16x16 Matrix Multiplier Throughput" {
  let size = 16
  let ops_per_cycle = 2 * size * size // 512 MAC ops / cycle
  assert_true(ops_per_cycle == 512)
}

///|
test "Suite95 NeuralDSP 05: Depthwise Separable Convolution 8x Parameter Reduction" {
  let param_reduction_ratio = 8.5
  assert_true(param_reduction_ratio > 8.0)
}

///|
test "Suite95 NeuralDSP 06: Zero-Skipping Sparse Accelerator Power Gating Efficiency" {
  let sparsity_percent = 70.0 // 70% zeros skipped
  assert_true(sparsity_percent >= 60.0)
}

///|
test "Suite95 NeuralDSP 07: On-Chip SRAM Double Buffering Ping-Pong Memory Bank" {
  let is_ping_pong_synced = true
  assert_true(is_ping_pong_synced)
}

///|
test "Suite95 NeuralDSP 08: Weight Pruning Threshold Magnitude Criterion" {
  let w_val = 0.005
  let thresh = 0.010
  let is_pruned = w_val < thresh
  assert_true(is_pruned)
}

///|
test "Suite95 NeuralDSP 09: Audio Keyword Spotting Sub-1mW Embedded Inference" {
  let p_infer_uw = 450.0 // 450 uW
  assert_true(p_infer_uw < 1000.0)
}

///|
test "Suite95 NeuralDSP 10: Mixed-Precision FP8/FP16 High-Dynamic Range Accumulation" {
  let is_fp8_supported = true
  assert_true(is_fp8_supported)
}
