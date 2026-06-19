//! Small filesystem/path helpers.

use std::fs;

/// Expand a leading `~` to the home directory.
pub fn expand(p: &str, home: &str) -> String {
    match p.strip_prefix('~') {
        Some(rest) => format!("{home}{rest}"),
        None => p.to_string(),
    }
}

pub fn write_file(path: &str, contents: &str) {
    if let Err(e) = fs::write(path, contents) {
        eprintln!("  ! write {path}: {e}");
    }
}
