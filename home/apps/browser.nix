# Zen browser (Firefox-based), set as the system default. From the zen-browser
# flake (not in nixpkgs); its home-manager module wires the MIME/URL-scheme
# handlers and BROWSER env when setAsDefaultBrowser is on. The default channel's
# binary + desktop entry are `zen-beta` (used by the keybind + bar launcher).
{ inputs, ... }:
{
  imports = [ inputs.zen-browser.homeModules.default ];

  programs.zen-browser = {
    enable = true;
    setAsDefaultBrowser = true;
  };
}
