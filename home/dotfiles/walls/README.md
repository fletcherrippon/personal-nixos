# Wallpapers

Drop source wallpaper images in this folder (any colours — they don't need to
match the theme). Then point `theme.conf` at one:

    wallpaper=~/personal-nixos/home/dotfiles/walls/your-image.jpg

Run `theme`, and it recolours the image to your palette with **lutgen** and sets
it with **swww**. Leave `wallpaper=` blank for a solid-colour background.

Notes:
- The recoloured result is written to `~/.cache/wallpaper.png` (not tracked).
- Large source images bloat the git repo — keep them reasonable, or add this
  folder to `.gitignore` if you'd rather not track them.
