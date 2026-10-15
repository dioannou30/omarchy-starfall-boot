# Starfall — Omarchy boot screen

A custom [Plymouth](https://www.freedesktop.org/wiki/Software/Plymouth/) boot and disk-unlock screen for [Omarchy](https://omarchy.org/). A deep-navy night sky with twinkling stars, an occasional shooting star, and a speed-streaked `omarchy` wordmark above the password field.

![Starfall boot screen preview](preview.png)

## Features

- Night-sky background (`#0D1020`) with 60 randomly placed stars that twinkle at their own pace
- A shooting star that crosses the upper sky every 5–9 seconds
- Custom `omarchy` wordmark, password field, prompt icon, and cyan password dots
- Cyan progress bar after the disk is unlocked
- Also shown on shutdown and reboot

## Requirements

- Omarchy (Arch Linux + Limine bootloader)
- Plymouth enabled (default on Omarchy)

## Install

1. Clone the repo:

   ```bash
   git clone https://github.com/dioannou30/omarchy-starfall-boot.git
   cd omarchy-starfall-boot
   ```

2. Copy the theme into Plymouth's theme folder:

   ```bash
   sudo cp -r starfall /usr/share/plymouth/themes/starfall
   ```

3. Make it the default theme:

   ```bash
   sudo plymouth-set-default-theme starfall
   ```

4. Rebuild the boot image. This step is required: at power-on the disk is still encrypted, so Plymouth loads the theme from the boot image, not from `/usr/share`.

   ```bash
   sudo limine-mkinitcpio
   ```

5. Reboot.

## Update

Pull the latest version and repeat steps 2 and 4:

```bash
git pull
sudo rm -rf /usr/share/plymouth/themes/starfall
sudo cp -r starfall /usr/share/plymouth/themes/starfall
sudo limine-mkinitcpio
```

## Uninstall

Restore the stock Omarchy boot screen:

```bash
omarchy plymouth reset
sudo rm -rf /usr/share/plymouth/themes/starfall
```

## Notes

- Running any `omarchy plymouth set ...` or `omarchy plymouth reset` command switches back to the stock Omarchy theme. To return to Starfall, repeat steps 3 and 4.
- Testing with `plymouthd` from inside Hyprland shows nothing, because the compositor owns the display. The quickest check is to reboot or log out: the shutdown screen reads the theme straight from disk, so it shows changes even before the boot image is rebuilt.
- If you break the script while customizing, the screen may come up blank or plain. You can still type your disk password and press Enter. Run `omarchy plymouth reset` to get back to a working screen.

## Customizing

| File | What it is |
|---|---|
| `logo.png` | Wordmark, 800×188 |
| `entry.png` | Password field, 286×48 |
| `lock.png` | Prompt icon, 84×96 (shown at ~34×38) |
| `bullet.png` | Password dot, 14×14 (shown at 7×7) |
| `progress_box.png` / `progress_bar.png` | Progress bar track and fill, 300×10 |
| `star.png` | Star, 6×6 |
| `streak.png` | Shooting-star trail, 120×4 |
| `starfall.script` | Layout, colors, and animation |

Background color is set by `Window.SetBackgroundTopColor` / `SetBackgroundBottomColor` at the top of `starfall.script`. Star count, twinkle speed, and shooting-star timing live in the `star.*` and `streak.*` variables right below it. After any change, copy the folder again and rebuild the boot image.

## Credits

Based on the stock Omarchy Plymouth theme script.
