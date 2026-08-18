// SPICE Parameter & Math Expression Evaluator
// MoonBit Circuit Solver Engine

/// Parameter table storing key-value pairs for .param directives.
pub struct ParamTable {
  table : Map[String, Double]
} derive(Debug, Eq)

/// Creates a new parameter table.
pub fn ParamTable::new() -> ParamTable {
  ParamTable::{ table: Map::new() }
}

/// Sets a parameter value.
pub fn ParamTable::set(self : ParamTable, key : String, val : Double) -> Unit {
  self.table.set(key.to_lower(), val)
}

/// Gets a parameter value, or returns default value if missing.
pub fn ParamTable::get(self : ParamTable, key : String, default_val : Double) -> Double {
  match self.table.get(key.to_lower()) {
    Some(v) => v
    None => default_val
  }
}

/// Simple expression evaluator for numeric or variable references.
pub fn evaluate_expr(expr_str : String, params : ParamTable) -> Double {
  let trimmed = expr_str.trim_space()
  if trimmed.length() == 0 {
    return 0.0
  }
  let first_char = trimmed[0]
  if (first_char >= '0' && first_char <= '9') || first_char == '+' || first_char == '-' {
    return parse_spice_number(trimmed)
  }
  params.get(trimmed, 0.0)
}
