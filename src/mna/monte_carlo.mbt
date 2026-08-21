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
/// Pseudo-Random Generator (Xorshift32) for reproducible Monte Carlo runs.
pub struct LcgRng {
  mut seed : Int
} derive(Eq, Debug)

///|
/// Creates a new RNG with initial seed.
pub fn LcgRng::new(seed : Int) -> LcgRng {
  let s = if seed == 0 { 123456789 } else { seed }
  { seed: s }
}

///|
/// Generates uniform pseudo-random Double in range [0.0, 1.0).
pub fn LcgRng::next_uniform(self : LcgRng) -> Double {
  let mut x = self.seed
  x = x ^ (x << 13)
  x = x ^ (x >> 17)
  x = x ^ (x << 5)
  if x == 0 {
    x = 123456789
  }
  self.seed = x
  let pos = if x < 0 { -x } else { x }
  let rem = pos % 10000000
  rem.to_double() / 10000000.0
}

///|
/// Generates standard Gaussian distributed random number N(0, 1) using Box-Muller transform.
pub fn LcgRng::next_gaussian(self : LcgRng) -> Double {
  let u1 = self.next_uniform()
  let u2 = self.next_uniform()
  let safe_u1 = if u1 < 1.0e-10 { 1.0e-10 } else { u1 }

  let r = (-2.0 * @math.ln(safe_u1)).sqrt()
  let theta = 2.0 * @math.PI * u2
  r * @math.cos(theta)
}

///|
/// Component Tolerance Variation Specification for Monte Carlo.
pub struct ComponentVariation {
  comp_name : String
  nominal_value : Double
  tolerance_percent : Double // e.g. 5.0 for 5% tolerance
  is_gaussian : Bool // True for 3-sigma Gaussian, False for Uniform
} derive(Eq, Debug)

///|
/// Creates a new component variation spec.
pub fn ComponentVariation::new(
  comp_name : String,
  nominal_value : Double,
  tolerance_percent : Double,
  is_gaussian : Bool,
) -> ComponentVariation {
  { comp_name, nominal_value, tolerance_percent, is_gaussian }
}

///|
/// Single Monte Carlo trial run result.
pub struct MonteCarloRun {
  run_index : Int
  perturbed_values : Map[String, Double]
  node_voltages : Map[String, Double]
} derive(Eq, Debug)

///|
/// Comprehensive Monte Carlo statistical summary report.
pub struct MonteCarloSummary {
  output_node : String
  num_runs : Int
  mean_voltage : Double
  std_dev : Double
  min_voltage : Double
  max_voltage : Double
  p5_voltage : Double
  p50_median_voltage : Double
  p95_voltage : Double
  yield_percent : Double // Percentage within [v_spec_min, v_spec_max]
  runs : Array[MonteCarloRun]
} derive(Eq, Debug)

///|
/// Executes batch Monte Carlo tolerance simulation on netlist.
pub fn run_monte_carlo_dc(
  netlist : @spice.Netlist,
  variations : Array[ComponentVariation],
  num_runs : Int,
  output_node : String,
  spec_min : Double,
  spec_max : Double,
  seed : Int,
) -> MonteCarloSummary {
  let rng = LcgRng::new(seed)
  let runs : Array[MonteCarloRun] = []
  let output_vals : Array[Double] = []

  for r = 0; r < num_runs; r = r + 1 {
    let perturbed_map : Map[String, Double] = Map([])
    let perturbed_comps : Array[@spice.Component] = []

    // Perturb components according to tolerance
    for i = 0; i < netlist.components.length(); i = i + 1 {
      let comp = netlist.components[i]
      match comp {
        @spice.Component::Resistor(name, n1, n2, nom_r) => {
          let mut tol = 0.0
          let mut is_gauss = true
          for v_idx = 0; v_idx < variations.length(); v_idx = v_idx + 1 {
            if variations[v_idx].comp_name == name {
              tol = variations[v_idx].tolerance_percent / 100.0
              is_gauss = variations[v_idx].is_gaussian
              break
            }
          }

          let factor = if tol > 0.0 {
            if is_gauss {
              1.0 + rng.next_gaussian() / 3.0 * tol
            } else {
              1.0 + (rng.next_uniform() * 2.0 - 1.0) * tol
            }
          } else {
            1.0
          }

          let actual_r = nom_r * factor
          perturbed_map[name] = actual_r
          perturbed_comps.push(
            @spice.Component::Resistor(name, n1, n2, actual_r),
          )
        }
        _ => perturbed_comps.push(comp)
      }
    }

    let sub_netlist = @spice.Netlist::{
      title: "MC Run " + r.to_string(),
      components: perturbed_comps,
      models: netlist.models,
      analyses: [@spice.AnalysisCommand::Op],
    }

    let dc_sol = solve_dc_op(sub_netlist)
    let v_out = match dc_sol.node_voltages.get(output_node) {
      Some(v) => v
      None => 0.0
    }
    output_vals.push(v_out)

    runs.push({
      run_index: r,
      perturbed_values: perturbed_map,
      node_voltages: dc_sol.node_voltages,
    })
  }

  // Statistical analytics: Mean and StdDev
  let mut sum_v = 0.0
  let mut min_v = 1.0e10
  let mut max_v = -1.0e10
  let mut in_spec_count = 0

  for i = 0; i < output_vals.length(); i = i + 1 {
    let v = output_vals[i]
    sum_v = sum_v + v
    if v < min_v {
      min_v = v
    }
    if v > max_v {
      max_v = v
    }
    if v >= spec_min && v <= spec_max {
      in_spec_count = in_spec_count + 1
    }
  }

  let mean = sum_v / num_runs.to_double()

  let mut sum_sq_diff = 0.0
  for i = 0; i < output_vals.length(); i = i + 1 {
    let diff = output_vals[i] - mean
    sum_sq_diff = sum_sq_diff + diff * diff
  }
  let std_dev = if num_runs > 1 {
    (sum_sq_diff / (num_runs - 1).to_double()).sqrt()
  } else {
    0.0
  }
  let yield_pct = in_spec_count.to_double() / num_runs.to_double() * 100.0

  // Sort output values for percentiles
  for i = 0; i < output_vals.length() - 1; i = i + 1 {
    for j = i + 1; j < output_vals.length(); j = j + 1 {
      if output_vals[j] < output_vals[i] {
        let tmp = output_vals[i]
        output_vals[i] = output_vals[j]
        output_vals[j] = tmp
      }
    }
  }

  let p5 = output_vals[(output_vals.length().to_double() * 0.05).to_int()]
  let p50 = output_vals[(output_vals.length().to_double() * 0.50).to_int()]
  let p95 = output_vals[(output_vals.length().to_double() * 0.95).to_int()]

  {
    output_node,
    num_runs,
    mean_voltage: mean,
    std_dev,
    min_voltage: min_v,
    max_voltage: max_v,
    p5_voltage: p5,
    p50_median_voltage: p50,
    p95_voltage: p95,
    yield_percent: yield_pct,
    runs,
  }
}
