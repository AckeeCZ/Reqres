//
//  ACKDefaultLogger.swift
//  Pods
//
//  Created by Jan Mísař on 02.08.16.
//
//

public class ReqresDefaultLogger: ReqresLogging {

    public var logLevel: LogLevel = .Verbose

    public func logVerbose(message: String) {
        print(message)
    }

    public func logLight(message: String) {
        print(message)
    }

    public func logError(message: String) {
        print(message)
    }
}

public class ReqresDefaultNSLogger: ReqresLogging {

    public var logLevel: LogLevel = .Verbose

    public func logVerbose(message: String) {
        NSLog(message)
    }

    public func logLight(message: String) {
        NSLog(message)
    }

    public func logError(message: String) {
        NSLog(message)
    }
}
