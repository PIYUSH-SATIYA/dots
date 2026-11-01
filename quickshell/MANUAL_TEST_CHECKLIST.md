# Quickshell Migration — Complete Manual Test Checklist

Use this file for the final manual validation pass. Mark a checkbox only after the
item actually passes. Leave it unchecked and record the failure in
[Test Notes](#test-notes) if it fails or cannot be tested.

Do not remove Walker, Elephant, Waybar, SwayNC, or SwayOSD yet. Both shell modes
must remain independently usable until this review is complete and the results
have been handed back for fixes.

## Test Metadata

- Tester:
- Date:
- Host:
- Session type: Hyprland / Wayland
- Display layout and scale:
- Branch:
- Commit:
- Starting shell mode:
- Quickshell version:
- Hyprland version:

## How to Run

Recommended order:

1. Run the automated preconditions.
2. Test a fresh login/restart in Quickshell mode.
3. Run the Quickshell feature sections.
4. Switch to legacy and run the legacy regression section.
5. Test a fresh login/restart in legacy mode.
6. Switch back to Quickshell and complete the final-state checks.
7. Fill in the notes and hand this file back.

Marking convention:

- `[x]` — passed.
- `[ ]` — not run, failed, or blocked. Record it under **Failures** in the notes.
- Use the section name and exact item text when reporting a failure.

Capture evidence for every failure where possible:

```text
Screenshot:
Log command:
Log excerpt:
Frequency:
Reproduction steps:
```

Useful commands:

```bash
hyprctl configerrors
qmllint quickshell/*.qml
bash -n hypr/scripts/*.sh quickshell/scripts/*.sh
luac -p hypr/*.lua hypr/binds/*.lua
qs log --tail 100
hyprctl layers
systemctl --user status elephant.service swaync.service
pgrep -a -x quickshell
pgrep -a -x waybar
pgrep -a -x swaync
pgrep -a -x swayosd-server
pgrep -a -x walker
pgrep -a -x elephant
```

## Preconditions

- [x] `hyprctl configerrors` reports no errors.
- [x] `qmllint quickshell/*.qml` passes.
  this showed no resp.
- [ ] `bash -n` passes for every script under `hypr/scripts/` and `quickshell/scripts/`.
- [ ] `luac -p` passes for the edited Hyprland Lua files.
- [ ] The current branch and commit are recorded above.
- [ ] Audio output is unmuted at a safe starting volume.
- [ ] Brightness is at a safe starting level.
- [ ] A media player with a test track is available.
- [ ] A Wi-Fi and Bluetooth device are available for state-change tests.
- [ ] A second monitor is available if multi-monitor behavior is in scope.
- [ ] The legacy stack is still installed and has not been removed.
- [ ] The test session has a terminal available for `qs ipc`, `hyprctl`, and logs.
- [ ] The tester understands how to switch modes with `shell-mode.sh`.

## Fresh Session and Mode Independence

Run the first two items after a full logout/relogin or reboot, not only after
`hyprctl reload`.

### Quickshell session startup

- [x] The session starts with the intended mode from `~/.local/state/hypr-shell/mode`.
- [x] Quickshell starts automatically.
- [x] Exactly one Quickshell instance is running.
- [x] The Quickshell bar appears and reserves the expected space.
- [x] No Waybar process is running.
- [x] No SwayNC process is running.
- [x] No SwayOSD server is running.
- [x] No Elephant process is running.
- [x] No Walker process is running.
- [x] `swaync.service` is masked or inactive.
- [x] The notification daemon is provided by Quickshell.
- [x] `SUPER+SPACE` opens the native launcher.
- [x] The launcher layer appears on the active monitor.
  i only have one monitor and this setup is intended to be used on single monitor setup only.

### Legacy session startup

all of can already be tested with your commands, tell me to restart and all when needed.


- [ ] The session starts with legacy mode selected.
- [ ] Waybar starts and exactly one instance is running.
- [ ] SwayNC starts and exactly one instance is running.
- [ ] SwayOSD starts and exactly one instance is running.
- [ ] Elephant starts.
- [ ] The Walker service starts.
- [ ] Quickshell is not running.
- [ ] `swaync.service` is unmasked.
- [ ] The legacy notification backend is active.
- [ ] `SUPER+SPACE` opens Walker.
- [ ] The Walker layer appears on the active monitor.

### Switching modes

- [ ] `shell-mode.sh quickshell` stops Waybar.
- [ ] `shell-mode.sh quickshell` stops SwayNC and masks `swaync.service`.
- [ ] `shell-mode.sh quickshell` stops `swayosd-server`.
- [ ] `shell-mode.sh quickshell` stops Walker.
- [ ] `shell-mode.sh quickshell` stops Elephant.
- [ ] Quickshell starts and the bar appears without a duplicate bar.
- [ ] `shell-mode.sh legacy` stops Quickshell.
- [ ] `shell-mode.sh legacy` unmask/starts SwayNC.
- [ ] `shell-mode.sh legacy` starts `swayosd-server`.
- [ ] `shell-mode.sh legacy` starts Waybar.
- [ ] `shell-mode.sh legacy` starts Elephant.
- [ ] `shell-mode.sh legacy` starts the Walker service.
- [ ] `shell-mode.sh restart` restarts the active shell cleanly.
- [ ] `shell-mode.sh toggle` switches modes without duplicate daemons.
- [ ] `SUPER+CTRL+SPACE` switches modes without duplicate daemons.
- [ ] Switching to Quickshell does not leave legacy launcher processes behind.
- [ ] Switching to legacy does not leave Quickshell processes behind.
- [ ] `launcher-control.sh` opens the native launcher in Quickshell mode.
- [ ] `launcher-control.sh` opens Walker in legacy mode.
- [ ] The Quickshell failure fallback starts Waybar, SwayNC, SwayOSD, Elephant, and Walker.
- [ ] Notifications survive a Quickshell reload where expected.
- [ ] No focus is left stuck after a mode switch.

### Theme refresh independence

- [ ] `theme-system/refresh.sh` updates Quickshell colors in Quickshell mode.
- [ ] Quickshell theme refresh does not require SwayNC.
- [ ] Quickshell theme refresh does not start Walker or Elephant.
- [ ] Legacy theme refresh restarts/reloads Waybar correctly.
- [ ] Legacy theme refresh updates SwayNC correctly.
- [ ] Legacy theme refresh still starts/uses the expected services.

all theme refresh works in quickshell mode.

## Quickshell Bar

### Layout and theme

- [x] Bar height is 28px and reserves space.
- [x] Bar background, separator, and text colors match the active pywal theme.
- [x] Changing theme with `theme-system/refresh.sh` updates Quickshell colors.
- [x] No stale Waybar or SwayNC visuals remain in Quickshell mode.
- [x] Bar does not overlap the launcher, OSD, or notification center.

### Workspaces

- [x] Workspaces 1-5 are always visible.
- [x] Focused workspace is highlighted.
- [x] Occupied and empty workspaces are visually distinct.
  - Addressed: occupied workspaces use a subtle background and brighter text; empty workspaces are dimmed.
- [x] Clicking a workspace focuses it.
- [x] Scrolling over workspaces switches relative workspaces.
- [x] Workspace state updates after opening/closing windows.
- [x] Workspace state updates after moving a window to another workspace.

### Media

- [x] Current artist/title appears when a player is active.
- [x] Long titles truncate cleanly.
- [x] Click toggles play/pause.
- [x] Right-click stops playback.
- [x] Scroll up goes to the previous track.
- [x] Scroll down goes to the next track.
- [x] Module hides when no player is active.
- [x] Paused state is visually distinct.
- [x] Track changes update the widget without a restart.

### Clock

- [x] Clock shows `HH:mm`.
- [x] Left-click toggles the date alternate format.
- [x] Right-click opens `peaclock`.
- [x] Clock updates at minute boundaries.
- [x] Clock uses the expected timezone.
- [x] Hovering the clock shows a month calendar with today highlighted.

### System metrics

- [x] Per-core CPU sparkline updates.
  - Verified: hairline gaps between cores; hovering shows per-core percentages.
- [x] CPU percentage updates.
- [x] Memory usage updates.
- [x] CPU temperature updates.
- [x] Load average updates.
- [x] Warning/critical colors appear at the configured thresholds.

### Battery and power

- [x] Battery percentage appears when a battery is present.
- [x] Charging/full/icon state is correct.
- [x] Low/critical battery colors are correct.
- [x] Power profile icon changes between performance, balanced, and power-saver.
- [x] Clicking the power profile cycles profiles.
- [x] The selected profile is reflected after the popup is closed.

### Bluetooth

- [x] Disabled/off/no-controller state shows the correct icon.
- [x] Enabled state shows the correct icon.
- [x] Connected device name appears.
- [x] Clicking opens Bluetui in Kitty.
- [x] Bluetooth state updates after adapter/device changes.
- [x] Disconnecting and reconnecting a device updates the bar.

### Audio

- [x] Volume icon reflects the actual volume.
  - Quickshell now shows a hover volume slider; legacy mode still lacks the drawer, while scrolling updates the OSD.
- [x] Muted state shows the muted icon.
- [x] Left-click toggles mute.
- [x] Right-click opens `pavucontrol`.
- [x] Scroll changes volume by the expected step.
- [x] Volume OSD appears for click, scroll, and media keys.
- [x] Bar icon catches up after OSD changes.
- [x] Volume is capped at 100% in the bar, OSD, and control-center paths.
- [x] Volume cannot exceed 100% via the OSD, bar, or control center.
- [x] `wpctl` state and the bar agree after several changes.
  - Fixed: `osd-volume.sh` uses `wpctl set-volume -l 1.0`; `Osd.qml` clamps; the control-center slider max is 100. External mixers such as `pavucontrol` can still set PipeWire above 100%.

### Brightness

- [x] Brightness icon reflects the actual percentage.
- [x] Scroll changes brightness by the expected step.
  - same no slider and all as with volume
- [x] Brightness OSD appears for scroll and media keys.
- [x] Brightness respects the 10% minimum.
- [x] Brightness does not exceed 100%.
- [x] `brightnessctl`/sysfs state and the bar agree after several changes.

### Network

- [x] Connected Wi-Fi shows the SSID.
- [x] Disconnected/disabled state shows the correct icon.
- [x] Clicking opens Impala.
- [x] Right-click starts a scan.
- [x] Network state updates after connecting/disconnecting.
- [x] Network state updates after switching between Wi-Fi and Ethernet.

### Tray

- [x] Tray icons appear at the expected size.
- [x] Tray is hidden when no items exist.
- [x] Left-click performs item activation.
- [x] Right-click opens the tray menu where supported.
- [x] Scroll events reach the tray item.
- [x] Attention state is visually distinct.
- [x] A tray menu does not leave focus stuck after closing.
- [x] Tray icons update after an application exits or starts.

### Bar actions

- [x] Bell button toggles the notification center.
  - Verified: opening the center clears active toasts first, so the old popup no longer remains.
- [x] Bell color reflects DND state.
- [x] `QS` button opens the native launcher.
- [x] `SUPER+SPACE` opens the native launcher.
- [x] Bar remains clickable after shell reload.
- [x Bar remains clickable after the launcher closes.

## Notification Center and Toasts

### Toasts

- [x] A normal notification appears top-right below the bar.
- [x] A low-urgency notification uses the low timeout.
- [x] A critical notification does not auto-expire.
- [x] Toasts stack newest-first.
- [x] More than five toasts keeps only the newest five.
- [x] The default action runs when the toast is clicked.
- [x] Action buttons run the correct action.
- [x] The close button dismisses the toast.
- [x] Expired notifications disappear from toasts and remain tracked as configured.
- [x] Notification images render correctly.
- [x] Long summary/body text wraps or elides correctly.
- [x] Notifications are not shown while DND is enabled.
- [x] Under DND, notifications are still tracked for later viewing.
- [x] A notification with an action does not leave the launcher or center focused.
- [x] Multiple rapid notifications do not corrupt the stack.
  - i havent testsed all of it properly though as it requires scripts/ you give me directs commands to run these an di will answer you on the go about itt.

### Notification center

- [x] The bar bell opens and closes the center.
- [x] `SUPER+SHIFT+COMMA` toggles the center.
- [x] Escape closes the center.
- [x] The close button closes the center.
- [x] The center lists notifications newest-first.
- [x] Empty state shows `No Notifications`.
- [x] The count reflects tracked notifications.
- [x] Clear All dismisses all tracked notifications.
- [x] DND button toggles state and updates the bell.
- [x] `SUPER+CTRL+COMMA` closes the latest notification.
- [x] `SUPER+SHIFT+CTRL+COMMA` clears all notifications.
- [x] `SUPER+ALT+COMMA` toggles DND.
- [x] Center height fits on screen and scrolls when needed.
- [x] The center does not steal focus unexpectedly.
- [x] Clicking outside the center behaves as documented; if not implemented, record it as deferred.
- [ ] Opening the launcher while the center is open leaves one usable focused surface.

### Control center widgets

-- not doing alll these test, will update and fix if needed in another sessoins if required later.


- [ ] Quick action buttons open Wi-Fi, Bluetooth, and the color picker.
- [ ] Quick action active states reflect Wi-Fi, Bluetooth, and DND.
- [ ] Quick action DND button matches footer DND state.
- [ ] Volume slider matches current volume.
- [ ] Dragging the volume slider updates the sink.
- [ ] Volume slider updates the OSD.
- [ ] Volume slider supports 0-100%.
- [ ] Mute state is reflected in the volume widget.
- [ ] Brightness slider matches current brightness.
- [ ] Dragging the brightness slider updates the backlight.
- [ ] Brightness slider updates the OSD.
- [ ] Brightness slider clamps between 10% and 100%.
- [ ] MPRIS widget shows current art/title/artist.
- [ ] MPRIS previous, play/pause, next work.
- [ ] MPRIS widget updates on track changes.
- [ ] MPRIS widget hides when no player exists.
- [ ] Opening and closing the control center repeatedly does not leave focus stuck.

## OSD

- not doing all these exacly, will fix on the go in other session if required later.
- [ ] OSD dimensions are 276x64 and centered horizontally.
- [ ] OSD bottom margin is 160px.
- [ ] OSD uses the `quickshell-osd` namespace.
- [ ] OSD is non-focusable and does not reserve space.
- [ ] Volume up/down keys adjust volume and show the OSD.
- [ ] `ALT` volume up/down adjusts by the fine step.
- [ ] Mute key toggles mute and shows the OSD.
- [ ] Brightness up/down keys adjust and show the OSD.
- [ ] `ALT` brightness up/down adjusts by the fine step.
- [ ] Held/repeated keys queue updates without dropping steps.
- [ ] OSD hides after the configured timeout.
- [ ] OSD restarts its timer on repeated updates.
- [ ] Muted OSD shows `Muted` and the muted icon.
- [x] Volume is capped at 100%; the OSD never displays above 100%.
- [ ] Brightness OSD percentage matches sysfs/`brightnessctl`.
- [ ] OSD does not appear from SwayOSD in Quickshell mode.
- [ ] Legacy mode still shows the original SwayOSD.
- [ ] OSD appears on the correct monitor; record multi-monitor limitations if present.

## Native Launcher

-- done all of the required once directly from what i can remembt. will refer and fix later in other session if required.

### Window, lifecycle, and focus

- [ ] `SUPER+SPACE` toggles the launcher.
- [ ] Pressing `SUPER+SPACE` while open closes it.
- [ ] The launcher uses the `quickshell-launcher` namespace.
- [ ] The launcher is centered and receives keyboard focus.
- [ ] The launcher opens on the active monitor.
- [ ] The launcher works after switching from legacy to Quickshell.
- [ ] The launcher works after `shell-mode.sh restart`.
- [ ] Typing filters the current result list.
- [ ] Up/Down and PageUp/PageDown move the selection.
- [ ] Enter activates the selected result.
- [ ] Escape closes the launcher.
- [ ] Clicking outside the panel closes the launcher.
- [ ] Focus returns to the previously focused window after Escape.
- [ ] Focus returns to the previously focused window after click-outside close.
- [ ] Focus returns after activating an application.
- [ ] Open/close the launcher 20 times; focus is not stuck.
- [ ] Rapidly toggle the launcher 10 times; only one layer exists and focus is usable.
- [ ] No duplicate `quickshell-launcher` layer remains after closing.
- [ ] Reopening the launcher shows an empty/stale-free query state.
- [ ] The launcher can be opened again immediately after closing.
- [ ] Qt Wayland text-input warnings, if present in `qs log`, do not correspond to stuck focus; record the count in the notes.

### Query behavior

- [ ] Empty query lists applications.
- [ ] Typing filters applications.
- [ ] Clearing the query restores the full list.
- [ ] Rapid typing followed by a pause produces the correct final result.
- [ ] A query never leaves the result list empty while the process is still running.
- [ ] Result count updates with the visible list.
- [ ] Selection resets safely when the query changes.
- [ ] Arrow navigation wraps at the top and bottom.
- [ ] Activating a result closes the launcher.
- [ ] The launcher does not freeze while catalog data reloads.
- [ ] Empty and failed queries show a useful message.
- [ ] Stale results from a previous query do not replace newer results.

### Calculator regression

- [ ] In default apps mode, `=2+2*5` returns `12` within about one second.
- [ ] In default apps mode, `=sqrt(144)+123` returns `135` within about one second.
- [ ] Calculator results are not empty after the query timer settles.
- [ ] Calculator prefix mode does not leave the header stuck on Applications.
- [ ] Explicit calculator mode also evaluates `2+2*5`.
- [ ] Calculator action copies the result to the clipboard.
- [ ] Calculator handles an invalid expression without crashing the launcher.

### Modes and actions

- [ ] Empty query lists applications.
- [ ] Selecting an application launches it.
- [ ] `/` searches files and Enter opens the selected file.
- [ ] `/` does not block typing while `fd` runs.
- [ ] `:` lists clipboard history and Enter copies the selected entry.
- [ ] The copied clipboard item matches the selected entry.
- [ ] `` ` `` lists static and dynamic themes and Enter applies the selected theme.
- [ ] Theme selection updates the bar colors.
- [ ] `!` lists wallpapers and Enter applies the selected wallpaper.
- [ ] Wallpaper selection updates the desktop and theme colors.
- [ ] `?` lists keybindings and Enter copies the selected keybind.
- [ ] `.` lists symbols and Enter copies the selected glyph.
- [ ] `=` evaluates an expression and Enter copies the result.
- [ ] `@` searches the web or opens a URL.
- [ ] `@` with a full URL opens the URL directly.
- [ ] `>` runs the entered shell command.
- [ ] `>` only runs after explicit activation; typing alone does not execute.
- [ ] `$` lists Hyprland windows and Enter focuses the selected window.
- [ ] Window focus works across workspaces.
- [x] `SUPER+V` opens clipboard mode directly.
  - Verified: starts from `cliphist`, refreshes every second while open, and shows a side-by-side preview. Entries are not hardcoded.

- [ ] `SUPER+E` opens symbols mode directly.
- [ ] `SUPER+K` opens keybind mode directly.
- [ ] `SUPER+SHIFT+W` opens wallpaper mode directly.
- [ ] `SUPER+ALT+W` opens theme mode directly.
- [ ] Help mode lists every launcher mode.
- [ ] Selecting a help item enters the expected mode.
- [ ] Prefix changes update the mode label and placeholder.
- [ ] Prefix removal returns to applications mode.
- [ ] Every mode can be closed with Escape and click-outside.
- [ ] Every mode leaves focus usable after activation.

## Legacy Mode Regression

Legacy is not being removed in this pass. Confirm it still works independently.

- [ ] Waybar appears and reserves space.
- [ ] Waybar workspace, media, clock, metrics, battery, power, Bluetooth, audio, brightness, network, and tray modules still work.
- [ ] SwayNC notifications and control center work.
- [ ] SwayOSD volume and brightness OSDs work.
- [ ] `SUPER+SPACE` opens Walker.
- [ ] `SUPER+V` opens Walker clipboard mode.
- [ ] `SUPER+E` opens Walker symbols mode.
- [ ] `SUPER+K` opens Walker keybind mode.
- [ ] `SUPER+SHIFT+W` opens Walker wallpaper mode.
- [ ] `SUPER+ALT+W` opens Walker theme mode.
- [ ] Walker can select and launch an application.
- [ ] Walker can copy a clipboard entry.
- [ ] Walker can apply a wallpaper.
- [ ] Walker can apply a theme.
- [ ] `launcher-control.sh` modes route to Walker correctly.
- [ ] Theme refresh still updates Waybar and SwayNC.
- [ ] Legacy mode is not required to implement the native-only `$` windows, `>` runner, or help modes; record fallback behavior if tested.
- [ ] Notifications, OSD, and bar actions do not leave focus stuck.
- [ ] Switching back to Quickshell stops all legacy launchers and OSDs.

## Desktop Integrations

- [ ] `SUPER+RETURN` opens Kitty in the current working directory.
- [ ] Browser, incognito browser, Yazi, Neovim, and btop binds work.
- [ ] Lock screen works.
- [ ] wlogout opens with blur.
- [ ] Impala and Bluetui open as floating terminals.
- [ ] Screenshot binds copy/save correctly.
- [ ] Screen recording starts.
- [ ] Color picker copies a hex code.
- [ ] `SUPER+SHIFT+R` reloads Hyprland without breaking the shell.
- [ ] `SUPER+SHIFT+SPACE` restarts the active shell.
- [ ] `SUPER+CTRL+SPACE` toggles shell mode.
- [ ] Wallpaper and theme menus use the native launcher in Quickshell mode.
- [ ] Wallpaper and theme menus use Walker in legacy mode.
- [ ] `CTRL+ALT+I` toggles idle locking.
- [ ] `hypridle` state notifications appear in the active notification backend.
- [ ] Tray menus and notification actions do not leave focus stuck.
- [ ] No keybind opens a removed or missing launcher provider.

## Deferred Items

These are intentionally not blockers for this iteration. Confirm they are still
acceptable as deferred items.

- [ ] Notification grouping and inline replies remain deferred.
- [ ] Per-application volume expansion remains deferred.
- [ ] Idle inhibitor listing/clearing remains deferred.
- [ ] Notification-center outside-click dismissal remains deferred if not implemented.
- [ ] Waybar audio/brightness drawer parity beyond sliders remains deferred.
- [ ] Full SwayNC styling parity remains deferred.
- [ ] Multi-monitor OSD placement behavior remains deferred.
- [ ] Any visual differences that do not break function remain deferred.

## Final State

- [ ] The final shell mode is intentional and recorded above.
- [ ] `shell-mode.sh status` reports the intended final mode.
- [ ] No duplicate bar is running.
- [ ] No duplicate notification daemon is running.
- [ ] No duplicate OSD server is running.
- [ ] Quickshell mode has no Waybar, SwayNC, SwayOSD, Walker, or Elephant processes.
- [ ] Legacy mode has no Quickshell process.
- [ ] Volume and brightness are left at safe values.
- [ ] The launcher is closed and focus is on a normal window.
- [ ] Unrelated worktree changes are identified and were not included in migration commits.
- [ ] All failures are documented below.
- [ ] The completed file is ready to hand back for fixes.

## Test Notes

Fill this section in after the run. Keep the section headings so the results are
easy to process.

### Environment and session

- Tester:
- Date:
- Branch and commit:
- Hyprland version:
- Quickshell version:
- Display layout:
- Final mode:
- Fresh-session tests performed in: Quickshell / legacy / both

### Result summary

- Total checked:
- Passed:
- Failed:
- Not run:
- Blocked:
- Qt text-input warning observed: yes / no
- Warning count/conditions:

### Failures

Add one block per failure.

#### Failure 1: `<short title>`

- Checklist section/item:
- Expected:
- Actual:
- Reproduction steps:
- Frequency:
- Screenshot or log:
- Suspected cause:
- Severity: blocker / major / minor

#### Failure 2: `<short title>`

- Checklist section/item:
- Expected:
- Actual:
- Reproduction steps:
- Frequency:
- Screenshot or log:
- Suspected cause:
- Severity: blocker / major / minor

### Focus and input observations

- Did focus ever remain stuck after closing the launcher?
- Did focus return after activating an application?
- Did any Qt text-input warning correspond to a visible problem?
- Did tray menus or notification actions steal focus?
- Any keyboard shortcut conflicts:

### Visual observations

- Theme/pywal inconsistencies:
- Bar alignment or spacing issues:
- Launcher/OSD/notification-center overlap:
- Text truncation or missing icons:
- Multi-monitor issues:

### Legacy-mode observations

- Walker behavior:
- Elephant/Walker lifecycle:
- Waybar/SwayNC/SwayOSD behavior:
- Theme refresh behavior:
- Services still running unexpectedly:

### Deferred-item confirmation

- Items still acceptable as deferred:
- Items that should be pulled into this iteration:
- New deferred items discovered:

### Handoff notes for the next agent

- Highest-priority failure:
- Files likely involved:
- Suggested fix direction:
- Tests to rerun after fixes:
- Do not change:
- Additional context:
