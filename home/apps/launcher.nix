# anyrun — a Raycast-style launcher (Super+Space). Uses anyrun's own flake +
# home-manager module so plugin .so paths are wired automatically. Unlike the
# live-symlinked dotfiles (hypr/eww/...), anyrun's config + style are managed by
# this module (regenerated on rebuild), since the plugin paths must be resolved
# by Nix.
{ inputs, pkgs, ... }:
let
  anyrun = inputs.anyrun.packages.${pkgs.system};
in
{
  imports = [ inputs.anyrun.homeManagerModules.default ];

  programs.anyrun = {
    enable = true;
    package = anyrun.anyrun;

    config = {
      plugins = [
        anyrun.applications # launch apps
        anyrun.rink # calculator + unit/currency conversion
        anyrun.shell # run a shell command
        anyrun.websearch # search the web
        anyrun.symbols # emoji / unicode by name
      ];

      width.fraction = 0.4;
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
        padding: 8px;
        margin: 12px;
        border-radius: 12px;
        border: 2px solid @surface;
        background-color: @bg-color;
        box-shadow: 0 0 12px black;
      }

      text {
        min-height: 36px;
        padding: 8px 10px;
        border-radius: 8px;
        background-color: @surface;
        color: @fg-color;
      }

      .matches {
        background: transparent;
      }
      list.plugin {
        background: transparent;
      }

      label.match {
        color: @fg-color;
      }
      label.match.description {
        font-size: 12px;
        color: @desc-color;
      }
      label.plugin.info {
        color: @desc-color;
      }

      .match {
        background: transparent;
        border-radius: 8px;
        padding: 4px 8px;
      }
      .match:selected {
        background-color: @accent;
        color: @bg-color;
      }
    '';
  };
}
