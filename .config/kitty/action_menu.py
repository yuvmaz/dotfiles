#!/usr/bin/env python3
# SPDX-License-Identifier: GPL-3.0
# Action menu kitten for kitty

import sys
from typing import List, Optional

from kittens.tui.handler import Handler, kitten_ui
from kittens.tui.operations import MouseTracking
from kittens.tui.loop import Loop, MouseButton, EventType
from kitty.fast_data_types import add_timer, wcswidth
from kitty.typing_compat import KeyEventType, BossType


MENU = [
    ("Copy Selection", "copy_sel"),
    ("Copy Link Address", "copy_link"),
    ("Copy Path", "copy_path"),
    ("Paste from Clipboard", "paste_clip"),
    ("New tab", "new_tab"),
    ("Split horizontally", "hsplit"),
    ("Split vertically", "vsplit"),
    ("Close Tab/Window", "close"),
    ("Cancel", None),
]


class ActionMenu(Handler):
    mouse_tracking = MouseTracking.full

    def initialize(self) -> None:
        self.choice = None
        self.selected = 0
        self.draw()

    def draw(self) -> None:
        self.cmd.clear_screen()
        self.cmd.set_cursor_visible(True)
        self.cmd.set_default_colors()

        lines = [f"{i}. {label}" for i, (label, _) in enumerate(MENU, 1)]
        max_len = max(wcswidth(line) for line in lines)
        self.box_width = max_len + 4
        self.write("┌" + "─" * (self.box_width - 2) + "┐\r\n")
        for index, line in enumerate(lines):
            padding = " " * (max_len - wcswidth(line))
            if index == self.selected:
                self.write(f"│ \x1b[7m{line}{padding}\x1b[0m │\r\n")
            else:
                self.write(f"│ {line}{padding} │\r\n")
        self.write("└" + "─" * (self.box_width - 2) + "┘\r\n")
        self.write("\r\nArrows + Enter, keypad, or click; Esc cancels.\r\n")

    def on_key(self, key_event: KeyEventType) -> None:
        key = str(key_event.key).upper().replace("_", "")
        if key == "ESCAPE":
            self.quit_loop(0)
            return

        keypad_digits = {
            "KP0": 0, "KP1": 1, "KP2": 2, "KP3": 3, "KP4": 4,
            "KP5": 5, "KP6": 6, "KP7": 7, "KP8": 8, "KP9": 9,
            # NumLock-off keypad key names.
            "KPINSERT": 0, "KPEND": 1, "KPDOWN": 2, "KPNEXT": 3,
            "KPLEFT": 4, "KPBEGIN": 5, "KPRIGHT": 6, "KPHOME": 7,
            "KPUP": 8, "KPPAGEUP": 9, "KPPRIOR": 9,
        }
        number = int(key) if key.isdigit() else keypad_digits.get(key)
        if number is not None and 1 <= number <= len(MENU):
            self.choice = number - 1
            self.quit_loop(0)
        elif key in ("UP", "KPUP"):
            self.selected = (self.selected - 1) % len(MENU)
            self.draw()
        elif key in ("DOWN", "KPDOWN"):
            self.selected = (self.selected + 1) % len(MENU)
            self.draw()
        elif key in ("ENTER", "KPENTER", "RETURN"):
            self.choice = self.selected
            self.quit_loop(0)

    def on_mouse_event(self, event) -> None:
        if event.type == EventType.RELEASE and event.buttons & MouseButton.LEFT:
            row = event.cell_y
            if 1 <= row <= len(MENU) and 0 <= event.cell_x < self.box_width:
                self.choice = row - 1
                self.quit_loop(0)

    on_interrupt = on_eot = on_term = lambda self: self.quit_loop(0)


@kitten_ui(allow_remote_control=True)
def main(args):
    loop = Loop()
    handler = ActionMenu()
    loop.loop(handler)
    return handler.choice


def schedule_remote(boss, wid, *, action_name=None, launch_location=None,
                    target_window_obj=None, combine_action=None):
    def run(_timer_id=None):
        if combine_action:
            boss.combine(combine_action, target_window_obj)
        elif action_name:
            boss.call_remote_control(None, ("action", f"--match=id:{wid}", action_name))
        elif launch_location:
            boss.call_remote_control(None, ("launch", f"--match=id:{wid}", f"--location={launch_location}"))
        elif target_window_obj is not None:
            boss.call_remote_control(target_window_obj, ("action", "new_tab"))
    add_timer(run, 0, False)


def handle_result(args, answer, target_window_id, boss: BossType):
    if answer is None:
        return
    _, action = MENU[answer]
    if action is None:
        return
    window = boss.window_id_map.get(target_window_id)
    if window is None:
        return
    wid = window.id

    if action == "copy_sel":
        schedule_remote(boss, wid, action_name="copy_to_clipboard")
    elif action == "copy_link":
        schedule_remote(boss, wid, target_window_obj=window,
                        combine_action="kitten hints --program @ --type url")
    elif action == "copy_path":
        schedule_remote(boss, wid, target_window_obj=window,
                        combine_action="kitten hints --program @ --type path")
    elif action == "paste_clip":
        schedule_remote(boss, wid, action_name="paste_from_clipboard")
    elif action == "new_tab":
        schedule_remote(boss, wid, target_window_obj=window)
    elif action == "hsplit":
        schedule_remote(boss, wid, launch_location="hsplit")
    elif action == "vsplit":
        schedule_remote(boss, wid, launch_location="vsplit")
    elif action == "close":
        schedule_remote(boss, wid, action_name="close_window")
