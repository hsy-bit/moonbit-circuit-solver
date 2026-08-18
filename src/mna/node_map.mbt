// Modified Nodal Analysis - Node Indexing & Index Mapping
// MoonBit Circuit Solver Engine

/// Maps node names (strings) to MNA matrix index integers.
pub struct NodeIndexer {
  node_to_idx : Map[String, Int]
  idx_to_node : Map[Int, String]
  mut num_nodes : Int
  mut num_aux_vars : Int
} derive(Debug, Eq)

/// Creates a new NodeIndexer.
pub fn NodeIndexer::new() -> NodeIndexer {
  let map1 : Map[String, Int] = Map::new()
  let map2 : Map[Int, String] = Map::new()
  map1.set("0", -1)
  map1.set("gnd", -1)
  map1.set("GND", -1)
  NodeIndexer::{ node_to_idx: map1, idx_to_node: map2, num_nodes: 0, num_aux_vars: 0 }
}

/// Gets 0-based index for node name, allocating a new node index if needed.
pub fn NodeIndexer::get_or_add_node(self : NodeIndexer, name : String) -> Int {
  let lower_name = name.to_lower()
  if lower_name == "0" || lower_name == "gnd" {
    return -1
  }
  match self.node_to_idx.get(lower_name) {
    Some(idx) => idx
    None => {
      let idx = self.num_nodes
      self.node_to_idx.set(lower_name, idx)
      self.idx_to_node.set(idx, name)
      self.num_nodes = self.num_nodes + 1
      idx
    }
  }
}

/// Allocates an auxiliary variable index (e.g., for voltage source or inductor branch current).
pub fn NodeIndexer::allocate_aux_var(self : NodeIndexer, var_name : String) -> Int {
  let aux_idx = self.num_nodes + self.num_aux_vars
  self.idx_to_node.set(aux_idx, var_name)
  self.num_aux_vars = self.num_aux_vars + 1
  aux_idx
}

/// Total dimension of the MNA matrix equation (A matrix size).
pub fn NodeIndexer::total_size(self : NodeIndexer) -> Int {
  self.num_nodes + self.num_aux_vars
}

/// Number of node voltage variables.
pub fn NodeIndexer::node_count(self : NodeIndexer) -> Int {
  self.num_nodes
}

/// Gets node name from index.
pub fn NodeIndexer::get_node_name(self : NodeIndexer, idx : Int) -> String {
  match self.idx_to_node.get(idx) {
    Some(name) => name
    None => "Node_\{idx}"
  }
}
