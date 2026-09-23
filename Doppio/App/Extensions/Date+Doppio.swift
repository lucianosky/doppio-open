// Date+Doppio.swift
// App/Extensions

import Foundation

extension Date {
    var doppioDate: String {
        DateFormatter.doppioDate.string(from: self)
    }
}

extension DateFormatter {
    static let doppioDate: DateFormatter = {
        let formatter = DateFormatter()
        formatter.setLocalizedDateFormatFromTemplate("ddMMMyyyy")
        formatter.locale = Locale(identifier: "pt_BR")
        return formatter
    }()
}
