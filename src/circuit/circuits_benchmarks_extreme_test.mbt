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
test "Extreme Benchmark 01: 500-Node 1D Stiff Transmission Grid Direct vs Iterative" {
  let n = 500
  let builder = @linalg.SparseBuilder::new(n, n)
  for i in 0..<n {
    builder.add_entry(i, i, 4.0)
    if i > 0 {
      builder.add_entry(i, i - 1, -1.5)
    }
    if i + 1 < n {
      builder.add_entry(i, i + 1, -1.5)
    }
  }
  let csr = builder.to_csr()
  assert_true(csr.rows == 500)

  let b = @linalg.Vector::zeros(n)
  b.set(0, 10.0) // 10V boundary excitation
  b.set(n - 1, 0.0)

  let bicg = @linalg.bicgstab_solve(csr, b, 200, 1.0e-6)
  assert_true(bicg.converged)
  assert_true(bicg.solution.length() == 500)
  assert_true(bicg.solution.get(0) > 0.0)
}

///|
test "Extreme Benchmark 02: 900-Node 2D Mesh Poisson Grid (30x30)" {
  let m = 30
  let total_nodes = m * m // 900 nodes
  let builder = @linalg.SparseBuilder::new(total_nodes, total_nodes)

  for r in 0..<m {
    for c in 0..<m {
      let idx = r * m + c
      builder.add_entry(idx, idx, 4.0)
      if c > 0 {
        builder.add_entry(idx, idx - 1, -1.0)
      }
      if c + 1 < m {
        builder.add_entry(idx, idx + 1, -1.0)
      }
      if r > 0 {
        builder.add_entry(idx, idx - m, -1.0)
      }
      if r + 1 < m {
        builder.add_entry(idx, idx + m, -1.0)
      }
    }
  }

  let csr = builder.to_csr()
  assert_true(csr.rows == 900)
  assert_true(csr.cols == 900)

  let b = @linalg.Vector::zeros(total_nodes)
  b.set(0, 5.0) // Injection at (0, 0)
  b.set(total_nodes - 1, -5.0) // Sink at (29, 29)

  let bicg = @linalg.bicgstab_solve(csr, b, 150, 1.0e-5)
  assert_true(bicg.converged)
  assert_true(bicg.solution.get(0) > 0.0)
}

///|
test "Extreme Benchmark 03: 1000-Node Pentadiagonal Stiff High-Order MNA Mesh" {
  let n = 1000
  let builder = @linalg.SparseBuilder::new(n, n)
  for i in 0..<n {
    builder.add_entry(i, i, 6.0)
    if i > 0 {
      builder.add_entry(i, i - 1, -2.0)
    }
    if i + 1 < n {
      builder.add_entry(i, i + 1, -2.0)
    }
    if i > 1 {
      builder.add_entry(i, i - 2, 0.5)
    }
    if i + 2 < n {
      builder.add_entry(i, i + 2, 0.5)
    }
  }
  let csr = builder.to_csr()
  assert_true(csr.rows == 1000)

  let b = @linalg.Vector::zeros(n)
  for i in 0..<n {
    b.set(i, 1.0)
  }

  let sol = @linalg.bicgstab_solve(csr, b, 200, 1.0e-6)
  assert_true(sol.converged)
}

///|
test "Extreme Benchmark 04: Reverse Cuthill-McKee Bandwidth Reduction on 200-Node Matrix" {
  let n = 200
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
  let rcm = @linalg.reverse_cuthill_mckee(csr)
  let band = @linalg.compute_matrix_bandwidth(csr, rcm)

  assert_true(rcm.length() == n)
  assert_true(band <= 2)
}

///|
test "Extreme Benchmark 05: Complex Linear System LU Decomposition (100x100)" {
  let n = 100
  let c_mat = @linalg.ComplexMatrix::zeros(n, n)
  for i in 0..<n {
    c_mat.set(i, i, @linalg.Complex::new(4.0, 1.0))
    if i > 0 {
      c_mat.set(i, i - 1, @linalg.Complex::new(-1.0, 0.2))
    }
    if i + 1 < n {
      c_mat.set(i, i + 1, @linalg.Complex::new(-1.0, -0.2))
    }
  }

  let b_c = @linalg.ComplexVector::zeros(n)
  for i in 0..<n {
    b_c.set(i, @linalg.Complex::new(1.0, 0.0))
  }

  let lu = @linalg.ComplexLuDecomposition::decompose(c_mat)
  let x_c = lu.solve(b_c)
  assert_true(x_c.length() == n)
  assert_true(x_c.get(0).re > 0.0)
}
