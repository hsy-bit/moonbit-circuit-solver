// SPICE Netlist AST & Component Definitions
// MoonBit Circuit Solver Engine

///|
/// Independent source waveform type.
pub enum Waveform {
  Dc(Double)
  Pulse(Double, Double, Double, Double, Double, Double, Double) // v1, v2, delay, rise, fall, width, period
  Sine(Double, Double, Double, Double, Double) // offset, amp, freq, delay, damping
  Pwl(Array[(Double, Double)]) // (time, val) pairs
} derive(Debug, Eq)

///|
/// Semiconductor model type.
pub enum ModelKind {
  DiodeModel(Double, Double, Double) // Is, N, Vt
  BjtModel(Double, Double, Double, Bool) // Is, Bf, Br, is_npn
  MosfetModel(Double, Double, Double, Bool) // Vth, Kp, Lambda, is_nmos
} derive(Debug, Eq)

///|
/// Model definition directive (.model).
pub struct ModelDef {
  name : String
  kind : ModelKind
} derive(Debug, Eq)

///|
/// Component types supported in SPICE netlist.
pub enum Component {
  Resistor(String, String, String, Double) // name, node+, node-, R
  Capacitor(String, String, String, Double, Double) // name, node+, node-, C, ic
  Inductor(String, String, String, Double, Double) // name, node+, node-, L, ic
  VSource(String, String, String, Waveform) // name, node+, node-, waveform
  ISource(String, String, String, Waveform) // name, node+, node-, waveform
  Vcvs(String, String, String, String, String, Double) // name, out+, out-, ctrl+, ctrl-, gain
  Vccs(String, String, String, String, String, Double) // name, out+, out-, ctrl+, ctrl-, transconductance
  Cccs(String, String, String, String, Double) // name, out+, out-, vsource_name, gain
  Ccvs(String, String, String, String, Double) // name, out+, out-, vsource_name, transresistance
  Diode(String, String, String, String) // name, node+, node-, model_name
  Bjt(String, String, String, String, String) // name, collector, base, emitter, model_name
  Mosfet(String, String, String, String, String) // name, drain, gate, source, model_name
  OpAmp(String, String, String, String, Double) // name, in+, in-, out, open_loop_gain
} derive(Debug, Eq)

///|
/// Helper constructor for Resistor component.
pub fn Component::create_resistor(
  name : String,
  n1 : String,
  n2 : String,
  val : Double,
) -> Component {
  Resistor(name, n1, n2, val)
}

///|
/// Helper constructor for Capacitor component.
pub fn Component::create_capacitor(
  name : String,
  n1 : String,
  n2 : String,
  val : Double,
) -> Component {
  Capacitor(name, n1, n2, val, 0.0)
}

///|
/// Helper constructor for Inductor component.
pub fn Component::create_inductor(
  name : String,
  n1 : String,
  n2 : String,
  val : Double,
) -> Component {
  Inductor(name, n1, n2, val, 0.0)
}

///|
/// Helper constructor for DC VSource component.
pub fn Component::create_dc_vsource(
  name : String,
  n1 : String,
  n2 : String,
  val : Double,
) -> Component {
  VSource(name, n1, n2, Dc(val))
}

///|
/// Type of simulation analysis requested.
pub enum AnalysisCommand {
  Op // .op
  Dc(String, Double, Double, Double) // .dc src_name start stop step
  Ac(String, Int, Double, Double) // .ac type points fstart fstop
  Tran(Double, Double, Double) // .tran tstep tstop tstart
} derive(Debug, Eq)

///|
/// Represents a complete parsed SPICE circuit netlist.
pub struct Netlist {
  title : String
  components : Array[Component]
  models : Array[ModelDef]
  analyses : Array[AnalysisCommand]
} derive(Debug, Eq)

///|
/// Creates a new empty Netlist.
pub fn Netlist::new(title : String) -> Netlist {
  Netlist::{ title, components: [], models: [], analyses: [] }
}

///|
/// Adds a component to the netlist.
pub fn Netlist::add_component(self : Netlist, comp : Component) -> Unit {
  self.components.push(comp)
}

///|
/// Adds a model definition to the netlist.
pub fn Netlist::add_model(self : Netlist, model : ModelDef) -> Unit {
  self.models.push(model)
}

///|
/// Adds an analysis command to the netlist.
pub fn Netlist::add_analysis(self : Netlist, cmd : AnalysisCommand) -> Unit {
  self.analyses.push(cmd)
}
