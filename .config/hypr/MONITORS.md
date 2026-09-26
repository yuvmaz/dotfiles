# Monitor layout

**Philips on the TOP. LG on the BOTTOM.** Moving the pointer **up** from the LG
reaches the Philips.

| Position | Monitor           | Native mode       | Scale | EDID id            |
|----------|-------------------|-------------------|-------|--------------------|
| Top      | Philips PHL 243V5 | 1920x1080 @ 60 Hz | 1     | `PHL-49361-19827`  |
| Bottom   | LG HDR WFHD       | 2560x1080 @ 60 Hz | 1     | `GSM-23456-348447` |

The Philips is centred above the LG.

## How it works

All of it is `apply_monitor_layout()` in `hyprland.lua`. It:

1. Reads each connected monitor's EDID from the kernel (`/sys/class/drm/*/edid`).
   The id is manufacturer, product code and serial number. These are stored in
   the monitor itself, so they don't change when you swap cables or ports.
2. Takes each monitor's native mode from its EDID's first detailed timing.
3. Places the top monitor at y=0 and the bottom monitor directly below it.
4. Pins workspaces 4 and 9 to the top monitor.
5. Retries every second (up to 10 times) if a monitor's EDID can't be read
   yet, which can happen while it wakes up.

It runs:

- when Hyprland starts and on every config reload, as part of loading the config
- on the `monitor.added` and `monitor.removed` events: hotplug, monitor power-on
- after resume from sleep, through `after_sleep_cmd` in `hypridle.conf`
- when you press `SUPER+SHIFT+M`

Waybar and hyprpaper don't pin to specific monitors, so they never need to know
which connector a monitor is on.

To change the layout, edit the `MONITORS` table at the top of that section.

## Do not

- **Identify monitors by connector name** (`DP-1`, `DP-2`). The name belongs to
  the port, not the monitor, so it changes when cables are swapped.
- **Trust Hyprland's own make, model, serial or description**
  (`hyprctl monitors`). Hyprland has kept stale EDID data for a connector,
  which swapped every label. It also drove the Philips at the LG's 2560x1080.
  The kernel's EDID was correct throughout. Check it with:

  ```sh
  for c in /sys/class/drm/card*-*/; do
    [ "$(cat $c/status)" = connected ] && echo "$c" && di-edid-decode < $c/edid | grep -E 'Product Name|DTD 1'
  done
  ```

- **Rely on labels or coordinates without checking by hand.** When in doubt,
  put the pointer on a physical screen and run `hyprctl cursorpos`.
