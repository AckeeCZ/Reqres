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
        configuration.HTTPAdditionalHeaders = Manager.defaultHTTPHeaders
        let alamofireManager = Alamofire.Manager(configuration: configuration)

        // make sample request
        alamofireManager.request(.POST, "https://requestb.in/q9bnyvq9", parameters: ["foo": "bar"], encoding: .JSON)
            .authenticate(user: "blabla", password: "blabla")
            .validate()
            .response() { (request, response, data, error) in
                debugPrint(request)
                debugPrint(response)
        }
    }
}
