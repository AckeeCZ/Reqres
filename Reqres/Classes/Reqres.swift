//
//  ACKNetworkLogger.swift
//  ACKNetworkLogger
//
//  Created by Jan Mísař on 05/27/2016.
//  Copyright (c) 2016 Jan Mísař. All rights reserved.
//

import Foundation

let ReqresRequestHandledKey = "ReqresRequestHandledKey"
let ReqresRequestTimeKey = "ReqresRequestTimeKey"

open class Reqres: URLProtocol {
    var connection: NSURLConnection?
    var data: NSMutableData?
    var response: URLResponse?
    var newRequest: NSMutableURLRequest?

    open static var allowUTF8Emoji: Bool = true

    open static var logger: ReqresLogging = ReqresDefaultLogger()

    open class func register() {
        URLProtocol.registerClass(self)
    }

    open class func unregister() {
        URLProtocol.unregisterClass(self)
    }

    open class func defaultSessionConfiguration() -> URLSessionConfiguration {
        let config = URLSessionConfiguration.default
        config.protocolClasses?.insert(Reqres.self, at: 0)
        return config
    }

    // MARK: - NSURLProtocol

    open override class func canInit(with request: URLRequest) -> Bool {
        guard self.property(forKey: ReqresRequestHandledKey, in: request) == nil && self.logger.logLevel != .none else {
            return false
        }
        return true
    }

    open override class func canonicalRequest(for request: URLRequest) -> URLRequest {
        return request
    }

    open override class func requestIsCacheEquivalent(_ a: URLRequest, to b: URLRequest) -> Bool {
        return super.requestIsCacheEquivalent(a, to: b)
    }

    open override func startLoading() {
        guard let req = (request as NSURLRequest).mutableCopy() as? NSMutableURLRequest , newRequest == nil else { return }

        self.newRequest = req

        URLProtocol.setProperty(true, forKey: ReqresRequestHandledKey, in: newRequest!)
        URLProtocol.setProperty(Date(), forKey: ReqresRequestTimeKey, in: newRequest!)

        connection = NSURLConnection(request: newRequest! as URLRequest, delegate: self)

        logRequest(newRequest! as URLRequest)
    }

    open override func stopLoading() {
        connection?.cancel()
        connection = nil
    }

    // MARK: NSURLConnectionDelegate

    func connection(_ connection: NSURLConnection!, didReceiveResponse response: URLResponse!) {
        let policy = URLCache.StoragePolicy(rawValue: request.cachePolicy.rawValue) ?? .notAllowed
        client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: policy)

        self.response = response
        self.data = NSMutableData()
    }

    func connection(_ connection: NSURLConnection!, didReceiveData data: Data!) {
        client?.urlProtocol(self, didLoad: data)
        self.data?.append(data)
    }

    func connectionDidFinishLoading(_ connection: NSURLConnection!) {
        client?.urlProtocolDidFinishLoading(self)

        if let response = response {
            logResponse(response, method: connection.originalRequest.httpMethod, data: data as Data?)
        }
    }

    func connection(_ connection: NSURLConnection!, didFailWithError error: NSError!) {
        client?.urlProtocol(self, didFailWithError: error)
        logError(connection.originalRequest, error: error)
    }

    // MARK: - Logging

    open func logError(_ request: URLRequest, error: NSError) {

        var s = ""

        if let method = request.httpMethod {
            s += "\(method) "
        }

        if let url = request.url?.absoluteString {
            s += "\(url) "
        }

        s += "ERROR: \(error.localizedDescription)"

        if let reason = error.localizedFailureReason {
            s += "\nReason: \(reason)"
        }

        if let suggestion = error.localizedRecoverySuggestion {
            s += "\nSuggestion: \(suggestion)"
        }

        type(of: self).logger.logError(s)
    }

    open func logRequest(_ request: URLRequest) {

        var s = ""

        if type(of: self).allowUTF8Emoji {
            s += "⬆️ "
        }

        if let method = request.httpMethod {
            s += "\(method) "
        }

        if let url = request.url?.absoluteString {
            s += "'\(url)' "
        }

        if type(of: self).logger.logLevel == .verbose {

            if let headers = request.allHTTPHeaderFields , headers.count > 0 {
                s += "\n" + logHeaders(headers as [String : AnyObject])
            }

            s += "\nBody: \(bodyString(request.httpBodyData))"

            type(of: self).logger.logVerbose(s)
        } else {

            type(of: self).logger.logLight(s)
        }
    }

    open func logResponse(_ response: URLResponse, method: String?, data: Data? = nil) {

        var s = ""

        if type(of: self).allowUTF8Emoji {
            s += "⬇️ "
        }

        if let method = newRequest?.httpMethod {
            s += "\(method) "
        }

        if let url = response.url?.absoluteString {
            s += "\(url) "
        }

        if let httpResponse = response as? HTTPURLResponse {
            s += "("
            if type(of: self).allowUTF8Emoji {
                let iconNumber = Int(floor(Double(httpResponse.statusCode) / 100.0))
                if let iconString = statusIcons[iconNumber] {
                    s += "\(iconString) "
                }
            }

            s += "\(httpResponse.statusCode)"
            if let statusString = statusStrings[httpResponse.statusCode] {
                s += " \(statusString)"
            }
            s += ")"

            if let startDate = URLProtocol.property(forKey: ReqresRequestTimeKey, in: newRequest! as URLRequest) as? Date {
                let difference = fabs(startDate.timeIntervalSinceNow)
                s += String(format: " [time: %.5f s]", difference)
            }
        }

        if type(of: self).logger.logLevel == .verbose {

            if let headers = (response as? HTTPURLResponse)?.allHeaderFields as? [String: AnyObject] , headers.count > 0 {
                s += "\n" + logHeaders(headers)
            }

            s += "\nBody: \(bodyString(data))"

            type(of: self).logger.logVerbose(s)
        } else {

            type(of: self).logger.logLight(s)
        }
    }

    open func logHeaders(_ headers: [String: AnyObject]) -> String {
        var s = "Headers: [\n"
        for (key, value) in headers {
            s += "\t\(key) : \(value)\n"
        }
        s += "]"
        return s
    }

    func bodyString(_ body: Data?) -> String {

        if let body = body {
            if let json = try? JSONSerialization.jsonObject(with: body, options: .mutableContainers),
                let pretty = try? JSONSerialization.data(withJSONObject: json, options: .prettyPrinted),
                let string = String(data: pretty, encoding: String.Encoding.utf8) {
                    return string
            } else if let string = String(data: body, encoding: String.Encoding.utf8) {
                    return string
            } else {
                    return body.description
            }
        } else {
            return "nil"
        }
    }
}

