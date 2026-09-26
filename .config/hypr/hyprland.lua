local terminal = "kitty"
local menu = "wofi --show run"
local mainMod = "SUPER"
local scripts = "/home/yuvalm/.config/hypr/scripts"

local function exec(cmd)
    return hl.dsp.exec_cmd(cmd)
end

local function bind(keys, dispatcher, opts)
    hl.bind(mainMod .. " + " .. keys, dispatcher, opts)
end

dofile("/home/yuvalm/.config/hypr/i3tree-layout.lua")

-- The two monitors are stacked, so "the other one" is unambiguous. `hyprctl
-- dispatch` cannot be used for this: this Hyprland parses commands as Lua and
-- rejects it, so the move has to go through the Lua dispatcher.
local function move_workspace_to_other_monitor(workspace)
    local current = hl.get_active_monitor().name
    for _, monitor in ipairs(hl.get_monitors()) do
        if monitor.name ~= current then
            hl.dispatch(hl.dsp.workspace.move({
                workspace = workspace or hl.get_active_workspace().name,
                monitor = monitor.name,
            }))
            return
        end
    end
end

for _, env in ipairs({
    { "XCURSOR_SIZE", "24" },
    { "HYPRCURSOR_SIZE", "24" },
    { "XDG_DATA_DIRS", "/home/yuvalm/.local/share/flatpak/exports/share:/var/lib/flatpak/exports/share:/usr/local/share:/usr/share" },
}) do
    hl.env(env[1], env[2])
end

hl.on("hyprland.start", function()
    hl.exec_cmd("systemctl --user import-environment XDG_DATA_DIRS")
    for _, cmd in ipairs({
        "mako",
        "hyprpaper",
        "hypridle",
        "GTK_USE_PORTAL=0 waybar",
        scripts .. "/setup-monitors",
        "easyeffects",
        "google-chrome-stable --password-store=basic --user-data-dir=/home/yuvalm/.config/google-chrome-startup-youtube --no-first-run --no-default-browser-check --disable-background-networking --disable-component-update --disable-sync --disable-extensions --new-window --app=https://www.youtube.com",
        "google-chrome-stable --password-store=basic --user-data-dir=/home/yuvalm/.config/google-chrome-startup-spotify --no-first-run --no-default-browser-check --disable-background-networking --disable-component-update --disable-sync --disable-extensions --new-window --app=https://open.spotify.com",
    }) do
        hl.exec_cmd(cmd)
    end
end)

local monitor_fix_scheduled = false
local function schedule_monitor_fix()
    if monitor_fix_scheduled then
        return
    end
    monitor_fix_scheduled = true
    hl.timer(function()
        monitor_fix_scheduled = false
        hl.exec_cmd(scripts .. "/setup-monitors")
    end, { timeout = 1500, type = "oneshot" })
end

-- Any monitor re-enumeration (resume, hotplug) or a config reload can drop the
-- layout back to Hyprland's side-by-side default, so re-assert it from events
-- rather than relying on a single resume hook.
for _, event in ipairs({ "monitor.added", "monitor.removed", "config.reloaded" }) do
    hl.on(event, schedule_monitor_fix)
end

hl.config({
    general = {
        gaps_in = 5,
        gaps_out = 20,
        border_size = 2,
        col = {
            active_border = { colors = { "rgba(ced8f3ff)", "rgba(B546E3ff)" }, angle = 45 },
            inactive_border = "rgba(9097aa66)",
        },
        resize_on_border = false,
        allow_tearing = false,
        layout = "lua:i3tree",
    },
    decoration = {
        rounding = 10,
        rounding_power = 2,
        active_opacity = 1.0,
        inactive_opacity = 1.0,
        shadow = {
            enabled = true,
            range = 4,
            render_power = 3,
            color = 0xf0120c1f,
        },
        blur = {
            enabled = true,
            size = 3,
            passes = 1,
            vibrancy = 0.1696,
        },
    },
    animations = {
        enabled = true,
    },
    dwindle = {
        preserve_split = true,
    },
    master = {
        new_status = "master",
    },
    scrolling = {
        fullscreen_on_one_column = true,
    },
    misc = {
        force_default_wallpaper = -1,
        disable_hyprland_logo = false,
    },
    input = {
        kb_layout = "us,il",
        kb_variant = "",
        kb_model = "",
        kb_options = "grp:alt_shift_toggle",
        kb_rules = "",
        follow_mouse = 1,
        sensitivity = 0,
        touchpad = {
            natural_scroll = false,
        },
    },
})

