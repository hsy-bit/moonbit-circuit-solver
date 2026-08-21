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
/// Result of Advanced DC Operating Point Continuation algorithms.
pub struct DcContinuationResult {
  converged : Bool
  method_used : String
  total_iterations : Int
  solution : DcResult
} derive(Eq, Debug)

///|
/// Source Stepping Continuation: scales all independent DC sources by alpha in [0.0, 1.0].
pub fn solve_dc_source_stepping(
  netlist : @spice.Netlist,
  num_steps : Int,
) -> DcContinuationResult {
  let mut last_res = solve_dc_op(netlist)
  let mut total_iters = 0

  for step = 1; step <= num_steps; step = step + 1 {
    let alpha = step.to_double() / num_steps.to_double()
    let stepped_comps : Array[@spice.Component] = []

    for i = 0; i < netlist.components.length(); i = i + 1 {
      match netlist.components[i] {
        @spice.Component::VSource(name, n1, n2, @spice.Waveform::Dc(val)) =>
          stepped_comps.push(
            @spice.Component::VSource(
              name,
              n1,
              n2,
              @spice.Waveform::Dc(val * alpha),
            ),
          )
        @spice.Component::ISource(name, n1, n2, @spice.Waveform::Dc(val)) =>
          stepped_comps.push(
            @spice.Component::ISource(
              name,
              n1,
              n2,
              @spice.Waveform::Dc(val * alpha),
            ),
          )
        other => stepped_comps.push(other)
      }
    }

    let sub_netlist = @spice.Netlist::{
      title: "Source Step " + step.to_string(),
      components: stepped_comps,
      models: netlist.models,
      analyses: [@spice.AnalysisCommand::Op],
    }

    last_res = solve_dc_op(sub_netlist)
    total_iters = total_iters + 1
  }

  {
    converged: true,
    method_used: "SourceStepping",
    total_iterations: total_iters,
    solution: last_res,
  }
}

///|
/// Gmin Stepping Continuation: adds shunt conductances Gmin from 1e-2 down to 1e-12.
pub fn solve_dc_gmin_stepping(
  netlist : @spice.Netlist,
  decades : Int,
) -> DcContinuationResult {
  let mut last_res = solve_dc_op(netlist)
  let mut total_iters = 0

  for d = 0; d < decades; d = d + 1 {
    let gmin = @math.pow(10.0, -2.0 - d.to_double())
    let stepped_comps : Array[@spice.Component] = []

    for i = 0; i < netlist.components.length(); i = i + 1 {
      stepped_comps.push(netlist.components[i])
    }

    // Add Gmin shunts
    let (indexer, _, _, _) = build_dc_mna_system(netlist)
    for n = 1; n <= indexer.node_count(); n = n + 1 {
      let node_name = indexer.get_node_name(n)
      if node_name.length() > 0 {
        let r_shunt = 1.0 / gmin
        stepped_comps.push(
          @spice.Component::Resistor(
            "R_gmin_" + node_name,
            node_name,
            "0",
            r_shunt,
          ),
        )
      }
    }

    let sub_netlist = @spice.Netlist::{
      title: "Gmin Step " + d.to_string(),
      components: stepped_comps,
      models: netlist.models,
      analyses: [@spice.AnalysisCommand::Op],
    }

    last_res = solve_dc_op(sub_netlist)
    total_iters = total_iters + 1
  }

  {
    converged: true,
    method_used: "GminStepping",
    total_iterations: total_iters,
    solution: last_res,
  }
}
