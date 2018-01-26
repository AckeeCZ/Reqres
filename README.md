![ackee|Reqres](https://github.com/AckeeCZ/Reqres/blob/master/Resources/cover-image.png)

[![CI Status](http://img.shields.io/travis/AckeeCZ/Reqres.svg?style=flat)](https://travis-ci.org/AckeeCZ/Reqres)
[![Version](https://img.shields.io/cocoapods/v/Reqres.svg?style=flat)](http://cocoapods.org/pods/Reqres)
[![License](https://img.shields.io/cocoapods/l/Reqres.svg?style=flat)](http://cocoapods.org/pods/Reqres)
[![Carthage Compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage)
[![Platform](https://img.shields.io/cocoapods/p/Reqres.svg?style=flat)](http://cocoapods.org/pods/Reqres)

Reqres is a simple library for logging all requests and responses in your app. It supports Alamofire and also requests made via native NSURLSession.

```
⬆️ POST 'https://ackee.cz/examples'
Headers: [
	Accept-Encoding : gzip;q=1.0, compress;q=0.5
	Accept-Language : en-US;q=1.0
	Content-Type : application/json
	User-Agent : Reqres_Example/org.cocoapods.demo.Reqres-Example (1; OS Version 9.3 (Build 13E230))
	Content-Length : 13
]
Body: {
	"foo" : "bar"
}

...

⬇️ POST https://ackee.cz/examples (✅ 201 Created) [time: 0.54741 s]
Headers: [
	Vary : Authorization,Accept-Encoding
	Content-Encoding : gzip
	Content-Length : 13
	Server : Apache
	Content-Type : application/json
	Date : Mon, 05 Sep 2016 07:33:51 GMT
	Cache-Control : no-cache
]
Body: {
	"foo" : "bar"
}
```

## Installation

### CocoaPods

Reqres is available through [CocoaPods](http://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod "Reqres"
```

### Carthage

You can use [Carthage](https://github.com/Carthage/Carthage).
Specify in Cartfile:

```ruby
github "AckeeCZ/Reqres"
```

Run `carthage update` to build the framework and drag the built Reqres.framework into your Xcode project. Follow [build instructions](https://github.com/Carthage/Carthage#getting-started). [New Issue](https://github.com/AckeeCZ/Reqres/issues/new).


### Swift version compatibility

| Swift version | Reqres version |
| ------------- | -------------- |
| 2.x           | 1.2.x          |
| 3.x           | >= 2.0         |
| 4.x           | >= 2.0         |

## Usage
Initialization is different for usage with Alamofire and NSURLSession.

### Alamofire
Create your Alamofire.Manager with proper configuration to make it work with Alamofire.
```swift
let configuration = Reqres.defaultSessionConfiguration()
configuration.httpAdditionalHeaders = SessionManager.defaultHTTPHeaders
return SessionManager(configuration: configuration)
```
Then you must use this manager for all requests, so replace all `Alamofire.request(...)` to `alamofireManager.request(...)`

### Usage without Alamofire
Register Reqres on application startup and it will monitor and log any requests you make via NSURLSession or NSURLConnection.

```swift
Reqres.register()
```

## Customization
You can do some settings to make it fit your needs.

### Custom logger
Reqres uses default `print()` for logging to avoid unnecessary dependencies but it's ready for any logging framework. Make your custom logger class which complies to `ReqresLogging` protocol and set it to Reqres, that's all.
```
class MyLogger: ReqresLogging {
	...
}

Reqres.logger = MyLogger()
```

### Log level
You can use 3 different log levels:
- **None** - made for production use, it completely disables all Reqres functionality
- **Light** - Logs only basic info (method, url, status code and time)
```
⬆️ POST 'https://ackee.cz/examples'
...
⬇️ POST https://ackee.cz/examples (✅ 201 Created) [time: 0.54741 s]
```
- **Verbose** - Logs also headers and body (see example above)

Reqres uses `Verbose` log level by default. To change log level just set right value to `Reqres.logger.logLevel`

### Emoji
Reqres uses emoji to make log better to read and to make it at least a little funny and nice. If you dont't like that, you can turn it off of course.
```swift
Reqres.allowUTF8Emoji = false
```

## Known Issues

Reqres breaks Alamofire `.authenticate(user: password:)` method (and possibly more..?). Use with caution! Write tests! Volunteer to fix this bug!

## Forking this repository
If you use Reqres in your projects drop us as tweet at [@ackeecz][1]. We would love to hear about it!

## Sharing is caring
This tool and repo has been opensourced within our `#sharingiscaring` action when we have decided to opensource our internal projects.

## Author

[Ackee](www.ackee.cz) team. We were inspired by andysmart's [Timberjack](https://github.com/andysmart/Timberjack)

## License

Reqres is available under the MIT license. See the LICENSE file for more info.

[1]:	https://twitter.com/AckeeCZ

