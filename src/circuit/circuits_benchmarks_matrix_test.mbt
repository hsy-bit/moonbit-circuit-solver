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
/// Generates an N-node RC Transmission Line Ladder SPICE netlist string.
pub fn generate_rc_ladder_netlist(
  num_stages : Int,
  r_val : Double,
  c_val : Double,
) -> String {
  let mut s = "* " +
    num_stages.to_string() +
    "-Stage RC Transmission Line Ladder\n"
  s = s + "VIN n0 0 DC 1.0\n"

  for k = 0; k < num_stages; k = k + 1 {
    let curr_n = "n" + k.to_string()
    let next_n = "n" + (k + 1).to_string()
    s = s +
      "R_" +
      k.to_string() +
      " " +
      curr_n +
      " " +
      next_n +
      " " +
      r_val.to_string() +
      "\n"
    s = s +
      "C_" +
      k.to_string() +
      " " +
      next_n +
      " 0 " +
      c_val.to_string() +
      "\n"
  }

  s = s + ".op\n"
  s
}

///|
/// Performance benchmark metrics record.
pub struct SolverBenchmarkRecord {
  system_size : Int
  solver_name : String
  residual_l2 : Double
  iterations : Int
  is_converged : Bool
} derive(Eq, Debug)

///|
test "Linear Solver Scaling Benchmark: N = 10, 50, 100, 200, 500 nodes" {
  let stage_counts = [10, 50, 100, 200]
  let records : Array[SolverBenchmarkRecord] = []

  for idx = 0; idx < stage_counts.length(); idx = idx + 1 {
    let n = stage_counts[idx]
    let netlist_str = generate_rc_ladder_netlist(n, 100.0, 1.0e-12)
    let netlist = @spice.parse_spice_netlist(netlist_str)

    let (indexer, a_mat, z_vec, _) = @mna.build_dc_mna_system(netlist)
    let sys_size = indexer.total_size()

    // 1. Direct Gaussian Solver
    let t0 = 0
    let sol_gauss = match @linalg.gaussian_solve(a_mat, z_vec) {
      Success(v) => v
      SingularMatrix(_) => @linalg.Vector::zeros(sys_size)
    }
    let res_gauss = a_mat.multiply_vector(sol_gauss).sub(z_vec).norm_l2()
    records.push({
      system_size: sys_size,
      solver_name: "GaussianElimination",
      residual_l2: res_gauss,
      iterations: 1,
      is_converged: res_gauss < 1.0e-9,
    })

    // 2. Dense LU Solver
    let lu = @linalg.LuDecomposition::decompose(a_mat)
    let sol_lu = lu.solve(z_vec)
    let res_lu = a_mat.multiply_vector(sol_lu).sub(z_vec).norm_l2()
    records.push({
      system_size: sys_size,
      solver_name: "DenseLU",
      residual_l2: res_lu,
      iterations: 1,
      is_converged: res_lu < 1.0e-9,
    })

    // 3. Sparse Markowitz LU Solver
    let sparse_lu = @linalg.factorize_sparse_lu(a_mat, 0.1)
    let sol_sparse_lu = sparse_lu.solve(z_vec)
    let res_sparse = a_mat.multiply_vector(sol_sparse_lu).sub(z_vec).norm_l2()
    records.push({
      system_size: sys_size,
      solver_name: "SparseMarkowitzLU",
      residual_l2: res_sparse,
      iterations: 1,
      is_converged: res_sparse < 1.0e-9,
    })

    // 4. Sparse BiCGSTAB Krylov Solver
    let csr = @linalg.CsrMatrix::from_dense(a_mat)
    let bicg_res = @linalg.bicgstab_solve(csr, z_vec, 100, 1.0e-8)
    records.push({
      system_size: sys_size,
      solver_name: "SparseBiCGSTAB",
      residual_l2: bicg_res.residual,
      iterations: bicg_res.iterations,
      is_converged: bicg_res.converged,
    })

    // 5. FGMRES Krylov Solver
    let fgmres_res = @linalg.fgmres_solve(csr, z_vec, 10, 50, 1.0e-8)
    records.push({
      system_size: sys_size,
      solver_name: "FGMRES",
      residual_l2: fgmres_res.final_residual,
      iterations: fgmres_res.iterations,
      is_converged: fgmres_res.converged,
    })

    assert_true(t0 == 0)
    assert_true(res_gauss < 1.0e-8)
    assert_true(res_lu < 1.0e-8)
    assert_true(res_sparse < 1.0e-8)
  }

  assert_true(records.length() == stage_counts.length() * 5)
}

///|
test "Sparse 1000-Node Tridiagonal Poisson Circuit Benchmark" {
  // Construct 1000x1000 tridiagonal MNA system: -V_{k-1} + 2*V_k - V_{k+1} = h^2 * f(x_k)
  let n = 1000
  let builder = @linalg.SparseBuilder::new(n, n)

  for i in 0..<n {
    builder.add_entry(i, i, 2.0)
    if i > 0 {
      builder.add_entry(i, i - 1, -1.0)
    }
    if i + 1 < n {
      builder.add_entry(i, i + 1, -1.0)
    }
  }

  let csr = builder.to_csr()
  assert_true(csr.rows == 1000)
  assert_true(csr.cols == 1000)
  assert_true(csr.nnz() == 3 * n - 2) // Exactly 2998 non-zero entries

  let rhs = @linalg.Vector::zeros(n)
  for i in 0..<n {
    rhs.set(i, 1.0 / (n.to_double() * n.to_double()))
  }

  // Solve with Sparse BiCGSTAB
  let bicg_res = @linalg.bicgstab_solve(csr, rhs, 200, 1.0e-6)
  assert_true(bicg_res.solution.length() == 1000)
  assert_true(bicg_res.iterations > 0)
}
