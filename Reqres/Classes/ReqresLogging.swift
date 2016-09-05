//
//  ACKLogging.swift
//  Pods
//
//  Created by Jan Mísař on 02.08.16.
//
//

public enum LogLevel {
    case None
    case Light
    case Verbose
}

public protocol ReqresLogging {
    var logLevel: LogLevel { get set }

    func logVerbose(message: String)
    func logLight(message: String)
    func logError(message: String)
}
