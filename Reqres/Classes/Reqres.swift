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

public class Reqres: NSURLProtocol {
    var connection: NSURLConnection?
    var data: NSMutableData?
    var response: NSURLResponse?
    var newRequest: NSMutableURLRequest?

    public static var allowUTF8Emoji: Bool = true

    public static var logger: ReqresLogging = ReqresDefaultLogger()

    public class func register() {
        NSURLProtocol.registerClass(self)
    }

    public class func unregister() {
        NSURLProtocol.unregisterClass(self)
    }

    public class func defaultSessionConfiguration() -> NSURLSessionConfiguration {
        let config = NSURLSessionConfiguration.defaultSessionConfiguration()
        config.protocolClasses?.insert(Reqres.self, atIndex: 0)
        return config
    }

    // MARK: - NSURLProtocol

    public override class func canInitWithRequest(request: NSURLRequest) -> Bool {
        guard self.propertyForKey(ReqresRequestHandledKey, inRequest: request) == nil && self.logger.logLevel != .None else {
            return false
        }
        return true
    }

    public override class func canonicalRequestForRequest(request: NSURLRequest) -> NSURLRequest {
        return request
    }

    public override class func requestIsCacheEquivalent(a: NSURLRequest, toRequest b: NSURLRequest) -> Bool {
        return super.requestIsCacheEquivalent(a, toRequest: b)
    }

    public override func startLoading() {
        guard let req = request.mutableCopy() as? NSMutableURLRequest where newRequest == nil else { return }

        self.newRequest = req

        NSURLProtocol.setProperty(true, forKey: ReqresRequestHandledKey, inRequest: newRequest!)
        NSURLProtocol.setProperty(NSDate(), forKey: ReqresRequestTimeKey, inRequest: newRequest!)

        connection = NSURLConnection(request: newRequest!, delegate: self)

        logRequest(newRequest!)
    }

    public override func stopLoading() {
        connection?.cancel()
        connection = nil
    }

    // MARK: NSURLConnectionDelegate

    func connection(connection: NSURLConnection!, didReceiveResponse response: NSURLResponse!) {
        let policy = NSURLCacheStoragePolicy(rawValue: request.cachePolicy.rawValue) ?? .NotAllowed
        client?.URLProtocol(self, didReceiveResponse: response, cacheStoragePolicy: policy)

        self.response = response
        self.data = NSMutableData()
    }

    func connection(connection: NSURLConnection!, didReceiveData data: NSData!) {
        client?.URLProtocol(self, didLoadData: data)
        self.data?.appendData(data)
    }

    func connectionDidFinishLoading(connection: NSURLConnection!) {
        client?.URLProtocolDidFinishLoading(self)

        if let response = response {
            logResponse(response, method: connection.originalRequest.HTTPMethod, data: data)
        }
    }

    func connection(connection: NSURLConnection!, didFailWithError error: NSError!) {
        client?.URLProtocol(self, didFailWithError: error)
        logError(connection.originalRequest, error: error)
    }

    // MARK: - Logging

    public func logError(request: NSURLRequest, error: NSError) {

        var s = ""

        if let method = request.HTTPMethod {
            s += "\(method) "
        }

        if let url = request.URL?.absoluteString {
            s += "\(url) "
        }

        s += "ERROR: \(error.localizedDescription)"

        if let reason = error.localizedFailureReason {
            s += "\nReason: \(reason)"
        }

        if let suggestion = error.localizedRecoverySuggestion {
            s += "\nSuggestion: \(suggestion)"
        }

        self.dynamicType.logger.logError(s)
    }

    public func logRequest(request: NSURLRequest) {

        var s = ""

        if self.dynamicType.allowUTF8Emoji {
            s += "⬆️ "
        }

        if let method = request.HTTPMethod {
            s += "\(method) "
        }

        if let url = request.URL?.absoluteString {
            s += "'\(url)' "
        }

        if self.dynamicType.logger.logLevel == .Verbose {

            if let headers = request.allHTTPHeaderFields where headers.count > 0 {
                s += "\n" + logHeaders(headers)
            }

            s += "\nBody: \(bodyString(request.httpBodyData))"

            self.dynamicType.logger.logVerbose(s)
        } else {

            self.dynamicType.logger.logLight(s)
        }
    }

    public func logResponse(response: NSURLResponse, method: String?, data: NSData? = nil) {

        var s = ""

        if self.dynamicType.allowUTF8Emoji {
            s += "⬇️ "
        }

        if let method = newRequest?.HTTPMethod {
            s += "\(method) "
        }

        if let url = response.URL?.absoluteString {
            s += "\(url) "
        }

        if let httpResponse = response as? NSHTTPURLResponse {
            s += "("
            if self.dynamicType.allowUTF8Emoji {
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

            if let startDate = NSURLProtocol.propertyForKey(ReqresRequestTimeKey, inRequest: newRequest!) as? NSDate {
                let difference = fabs(startDate.timeIntervalSinceNow)
                s += String(format: " [time: %.5f s]", difference)
            }
        }

        if self.dynamicType.logger.logLevel == .Verbose {

            if let headers = (response as? NSHTTPURLResponse)?.allHeaderFields as? [String: AnyObject] where headers.count > 0 {
                s += "\n" + logHeaders(headers)
            }

            s += "\nBody: \(bodyString(data))"

            self.dynamicType.logger.logVerbose(s)
        } else {

            self.dynamicType.logger.logLight(s)
        }
    }

    public func logHeaders(headers: [String: AnyObject]) -> String {
        var s = "Headers: [\n"
        for (key, value) in headers {
            s += "\t\(key) : \(value)\n"
        }
        s += "]"
        return s
    }

    func bodyString(body: NSData?) -> String {

        if let body = body {
            if let json = try? NSJSONSerialization.JSONObjectWithData(body, options: .MutableContainers),
                let pretty = try? NSJSONSerialization.dataWithJSONObject(json, options: .PrettyPrinted),
                let string = String(data: pretty, encoding: NSUTF8StringEncoding) {
                    return string
            } else if let string = String(data: body, encoding: NSUTF8StringEncoding) {
                    return string
            } else {
                    return body.description
            }
        } else {
            return "nil"
        }
    }
}

extension NSURLRequest {
    var httpBodyData: NSData? {

        guard let stream = HTTPBodyStream else {
            return HTTPBody
        }

        let data = NSMutableData()
        stream.open()
        let bufferSize = 4096
        let buffer = UnsafeMutablePointer<UInt8>.alloc(bufferSize)
        while stream.hasBytesAvailable {
            let bytesRead = stream.read(buffer, maxLength: bufferSize)
            if bytesRead > 0 {
                let readData = NSData(bytes: buffer, length: bytesRead)
                data.appendData(readData)
            } else if bytesRead < 0 {
                print("error occured while reading HTTPBodyStream: \(bytesRead)")
            } else {
                break
            }
        }
        stream.close()
        return data
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
