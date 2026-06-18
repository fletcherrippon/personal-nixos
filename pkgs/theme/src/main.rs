//! `theme` — a generic, template-driven theme generator.
//!
//! It reads ~/.config/theme/theme.conf (key=value) and renders every template
//! in ~/.config/theme/templates/ to the path each declares, then recolours the
//! wallpaper (lutgen + swww) and reloads. There is NOTHING tool-specific in this
//! file — adding a variable or a whole new tool means editing theme.conf and a
//! template, never this code.
//!
//! Template format:
//!   First line:   @out <path>            destination (supports leading ~)
//!   Body:         {{ key }}              raw value from theme.conf
//!                 {{ key.hex }}          #rrggbb
//!                 {{ key.rgb }}          rgb(rrggbb)         (hyprland)
//!                 {{ key.rgba }}         rgba(r,g,b,opacity) (GTK3, no #RRGGBBAA)
//!                 {{ key.alpha }}        rrggbbAA            (fuzzel)

use std::collections::HashMap;
use std::{env, fs, path::Path, process::Command};

fn main() {
    let home = env::var("HOME").expect("HOME not set");
    let cfg = env::var("XDG_CONFIG_HOME").unwrap_or_else(|_| format!("{home}/.config"));
    let theme_dir = format!("{cfg}/theme");

    let conf = fs::read_to_string(format!("{theme_dir}/theme.conf"))
        .expect("cannot read theme.conf");
    let t: HashMap<String, String> = conf.lines().filter_map(parse_line).collect();
    let opacity: u32 = t.get("opacity").and_then(|s| s.parse().ok()).unwrap_or(100);

    // Render every template to its declared @out path.
    let tmpl_dir = format!("{theme_dir}/templates");
    match fs::read_dir(&tmpl_dir) {
        Ok(entries) => {
            for entry in entries.flatten() {
                let path = entry.path();
                if !path.is_file() {
                    continue;
                }
                match fs::read_to_string(&path) {
                    Ok(raw) => render_template(&raw, &t, opacity, &home),
                    Err(e) => eprintln!("  ! read {}: {e}", path.display()),
                }
            }
        }
        Err(e) => eprintln!("  ! no templates dir ({tmpl_dir}): {e}"),
    }

    set_wallpaper(&t, &home);
    reload();
    println!("\u{2713} theme applied");
}

fn parse_line(line: &str) -> Option<(String, String)> {
    let line = line.trim();
    if line.is_empty() || line.starts_with('#') {
        return None;
    }
    let (k, v) = line.split_once('=')?;
    Some((k.trim().to_string(), v.trim().to_string()))
}

/// First line `@out <path>` is the destination; the rest is rendered + written.
fn render_template(raw: &str, t: &HashMap<String, String>, opacity: u32, home: &str) {
    let mut lines = raw.lines();
    let out = match lines.next().and_then(|l| l.strip_prefix("@out ")) {
        Some(p) => p.trim().replacen('~', home, 1),
        None => {
            eprintln!("  ! template missing `@out <path>` first line");
            return;
        }
    };
    let body = lines.collect::<Vec<_>>().join("\n");
    let rendered = substitute(&body, t, opacity);
    if let Err(e) = fs::write(&out, format!("{rendered}\n")) {
        eprintln!("  ! write {out}: {e}");
    }
}

/// Replace every `{{ key[.fmt] }}` with the formatted theme value.
fn substitute(body: &str, t: &HashMap<String, String>, opacity: u32) -> String {
    let mut out = String::new();
    let mut rest = body;
    while let Some(i) = rest.find("{{") {
        out.push_str(&rest[..i]);
        let after = &rest[i + 2..];
        match after.find("}}") {
            Some(j) => {
                out.push_str(&format_expr(after[..j].trim(), t, opacity));
                rest = &after[j + 2..];
            }
            None => {
                out.push_str("{{");
                rest = after;
            }
        }
    }
    out.push_str(rest);
    out
}

fn format_expr(expr: &str, t: &HashMap<String, String>, opacity: u32) -> String {
    let (key, fmt) = expr.split_once('.').unwrap_or((expr, ""));
    let v = t.get(key).cloned().unwrap_or_default();
    match fmt {
        "" => v,
        "hex" => format!("#{v}"),
        "rgb" => format!("rgb({v})"),
        "rgba" => {
            let (r, g, b) = hex_rgb(&v);
            let a = if opacity >= 100 {
                "1".to_string()
            } else {
                format!("0.{:02}", opacity)
            };
            format!("rgba({r}, {g}, {b}, {a})")
        }
        "alpha" => format!("{v}{:02x}", opacity * 255 / 100),
        other => {
            eprintln!("  ! unknown format '.{other}' on {{{{{expr}}}}}");
            v
        }
    }
}

fn set_wallpaper(t: &HashMap<String, String>, home: &str) {
    let wall = t
        .get("wallpaper")
        .cloned()
        .unwrap_or_default()
        .replacen('~', home, 1);

    if !wall.is_empty() && Path::new(&wall).exists() {
        let out = format!("{home}/.cache/wallpaper.png");
        // Palette = every value that is a 6-digit hex colour (no hardcoded list).
        let palette: Vec<String> = t
            .values()
            .filter(|v| v.len() == 6 && v.chars().all(|c| c.is_ascii_hexdigit()))
            .map(|v| format!("#{v}"))
            .collect();
        let ok = Command::new("lutgen")
            .args(["apply", "--preserve", wall.as_str(), "-o", out.as_str(), "--"])
            .args(&palette)
            .status()
            .map(|s| s.success())
            .unwrap_or(false);
        if ok {
            Command::new("swww")
                .args(["img", out.as_str(), "--transition-type", "fade"])
                .status()
                .ok();
        } else {
            eprintln!("  ! lutgen failed -- check `lutgen apply --help`");
        }
    } else if let Some(base) = t.get("base") {
        Command::new("swww").args(["clear", base.as_str()]).status().ok();
    }
}

fn reload() {
    Command::new("eww").args(["reload"]).status().ok();
    Command::new("hyprctl").args(["reload"]).status().ok();
    Command::new("makoctl").args(["reload"]).status().ok();
    Command::new("pkill").args(["-SIGUSR2", "waybar"]).status().ok();
}

/// Parse "rrggbb" (optionally '#'-prefixed) into (r, g, b).
fn hex_rgb(hex: &str) -> (u8, u8, u8) {
    let n = u32::from_str_radix(hex.trim_start_matches('#'), 16).unwrap_or(0);
    ((n >> 16) as u8, (n >> 8) as u8, n as u8)
}
