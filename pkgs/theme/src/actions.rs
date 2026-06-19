//! Side effects after generating files: recolour + set the wallpaper, reload tools.

use crate::util::expand;
use crate::value::Value;
use std::{path::Path, process::Command};

/// Recolour the source wallpaper to the palette (lutgen) and set it (swww).
/// Falls back to a solid `base` colour when no wallpaper is configured.
pub fn set_wallpaper(vars: &[(String, Value)], home: &str) {
    let wall = vars.iter().find_map(|(k, v)| match (k.as_str(), v) {
        ("wallpaper", Value::Text(s)) if !s.is_empty() => Some(expand(s, home)),
        _ => None,
    });

    match wall {
        Some(w) if Path::new(&w).exists() => {
            let out = format!("{home}/.cache/wallpaper.png");
            let palette: Vec<String> = vars.iter().filter_map(|(_, v)| v.hex()).collect();
            let ok = Command::new("lutgen")
                .args(["apply", "--preserve", w.as_str(), "-o", out.as_str(), "--"])
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
        }
        _ => {
            if let Some(hex) = vars.iter().find(|(k, _)| k == "base").and_then(|(_, v)| v.hex()) {
                Command::new("swww")
                    .args(["clear", hex.trim_start_matches('#')])
                    .status()
                    .ok();
            }
        }
    }
}

pub fn reload() {
    Command::new("eww").args(["reload"]).status().ok();
    Command::new("hyprctl").args(["reload"]).status().ok();
    Command::new("makoctl").args(["reload"]).status().ok();
    Command::new("pkill").args(["-SIGUSR2", "waybar"]).status().ok();
}