extension URLRequest {
    var httpBodyData: Data? {

        guard let stream = httpBodyStream else {
            return httpBody
        }

        let data = NSMutableData()
        stream.open()
        let bufferSize = 4096
        let buffer = UnsafeMutablePointer<UInt8>.allocate(capacity: bufferSize)
        while stream.hasBytesAvailable {
            let bytesRead = stream.read(buffer, maxLength: bufferSize)
            if bytesRead > 0 {
                let readData = Data(bytes: UnsafePointer<UInt8>(buffer), count: bytesRead)
                data.append(readData)
            } else if bytesRead < 0 {
                print("error occured while reading HTTPBodyStream: \(bytesRead)")
            } else {
                break
            }
        }
        stream.close()
        return data as Data
    }
}

let statusIcons = [
    1: "ℹ️",
    2: "✅",
    3: "⤴️",
    4: "⛔️",
    5: "❌"
]

let statusStrings = [
    // 1xx (Informational)
    100: "Continue",
    101: "Switching Protocols",
    102: "Processing",

    // 2xx (Success)
    200: "OK",
    201: "Created",
    202: "Accepted",
    203: "Non-Authoritative Information",
    204: "No Content",
    205: "Reset Content",
    206: "Partial Content",
    207: "Multi-Status",
    208: "Already Reported",
    226: "IM Used",

    // 3xx (Redirection)
    300: "Multiple Choices",
    301: "Moved Permanently",
    302: "Found",
    303: "See Other",
    304: "Not Modified",
    305: "Use Proxy",
    306: "Switch Proxy",
    307: "Temporary Redirect",
    308: "Permanent Redirect",

    // 4xx (Client Error)
    400: "Bad Request",
    401: "Unauthorized",
    402: "Payment Required",
    403: "Forbidden",
    404: "Not Found",
    405: "Method Not Allowed",
    406: "Not Acceptable",
    407: "Proxy Authentication Required",
    408: "Request Timeout",
    409: "Conflict",
    410: "Gone",
    411: "Length Required",
    412: "Precondition Failed",
    413: "Request Entity Too Large",
    414: "Request-URI Too Long",
    415: "Unsupported Media Type",
    416: "Requested Range Not Satisfiable",
    417: "Expectation Failed",
    418: "I'm a teapot",
    420: "Enhance Your Calm",
    422: "Unprocessable Entity",
    423: "Locked",
    424: "Method Failure",
    425: "Unordered Collection",
    426: "Upgrade Required",
    428: "Precondition Required",
    429: "Too Many Requests",
    431: "Request Header Fields Too Large",
    451: "Unavailable For Legal Reasons",

    // 5xx (Server Error)
    500: "Internal Server Error",
    501: "Not Implemented",
    502: "Bad Gateway",
    503: "Service Unavailable",
    504: "Gateway Timeout",
    505: "HTTP Version Not Supported",
    506: "Variant Also Negotiates",
    507: "Insufficient Storage",
    508: "Loop Detected",
    509: "Bandwidth Limit Exceeded",
    510: "Not Extended",
    511: "Network Authentication Required"
]
