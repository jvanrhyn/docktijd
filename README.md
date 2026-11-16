# DockTijd

A macOS app whose Dock icon is a live clock. Pick one of 10 faces (5 analogue, 5 digital) from the Dock icon's right-click menu.

## Build

```sh
brew install xcodegen      # dev-time only
xcodegen                   # generates DockTijd.xcodeproj from project.yml
xcodebuild -scheme DockTijd -destination 'platform=macOS' test
open DockTijd.xcodeproj    # or run from Xcode
```

## Use

1. Run the app, then right-click its Dock icon and choose **Keep in Dock**.
2. Right-click the icon any time to switch faces, or toggle **Open at Login**.

A Dock icon can only change while the app is running, so enable **Open at Login** to always have a live clock.
When the app is not running (quit or crashed) the Dock shows the static sleeping-clock icon instead.

## Design

- `docs/superpowers/specs/2026-11-16-docktijd-design.md`: design
- `docs/superpowers/plans/2026-11-16-docktijd.md`: implementation plan
- `Tools/MakeSleepIcon.swift`: regenerates the sleeping app icon (usage in the file header)

## Performance (Release build, Apple silicon, 50 s samples)

| Face | Redraw | Avg CPU | Memory footprint |
|---|---|---|---|
| Per-minute faces (e.g. Classic) | once a minute | ~0.2% (mostly launch tail, effectively idle) | ~14 MB |
| Railway (per-second) | every second | ~0.4% | ~15 MB |
| LCD (per-second) | every second | ~0.3% | ~15 MB |

Per-second faces render their unchanging layer (background, dial, numerals) once and only redraw the hands or digits each tick.
The timer is a single one-shot dispatch timer aligned to the second/minute boundary, paused during system sleep.
