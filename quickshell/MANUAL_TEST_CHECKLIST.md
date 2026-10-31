# Quickshell Migration Manual Test Checklist

Run this checklist from top to bottom after the first-iteration migration is complete.
Reset the session to a known state before starting.

First iteration implements the native bar, notifications/toasts, OSD, control-center quick actions, volume/brightness sliders, MPRIS controls, and the native launcher. Known deferred scope is listed at the end.

## Preconditions

- [ ] `hyprctl configerrors` returns nothing.
- [ ] `qmllint quickshell/*.qml` passes.
- [ ] `bash -n` passes for every script under `hypr/scripts/` and `quickshell/scripts/`.
- [ ] `~/.local/state/hypr-shell/mode` is understood. Start in `legacy`.
- [ ] `swaync`, `swayosd-server`, and `waybar` are running in legacy mode.
- [ ] `quickshell` is not running in legacy mode.
- [ ] Audio sink is unmuted at a comfortable starting volume.
- [ ] Brightness is at a safe starting level.
- [ ] A media player with a test track is available.

## Mode Switching

- [ ] `shell-mode.sh quickshell` stops Waybar.
- [ ] `shell-mode.sh quickshell` stops SwayNC and masks `swaync.service`.
- [ ] `shell-mode.sh quickshell` stops `swayosd-server`.
- [ ] Quickshell starts and the bar appears without a duplicate bar.
- [ ] `shell-mode.sh legacy` stops Quickshell.
- [ ] `shell-mode.sh legacy` unmask/starts SwayNC.
- [ ] `shell-mode.sh legacy` starts `swayosd-server`.
- [ ] `shell-mode.sh legacy` starts Waybar.
- [ ] `shell-mode.sh restart` restarts the active shell cleanly.
- [ ] `shell-mode.sh toggle` switches between modes without duplication.
- [ ] Quickshell failure fallback starts Waybar, SwayNC, and SwayOSD.
- [ ] Notifications survive a Quickshell reload where expected.

## Bar

### Layout and theme

- [ ] Bar height is 28px and reserves space.
- [ ] Bar background, separator, and text colors match the active pywal theme.
- [ ] Changing theme with `theme-system/refresh.sh` updates Quickshell colors.
- [ ] No stale Waybar or SwayNC visuals remain in Quickshell mode.

### Workspaces

- [ ] Workspaces 1-5 are always visible.
- [ ] Focused workspace is highlighted.
- [ ] Occupied and empty workspaces are visually distinct.
- [ ] Clicking a workspace focuses it.
- [ ] Scrolling over workspaces switches relative workspaces.
- [ ] Workspace state updates after opening/closing windows.

### Media

- [ ] Current artist/title appears when a player is active.
- [ ] Long titles truncate cleanly.
- [ ] Click toggles play/pause.
- [ ] Right-click stops playback.
- [ ] Scroll up goes to previous track.
- [ ] Scroll down goes to next track.
- [ ] Module hides when no player is active.
- [ ] Paused state is visually distinct.

### Clock

- [ ] Clock shows `HH:mm`.
- [ ] Left-click toggles date alternate format.
- [ ] Right-click opens `peaclock`.
- [ ] Clock updates at minute boundaries.
- [ ] Clock uses the expected timezone.

### System metrics

- [ ] Per-core CPU sparkline updates.
- [ ] CPU percentage updates.
- [ ] Memory usage updates.
- [ ] CPU temperature updates.
- [ ] Load average updates.
- [ ] Warning/critical colors appear at configured thresholds.

### Battery and power

- [ ] Battery percentage appears when a battery is present.
- [ ] Charging/full/icon state is correct.
- [ ] Low/critical battery colors are correct.
- [ ] Power profile icon changes between performance, balanced, and power-saver.
- [ ] Clicking power profile cycles profiles.

### Bluetooth

- [ ] Disabled/off/no-controller state shows the correct icon.
- [ ] Enabled state shows the correct icon.
- [ ] Connected device name appears.
- [ ] Clicking opens Bluetui in Kitty.
- [ ] Bluetooth state updates after adapter/device changes.

