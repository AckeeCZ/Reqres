//
//  ReqresDefaultLogger.swift
//  Reqres
//
//  Created by Jan Mísař on 02.08.16.
//
//

import os.log

open class ReqresDefaultLogger: ReqresLogging {

    private let dateFormatter: DateFormatter = {
        let df = DateFormatter()
        df.dateFormat = "YYYY-MM-dd HH:mm:ss.SSS"
        return df
    }()

    open var logLevel: LogLevel = .verbose

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

    @available(iOSApplicationExtension 10.0, *)
    private var networkingLogger: OSLog { return OSLog(subsystem: Bundle.main.bundleIdentifier ?? "-", category: "Networking") }

    open func logVerbose(_ message: String) {
        if #available(iOSApplicationExtension 10.0, *) {
            os_log("%{private}@", log: networkingLogger, type: .info, message)
        } else {
            NSLog(message)
        }
    }

    open func logLight(_ message: String) {
        if #available(iOSApplicationExtension 10.0, *) {
            os_log("%{private}@", log: networkingLogger, type: .info, message)
        } else {
            NSLog(message)
        }
    }

    open func logError(_ message: String) {
        if #available(iOSApplicationExtension 10.0, *) {
            os_log("%{private}@", log: networkingLogger, type: .error, message)
        } else {
            NSLog(message)
        }
    }
}
