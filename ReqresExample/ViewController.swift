//
//  ViewController.swift
//  ReqresExample
//
//  Created by Jakub Olejník on 27/12/2017.
//

import UIKit
import Reqres
import Alamofire

class ViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // create alamofire manger with right configuration
        let configuration = Reqres.defaultSessionConfiguration()
        configuration.httpAdditionalHeaders = SessionManager.defaultHTTPHeaders
        let alamofireManager = SessionManager(configuration: configuration)
        
        // make sample request
        alamofireManager.request("https://requestb.in/q9bnyvq9", method: .post, parameters: ["foo": "bar"], encoding: JSONEncoding.default)
            .authenticate(user: "blabla", password: "blabla")
            .validate()
            .response(completionHandler: { (response) in
                if let request = response.request {
                    debugPrint(request)
                }
                
                if let response = response.response {
                    debugPrint(response)
                }
            })
    }
}
