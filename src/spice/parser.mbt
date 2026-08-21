// SPICE Netlist Parser
// MoonBit Circuit Solver Engine

///|
/// Splits a line by whitespace into tokens.
pub fn split_line_tokens(line : String) -> Array[String] {
  let tokens : Array[String] = []
  let len = line.length()
  let mut start = 0
  let mut in_tok = false

  for i = 0; i < len; i = i + 1 {
    let c = line[i]
    if c == ' ' || c == '\t' || c == '\r' || c == '\n' || c == ',' {
      if in_tok {
        tokens.push(line[start:i].to_owned())
        in_tok = false
      }
    } else if !in_tok {
      start = i
      in_tok = true
    }
  }
  if in_tok {
    tokens.push(line[start:len].to_owned())
  }
  tokens
}

///|
/// Parses waveform source specifier (DC, PULSE, SINE, PWL).
pub fn parse_waveform_spec(
  tok_arr : Array[String],
  start_idx : Int,
) -> Waveform {
  if start_idx >= tok_arr.length() {
    return Dc(0.0)
  }
  let first = tok_arr[start_idx].to_upper()
  if first.has_prefix("PULSE") && tok_arr.length() >= start_idx + 7 {
    let v1 = parse_spice_number(tok_arr[start_idx + 1])
    let v2 = parse_spice_number(tok_arr[start_idx + 2])
    let td = parse_spice_number(tok_arr[start_idx + 3])
    let tr = parse_spice_number(tok_arr[start_idx + 4])
    let tf = parse_spice_number(tok_arr[start_idx + 5])
    let pw = parse_spice_number(tok_arr[start_idx + 6])
    let per = if tok_arr.length() >= start_idx + 8 {
      parse_spice_number(tok_arr[start_idx + 7])
    } else {
      pw * 2.0
    }
    Pulse(v1, v2, td, tr, tf, pw, per)
  } else if first.has_prefix("SINE") || first.has_prefix("SIN") {
    let offset = if tok_arr.length() >= start_idx + 2 {
      parse_spice_number(tok_arr[start_idx + 1])
    } else {
      0.0
    }
    let amp = if tok_arr.length() >= start_idx + 3 {
      parse_spice_number(tok_arr[start_idx + 2])
    } else {
      1.0
    }
    let freq = if tok_arr.length() >= start_idx + 4 {
      parse_spice_number(tok_arr[start_idx + 3])
    } else {
      1000.0
    }
    let td = if tok_arr.length() >= start_idx + 5 {
      parse_spice_number(tok_arr[start_idx + 4])
    } else {
      0.0
    }
    let damp = if tok_arr.length() >= start_idx + 6 {
      parse_spice_number(tok_arr[start_idx + 5])
    } else {
      0.0
    }
    Sine(offset, amp, freq, td, damp)
  } else if first.has_prefix("PWL") {
    let pts : Array[(Double, Double)] = []
    let mut i = start_idx + 1
    while i + 1 < tok_arr.length() {
      let t = parse_spice_number(tok_arr[i])
      let v = parse_spice_number(tok_arr[i + 1])
      pts.push((t, v))
      i = i + 2
    }
    Pwl(pts)
  } else if (first == "DC" || first.has_prefix("DC")) &&
    tok_arr.length() > start_idx + 1 {
    let v_val = parse_spice_number(tok_arr[start_idx + 1])
    Dc(v_val)
  } else {
    let v_val = parse_spice_number(tok_arr[start_idx])
    Dc(v_val)
  }
}

