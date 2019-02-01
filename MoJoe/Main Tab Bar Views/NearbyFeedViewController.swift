//
//  NearbyFeedViewController.swift
//  MoJoe
//
//  Created by Daniel Grant on 11/11/18.
//  Copyright © 2018 Daniel Grant. All rights reserved.
//

import UIKit
import Firebase

class NearbyFeedViewController: UIViewController {
    //MARK: variables and constants
    var posts: [Review] = []
    
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
    
    let ref = Database.database().reference(withPath: "Reviews")
   
    //MARK: outlets then actions
    @IBOutlet weak var messageField: UITextField!
    @IBOutlet weak var tableView: UITableView!
    
    
    @IBAction func toReviewButton(_ sender: Any) {
        let reviewTypeAlert = UIAlertController(title: "Would you like to share:", message: "", preferredStyle: .alert)
       
        
        
        reviewTypeAlert.addAction(UIAlertAction(title: "A coffee from a shop you visited?", style: .default, handler: {action in self.performSegue(withIdentifier: "feedToBrew", sender: self)}))
    
        reviewTypeAlert.addAction(UIAlertAction(title: "A coffee you brewed yourself?", style: .default, handler: { action in self.performSegue(withIdentifier: "feedToVisit", sender: self)}))
        reviewTypeAlert.addAction(UIAlertAction(title: "Dismiss", style: .default, handler: { action in reviewTypeAlert.dismiss(animated: true, completion: nil)}))
        
        self.present(reviewTypeAlert, animated: true, completion: nil)
    }
    
    
    //MARK: tap gesture recognizer
    @IBAction func tapHideKeyboard(_ sender: Any) {
        self.messageField.resignFirstResponder()
    }
    
    
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

   //using an observer to recognize changes in the database then adding it to the posts array as the newReviews array
     ref.queryOrdered(byChild: "date").observe(.value, with: { (snapshot) in
       
        var newReviews: [Review] = []
        
        for child in snapshot.children {
            if let snapshot = child as? DataSnapshot,
                let review = Review(snapshot: snapshot){
                newReviews.append(review)
            }
        }
        self.posts = newReviews.reversed()
        self.tableView.reloadData()
     })
    }

    @IBAction func sendMessage(_ sender: Any) {
        guard let message = messageField.text,
            let user = self.user else {
            return
        }
        
        let review = Review(description: message, reviewer: user.email, date: date)
    
        
        let reviewRef = self.ref.child(message)
        
        reviewRef.setValue(review.makeDictionary())
        
        self.messageField.text = nil
    }
}

extension NearbyFeedViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return posts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
       
        let reviewCell = tableView.dequeueReusableCell(withIdentifier: "Review Cell", for: indexPath)
        let review = posts[indexPath.row]
        
    
        
        reviewCell.textLabel?.text = review.description
        reviewCell.detailTextLabel?.text = review.reviewer
        
        return reviewCell
    }
}

extension NearbyFeedViewController: UITextFieldDelegate {
    //UITextFieldDelegate(2) 1)- this is the function called when you hit the enter/retur/done button
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        //hide keyboard
        textField.resignFirstResponder()
        return true
    }
    //2) this function runs when the text field returns true after it is no longer the first responder
    func textFieldDidEndEditing(_ textField: UITextField)  {
        
        
    }
    
    
}
