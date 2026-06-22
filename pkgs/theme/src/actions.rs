//! Side effects after generating files: recolour + set the wallpaper, reload tools.

use crate::util::expand;
use crate::value::Value;
use std::{path::Path, process::Command};

fn run_ok(cmd: &str, args: &[&str]) -> bool {
    Command::new(cmd)
        .args(args)
        .status()
        .map(|s| s.success())
        .unwrap_or(false)
}

/// `WxH` of an image via ImageMagick, for sizing the gradient overlay.
fn dims_of(path: &str) -> Option<String> {
    let out = Command::new("magick")
        .args(["identify", "-format", "%wx%h", path])
        .output()
        .ok()?;
    if !out.status.success() {
        return None;
    }
    let s = String::from_utf8_lossy(&out.stdout).trim().to_string();
    (!s.is_empty()).then_some(s)
}

/// Recolour the source wallpaper to the palette and set it (awww).
///
/// Mapping every pixel onto a small dark palette (lutgen alone) washes the image
/// out to grey. To keep it vibrant while still themed + moody:
///   1. lutgen-recolour (luminance preserved)
///   2. blend ~50% back with the original so real colour returns
///   3. lift saturation + deepen contrast so subjects pop
///   4. darken the top toward `base` with a gradient so backgrounds recede
/// Falls back to the plain recolour if magick is unavailable, or a solid colour
/// when no wallpaper is set.
pub fn set_wallpaper(vars: &[(String, Value)], home: &str) {
    let wall = vars.iter().find_map(|(k, v)| match (k.as_str(), v) {
        ("wallpaper", Value::Text(s)) if !s.is_empty() => Some(expand(s, home)),
        _ => None,
    });
    let base = vars.iter().find(|(k, _)| k == "base").and_then(|(_, v)| v.hex());

    match wall {
        Some(w) if Path::new(&w).exists() => {
            let recolored = format!("{home}/.cache/wallpaper-recolored.png");
            let out = format!("{home}/.cache/wallpaper.png");
            let palette: Vec<String> = vars.iter().filter_map(|(_, v)| v.hex()).collect();

            // 1. recolour to the palette (luminance preserved)
            let mut lut = vec![
                "apply",
                "--preserve",
                w.as_str(),
                "-o",
                recolored.as_str(),
                "--",
            ];
            lut.extend(palette.iter().map(String::as_str));
            if !run_ok("lutgen", &lut) {
                eprintln!("  ! lutgen failed -- check `lutgen apply --help`");
                return;
            }

            // 2. blend back with the original (keep colour) + 3. saturation/contrast
            let toned_ok = run_ok(
                "magick",
                &[
                    w.as_str(),
                    recolored.as_str(),
                    "-compose",
                    "blend",
                    "-define",
                    "compose:args=50", // 50% themed + 50% original
                    "-composite",
                    "-modulate",
                    "98,125,100", // brightness, saturation, hue (%)
                    "-sigmoidal-contrast",
                    "3x55%",
                    out.as_str(),
                ],
            );

            // 4. darken the top toward base so the background recedes
            if toned_ok {
                if let (Some(dims), Some(b)) = (dims_of(&out), &base) {
                    let grad = format!("gradient:{b}C0-{b}00"); // ~75% at top -> 0 at bottom
                    run_ok(
                        "magick",
                        &[
                            out.as_str(),
                            "(",
                            "-size",
                            dims.as_str(),
                            grad.as_str(),
                            ")",
                            "-composite",
                            out.as_str(),
                        ],
                    );
                }
            }

            // 5. set it (toned output, or the plain recolour if magick was missing)
            let final_path = if toned_ok {
                out.as_str()
            } else {
                recolored.as_str()
            };
            run_ok("awww", &["img", final_path, "--transition-type", "fade"]);
        }
        _ => {
            if let Some(hex) = base {
                run_ok("awww", &["clear", hex.trim_start_matches('#')]);
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
