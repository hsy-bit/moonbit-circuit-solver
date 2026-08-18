// Transient Simulation - Adaptive Time Step Control (LTE)
// MoonBit Circuit Solver Engine

/// Calculates Local Truncation Error (LTE) and computes next recommended time step dt.
pub fn calculate_next_dt(dt_current : Double, lte : Double, tol : Double, dt_min : Double, dt_max : Double) -> Double {
  if lte <= 0.0 {
    return dt_current * 1.2
  }
  let ratio = tol / lte
  let factor = ratio.pow(0.3333333333333333)
  let mut next_dt = dt_current * factor

  if next_dt > dt_current * 2.0 {
    next_dt = dt_current * 2.0
  }
  if next_dt < dt_current * 0.5 {
    next_dt = dt_current * 0.5
  }
  if next_dt > dt_max {
    next_dt = dt_max
  }
  if next_dt < dt_min {
    next_dt = dt_min
  }
  next_dt
}
