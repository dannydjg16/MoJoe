//
//  BrewPickViewController.swift
//  MoJoe
//
//  Created by Daniel Grant on 2/11/19.
//  Copyright © 2019 Daniel Grant. All rights reserved.
//

import UIKit
import Firebase

protocol ChangeCellTextDelegate: class {
    func changeCellText(text: String)
}

class BrewPickViewController: UIViewController {

    @IBOutlet weak var practiceField: UITextField!
    let ref = Database.database().reference(withPath: "Reviews")
    var user: User? {
        var ref: DatabaseReference!
        guard let firebaseUser = Auth.auth().currentUser,
            let email = firebaseUser.email else {
                return nil
        }
        return User(uid: firebaseUser.uid, email: email)
    }
    
    var date: String {
        get {
            let postDate = Date()
            let dateFormat = DateFormatter()
            dateFormat.dateFormat = "YYYY-MM-dd HH:mm:ss"
            let stringDate = dateFormat.string(from: postDate)
            return stringDate
        }
    }
    
    
    
    
    
    
    
    @IBOutlet weak var brewTextField: UITextField!
    
    weak var cellDelegate: ChangeCellTextDelegate?
    
    @IBAction func addBrew(_ sender: Any) {
        cellDelegate?.changeCellText(text: brewTextField.text!)
       
       navigationController?.dismiss(animated: true, completion: nil)
    }
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    

    

}
