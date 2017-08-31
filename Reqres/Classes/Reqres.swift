//
//  Reqres.swift
//  Reqres
//
//  Created by Jan Mísař on 05/27/2016.
//  Copyright (c) 2016 Jan Mísař. All rights reserved.
//

import Foundation

let ReqresRequestHandledKey = "ReqresRequestHandledKey"
let ReqresRequestTimeKey = "ReqresRequestTimeKey"

open class Reqres: URLProtocol, URLSessionDelegate {
    var dataTask: URLSessionDataTask?
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
        guard let req = (request as NSURLRequest).mutableCopy() as? NSMutableURLRequest, newRequest == nil else { return }

        self.newRequest = req

        URLProtocol.setProperty(true, forKey: ReqresRequestHandledKey, in: newRequest!)
        URLProtocol.setProperty(Date(), forKey: ReqresRequestTimeKey, in: newRequest!)

        let session = URLSession(configuration: .default, delegate: self, delegateQueue: nil)
        dataTask = session.dataTask(with: request) { [weak self] data, response, error in
            guard let `self` = self else { return }

            if let error = error {
                self.client?.urlProtocol(self, didFailWithError: error)
                self.logError(self.request, error: error as NSError)

                return
            }

            guard let response = response, let data = data else { return }

            self.client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .allowed)
            self.client?.urlProtocol(self, didLoad: data)
            self.client?.urlProtocolDidFinishLoading(self)
            self.logResponse(response, method: nil, data: data)
        }
        dataTask?.resume()

        logRequest(newRequest! as URLRequest)
    }

    open override func stopLoading() {
        dataTask?.cancel()
    }

    // MARK: - Logging

    open func logError(_ request: URLRequest, error: NSError) {

        var s = ""

        if type(of: self).allowUTF8Emoji {
            s += "⚠️ "
        }

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

            if let headers = request.allHTTPHeaderFields, headers.count > 0 {
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

        if let method = method {
            s += "\(method)"
        } else if let method = newRequest?.httpMethod {
            s += "\(method) "
        }

        if let url = response.url?.absoluteString {
            s += "'\(url)' "
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

            if let headers = (response as? HTTPURLResponse)?.allHeaderFields as? [String: AnyObject], headers.count > 0 {
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
        let bufferSize = 4_096
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