for _, curve in ipairs({
    { "easeOutQuint", { type = "bezier", points = { { 0.23, 1 }, { 0.32, 1 } } } },
    { "easeInOutCubic", { type = "bezier", points = { { 0.65, 0.05 }, { 0.36, 1 } } } },
    { "linear", { type = "bezier", points = { { 0, 0 }, { 1, 1 } } } },
    { "almostLinear", { type = "bezier", points = { { 0.5, 0.5 }, { 0.75, 1 } } } },
    { "quick", { type = "bezier", points = { { 0.15, 0 }, { 0.1, 1 } } } },
    { "easy", { type = "spring", mass = 1, stiffness = 238.1191, dampening = 24.21279333 } },
}) do
    hl.curve(curve[1], curve[2])
end

for _, animation in ipairs({
    { leaf = "global", enabled = true, speed = 10, bezier = "default" },
    { leaf = "border", enabled = true, speed = 5.39, bezier = "easeOutQuint" },
    { leaf = "windows", enabled = true, speed = 4.79, spring = "easy" },
    { leaf = "windowsIn", enabled = true, speed = 4.1, spring = "easy", style = "popin 87%" },
    { leaf = "windowsOut", enabled = true, speed = 1.49, bezier = "linear", style = "popin 87%" },
    { leaf = "fadeIn", enabled = true, speed = 1.73, bezier = "almostLinear" },
    { leaf = "fadeOut", enabled = true, speed = 1.46, bezier = "almostLinear" },
    { leaf = "fade", enabled = true, speed = 3.03, bezier = "quick" },
    { leaf = "layers", enabled = true, speed = 3.81, bezier = "easeOutQuint" },
    { leaf = "layersIn", enabled = true, speed = 4, bezier = "easeOutQuint", style = "fade" },
    { leaf = "layersOut", enabled = true, speed = 1.5, bezier = "linear", style = "fade" },
    { leaf = "fadeLayersIn", enabled = true, speed = 1.79, bezier = "almostLinear" },
    { leaf = "fadeLayersOut", enabled = true, speed = 1.39, bezier = "almostLinear" },
    { leaf = "workspaces", enabled = true, speed = 1.94, bezier = "almostLinear", style = "fade" },
    { leaf = "workspacesIn", enabled = true, speed = 1.21, bezier = "almostLinear", style = "fade" },
    { leaf = "workspacesOut", enabled = true, speed = 1.94, bezier = "almostLinear", style = "fade" },
    { leaf = "zoomFactor", enabled = true, speed = 7, bezier = "quick" },
}) do
    hl.animation(animation)
end

hl.gesture({ fingers = 3, direction = "horizontal", action = "workspace" })
hl.device({ name = "epic-mouse-v1", sensitivity = -0.5 })

bind("Return", exec(terminal))
bind("KP_Enter", exec(terminal))
bind("C", hl.dsp.window.close())
bind("SHIFT + Q", hl.dsp.window.close())
bind("SHIFT + E", exec(scripts .. "/confirm-exit"))
bind("D", exec(menu))
bind("code:56", exec(scripts .. "/start-chrome"))
bind("SHIFT + code:56", exec(scripts .. "/start-chrome-incognito"))
bind("N", exec("firefox-bin"))
bind("P", exec("command -v pavucontrol >/dev/null 2>&1 && exec pavucontrol || exec kitty --single-instance -e wpctl status"))
-- Match i3's split bindings: toggle, horizontal, vertical.
bind("E", hl.dsp.layout("togglesplit"))
bind("G", hl.dsp.layout("splith"))
bind("V", hl.dsp.layout("splitv"))
bind("F", hl.dsp.window.fullscreen())
bind("SHIFT + F", hl.dsp.window.fullscreen({ action = "toggle" }))
bind("S", hl.dsp.layout("stacking"))
bind("W", hl.dsp.layout("tabbed"))
bind("SHIFT + SPACE", hl.dsp.window.float({ action = "toggle" }))
bind("SPACE", hl.dsp.window.cycle_next())
bind("A", hl.dsp.window.cycle_next({ prev = true }))
bind("SHIFT + C", exec("hyprctl reload && " .. scripts .. "/setup-monitors"))
bind("SHIFT + R", exec("hyprctl reload && " .. scripts .. "/setup-monitors"))
bind("SHIFT + F9", exec("systemctl suspend"))
bind("SHIFT + M", exec(scripts .. "/setup-monitors"))
bind("bracketleft", function() move_workspace_to_other_monitor(2) end)
bind("SHIFT + T", function() move_workspace_to_other_monitor() end)

