// SPICE Lexer & Tokenizer
// MoonBit Circuit Solver Engine

///|
/// Lexical tokens in SPICE netlist syntax.
pub enum Token {
  TokId(String)
  TokNum(Double)
  TokStr(String)
  TokEquals
  TokComma
  TokDot
  TokLParen
  TokRParen
  TokEol
  TokEof
} derive(Debug, Eq)

///|
/// Converts SPICE SI suffix string (k, u, m, n, p, f, meg, g) to numerical multiplier.
pub fn parse_spice_number(s : String) -> Double {
  let len = s.length()
  if len == 0 {
    return 0.0
  }
  let mut num_end = len
  let lower_s = s.to_lower()

  // Find where numbers end and suffix starts
  for i = 0; i < len; i = i + 1 {
    let c = s[i]
    let is_digit = c >= '0' && c <= '9'
    let is_symbol = c == '.' || c == '+' || c == '-' || c == 'e' || c == 'E'
    if !(is_digit || is_symbol) {
      num_end = i
      break
    }
  }

  let num_str = s[0:num_end].to_owned()
  let mut val = 0.0
  let mut parsed = false
  // Try parsing float prefix
  for i = 0; i < num_str.length(); i = i + 1 {
    let c = num_str[i]
    if c >= '0' && c <= '9' {
      parsed = true
    }
  }

  if !parsed {
    return 0.0
  }

  // Parse double using standard float parser logic
  let mut integer_part = 0.0
  let mut frac_part = 0.0
  let mut frac_div = 1.0
  let mut in_frac = false
  let mut is_neg = false
  let mut idx = 0

  if num_str.length() > 0 && num_str[0] == '-' {
    is_neg = true
    idx = 1
  } else if num_str.length() > 0 && num_str[0] == '+' {
    idx = 1
  }

  while idx < num_str.length() {
    let c = num_str[idx]
    if c == '.' {
      in_frac = true
    } else if c >= '0' && c <= '9' {
      let digit = (c.to_int() - '0'.to_int()).to_double()
      if in_frac {
        frac_div = frac_div * 10.0
        frac_part = frac_part + digit / frac_div
      } else {
        integer_part = integer_part * 10.0 + digit
      }
    }
    idx = idx + 1
  }

  val = integer_part + frac_part
  if is_neg {
    val = -val
  }

  // Process suffix multiplier
  if num_end < len {
    let suf = lower_s[num_end:len].to_owned()
    if suf.has_prefix("meg") {
      val = val * 1000000.0
    } else if suf.has_prefix("k") {
      val = val * 1000.0
    } else if suf.has_prefix("m") {
      val = val * 0.001
    } else if suf.has_prefix("u") {
      val = val * 0.000001
    } else if suf.has_prefix("n") {
      val = val * 0.000000001
    } else if suf.has_prefix("p") {
      val = val * 0.000000000001
    } else if suf.has_prefix("f") {
      val = val * 0.000000000000001
    } else if suf.has_prefix("g") {
      val = val * 1000000000.0
    }
  }

  val
}

///|
/// Tokenizer state for scanning SPICE text stream.
pub struct Lexer {
  input : String
  mut pos : Int
  len : Int
} derive(Debug, Eq)

///|
/// Creates a new Lexer for SPICE text.
pub fn Lexer::new(input : String) -> Lexer {
  let len = input.length()
  Lexer::{ input, pos: 0, len }
}

///|
/// Scans next token from input stream.
pub fn Lexer::next_token(self : Lexer) -> Token {
  while self.pos < self.len {
    let c = self.input[self.pos]
    if c == ' ' || c == '\t' || c == '\r' {
      self.pos = self.pos + 1
    } else if c == '\n' {
      self.pos = self.pos + 1
      return TokEol
    } else if c == ';' || c == '*' {
      // Comment line - skip to EOL
      while self.pos < self.len && self.input[self.pos] != '\n' {
        self.pos = self.pos + 1
      }
    } else if c == '=' {
      self.pos = self.pos + 1
      return TokEquals
    } else if c == ',' {
      self.pos = self.pos + 1
      return TokComma
    } else if c == '.' {
      self.pos = self.pos + 1
      return TokDot
    } else if c == '(' {
      self.pos = self.pos + 1
      return TokLParen
    } else if c == ')' {
      self.pos = self.pos + 1
      return TokRParen
    } else if c == '"' || c == '\'' {
      self.pos = self.pos + 1
      let start = self.pos
      while self.pos < self.len && self.input[self.pos] != c {
        self.pos = self.pos + 1
      }
      let str_val = self.input[start:self.pos].to_owned()
      if self.pos < self.len {
        self.pos = self.pos + 1
      }
      return TokStr(str_val)
    } else {
      let is_digit = c >= '0' && c <= '9'
      let is_sign = (c == '+' || c == '-') &&
        self.pos + 1 < self.len &&
        self.input[self.pos + 1] >= '0' &&
        self.input[self.pos + 1] <= '9'

      let start = self.pos
      while self.pos < self.len {
        let ch = self.input[self.pos]
        if ch == ' ' ||
          ch == '\t' ||
          ch == '\r' ||
          ch == '\n' ||
          ch == '=' ||
          ch == ',' ||
          ch == '(' ||
          ch == ')' {
          break
        }
        self.pos = self.pos + 1
      }
      let tok_str = self.input[start:self.pos].to_owned()
      if is_digit || is_sign {
        let num_val = parse_spice_number(tok_str)
        return TokNum(num_val)
      } else {
        return TokId(tok_str)
      }
    }
  }
  TokEof
}
