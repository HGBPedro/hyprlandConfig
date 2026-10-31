# Atrium greeter: Sage theme setup

How to install the `atrium-sage.css` theme, your background image, and the SF Pro fonts for the Atrium greeter on Arch Linux.

| Item | Value |
|---|---|
| Primary color | `#B2D3A8` (text, focus, button background) |
| Secondary color | `#274B40` (button text, input background) |
| Container | `#1A322B` at 85% opacity |
| Font | SF Pro, base size 12px, buttons 14px / weight 500 |

> **Why system folders?** The greeter runs as its own system user, not as you.
> It cannot read anything inside your home folder (`~/Pictures`, `~/.local/share/fonts`, etc.),
> so every file it uses must be copied to a system location and be world-readable.

---

## 1. Background image

**Save it to:** `/usr/share/backgrounds/atrium/`

```bash
sudo install -Dm644 ~/Pictures/wallpaper.jpg /usr/share/backgrounds/atrium/wallpaper.jpg
```

- Replace `~/Pictures/wallpaper.jpg` with the path to your image.
- JPEG and PNG always work; WebP, GIF, BMP, SVG and TIFF work on most systems.
- To get a random wallpaper on each launch, put several images in that folder and point the config at the folder instead of a file (step 4).

---

## 2. Fonts (SF Pro)

**Copy them to:** `/usr/share/fonts/OTF/` (or `/usr/share/fonts/TTF/` for `.ttf` files)

```bash
sudo mkdir -p /usr/share/fonts/OTF
sudo cp ~/Downloads/SF-Pro*/*.otf /usr/share/fonts/OTF/
sudo chmod 644 /usr/share/fonts/OTF/SF-Pro*.otf
sudo fc-cache -f
```

- Replace `~/Downloads/SF-Pro*/` with the folder holding your font files.
- Include the **Medium** weight file (e.g. `SF-Pro-Display-Medium.otf`): the buttons use weight 500, which is Medium. Without it GTK falls back to Regular or Bold.
- Alternative: install the AUR package instead, e.g. `paru -S apple-fonts`.

**Check the family name:**

```bash
fc-list | grep -i "SF Pro"
```

The theme looks for `"SF Pro Display"`, `"SF Pro Text"` and `"SF Pro"`. If your output shows a different family name, edit the `font-family` line in the theme file (step 3).

---

## 3. Theme file

**Save it to:** `/usr/share/atrium/themes/atrium-sage.css`

```bash
sudo install -Dm644 ~/Downloads/atrium-sage.css /usr/share/atrium/themes/atrium-sage.css
```

> If you built Atrium from source instead of the AUR package, the shipped themes live in
> `/usr/local/share/atrium/themes/`. Either location works, as long as the config points to it.

To change the colors later, edit the palette at the top of the file:

```css
@define-color sage-primary          #B2D3A8;
@define-color sage-primary-hover    #C8E2BF;
@define-color sage-secondary        #274B40;
@define-color sage-container        #1A322B;
```

The container opacity is in the `.card` rule: `alpha(@sage-container, 0.85)`.

---

## 4. Greeter configuration

**Edit:** `/etc/atrium-greeter.conf`

```bash
sudo nano /etc/atrium-greeter.conf
```

Set (or uncomment) these three keys:

```ini
# Base font size in pixels — all other text sizes scale from this
base-font-size = 12

# Background image (or a folder, for a random image each launch)
background-image = /usr/share/backgrounds/atrium/wallpaper.jpg

# Theme
theme = /usr/share/atrium/themes/atrium-sage.css
```

---

## 5. Apply

```bash
sudo systemctl reload atrium
```

This restarts idle greeters with the new config, no reboot needed. To see it, log out or switch to the greeter's virtual terminal.

---

## Troubleshooting

| Problem | Fix |
|---|---|
| Theme not applied / wrong colors | Check for CSS errors: `journalctl -u atrium -b \| grep -i css` |
| Default font still shown | Fonts not in `/usr/share/fonts`, missing `fc-cache -f`, or family name differs (step 2) |
| Buttons look Regular, not Medium | The Medium weight `.otf` is missing |
| Black background, no image | Wrong path in `background-image`, or file not readable: `ls -l /usr/share/backgrounds/atrium/` should show `-rw-r--r--` |
| Changes lost after an update | Reinstalling Atrium from source overwrites `/etc/atrium-greeter.conf` and its themes folder; keep a backup of both files |

**Backup command:**

```bash
mkdir -p ~/atrium-backup
cp /etc/atrium-greeter.conf /usr/share/atrium/themes/atrium-sage.css ~/atrium-backup/
```