///|
/// Parses full SPICE netlist string into Netlist AST structure.
pub fn parse_spice_netlist(content : String) -> Netlist {
  let lines = content.split("\n")
  let netlist = Netlist::new("SPICE Circuit")
  let params = ParamTable::new()

  for raw_line in lines {
    let line = raw_line.trim().to_owned()
    if line.length() == 0 || line.has_prefix("*") || line.has_prefix(";") {
      continue
    }

    let tok_arr = split_line_tokens(line)
    if tok_arr.length() == 0 {
      continue
    }

    let first = tok_arr[0]
    let prefix = first[0:1].to_owned().to_upper()

    if first.has_prefix(".") {
      let cmd = first.to_lower()
      if cmd == ".op" {
        netlist.add_analysis(Op)
      } else if cmd == ".dc" && tok_arr.length() >= 5 {
        let src = tok_arr[1]
        let start = parse_spice_number(tok_arr[2])
        let stop = parse_spice_number(tok_arr[3])
        let step = parse_spice_number(tok_arr[4])
        netlist.add_analysis(Dc(src, start, stop, step))
      } else if cmd == ".ac" && tok_arr.length() >= 5 {
        let sweep_type = tok_arr[1]
        let pts = parse_spice_number(tok_arr[2]).to_int()
        let fstart = parse_spice_number(tok_arr[3])
        let fstop = parse_spice_number(tok_arr[4])
        netlist.add_analysis(Ac(sweep_type, pts, fstart, fstop))
      } else if cmd == ".tran" && tok_arr.length() >= 3 {
        let tstep = parse_spice_number(tok_arr[1])
        let tstop = parse_spice_number(tok_arr[2])
        let tstart = if tok_arr.length() >= 4 {
          parse_spice_number(tok_arr[3])
        } else {
          0.0
        }
        netlist.add_analysis(Tran(tstep, tstop, tstart))
      } else if cmd == ".model" && tok_arr.length() >= 3 {
        let name = tok_arr[1]
        let mtype = tok_arr[2].to_lower()
        if mtype == "d" {
          netlist.add_model(ModelDef::{
            name,
            kind: DiodeModel(0.00000000000001, 1.0, 0.02585),
          })
        } else if mtype == "npn" {
          netlist.add_model(ModelDef::{
            name,
            kind: BjtModel(0.00000000000001, 100.0, 1.0, true),
          })
        } else if mtype == "pnp" {
          netlist.add_model(ModelDef::{
            name,
            kind: BjtModel(0.00000000000001, 100.0, 1.0, false),
          })
        } else if mtype == "nmos" {
          netlist.add_model(ModelDef::{
            name,
            kind: MosfetModel(0.7, 0.001, 0.01, true),
          })
        } else if mtype == "pmos" {
          netlist.add_model(ModelDef::{
            name,
            kind: MosfetModel(-0.7, 0.001, 0.01, false),
          })
        }
      } else if cmd == ".param" && tok_arr.length() >= 2 {
        for i = 1; i < tok_arr.length(); i = i + 1 {
          let kv = tok_arr[i].split("=")
          let kv_arr : Array[String] = []
          for s in kv {
            kv_arr.push(s.to_owned())
          }
          if kv_arr.length() == 2 {
            let k = kv_arr[0].trim().to_owned()
            let v = evaluate_expr(kv_arr[1], params)
            params.set(k, v)
          }
        }
      }
    } else if prefix == "R" && tok_arr.length() >= 4 {
      let r_val = parse_spice_number(tok_arr[3])
      netlist.add_component(Resistor(tok_arr[0], tok_arr[1], tok_arr[2], r_val))
    } else if prefix == "C" && tok_arr.length() >= 4 {
      let c_val = parse_spice_number(tok_arr[3])
      let ic = if tok_arr.length() >= 5 {
        parse_spice_number(tok_arr[4])
      } else {
        0.0
      }
      netlist.add_component(
        Capacitor(tok_arr[0], tok_arr[1], tok_arr[2], c_val, ic),
      )
    } else if prefix == "L" && tok_arr.length() >= 4 {
      let l_val = parse_spice_number(tok_arr[3])
      let ic = if tok_arr.length() >= 5 {
        parse_spice_number(tok_arr[4])
      } else {
        0.0
      }
      netlist.add_component(
        Inductor(tok_arr[0], tok_arr[1], tok_arr[2], l_val, ic),
      )
    } else if prefix == "V" && tok_arr.length() >= 4 {
      let wave = parse_waveform_spec(tok_arr, 3)
      netlist.add_component(VSource(tok_arr[0], tok_arr[1], tok_arr[2], wave))
    } else if prefix == "I" && tok_arr.length() >= 4 {
      let wave = parse_waveform_spec(tok_arr, 3)
      netlist.add_component(ISource(tok_arr[0], tok_arr[1], tok_arr[2], wave))
    } else if prefix == "D" && tok_arr.length() >= 4 {
      netlist.add_component(
        Diode(tok_arr[0], tok_arr[1], tok_arr[2], tok_arr[3]),
      )
    } else if prefix == "Q" && tok_arr.length() >= 5 {
      netlist.add_component(
        Bjt(tok_arr[0], tok_arr[1], tok_arr[2], tok_arr[3], tok_arr[4]),
      )
    } else if prefix == "M" && tok_arr.length() >= 5 {
      netlist.add_component(
        Mosfet(tok_arr[0], tok_arr[1], tok_arr[2], tok_arr[3], tok_arr[4]),
      )
    } else if prefix == "E" && tok_arr.length() >= 6 {
      let gain = parse_spice_number(tok_arr[5])
      netlist.add_component(
        Vcvs(tok_arr[0], tok_arr[1], tok_arr[2], tok_arr[3], tok_arr[4], gain),
      )
    } else if prefix == "G" && tok_arr.length() >= 6 {
      let gm = parse_spice_number(tok_arr[5])
      netlist.add_component(
        Vccs(tok_arr[0], tok_arr[1], tok_arr[2], tok_arr[3], tok_arr[4], gm),
      )
    } else if prefix == "F" && tok_arr.length() >= 5 {
      let gain = parse_spice_number(tok_arr[4])
      netlist.add_component(
        Cccs(tok_arr[0], tok_arr[1], tok_arr[2], tok_arr[3], gain),
      )
    } else if prefix == "H" && tok_arr.length() >= 5 {
      let rm = parse_spice_number(tok_arr[4])
      netlist.add_component(
        Ccvs(tok_arr[0], tok_arr[1], tok_arr[2], tok_arr[3], rm),
      )
    } else if prefix == "X" && tok_arr.length() >= 5 {
      let gain = 100000.0
      netlist.add_component(
        OpAmp(tok_arr[0], tok_arr[1], tok_arr[2], tok_arr[3], gain),
      )
    }
  }

  netlist
}
