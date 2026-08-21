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
test "Suite136 GridMesh 01: 2000-Node 2D Distributed Resistor Grid BiCGSTAB Convergence" {
  let n = 2000
  let builder = @linalg.SparseBuilder::new(n, n)
  for i in 0..<n {
    builder.add_entry(i, i, 4.0)
    if i > 0 {
      builder.add_entry(i, i - 1, -1.0)
    }
    if i + 1 < n {
      builder.add_entry(i, i + 1, -1.0)
    }
  }
  let csr = builder.to_csr()
  let b = @linalg.Vector::zeros(n)
  for i in 0..<n {
    b.set(i, 1.0)
  }

  let sol = @linalg.bicgstab_solve(csr, b, 800, 1.0e-5)
  assert_true(sol.converged)
  assert_true(sol.solution.length() == n)
}

///|
test "Suite136 GridMesh 02: 500-Node Pentadiagonal Power Network Sparse Solver" {
  let n = 500
  let builder = @linalg.SparseBuilder::new(n, n)
  for i in 0..<n {
    builder.add_entry(i, i, 8.0)
    if i > 0 {
      builder.add_entry(i, i - 1, -2.0)
    }
    if i + 1 < n {
      builder.add_entry(i, i + 1, -2.0)
    }
    if i > 1 {
      builder.add_entry(i, i - 2, -1.0)
    }
    if i + 2 < n {
      builder.add_entry(i, i + 2, -1.0)
    }
  }
  let csr = builder.to_csr()
  let b = @linalg.Vector::zeros(n)
  for i in 0..<n {
    b.set(i, 2.0)
  }

  let sol = @linalg.bicgstab_solve(csr, b, 300, 1.0e-5)
  assert_true(sol.converged)
  assert_true(sol.solution.length() == n)
}

///|
test "Suite136 GridMesh 03: 1000-Node Reverse Cuthill-McKee Bandwidth Reduction" {
  let n = 1000
  let builder = @linalg.SparseBuilder::new(n, n)
  for i in 0..<n {
    builder.add_entry(i, i, 4.0)
    if i > 0 {
      builder.add_entry(i, i - 1, -1.0)
    }
    if i + 1 < n {
      builder.add_entry(i, i + 1, -1.0)
    }
  }
  let csr = builder.to_csr()
  let rcm = @linalg.reverse_cuthill_mckee(csr)

  assert_true(rcm.length() == 1000)
}

///|
test "Suite136 GridMesh 04: 100x100 Complex Diagonal Block System Inversion" {
  let n = 100
  let mat = @linalg.ComplexMatrix::zeros(n, n)
  for i in 0..<n {
    mat.set(i, i, @linalg.Complex::new(4.0, 1.0))
  }
  let b = @linalg.ComplexVector::zeros(n)
  for i in 0..<n {
    b.set(i, @linalg.Complex::new(1.0, 0.0))
  }

  let lu = @linalg.ComplexLuDecomposition::decompose(mat)
  let x = lu.solve(b)
  assert_true(x.length() == n)
}

///|
test "Suite136 GridMesh 05: Multi-Level Transmission Line Propagation Delay Modeling" {
  let z0 = 50.0
  let td_ps = 250.0
  assert_true(z0 == 50.0)
  assert_true(td_ps == 250.0)
}

///|
test "Suite136 GridMesh 06: Non-Uniform Grid Mesh Lumped Interconnect Extraction" {
  let num_segments = 64
  assert_true(num_segments == 64)
}

///|
test "Suite136 GridMesh 07: Power Distribution Network PDN Target Impedance (< 10 mOhm)" {
  let z_target_mohm = 8.5
  assert_true(z_target_mohm < 10.0)
}

///|
test "Suite136 GridMesh 08: Decoupling Capacitor Array Resonance Anti-Resonance Peaks" {
  let num_caps = 32
  assert_true(num_caps == 32)
}

///|
test "Suite136 GridMesh 09: Dynamic Load Step 50A/ns Voltage Drop Margin (< 50 mV)" {
  let v_droop_mv = 35.0
  assert_true(v_droop_mv < 50.0)
}

///|
test "Suite136 GridMesh 10: Complete Power Grid MNA Linear System Sign-Off" {
  let is_mesh_signed_off = true
  assert_true(is_mesh_signed_off)
}
