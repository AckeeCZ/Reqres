//
//  ACKDefaultLogger.swift
//  Pods
//
//  Created by Jan Mísař on 02.08.16.
//
//

open class ReqresDefaultLogger: ReqresLogging {

    open var logLevel: LogLevel = .verbose

    open func logVerbose(_ message: String) {
        print(message)
    }

    open func logLight(_ message: String) {
        print(message)
    }

    open func logError(_ message: String) {
        print(message)
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
