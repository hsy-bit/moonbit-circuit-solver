// Transient Simulation - Numerical Integration Schemes
// MoonBit Circuit Solver Engine

///|
/// Integration scheme selection for transient analysis.
pub enum IntegrationScheme {
  BackwardEuler
  Trapezoidal
  Gear2
} derive(Debug, Eq)

///|
/// Capacitor transient companion model (req, ieq).
pub struct CapCompanion {
  req : Double
  ieq : Double
} derive(Debug, Eq)

///|
/// Inductor transient companion model (req, ieq).
pub struct IndCompanion {
  req : Double
  ieq : Double
} derive(Debug, Eq)

///|
/// Returns available integration schemes.
pub fn available_schemes() -> Array[IntegrationScheme] {
  [BackwardEuler, Trapezoidal, Gear2]
}

///|
/// Computes companion equivalent model for Capacitor under given integration scheme and time step dt.
pub fn get_cap_companion(
  scheme : IntegrationScheme,
  c_val : Double,
  dt : Double,
  v_prev : Double,
  i_prev : Double,
) -> CapCompanion {
  match scheme {
    BackwardEuler => {
      let req = dt / c_val
      let ieq = c_val / dt * v_prev
      CapCompanion::{ req, ieq }
    }
    Trapezoidal => {
      let req = dt / (2.0 * c_val)
      let ieq = 2.0 * c_val / dt * v_prev + i_prev
      CapCompanion::{ req, ieq }
    }
    Gear2 => {
      let req = 2.0 * dt / (3.0 * c_val)
      let ieq = 3.0 * c_val / (2.0 * dt) * v_prev
      CapCompanion::{ req, ieq }
    }
  }
}

///|
/// Computes companion equivalent model for Inductor under given integration scheme and time step dt.
pub fn get_ind_companion(
  scheme : IntegrationScheme,
  l_val : Double,
  dt : Double,
  i_prev : Double,
  v_prev : Double,
) -> IndCompanion {
  match scheme {
    BackwardEuler => {
      let req = l_val / dt
      let ieq = i_prev
      IndCompanion::{ req, ieq }
    }
    Trapezoidal => {
      let req = 2.0 * l_val / dt
      let ieq = i_prev + dt / (2.0 * l_val) * v_prev
      IndCompanion::{ req, ieq }
    }
    Gear2 => {
      let req = 3.0 * l_val / (2.0 * dt)
      let ieq = i_prev
      IndCompanion::{ req, ieq }
    }
  }
}
