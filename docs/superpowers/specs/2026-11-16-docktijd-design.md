# DockTijd: design (short)

## Intent
A macOS app whose only job is to make its pinned Dock icon a live clock. The user picks one of 10 faces (5 analogue, 5 digital). Priorities: visually polished, very fast, very light.

## Goals
- Dock icon always shows the current time while the app runs.
- 10 faces, switchable from the Dock right-click menu (each item has a small preview image).
- Near-zero idle CPU, small memory footprint, instant face switching.
- Selected face persists across launches.

## Non-goals / anti-goals
- No settings window, no menu-bar item, no widgets, no timezones or alarms.
- Anti-goal: an icon that lags, jitters, or keeps the CPU awake between ticks.

## Constraints
- A Dock icon can only update while the process runs, so the app must be running. Offer launch-at-login via `SMAppService` (a Dock-menu toggle; this is my call).
- Swift 6 (strict concurrency), latest Xcode and macOS SDK, native AppKit. No third-party dependencies.

## Approaches considered
- **A. Core Graphics in a custom `NSView` (chosen).** Leanest and fastest; faces are more verbose to write.
- B. SwiftUI in `NSHostingView`. Faster to author; heavier per tick. Rejected for the footprint.
- C. Pre-rendered assets. Rejected: no live hands, or an enormous frame count.

## Design
- `ClockFace` protocol: `id`, `name`, `showsSeconds`, `draw(in: CGRect, time: ClockTime)`. Faces are stateless value types.
- `ClockView: NSView` calls the current face's `draw`. It is installed as `NSApp.dockTile.contentView`, and `dockTile.display()` is called per tick.
- `ClockEngine`: a single timer aligned to the next second or minute boundary (seconds only if the face needs them), with leeway minimised, and paused when the system sleeps. Time comes from `Date` on every tick, so drift cannot accumulate.
- `AppDelegate.applicationDockMenu`: a list of 10 faces under "Analogue" and "Digital" headings, with a checkmark on the current one and a preview `NSImage` per item (the same `draw` code rendered once and cached). It also holds a "Open at Login" toggle.
- Selection is stored in `UserDefaults`. Changing it swaps the face and redraws immediately.
- The app has no window (`LSUIElement` = NO so the Dock icon exists, with no main window scene). It uses a minimal `NSApplicationDelegate` entry point.
- Respects 12/24-hour via the system locale for digital faces (my call).

## Sleeping icon (not running)
When the app is not running, no code of ours executes, so the Dock shows the static icon from the app bundle. Decision (my call): the bundled app icon (`AppIcon`) IS the sleeping graphic, a clock with closed eyes, a nightcap, a moon and "Zzz" in the same rounded-square style. It appears automatically when the app is quit or has crashed, and the live face takes over on launch. This needs no helper process and no bundle modification.
Rejected: rewriting the bundle's icon on quit via `NSWorkspace.setIcon(_:forFile:)` to show "the current face asleep". It adds a custom-icon file to the bundle (risking code-signature and notarization problems), needs the Dock to refresh its cache, and does not run on force-quit or a crash.
Optional small touch: when quitting normally, redraw the current face with a fading "Zzz" overlay for a moment before exit.

## Faces (my proposals, builder may refine the visuals)
Analogue: 1. Classic (white dial, black hands, Roman-free ticks), 2. Minimal Dark (no numerals, bold hands), 3. Railway (numbered, red second hand), 4. Aqua Gradient (glossy glass), 5. Retro Gold.
Digital: 6. Bold Mono (big white on black), 7. Neon (glow, dark gradient), 8. Flip card, 9. LCD (seven-segment, green), 10. Gradient Pill (rounded, modern, with AM/PM).
All faces draw into the standard rounded-square macOS icon shape with a subtle shadow.

## Left to the builder
Exact colours, typography and geometry per face; the project layout; unit tests for time and boundary-alignment logic; checking Instruments to confirm idle CPU is near zero.
