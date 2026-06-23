# anyrun — a Raycast-style launcher (Super+Space). Uses home-manager's built-in
# programs.anyrun module (no flake input / no lock entry) with nixpkgs' anyrun,
# which bundles every plugin in $out/lib and sets ANYRUN_PLUGINS -- so plugins
# are referenced by bare .so name. Unlike the live-symlinked dotfiles
# (hypr/eww/...), anyrun's config + style are Nix-managed (regenerated on rebuild).
{ pkgs, ... }:
{
  programs.anyrun = {
    enable = true;
    package = pkgs.anyrun;

    config = {
      plugins = [
        "libapplications.so" # launch apps
        "librink.so" # calculator + unit/currency conversion
        "libshell.so" # run a shell command
        "libwebsearch.so" # search the web
        "libsymbols.so" # emoji / unicode by name
        "libdictionary.so" # word definitions
        "libtranslate.so" # translate text
      ];

      width.fraction = 0.3;
      y.absolute = 240;
      hideIcons = false;
      hidePluginInfo = false;
      closeOnClick = true;
      showResultsImmediately = true;
      layer = "overlay";
    };

    # moonfly palette. NOTE: hardcoded here rather than pulled from theme.conf --
    # anyrun's config is Nix-managed (not a live-symlink), so it can't @import the
    # generated theme fragment. Keep these in sync with theme.conf by hand for now.
    extraCss = ''
      @define-color accent #80a0ff;
      @define-color bg-color #080808;
      @define-color surface #323437;
      @define-color fg-color #bdbdbd;
      @define-color desc-color #949494;

      window {
        background: transparent;
      }

      box.main {
        padding: 6px;
        margin: 8px;
        border-radius: 12px;
        border: 1px solid @surface;
        background-color: @bg-color;
      }

      /* search entry */
      entry,
      text {
        min-height: 0;
        margin-bottom: 4px;
        padding: 8px 10px;
        border: none;
        border-radius: 8px;
        background-color: @surface;
        color: @fg-color;
        font-size: 15px;
      }

      .matches,
      list.plugin {
        background: transparent;
      }

      /* result rows: transparent, subtle grey highlight when selected */
      .match {
        padding: 6px 10px;
        border-radius: 8px;
        background: transparent;
      }
      .match:selected {
        background-color: @surface;
      }

      label.match {
        color: @fg-color;
        font-size: 14px;
      }
      label.match.description {
        color: @desc-color;
        font-size: 12px;
      }
      label.plugin.info {
        color: @desc-color;
        font-size: 12px;
      }
    '';
  };
}
