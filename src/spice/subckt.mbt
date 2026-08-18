// SPICE Subcircuit Expansion Engine
// MoonBit Circuit Solver Engine

///|
/// Represents a SPICE .subckt definition.
pub struct SubcircuitDef {
  name : String
  ports : Array[String]
  components : Array[Component]
} derive(Debug, Eq)

///|
/// Creates a new SubcircuitDef.
pub fn SubcircuitDef::new(
  name : String,
  ports : Array[String],
  components : Array[Component],
) -> SubcircuitDef {
  SubcircuitDef::{ name, ports, components }
}

///|
/// Table of defined subcircuits.
pub struct SubcircuitTable {
  defs : Map[String, SubcircuitDef]
} derive(Debug, Eq)

///|
/// Creates a new SubcircuitTable.
pub fn SubcircuitTable::new() -> SubcircuitTable {
  SubcircuitTable::{ defs: Map([]) }
}

///|
/// Registers a subcircuit definition.
pub fn SubcircuitTable::register(
  self : SubcircuitTable,
  sub : SubcircuitDef,
) -> Unit {
  self.defs.set(sub.name.to_lower(), sub)
}

///|
/// Expands subcircuit instance X into flattened components.
pub fn expand_subcircuit_instance(
  inst_name : String,
  port_connections : Array[String],
  sub_def : SubcircuitDef,
) -> Array[Component] {
  let expanded : Array[Component] = []
  let port_map : Map[String, String] = Map([])

  let num_ports = sub_def.ports.length()
  for i = 0; i < num_ports; i = i + 1 {
    if i < port_connections.length() {
      port_map.set(sub_def.ports[i].to_lower(), port_connections[i])
    }
  }

  // Rename internal nodes with instance prefix
  for comp in sub_def.components {
    match comp {
      Resistor(r_name, n1, n2, val) => {
        let n1_mapped = match port_map.get(n1.to_lower()) {
          Some(m) => m
          None => inst_name + "_" + n1
        }
        let n2_mapped = match port_map.get(n2.to_lower()) {
          Some(m) => m
          None => inst_name + "_" + n2
        }
        expanded.push(
          Resistor(inst_name + "_" + r_name, n1_mapped, n2_mapped, val),
        )
      }
      Capacitor(c_name, n1, n2, val, ic) => {
        let n1_mapped = match port_map.get(n1.to_lower()) {
          Some(m) => m
          None => inst_name + "_" + n1
        }
        let n2_mapped = match port_map.get(n2.to_lower()) {
          Some(m) => m
          None => inst_name + "_" + n2
        }
        expanded.push(
          Capacitor(inst_name + "_" + c_name, n1_mapped, n2_mapped, val, ic),
        )
      }
      _ => expanded.push(comp)
    }
  }

  expanded
}
