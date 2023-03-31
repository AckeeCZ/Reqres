import UIKit
import Reqres

final class ViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
    
        var request = URLRequest(url: .init(string: "https://putsreq.com/9V1Gbu0Cg0cEGanBpMlU")!)
        request.httpMethod = "POST"
        request.httpBody = try? JSONEncoder().encode(["foo": "bar"])
        
        // make sample request
        URLSession.shared.dataTask(with: request)
            .resume()
    }
}
