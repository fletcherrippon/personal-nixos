//! Parse theme.conf into ordered (name, value) pairs. Each value's type is
//! inferred from its syntax.

use crate::value::Value;

/// Parse config text into ordered (name, value) pairs.
pub fn parse(text: &str) -> Vec<(String, Value)> {
    text.lines().filter_map(parse_line).collect()
}

fn parse_line(line: &str) -> Option<(String, Value)> {
    let line = line.trim();
    if line.is_empty() || line.starts_with('#') {
        return None;
    }
    let (k, v) = line.split_once('=')?;
    Some((k.trim().to_string(), parse_value(v.trim())))
}

fn parse_value(s: &str) -> Value {
    if let Some(hex) = s.strip_prefix('#') {
        return match hex.split_once('@') {
            Some((h, a)) => {
                Value::ColorA(parse_hex(h), a.trim().trim_end_matches('%').parse().unwrap_or(100))
            }
            None => Value::Color(parse_hex(hex)),
        };
    }
    // length: number + unit (check rem before em so "2rem" isn't read as "em")
    for unit in ["px", "rem", "em", "%", "deg"] {
        if let Some(num) = s.strip_suffix(unit) {
            if let Ok(n) = num.trim().parse::<f64>() {
                return Value::Len(n, unit.to_string());
            }
        }
    }
    if let Ok(n) = s.parse::<f64>() {
        return Value::Num(n);
    }
    Value::Text(s.to_string())
}

fn parse_hex(h: &str) -> [u8; 3] {
    let n = u32::from_str_radix(h.get(..6).unwrap_or(h), 16).unwrap_or(0);
    [(n >> 16) as u8, (n >> 8) as u8, n as u8]
}
