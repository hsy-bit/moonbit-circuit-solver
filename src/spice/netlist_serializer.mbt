// SPICE AST Serializer & Netlist Formatter
// MoonBit Circuit Solver Engine

///|
/// Serializes waveform back to SPICE text.
pub fn serialize_waveform(wave : Waveform) -> String {
  match wave {
    Dc(v) => v.to_string()
    Pulse(v1, v2, td, tr, tf, pw, per) =>
      "PULSE(" +
      v1.to_string() +
      " " +
      v2.to_string() +
      " " +
      td.to_string() +
      " " +
      tr.to_string() +
      " " +
      tf.to_string() +
      " " +
      pw.to_string() +
      " " +
      per.to_string() +
      ")"
    Sine(offset, amp, freq, td, damp) =>
      "SINE(" +
      offset.to_string() +
      " " +
      amp.to_string() +
      " " +
      freq.to_string() +
      " " +
      td.to_string() +
      " " +
      damp.to_string() +
      ")"
    Pwl(pts) => {
      let mut sb = "PWL("
      for i = 0; i < pts.length(); i = i + 1 {
        if i > 0 {
          sb = sb + " "
        }
        sb = sb + pts[i].0.to_string() + " " + pts[i].1.to_string()
      }
      sb + ")"
    }
  }
}

///|
/// Serializes component back to SPICE line string.
pub fn serialize_component(comp : Component) -> String {
  match comp {
    Resistor(name, n1, n2, r) =>
      name + " " + n1 + " " + n2 + " " + r.to_string()
    Capacitor(name, n1, n2, c, _) =>
      name + " " + n1 + " " + n2 + " " + c.to_string()
    Inductor(name, n1, n2, l, _) =>
      name + " " + n1 + " " + n2 + " " + l.to_string()
    VSource(name, n1, n2, wave) =>
      name + " " + n1 + " " + n2 + " " + serialize_waveform(wave)
    ISource(name, n1, n2, wave) =>
      name + " " + n1 + " " + n2 + " " + serialize_waveform(wave)
    Diode(name, n1, n2, m) => name + " " + n1 + " " + n2 + " " + m
    Bjt(name, c, b, e, m) => name + " " + c + " " + b + " " + e + " " + m
    Mosfet(name, d, g, s, m) => name + " " + d + " " + g + " " + s + " " + m
    Vcvs(name, n1, n2, nc1, nc2, g) =>
      name + " " + n1 + " " + n2 + " " + nc1 + " " + nc2 + " " + g.to_string()
    Vccs(name, n1, n2, nc1, nc2, gm) =>
      name + " " + n1 + " " + n2 + " " + nc1 + " " + nc2 + " " + gm.to_string()
    Cccs(name, n1, n2, vsrc, g) =>
      name + " " + n1 + " " + n2 + " " + vsrc + " " + g.to_string()
    Ccvs(name, n1, n2, vsrc, rm) =>
      name + " " + n1 + " " + n2 + " " + vsrc + " " + rm.to_string()
    OpAmp(name, np, nn, out, gain) =>
      name + " " + np + " " + nn + " " + out + " OPAMP gain=" + gain.to_string()
  }
}

///|
/// Serializes complete Netlist AST to standard SPICE circuit text.
pub fn serialize_netlist(netlist : Netlist) -> String {
  let mut sb = "* " + netlist.title + "\n"
  for comp in netlist.components {
    sb = sb + serialize_component(comp) + "\n"
  }
  for cmd in netlist.analyses {
    match cmd {
      Op => sb = sb + ".op\n"
      Dc(src, start, stop, step) =>
        sb = sb +
          ".dc " +
          src +
          " " +
          start.to_string() +
          " " +
          stop.to_string() +
          " " +
          step.to_string() +
          "\n"
      Ac(t, pts, f1, f2) =>
        sb = sb +
          ".ac " +
          t +
          " " +
          pts.to_string() +
          " " +
          f1.to_string() +
          " " +
          f2.to_string() +
          "\n"
      Tran(tstep, tstop, tstart) =>
        sb = sb +
          ".tran " +
          tstep.to_string() +
          " " +
          tstop.to_string() +
          " " +
          tstart.to_string() +
          "\n"
    }
  }
  sb = sb + ".end\n"
  sb
}
