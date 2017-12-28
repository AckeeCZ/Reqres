//
//  ReqresDefaultLogger.swift
//  Reqres
//
//  Created by Jan Mísař on 02.08.16.
//
//

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

    open func logVerbose(_ message: String) {
        NSLog(message)
    }

    open func logLight(_ message: String) {
        NSLog(message)
    }

    open func logError(_ message: String) {
        NSLog(message)
    }
}
