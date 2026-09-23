// BrewLogger.swift
// Brew/Shared/Logger
//
// Project-agnostic logging infrastructure.
//
// Architecture (ring 4 — Frameworks & Drivers):
// - BrewLogging protocol lives in Brew/ — agnostic, no domain knowledge
// - Concrete implementations live in App/ (e.g. RaipeLogger)
// - BrewLogger.current is injected in App.init(), same pattern as BrewTheme
//
// Usage (from any ring):
//   logDebug("Cache hit", category: .repository)
//   logError("Decoding failed: \(error)", category: .network)
//
// Security rules (from brew-constitution.md):
// - NEVER log user PII: email, name, phone, auth tokens
// - Logging user IDs is acceptable
// - All logging is stripped in release builds — see DEBUG guard in implementations

import Foundation

// MARK: - LogLevel

public enum LogLevel: String {
    case debug    = "⚪ DEBUG"
    case info     = "🔵 INFO"
    case warning  = "🟡 WARNING"
    case error    = "🔴 ERROR"
    case critical = "🚨 CRITICAL"
}

// MARK: - LogCategory

/// Identifies the architectural layer or domain area that produced the log.
/// Add categories as new layers are implemented — do not log from a category
/// before its layer is built.
public enum LogCategory: String {
    case network
    case repository
    case usecase
    case viewmodel
    case auth
    case playback
    case billing
    case ui
}

// MARK: - BrewLogging

/// Protocol for logger implementations.
/// Inject a concrete implementation via `BrewLogger.current` in `App.init()`.
public protocol BrewLogging: Sendable {
    func log(
        _ level: LogLevel,
        _ message: String,
        category: LogCategory,
        file: String,
        function: String,
        line: Int
    )
}

// MARK: - BrewLogger

/// Global logger access point.
/// Follows the same injection pattern as `BrewTheme`.
///
/// Inject in `App.init()`:
/// ```swift
/// BrewLogger.current = RaipeLogger()
/// ```
public enum BrewLogger {

    /// The active logger. Defaults to `NoOpLogger` until injected.
    /// Written once at app startup (in `App.init()`) before any concurrent
    /// reads — `nonisolated(unsafe)` is safe here.
    nonisolated(unsafe) public static var current: any BrewLogging = NoOpLogger()
}

// MARK: - NoOpLogger

/// Silent logger used before injection and in release builds as a safety net.
public struct NoOpLogger: BrewLogging {
    public func log(
        _ level: LogLevel,
        _ message: String,
        category: LogCategory,
        file: String,
        function: String,
        line: Int
    ) {}
}

// MARK: - Convenience Functions

/// Logs a debug message. Compiled out in release builds.
public func logDebug(
    _ message: String,
    category: LogCategory = .ui,
    file: String = #file,
    function: String = #function,
    line: Int = #line
) {
    #if DEBUG
    BrewLogger.current.log(.debug, message, category: category, file: file, function: function, line: line)
    #endif
}

/// Logs an info message. Compiled out in release builds.
public func logInfo(
    _ message: String,
    category: LogCategory = .ui,
    file: String = #file,
    function: String = #function,
    line: Int = #line
) {
    #if DEBUG
    BrewLogger.current.log(.info, message, category: category, file: file, function: function, line: line)
    #endif
}

/// Logs a warning. Compiled out in release builds.
public func logWarning(
    _ message: String,
    category: LogCategory = .ui,
    file: String = #file,
    function: String = #function,
    line: Int = #line
) {
    #if DEBUG
    BrewLogger.current.log(.warning, message, category: category, file: file, function: function, line: line)
    #endif
}

/// Logs an error. Compiled out in release builds.
public func logError(
    _ message: String,
    category: LogCategory = .ui,
    file: String = #file,
    function: String = #function,
    line: Int = #line
) {
    #if DEBUG
    BrewLogger.current.log(.error, message, category: category, file: file, function: function, line: line)
    #endif
}

/// Logs a critical failure. Compiled out in release builds.
public func logCritical(
    _ message: String,
    category: LogCategory = .ui,
    file: String = #file,
    function: String = #function,
    line: Int = #line
) {
    #if DEBUG
    BrewLogger.current.log(.critical, message, category: category, file: file, function: function, line: line)
    #endif
}
