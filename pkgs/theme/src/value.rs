//! The typed theme value and how it renders for each target tool.

#[derive(Clone)]
pub enum Value {
    Color([u8; 3]),
    ColorA([u8; 3], u32), // rgb + alpha percent (0..100)
    Len(f64, String),     // number + unit (px/em/rem/%/deg)
    Num(f64),
    Text(String),
}

#[derive(Clone, Copy)]
pub enum Format {
    Scss,
    GtkCss,
    Hypr,
    Fuzzel,
    Mako,
}

impl Value {
    /// Render this value for one target tool.
    pub fn render(&self, f: Format) -> String {
        use Format::*;
        match self {
            Value::Color(c) => match f {
                Scss | GtkCss | Mako => format!("#{}", hexstr(c)),
                Hypr => format!("rgb({})", hexstr(c)),
                Fuzzel => format!("{}ff", hexstr(c)),
            },
            Value::ColorA(c, a) => match f {
                Scss | GtkCss => {
                    let frac = if *a >= 100 { "1".to_string() } else { format!("0.{:02}", a) };
                    format!("rgba({}, {}, {}, {})", c[0], c[1], c[2], frac)
                }
                Hypr => format!("rgba({}{:02x})", hexstr(c), a * 255 / 100),
                Fuzzel => format!("{}{:02x}", hexstr(c), a * 255 / 100),
                Mako => format!("#{}", hexstr(c)), // mako = solid, drop alpha
            },
            Value::Len(n, unit) => match f {
                // GTK CSS keeps the unit; the rest want a raw px number.
                Scss | GtkCss => format!("{}{}", numstr(*n), unit),
                _ => numstr(if unit == "em" || unit == "rem" { n * 16.0 } else { *n }),
            },
            Value::Num(n) => numstr(*n),
            Value::Text(s) => match f {
                Scss => format!("\"{s}\""),
                _ => s.clone(),
            },
        }
    }

    pub fn is_color(&self) -> bool {
        matches!(self, Value::Color(_) | Value::ColorA(_, _))
    }

    /// `#rrggbb` form of any colour value (used for the wallpaper palette).
    pub fn hex(&self) -> Option<String> {
        match self {
            Value::Color(c) | Value::ColorA(c, _) => Some(format!("#{}", hexstr(c))),
            _ => None,
        }
    }
}

fn hexstr(c: &[u8; 3]) -> String {
    format!("{:02x}{:02x}{:02x}", c[0], c[1], c[2])
}

fn numstr(n: f64) -> String {
    if n.fract() == 0.0 {
        format!("{}", n as i64)
    } else {
        format!("{n}")
    }
}
