// SPICE Built-in Semiconductor Model Registry
// MoonBit Circuit Solver Engine

///|
/// Registry of standard built-in semiconductor device models.
pub struct ModelRegistry {
  models : Map[String, ModelDef]
} derive(Debug, Eq)

///|
/// Creates a new ModelRegistry populated with standard industry models (1N4148, 1N4001, 2N2222, 2N3904, 2N3906, BS170).
pub fn ModelRegistry::default() -> ModelRegistry {
  let reg = ModelRegistry::{ models: Map([]) }
  reg.models.set("1n4148", ModelDef::{
    name: "1N4148",
    kind: DiodeModel(2.52e-9, 1.752, 0.02585),
  })
  reg.models.set("1n4001", ModelDef::{
    name: "1N4001",
    kind: DiodeModel(14.11e-9, 1.98, 0.02585),
  })
  reg.models.set("2n2222", ModelDef::{
    name: "2N2222",
    kind: BjtModel(14.34e-15, 200.0, 3.0, true),
  })
  reg.models.set("2n3904", ModelDef::{
    name: "2N3904",
    kind: BjtModel(6.734e-15, 300.0, 4.0, true),
  })
  reg.models.set("2n3906", ModelDef::{
    name: "2N3906",
    kind: BjtModel(1.41e-15, 180.0, 4.0, false),
  })
  reg.models.set("bs170", ModelDef::{
    name: "BS170",
    kind: MosfetModel(2.1, 0.235, 0.01, true),
  })
  reg
}

///|
/// Looks up model by name.
pub fn ModelRegistry::lookup(self : ModelRegistry, name : String) -> ModelDef? {
  self.models.get(name.to_lower())
}
