//! `theme` — generate per-tool theme files from a typed config (no templates).
//!
//! Modules:
//!   config   — parse theme.conf into typed (name, value) pairs
//!   value    — the Value type and per-tool rendering
//!   generate — produce each tool's file
//!   actions  — wallpaper + reload side effects
//!   util     — path/fs helpers
//!
//! Usage:
//!   theme [CONFIG] [--out DIR] [--eww-out P] [--waybar-out P] [--hypr-out P]
//!         [--fuzzel-out P] [--mako-out P] [--no-reload]
//!   theme CONFIG DIR           # positional: config + output dir

mod actions;
mod config;
mod generate;
mod util;
mod value;

use std::{env, fs};
use util::{expand, write_file};
use value::Format;

fn main() {
    let home = env::var("HOME").unwrap_or_default();
    let cfgdir = env::var("XDG_CONFIG_HOME").unwrap_or_else(|_| format!("{home}/.config"));
    let args: Vec<String> = env::args().skip(1).collect();

    // ---- arg parsing (std only) ----
    let mut config: Option<String> = None;
    let mut out_dir: Option<String> = None;
    let mut no_reload = false;
    let mut outs: [Option<String>; 5] = [None, None, None, None, None];
    let flags = ["--eww-out", "--waybar-out", "--hypr-out", "--fuzzel-out", "--mako-out"];
    let mut positional: Vec<String> = Vec::new();

    let mut i = 0;
    while i < args.len() {
        let a = args[i].as_str();
        if a == "--config" {
            i += 1;
            config = args.get(i).cloned();
        } else if a == "--out" {
            i += 1;
            out_dir = args.get(i).cloned();
        } else if a == "--no-reload" {
            no_reload = true;
        } else if let Some(idx) = flags.iter().position(|f| *f == a) {
            i += 1;
            outs[idx] = args.get(i).cloned();
        } else if a.starts_with("--") {
            eprintln!("unknown flag: {a}");
        } else {
            positional.push(a.to_string());
        }
        i += 1;
    }
    if config.is_none() {
        config = positional.first().cloned();
    }
    if out_dir.is_none() && positional.len() >= 2 {
        out_dir = Some(positional[1].clone());
    }
    let config = config.unwrap_or_else(|| format!("{cfgdir}/theme/theme.conf"));

    // ---- resolve outputs: per-tool flag > --out DIR > built-in default ----
    let defaults = [
        format!("{cfgdir}/eww/_theme.scss"),
        format!("{cfgdir}/waybar/colors.css"),
        format!("{cfgdir}/hypr/conf.d/00-theme.conf"),
        format!("{cfgdir}/fuzzel/fuzzel.ini"),
        format!("{cfgdir}/mako/config"),
    ];
    let dir_names = ["eww.scss", "waybar.css", "hypr.conf", "fuzzel.ini", "mako.conf"];
    let dest = |idx: usize| -> String {
        if let Some(p) = &outs[idx] {
            expand(p, &home)
        } else if let Some(d) = &out_dir {
            format!("{}/{}", expand(d, &home), dir_names[idx])
        } else {
            defaults[idx].clone()
        }
    };

    // ---- parse + generate ----
    let text = match fs::read_to_string(expand(&config, &home)) {
        Ok(t) => t,
        Err(e) => {
            eprintln!("cannot read {config}: {e}");
            std::process::exit(1);
        }
    };
    let vars = config::parse(&text);

    write_file(&dest(0), &generate::vars(&vars, Format::Scss));
    write_file(&dest(1), &generate::vars(&vars, Format::GtkCss));
    write_file(&dest(2), &generate::vars(&vars, Format::Hypr));
    write_file(&dest(3), &generate::fuzzel(&vars));
    write_file(&dest(4), &generate::mako(&vars));

    if !no_reload {
        actions::set_wallpaper(&vars, &home);
        actions::reload();
    }
    println!("\u{2713} theme generated");
}
