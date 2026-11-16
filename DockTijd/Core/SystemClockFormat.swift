import Foundation

enum SystemClockFormat {
    /// True when the user's locale/system setting displays 24-hour time.
    static var uses24Hour: Bool { uses24Hour(locale: .current) }

    /// The localized "j" template resolves to the locale's preferred hour pattern. 12-hour patterns
    /// use `h` or `K` (some locales put the day period in `B` rather than `a`), 24-hour ones `H`/`k`.
    static func uses24Hour(locale: Locale) -> Bool {
        let pattern = DateFormatter.dateFormat(fromTemplate: "j", options: 0, locale: locale) ?? "HH"
        var unquoted = ""
        var inQuote = false
        for ch in pattern {
            if ch == "'" { inQuote.toggle() } else if !inQuote { unquoted.append(ch) }
        }
        return !(unquoted.contains("h") || unquoted.contains("K"))
    }
}
