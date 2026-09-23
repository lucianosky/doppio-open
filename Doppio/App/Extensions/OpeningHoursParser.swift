// OpeningHoursParser.swift
// App/Extensions
//
// Parses OSM Opening Hours strings to determine open/closed status.
// Format reference: https://wiki.openstreetmap.org/wiki/Key:opening_hours/specification
// Business rule: docs/opening-hours.md
//
// Assumptions:
// - Input is always a valid OSM Opening Hours string (backend guarantee).
// - Days: Mo Tu We Th Fr Sa Su (ranges with -, lists with ,).
// - Times: HH:MM in 24h format.
// - Multiple rules separated by ;.

import Foundation

enum OpeningHoursParser {

    // MARK: - Public API

    /// Converts OSM day abbreviations to Portuguese for display.
    /// "Mo-Sa 10:00-18:00" → "Seg–Sáb 10:00–18:00"
    static func formatForDisplay(_ hours: String) -> String {
        let dayMap: [(String, String)] = [
            ("Mo", "Seg"), ("Tu", "Ter"), ("We", "Qua"), ("Th", "Qui"),
            ("Fr", "Sex"), ("Sa", "Sáb"), ("Su", "Dom")
        ]
        var result = hours
        for (osm, ptbr) in dayMap {
            result = result.replacingOccurrences(of: osm, with: ptbr)
        }
        return result
    }

    /// Returns true if the establishment is currently open.
    /// Returns nil if `hours` is nil or unparseable.
    static func isOpenNow(hours: String?, date: Date = Date()) -> Bool? {
        guard let hours else { return nil }
        let rules = parse(hours)
        guard !rules.isEmpty else { return nil }
        return rules.contains { $0.contains(date: date) }
    }

    /// Returns true if currently open AND closes within `minutes` minutes (default 60).
    /// Returns false if closed or no data.
    static func isClosingSoon(hours: String?, within minutes: Int = 60, date: Date = Date()) -> Bool {
        guard isOpenNow(hours: hours, date: date) == true else { return false }
        guard let next = nextChange(hours: hours, date: date) else { return false }
        return next.timeIntervalSince(date) <= Double(minutes * 60)
    }

    /// Returns the next time the status changes (opening or closing time today or tomorrow).
    /// Useful for displaying "Abre às 14h" or "Fecha às 18h".
    /// Returns nil if `hours` is nil, unparseable, or no change found within 24h.
    static func nextChange(hours: String?, date: Date = Date()) -> Date? {
        guard let hours else { return nil }
        let rules = parse(hours)
        guard !rules.isEmpty else { return nil }

        let calendar = Calendar.current
        // Check candidates within the next 24 hours (every boundary in each rule)
        var candidates: [Date] = []

        for offsetHours in 0...1 {
            guard let dayDate = calendar.date(byAdding: .day, value: offsetHours, to: date) else { continue }
            let weekday = calendar.component(.weekday, from: dayDate) // 1=Sun..7=Sat
            let osmDay  = weekdayToOSM(weekday)

            for rule in rules where rule.days.contains(osmDay) {
                if let open = boundaryDate(hhmm: rule.openHHMM, base: dayDate),
                   open > date { candidates.append(open) }
                if let close = boundaryDate(hhmm: rule.closeHHMM, base: dayDate),
                   close > date { candidates.append(close) }
            }
        }

        return candidates.min()
    }

    // MARK: - Internal model

    private struct Rule {
        let days: Set<String>      // ["Mo","Tu","We","Th","Fr"]
        let openHHMM: Int          // 800  (= 08:00)
        let closeHHMM: Int         // 1800 (= 18:00)

        func contains(date: Date) -> Bool {
            let calendar = Calendar.current
            let weekday  = calendar.component(.weekday, from: date)
            let osmDay   = weekdayToOSM(weekday)
            guard days.contains(osmDay) else { return false }

            let hr = calendar.component(.hour, from: date)
            let mn = calendar.component(.minute, from: date)
            let current = hr * 100 + mn
            return current >= openHHMM && current < closeHHMM
        }
    }

    // MARK: - Parsing

    private static func parse(_ hours: String) -> [Rule] {
        hours
            .components(separatedBy: ";")
            .compactMap { parseRule($0.trimmingCharacters(in: .whitespaces)) }
    }

    private static func parseRule(_ rule: String) -> Rule? {
        // Expected: "Mo-Fr 08:00-18:00" or "Sa,Su 10:00-16:00"
        let parts = rule.split(separator: " ", maxSplits: 1)
        guard parts.count == 2 else { return nil }

        let daysStr  = String(parts[0])
        let timesStr = String(parts[1])

        let days  = expandDays(daysStr)
        guard !days.isEmpty else { return nil }

        let times = timesStr.components(separatedBy: "-")
        guard times.count == 2,
              let open  = parseHHMM(times[0]),
              let close = parseHHMM(times[1])
        else { return nil }

        return Rule(days: days, openHHMM: open, closeHHMM: close)
    }

    // "Mo-Fr" → ["Mo","Tu","We","Th","Fr"]
    // "Sa,Su" → ["Sa","Su"]
    // "Mo"    → ["Mo"]
    private static func expandDays(_ str: String) -> Set<String> {
        let ordered = ["Mo", "Tu", "We", "Th", "Fr", "Sa", "Su"]

        if str.contains("-") {
            let parts = str.components(separatedBy: "-")
            guard parts.count == 2,
                  let start = ordered.firstIndex(of: parts[0]),
                  let end   = ordered.firstIndex(of: parts[1]),
                  start <= end
            else { return [] }
            return Set(ordered[start...end])
        }

        if str.contains(",") {
            return Set(str.components(separatedBy: ",").filter { ordered.contains($0) })
        }

        return ordered.contains(str) ? [str] : []
    }

    // "08:00" → 800, "18:00" → 1800
    private static func parseHHMM(_ str: String) -> Int? {
        let parts = str.trimmingCharacters(in: .whitespaces).components(separatedBy: ":")
        guard parts.count == 2,
              let hr = Int(parts[0]),
              let mn = Int(parts[1])
        else { return nil }
        return hr * 100 + mn
    }

    // MARK: - Helpers

    // Calendar.weekday: 1=Sun, 2=Mon … 7=Sat → OSM: Su Mo Tu We Th Fr Sa
    private static func weekdayToOSM(_ weekday: Int) -> String {
        ["Su", "Mo", "Tu", "We", "Th", "Fr", "Sa"][weekday - 1]
    }

    private static func boundaryDate(hhmm: Int, base: Date) -> Date? {
        let calendar = Calendar.current
        var comps    = calendar.dateComponents([.year, .month, .day], from: base)
        comps.hour   = hhmm / 100
        comps.minute = hhmm % 100
        comps.second = 0
        return calendar.date(from: comps)
    }
}
