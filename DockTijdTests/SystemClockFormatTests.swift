import Testing
import Foundation
@testable import DockTijd

struct SystemClockFormatTests {
    @Test(arguments: ["en_US", "hi_IN", "ur_PK", "zh_TW", "zh_Hant_TW"])
    func twelveHourLocales(id: String) {
        #expect(SystemClockFormat.uses24Hour(locale: Locale(identifier: id)) == false, "\(id)")
    }

    @Test(arguments: ["en_GB", "de_DE", "nl_NL", "fr_FR"])
    func twentyFourHourLocales(id: String) {
        #expect(SystemClockFormat.uses24Hour(locale: Locale(identifier: id)) == true, "\(id)")
    }
}