for _, direction in ipairs({
    { name = "left", keys = { "H", "left" } },
    { name = "down", keys = { "J", "down" } },
    { name = "up", keys = { "K", "up" } },
    { name = "right", keys = { "L", "right" } },
}) do
    for _, key in ipairs(direction.keys) do
        -- The custom layout resolves focus against its own tile geometry.
        bind(key, hl.dsp.layout("focus " .. direction.name))
        bind("SHIFT + " .. key, hl.dsp.layout("move " .. direction.name))
    end
end

bind("R", hl.dsp.submap("resize"))

local numberKeys = { "1", "2", "3", "4", "5", "6", "7", "8", "9", "0" }
local keypadKeys = { "KP_End", "KP_Down", "KP_Next", "KP_Left", "KP_Begin", "KP_Right", "KP_Home", "KP_Up", "KP_Prior", "KP_Insert" }
for i = 1, 10 do
    bind(numberKeys[i], hl.dsp.focus({ workspace = i }))
    bind("SHIFT + " .. numberKeys[i], hl.dsp.window.move({ workspace = i }))
    bind(keypadKeys[i], hl.dsp.focus({ workspace = i }))
    bind("SHIFT + " .. keypadKeys[i], hl.dsp.window.move({ workspace = i }))
end

bind("SHIFT + N", hl.dsp.focus({ workspace = "e+1", on_current_monitor = true }))
bind("mouse_down", hl.dsp.focus({ workspace = "e+1" }))
bind("mouse_up", hl.dsp.focus({ workspace = "e-1" }))
bind("mouse:272", hl.dsp.window.drag(), { mouse = true })
bind("mouse:273", hl.dsp.window.resize(), { mouse = true })

local repeating = { locked = true, repeating = true }
for _, media in ipairs({
    { "XF86AudioRaiseVolume", "wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ 5%+" },
    { "XF86AudioLowerVolume", "wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-" },
    { "XF86AudioMute", "wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle" },
    { "XF86AudioMicMute", "wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle" },
    { "XF86MonBrightnessUp", "brightnessctl -e4 -n2 set 5%+" },
    { "XF86MonBrightnessDown", "brightnessctl -e4 -n2 set 5%-" },
}) do
    hl.bind(media[1], exec(media[2]), repeating)
end

for _, media in ipairs({
    { "XF86AudioNext", "playerctl next" },
    { "XF86AudioPause", "playerctl play-pause" },
    { "XF86AudioPlay", "playerctl play-pause" },
    { "XF86AudioPrev", "playerctl previous" },
}) do
    hl.bind(media[1], exec(media[2]), { locked = true })
end

hl.window_rule({
    name = "terminal-style",
    match = { class = "^(kitty|terminator)$" },
    opacity = "1.0 override 0.8 override 1.0 override",
    rounding = 15,
})

hl.window_rule({
    name = "suppress-maximize-events",
    match = { class = ".*" },
    suppress_event = "maximize",
})

hl.window_rule({
    name = "fix-xwayland-drags",
    match = {
        class = "^$",
        title = "^$",
        xwayland = true,
        float = true,
        fullscreen = false,
        pin = false,
    },
    no_focus = true,
})

hl.window_rule({
    name = "move-hyprland-run",
    match = { class = "hyprland-run" },
    move = "20 monitor_h-120",
    float = true,
})

local startupWindowWorkspaces = {
    ["chrome-www.youtube.com__-Default"] = 4,
    ["chrome-open.spotify.com__-Default"] = 4,
    ["com.github.wwmm.easyeffects"] = 9,
}

-- Workspaces 4 and 9 are pinned to the Philips by scripts/setup-monitors, which
-- resolves the panel by EDID serial. Do not hardcode a connector name here: it
-- would go stale the moment the cables are swapped.

hl.on("window.open_early", function(win)
    local workspace = startupWindowWorkspaces[win.class]
    if workspace then
        hl.dispatch(hl.dsp.window.move({ window = win, workspace = workspace }))
    end
end)