### Audio

- [ ] Volume icon reflects actual volume.
- [ ] Muted state shows the muted icon.
- [ ] Left-click toggles mute.
- [ ] Right-click opens `pavucontrol`.
- [ ] Scroll changes volume by the expected step.
- [ ] Volume OSD appears for click, scroll, and media keys.
- [ ] Bar icon catches up after OSD changes.
- [ ] Volume can exceed 100% up to the configured limit.

### Brightness

- [ ] Brightness icon reflects actual percentage.
- [ ] Scroll changes brightness by the expected step.
- [ ] Brightness OSD appears for scroll and media keys.
- [ ] Brightness respects the 10% minimum.
- [ ] Brightness does not exceed 100%.

### Network

- [ ] Connected Wi-Fi shows SSID.
- [ ] Disconnected/disabled state shows the correct icon.
- [ ] Clicking opens Impala.
- [ ] Right-click starts a scan.
- [ ] Network state updates after connecting/disconnecting.

### Tray

- [ ] Tray icons appear at the expected size.
- [ ] Tray hidden when no items exist.
- [ ] Left-click performs the item activation.
- [ ] Right-click opens the tray menu where supported.
- [ ] Scroll events reach the tray item.
- [ ] Attention state is visually distinct.

### Bar actions

- [ ] Bell button toggles the notification center.
- [ ] Bell color reflects DND state.
- [ ] `QS` button opens the native launcher.
- [ ] `SUPER+SPACE` opens the native launcher.
- [ ] Bar remains clickable after shell reload.

## Notification Center and Toasts

### Toasts

- [ ] Normal notification appears top-right below the bar.
- [ ] Low-urgency notification uses the low timeout.
- [ ] Critical notification does not auto-expire.
- [ ] Toasts stack newest-first.
- [ ] More than five toasts keeps only the newest five.
- [ ] Default action runs when the toast is clicked.
- [ ] Action buttons run the correct action.
- [ ] Close button dismisses the toast.
- [ ] Expired notifications disappear from toasts and remain tracked as configured.
- [ ] Notification images render correctly.
- [ ] Long summary/body text wraps or elides correctly.
- [ ] Notifications are not shown while DND is enabled.
- [ ] Under DND, notifications are still tracked for later viewing.

### Center

- [ ] Bar bell opens and closes the center.
- [ ] `SUPER+SHIFT+COMMA` toggles the center.
- [ ] Escape closes the center.
- [ ] Close button closes the center.
- [ ] Center lists notifications newest-first.
- [ ] Empty state shows "No Notifications".
- [ ] Count reflects tracked notifications.
- [ ] Clear All dismisses all tracked notifications.
- [ ] DND button toggles state and updates the bell.
- [ ] `SUPER+CTRL+COMMA` closes the latest notification.
- [ ] `SUPER+SHIFT+CTRL+COMMA` clears all notifications.
- [ ] `SUPER+ALT+COMMA` toggles DND.
- [ ] Center height fits on screen and scrolls when needed.
- [ ] Center does not steal focus unexpectedly.

### Control center widgets

- [ ] Quick action buttons open Wi-Fi, Bluetooth, and color picker.
- [ ] Quick action active states reflect Wi-Fi, Bluetooth, and DND.
- [ ] Quick action DND button matches footer DND state.
- [ ] Volume slider matches current volume.
- [ ] Dragging the volume slider updates the sink.
- [ ] Volume slider updates the OSD.
- [ ] Volume slider supports 0-150%.
- [ ] Mute state is reflected in the volume widget.
- [ ] Brightness slider matches current brightness.
- [ ] Dragging the brightness slider updates the backlight.
- [ ] Brightness slider updates the OSD.
- [ ] Brightness slider clamps between 10% and 100%.
- [ ] MPRIS widget shows current art/title/artist.
- [ ] MPRIS previous, play/pause, next work.
- [ ] MPRIS widget updates on track changes.
- [ ] MPRIS widget hides when no player exists.

