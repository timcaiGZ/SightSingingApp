import Foundation
import SwiftData
import os.log

/// 应用日志工具 — 统一错误处理和日志记录
enum LogLevel: String {
    case debug = "DEBUG"
    case info = "INFO"
    case warning = "WARNING"
    case error = "ERROR"
}

/// 日志分类
enum LogCategory: String {
    case audio = "Audio"
    case pitch = "Pitch"
    case test = "Test"
    case practice = "Practice"
    case database = "Database"
    case general = "General"
}

/// 应用日志工具
struct AppLogger {
    private static let subsystem = Bundle.main.bundleIdentifier ?? "com.sightsinging.app"
    
    // 私有日志记录器
    private static func logger(for category: LogCategory) -> Logger {
        Logger(subsystem: subsystem, category: category.rawValue)
    }
    
    /// 调试日志
    static func debug(_ message: String, category: LogCategory = .general) {
        #if DEBUG
        logger(for: category).debug("\(message, privacy: .public)")
        #endif
    }
    
    /// 信息日志
    static func info(_ message: String, category: LogCategory = .general) {
        logger(for: category).info("\(message, privacy: .public)")
    }
    
    /// 警告日志
    static func warning(_ message: String, category: LogCategory = .general) {
        logger(for: category).warning("\(message, privacy: .public)")
    }
    
    /// 错误日志
    static func error(_ message: String, category: LogCategory = .general, error: Error? = nil) {
        if let error = error {
            logger(for: category).error("\(message, privacy: .public): \(error.localizedDescription, privacy: .public)")
        } else {
            logger(for: category).error("\(message, privacy: .public)")
        }
    }
    
    /// SwiftData 保存操作（带错误处理）
    static func saveContext(_ context: Any, file: String = #file, line: Int = #line) -> Bool {
        guard let modelContext = context as? (any ModelContextProtocol) else {
            warning("无效的 ModelContext", category: .database)
            return false
        }
        
        do {
            try modelContext.save()
            return true
        } catch {
            Self.error("保存上下文失败", category: .database, error: error)
            return false
        }
    }
}

/// SwiftData ModelContext 协议（兼容检查）
protocol ModelContextProtocol {
    func save() throws
}

extension ModelContext: ModelContextProtocol {}
