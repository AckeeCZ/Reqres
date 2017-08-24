//
//  ViewController.swift
//  Reqres
//
//  Created by Jan Mísař on 09/05/2016.
//  Copyright (c) 2016 Jan Mísař. All rights reserved.
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
                debugPrint(response.request)
                debugPrint(response.response)
            })

    }
}
