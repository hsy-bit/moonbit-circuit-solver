// Programmatic Netlist Builder API
// MoonBit Circuit Solver Engine

///|
/// Programmatic builder for constructing SPICE Netlists without string parsing.
pub struct NetlistBuilder {
  netlist : Netlist
} derive(Debug, Eq)

///|
/// Creates a new NetlistBuilder with circuit title.
pub fn NetlistBuilder::new(title : String) -> NetlistBuilder {
  NetlistBuilder::{ netlist: Netlist::new(title) }
}

///|
/// Adds a resistor component.
pub fn NetlistBuilder::add_resistor(
  self : NetlistBuilder,
  name : String,
  n1 : String,
  n2 : String,
  r_val : Double,
) -> NetlistBuilder {
  self.netlist.add_component(Resistor(name, n1, n2, r_val))
  self
}

///|
/// Adds a capacitor component.
pub fn NetlistBuilder::add_capacitor(
  self : NetlistBuilder,
  name : String,
  n1 : String,
  n2 : String,
  c_val : Double,
) -> NetlistBuilder {
  self.netlist.add_component(Capacitor(name, n1, n2, c_val, 0.0))
  self
}

///|
/// Adds an inductor component.
pub fn NetlistBuilder::add_inductor(
  self : NetlistBuilder,
  name : String,
  n1 : String,
  n2 : String,
  l_val : Double,
) -> NetlistBuilder {
  self.netlist.add_component(Inductor(name, n1, n2, l_val, 0.0))
  self
}

///|
/// Adds a DC voltage source.
pub fn NetlistBuilder::add_dc_vsource(
  self : NetlistBuilder,
  name : String,
  n1 : String,
  n2 : String,
  v_val : Double,
) -> NetlistBuilder {
  self.netlist.add_component(VSource(name, n1, n2, Dc(v_val)))
  self
}

///|
/// Adds a DC current source.
pub fn NetlistBuilder::add_dc_isource(
  self : NetlistBuilder,
  name : String,
  n1 : String,
  n2 : String,
  i_val : Double,
) -> NetlistBuilder {
  self.netlist.add_component(ISource(name, n1, n2, Dc(i_val)))
  self
}

///|
/// Returns built Netlist.
pub fn NetlistBuilder::build(self : NetlistBuilder) -> Netlist {
  self.netlist
}