## OSD

- [ ] OSD dimensions are 276x64 and centered horizontally.
- [ ] OSD bottom margin is 160px.
- [ ] OSD uses the `quickshell-osd` namespace.
- [ ] OSD is non-focusable and does not reserve space.
- [ ] Volume up/down keys adjust volume and show OSD.
- [ ] `ALT` volume up/down adjusts by the fine step.
- [ ] Mute key toggles mute and shows OSD.
- [ ] Brightness up/down keys adjust and show OSD.
- [ ] `ALT` brightness up/down adjusts by the fine step.
- [ ] Held/repeated keys queue updates without dropping steps.
- [ ] OSD hides after the configured timeout.
- [ ] OSD restarts its timer on repeated updates.
- [ ] Muted OSD shows "Muted" and the muted icon.
- [ ] Volume above 100% displays the correct percentage with a full bar.
- [ ] Brightness OSD percentage matches sysfs/brightnessctl.
- [ ] OSD does not appear from SwayOSD in Quickshell mode.
- [ ] Legacy mode still shows the original SwayOSD.

## Native Launcher

### Window and input

- [ ] `SUPER+SPACE` toggles the launcher.
- [ ] Pressing `SUPER+SPACE` while open closes it.
- [ ] The launcher uses the `quickshell-launcher` namespace.
- [ ] The launcher is centered and receives keyboard focus.
- [ ] Typing filters the current result list.
- [ ] Up/Down and PageUp/PageDown move the selection.
- [ ] Enter activates the selected result.
- [ ] Escape and clicking outside the panel close the launcher.
- [ ] The overlay does not leave keyboard focus stuck.
- [ ] The launcher opens on the active monitor.

### Modes and actions

- [ ] Empty query lists applications.
- [ ] Selecting an application launches it.
- [ ] `/` searches files and Enter opens the selected file.
- [ ] `:` lists clipboard history and Enter copies the selected entry.
- [ ] `` ` `` lists static and dynamic themes and Enter applies the selected theme.
- [ ] `!` lists wallpapers and Enter applies the selected wallpaper.
- [ ] `?` lists keybindings and Enter copies the selected keybind.
- [ ] `.` lists symbols and Enter copies the selected glyph.
- [ ] `=` evaluates an expression and Enter copies the result.
- [ ] `@` searches the web or opens a URL.
- [ ] `>` runs the entered shell command.
- [ ] `$` lists Hyprland windows and Enter focuses the selected window.
- [ ] `SUPER+V` opens clipboard mode directly.
- [ ] `SUPER+E` opens symbols mode directly.
- [ ] `SUPER+K` opens keybind mode directly.
- [ ] `SUPER+SHIFT+W` opens wallpaper mode directly.
- [ ] `SUPER+ALT+W` opens theme mode directly.
- [ ] Help mode lists every launcher mode.
- [ ] Launcher data refresh does not block typing.
- [ ] Empty and failed queries show a useful message.

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
- [ ] Wallpaper and theme menus use the native launcher.
- [ ] `CTRL+ALT+I` toggles idle locking.
- [ ] `hypridle` state notifications appear in the active notification backend.
- [ ] Tray menus and notification actions do not leave focus stuck.

## First-Iteration Deferred Items

These are intentionally not blockers for the first iteration:

- Notification grouping and inline replies.
- Per-application volume expansion.
- Idle inhibitor listing/clearing.
- Notification center outside-click dismissal if not implemented.
- Calendar popup/tooltip parity with Waybar.
- Waybar audio/brightness drawer parity beyond sliders.
- Full SwayNC styling parity.
- Multi-monitor OSD placement behavior.
- Any visual differences that do not break function.

## Final State

- [ ] `shell-mode.sh status` reports the intended final mode.
- [ ] No duplicate bar, notification daemon, or OSD server is running.
- [ ] Volume and brightness are left at safe values.
- [ ] Working tree contains only intended migration changes.
- [ ] Checklist results and deferred items are recorded.
