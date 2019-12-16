//
//  ReqresDefaultLogger.swift
//  Reqres
//
//  Created by Jan Mísař on 02.08.16.
//
//

import os.log
import Foundation

open class ReqresDefaultLogger: ReqresLogging {

    private let dateFormatter: DateFormatter = {
        let df = DateFormatter()
        df.dateFormat = "YYYY-MM-dd HH:mm:ss.SSS"
        return df
    }()

    open var logLevel: LogLevel = .verbose
    
    public init() {
        
    }

    open func logVerbose(_ message: String) {
        logMessage(message)
    }

    open func logLight(_ message: String) {
        logMessage(message)
    }

    open func logError(_ message: String) {
        logMessage(message)
    }

    private func logMessage(_ message: String) {
        print("[" + dateFormatter.string(from: Date()) + "] " + message)
    }
}

open class ReqresDefaultNSLogger: ReqresLogging {

    open var logLevel: LogLevel = .verbose

    // It is not advised to wrap os_log, but we are basically wrapping it here anyway, so it should not matter
    private enum MessageType {
        case debug, error
    }

    private func logMessage(_ message: String, type: MessageType) {
        if #available(iOS 10.0, *) {
            // Currently there is a bug which does not display .debug logs in the console, thus info
            let osLogType: OSLogType = type == .debug ? .info : .error
            let networkingLogger = OSLog(subsystem: Bundle.main.bundleIdentifier ?? "-", category: "Networking")
            os_log("%{private}@", log: networkingLogger, type: osLogType, message)
        } else {
            NSLog(message)
        }
    }
    
    public init() {
        
    }

    open func logVerbose(_ message: String) {
        logMessage(message, type: .debug)
    }

    open func logLight(_ message: String) {
        logMessage(message, type: .debug)
    }

    open func logError(_ message: String) {
        logMessage(message, type: .error)
    }
}
