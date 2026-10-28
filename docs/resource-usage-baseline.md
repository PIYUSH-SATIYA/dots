# Desktop UI Resource Baseline

Captured before the Waybar/Walker/SwayNC to Quickshell migration.

## Conditions

- Date: 2026-10-29T01:48+05:30
- System: Arch Linux, Hyprland 0.56.2
- Display: eDP-1, 1920x1080 at 144 Hz
- Power: AC online, battery 79%, power-profiles-daemon profile `balanced`
- Uptime: 16h32m
- Load average at capture: 5.69
- CPU sample: 5 seconds while idle
- RSS, PSS, and USS: `/proc/<pid>/smaps_rollup` or `smem`
- Totals also checked with `ps_mem`
- Package sizes: `pacman -Qi` installed size

The CPU percentage is a short idle sample taken under a high system load average.
Treat it as directional, not a precise benchmark.

## Runtime processes

| Component | PID | RSS MiB | PSS MiB | USS MiB | CPU % | CPU time | Threads |
| --- | ---: | ---: | ---: | ---: | ---: | ---: | ---: |
| Waybar | 926 | 58.96 | 27.82 | 19.63 | 0.40 | 128.39s | 26 |
| SwayNC | 923 | 146.75 | 78.73 | 61.14 | 0.00 | 12.96s | 16 |
| SwayOSD | 927 | 100.51 | 44.37 | 30.39 | 0.00 | 0.97s | 26 |
| Walker | 930 | 110.84 | 57.13 | 44.92 | 0.00 | 5.26s | 8 |
| Elephant | 941 | 54.19 | 52.37 | 52.35 | 0.00 | 4.29s | 19 |
| wl-paste watcher | 1100 | 3.87 | 0.33 | 0.25 | 0.00 | 0.06s | 2 |
| wl-paste watcher | 1101 | 3.87 | 0.33 | 0.25 | 0.00 | 0.06s | 2 |

Totals:

- RSS: 475.11 MiB
- PSS: 260.74 MiB
- USS: 208.67 MiB
- Idle CPU: 0.40%
- Accumulated CPU time: 151.93s
- Threads: 97
- `ps_mem`: 261.4 MiB

PSS is the primary comparison metric. RSS double-counts shared libraries and is not a
reliable sum across processes.

One `wl-paste` watcher had parent PID 1. `wlogout` was installed but not running.

## Installed package sizes

| Package | Installed MiB |
| --- | ---: |
| waybar | 2.17 |
| swaync | 0.73 |
| swayosd | 8.34 |
| walker | 6.79 |
| wlogout | 0.12 |
| elephant-bin | 22.49 |
| elephant-calc-bin | 23.54 |
| elephant-clipboard-bin | 25.70 |
| elephant-desktopapplications-bin | 24.14 |
| elephant-files-bin | 25.44 |
| elephant-menus-bin | 23.40 |
| elephant-providerlist-bin | 23.61 |
| elephant-runner-bin | 23.59 |
| elephant-symbols-bin | 141.38 |
| elephant-websearch-bin | 23.64 |

Total: 375.08 MiB.

Elephant package total without `elephant-bin`: 356.93 MiB.
The `elephant-symbols-bin` package alone accounts for 141.38 MiB.

## Active provider inventory

Elephant `listproviders` reported:

```text
runner
calc
websearch
providerlist
menus:themes
menus:keybinds
menus:wallpaper
clipboard
files
desktopapplications
symbols
```

Walker configured `archlinuxpkgs`, `bookmarks`, and `windows` prefixes, but those
providers are not installed. Their prefixes currently do nothing.

## Reproduction

```bash
ps -eo pid,comm,rss,%cpu,time,nlwp --sort=comm
smem -P 'waybar|swaync|swayosd|walker|elephant|wl-paste' -c \
  'pid,comm,rss,pss,uss'
ps_mem
pacman -Qi waybar swaync swayosd walker wlogout \
  elephant-bin elephant-calc-bin elephant-clipboard-bin \
  elephant-desktopapplications-bin elephant-files-bin \
  elephant-menus-bin elephant-providerlist-bin elephant-runner-bin \
  elephant-symbols-bin elephant-websearch-bin
```

## Post-migration measurement

Measure under the same conditions:

- AC online
- Same power profile
- Same display refresh rate
- Idle desktop, no launcher or control center open
- Same 5-second CPU sample
- PSS total as the primary metric
- Package-size delta after Phase 5 removal

Record Quickshell separately from any remaining legacy processes so the dual-write
phase does not produce a misleading total.
