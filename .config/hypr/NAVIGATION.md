# Directional window navigation

The directional bindings use the custom `i3tree` layout and also accept the
arrow keys:

| Binding | Action |
| --- | --- |
| `SUPER+H/J/K/L` | Focus the nearest window left/down/up/right. If there is no window in that direction on the current workspace, focus the active workspace on the nearest monitor in that direction. |
| `SUPER+SHIFT+H/J/K/L` | Move the current window left/down/up/right within the current workspace layout. These bindings do not move focus to another monitor. |

The Philips monitor is above the LG, so `SUPER+K` crosses from the LG to the
Philips when no window above is available on the current workspace. `SUPER+J`
crosses in the opposite direction. There is no monitor to the left or right in
the current monitor arrangement.
