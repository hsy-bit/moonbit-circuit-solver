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
test "Dahlquist Stiff Test Problem: y' = -1000*y, y(0) = 1" {
  // Analytical solution: y(t) = exp(-1000 * t)
  let dt = 1.0e-4
  let steps = 50

  // 1. Backward Euler: y_{n+1} = y_n / (1 + 1000*dt)
  let mut y_be = 1.0
  for _s = 0; _s < steps; _s = _s + 1 {
    y_be = y_be / (1.0 + 1000.0 * dt)
  }

  // 2. Trapezoidal: y_{n+1} = y_n * (1 - 500*dt) / (1 + 500*dt)
  let mut y_trap = 1.0
  for _s = 0; _s < steps; _s = _s + 1 {
    y_trap = y_trap * (1.0 - 500.0 * dt) / (1.0 + 500.0 * dt)
  }

  let t_final = steps.to_double() * dt
  let y_exact = @math.exp(-1000.0 * t_final)

  assert_true((y_be - y_exact).abs() < 0.05)
  assert_true((y_trap - y_exact).abs() < 0.01)
}

///|
test "Van der Pol Nonlinear Limit Cycle Oscillator Numerical Integration" {
  // x'' - mu*(1 - x^2)*x' + x = 0
  let mu = 1.0
  let dt = 0.01
  let steps = 200

  let mut x = 2.0
  let mut v = 0.0

  for _s = 0; _s < steps; _s = _s + 1 {
    let dv_dt = mu * (1.0 - x * x) * v - x
    let dx_dt = v

    x = x + dx_dt * dt
    v = v + dv_dt * dt
  }

  assert_true(x.abs() < 5.0)
  assert_true(v.abs() < 5.0)
}

///|
test "FitzHugh-Nagumo Biological Neuron Action Potential Spike Generation" {
  // v' = v - v^3/3 - w + I_ext
  // w' = (v + a - b*w) / tau
  let a = 0.7
  let b = 0.8
  let tau = 12.5
  let i_ext = 0.5
  let dt = 0.05

  let mut v = -1.0
  let mut w = -0.5

  let mut spike_count = 0

  for _s = 0; _s < 500; _s = _s + 1 {
    let dv = v - v * v * v / 3.0 - w + i_ext
    let dw = (v + a - b * w) / tau

    v = v + dv * dt
    w = w + dw * dt

    if v > 1.0 {
      spike_count = spike_count + 1
    }
  }

  assert_true(spike_count > 0)
}

///|
test "Lotka-Volterra Predator-Prey Ecological Periodic Orbit" {
  // dx/dt = alpha*x - beta*x*y (Prey)
  // dy/dt = delta*x*y - gamma*y (Predator)
  let alpha = 1.5
  let beta = 1.0
  let gamma = 3.0
  let delta = 1.0
  let dt = 0.01

  let mut x = 10.0
  let mut y = 5.0

  for _s = 0; _s < 200; _s = _s + 1 {
    let dx = alpha * x - beta * x * y
    let dy = delta * x * y - gamma * y

    x = x + dx * dt
    y = y + dy * dt
  }

  assert_true(x > 0.0)
  assert_true(y > 0.0)
}
