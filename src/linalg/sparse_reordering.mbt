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
/// Reverse Cuthill-McKee (RCM) algorithm for matrix bandwidth and profile reduction.
pub fn reverse_cuthill_mckee(adj_matrix : CsrMatrix) -> Array[Int] {
  let n = adj_matrix.rows
  let degrees = Array::make(n, 0)
  for i in 0..<n {
    let start = adj_matrix.row_ptr[i]
    let end = adj_matrix.row_ptr[i + 1]
    degrees[i] = end - start
  }

  let visited = Array::make(n, false)
  let order : Array[Int] = []

  // Find starting node with minimum degree
  for comp = 0; comp < n; comp = comp + 1 {
    let mut min_deg = 9999999
    let mut start_node = -1
    for i in 0..<n {
      if !visited[i] && degrees[i] < min_deg {
        min_deg = degrees[i]
        start_node = i
      }
    }

    if start_node >= 0 {
      let queue : Array[Int] = [start_node]
      visited[start_node] = true

      let mut head = 0
      while head < queue.length() {
        let curr = queue[head]
        head = head + 1
        order.push(curr)

        // Find unvisited neighbors and sort by increasing degree
        let row_start = adj_matrix.row_ptr[curr]
        let row_end = adj_matrix.row_ptr[curr + 1]
        let neighbors : Array[Int] = []

        for p = row_start; p < row_end; p = p + 1 {
          let nbr = adj_matrix.col_ind[p]
          if !visited[nbr] {
            visited[nbr] = true
            neighbors.push(nbr)
          }
        }

        // Simple insertion sort on neighbors by degree
        for i = 0; i < neighbors.length(); i = i + 1 {
          for j = i + 1; j < neighbors.length(); j = j + 1 {
            if degrees[neighbors[j]] < degrees[neighbors[i]] {
              let tmp = neighbors[i]
              neighbors[i] = neighbors[j]
              neighbors[j] = tmp
            }
          }
          queue.push(neighbors[i])
        }
      }
    }
  }

  // Reverse the order array for RCM
  let rcm_order = Array::make(n, 0)
  for i in 0..<n {
    rcm_order[i] = order[n - 1 - i]
  }

  rcm_order
}

///|
/// Computes the bandwidth of a CSR matrix under a given permutation.
pub fn compute_matrix_bandwidth(mat : CsrMatrix, perm : Array[Int]) -> Int {
  let n = mat.rows
  let inv_perm = Array::make(n, 0)
  for i in 0..<n {
    inv_perm[perm[i]] = i
  }

  let mut max_band = 0
  for i in 0..<n {
    let pi = inv_perm[i]
    let row_start = mat.row_ptr[i]
    let row_end = mat.row_ptr[i + 1]
    for p = row_start; p < row_end; p = p + 1 {
      let j = mat.col_ind[p]
      let pj = inv_perm[j]
      let diff = if pi >= pj { pi - pj } else { pj - pi }
      if diff > max_band {
        max_band = diff
      }
    }
  }

  max_band
}

///|
/// Solves block tridiagonal system: A_i * X_{i-1} + B_i * X_i + C_i * X_{i+1} = D_i.
pub fn solve_scalar_tridiagonal(
  a_sub : Array[Double],
  b_diag : Array[Double],
  c_super : Array[Double],
  d_rhs : Array[Double],
) -> Array[Double] {
  let n = b_diag.length()
  let c_prime = Array::make(n, 0.0)
  let d_prime = Array::make(n, 0.0)
  let x_sol = Array::make(n, 0.0)

  // Forward sweep
  c_prime[0] = c_super[0] / b_diag[0]
  d_prime[0] = d_rhs[0] / b_diag[0]

  for i = 1; i < n; i = i + 1 {
    let denom = b_diag[i] - a_sub[i - 1] * c_prime[i - 1]
    let safe_denom = if denom.abs() > 1.0e-15 { denom } else { 1.0e-15 }
    if i < n - 1 {
      c_prime[i] = c_super[i] / safe_denom
    }
    d_prime[i] = (d_rhs[i] - a_sub[i - 1] * d_prime[i - 1]) / safe_denom
  }

  // Back substitution
  x_sol[n - 1] = d_prime[n - 1]
  for i = n - 2; i >= 0; i = i - 1 {
    x_sol[i] = d_prime[i] - c_prime[i] * x_sol[i + 1]
  }

  x_sol
}
