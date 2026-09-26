# Monitor layout

**Philips on top; LG on the bottom.** Move the pointer **up** from the LG to
reach the Philips.

| Position | Monitor | Native mode | Scale | Kernel EDID ID |
| --- | --- | --- | --- | --- |
| Top | Philips PHL 243V5 | 1920×1080 @ 60 Hz | 1× | `PHL-49361-19827` |
| Bottom | LG HDR WFHD | 2560×1080 @ 59.978 Hz | 1× | `GSM-23456-348447` |

The Philips is centred over the LG. Both screens use their native resolution.

## How the layout is applied

`apply_monitor_layout()` in `hyprland.lua` is the single source of monitor
configuration. It reads each connected output's EDID from `/sys/class/drm`,
identifies the panel by manufacturer, product code and serial, takes the
preferred timing from the first detailed timing descriptor, then assigns the
Hyprland connector and lays out the panels vertically. The EDID identity belongs
to the monitor, so it remains the same when cables or ports change.

The function runs:

- when Hyprland starts and whenever its configuration reloads
- when a monitor is added or removed
- after sleep, through `hypridle.conf`'s `after_sleep_cmd`
- on demand with `SUPER+SHIFT+M`

If a connected monitor's EDID is temporarily unavailable during wake, the
function retries once per second for up to 10 attempts. Workspaces 4 and 9 are
pinned to the Philips. Waybar and hyprpaper are not pinned to connector names.

Startup and suspend/resume have both been confirmed working. To inspect the
kernel's current monitor identities and preferred modes:

```sh
for c in /sys/class/drm/card*-*/; do
  [ "$(cat "$c/status")" = connected ] || continue
  printf '\n%s\n' "$c"
  di-edid-decode < "$c/edid" | grep -E 'Manufacturer:|Product Name|DTD 1:'
done
```

To check the pointer's current virtual position, run `hyprctl cursorpos`. Hyprland
may report stale or swapped make/model/serial labels in `hyprctl monitors`; use
the kernel EDID and the pointer's position on the physical screens to verify the
mapping instead.

## When changing the layout

Edit the `MONITORS` table in `hyprland.lua`. Keep monitor identities tied to the
kernel EDID IDs above; do not replace them with `DP-1`/`DP-2`, which identify
ports and can change when cables are moved. The layout function derives the
native modes and positions from the EDIDs, so it should not need hard-coded
connector names or resolution overrides.
