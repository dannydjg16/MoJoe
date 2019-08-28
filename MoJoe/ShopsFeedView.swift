//
//  ShopsFeedView.swift
//  MoJoe
//
//  Created by Daniel Grant on 4/23/19.
//  Copyright © 2019 Daniel Grant. All rights reserved.
//

import UIKit
import Firebase

class ShopsFeedView: UIViewController {

    var userMe = Auth.auth().currentUser
    var shopTagsArray: [String] = []
    var shopReviews: [ShopReivew] = []
    
    
    
   
    
    
    let shopReviewRef = Database.database().reference(withPath: "ShopReview")
    let userRef = Database.database().reference(withPath: "Users")
    
    @IBOutlet weak var shopReviewTable: UITableView!
    
    var toReviewPage = UIButton()
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toCommentsPage", let commentsPage = segue.destination as? CommentsForShopReview {
            commentsPage.postIDFromFeed = sender as! String
            
           // commentsPage.postIDFromFeed = (need to figure out how to set this from this file. could be in this function, could be somewher else. maybe ill use a closure.)
        }
    }

    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        //MARK: Review page button stuff
        self.toReviewPage = UIButton(type: .custom)
        self.toReviewPage.setTitleColor(#colorLiteral(red: 0.6679978967, green: 0.4751212597, blue: 0.2586010993, alpha: 1), for: .normal)
        self.toReviewPage.addTarget(self, action: #selector(displayReviewPage), for: .touchUpInside)
        self.view.addSubview(toReviewPage)
    
        
        
        
        
        shopReviewRef.queryOrdered(byChild: "date").observe(.value, with: {
            (snapshot) in
            
            var newShopReviews: [ShopReivew] = []
            
            for child in snapshot.children {
                if let snapshot = child as? DataSnapshot,
                    let shopReview = ShopReivew(snapshot: snapshot) {
                    newShopReviews.append(shopReview)
                    
                    self.shopReviews = newShopReviews
                    self.shopReviewTable.reloadData()
                }
            }
            self.shopReviews = newShopReviews
            self.shopReviewTable.reloadData()
    })
    }
    
    @objc func displayReviewPage(){
        self.performSegue(withIdentifier: "toShopReviewSegue", sender: self)
    }
    //MARK: More button Stuff
    override func viewWillLayoutSubviews() {
        toReviewPage.layer.cornerRadius = toReviewPage.layer.frame.size.width / 2
        toReviewPage.backgroundColor = #colorLiteral(red: 0.812450707, green: 0.7277771831, blue: 0.3973348141, alpha: 1)
        toReviewPage.clipsToBounds = true
        toReviewPage.setImage(#imageLiteral(resourceName: "coffee-bean-for-a-coffee-break"), for: .normal)
       
        toReviewPage.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([toReviewPage.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -14),toReviewPage.bottomAnchor.constraint(equalTo: self.view.bottomAnchor, constant: -100.0), toReviewPage.widthAnchor.constraint(equalToConstant: 50), toReviewPage.heightAnchor.constraint(equalToConstant: 50)])
        
    }
    
   
}


extension ShopsFeedView: UITableViewDataSource, UITableViewDelegate {
    
    func borderSet(cell: UITableViewCell, color: UIColor, width: Int) {
        cell.layer.borderColor = color.cgColor
        cell.layer.borderWidth = CGFloat(width)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        return 310
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return shopReviews.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let shop = shopReviews[indexPath.row]
        
        let shopCell =  shopReviewTable.dequeueReusableCell(withIdentifier: "ShopReviewCell") as! ShopReviewCell
        
        shopCell.setShopReviewCell(review: shop)
        
        let uid = shop.user
        
        self.userRef.child(uid).child("UserName").observeSingleEvent(of: .value, with: { (dataSnapshot) in
            
            guard let currentUserName = dataSnapshot.value as? String else { return }
           shopCell.userVisitedLabel.text = "\(currentUserName) visited..."
            
        })
        
        
        self.userRef.child(uid).child("UserPhoto").observeSingleEvent(of: .value, with: {(dataSnapshot) in
            
            guard let currentProfilePicture = dataSnapshot.value as? String else { return }
            
            shopCell.profilePic.setImage(from: currentProfilePicture)
           
            
        })

        shopCell.shopTagsArray = shop.shopTags.components(separatedBy: ", ")
     
        let timeAgoString = Date().timeSinceShopReview(theShop: shop)
        
        shopCell.timeSinceLabel.text = timeAgoString
        
        borderSet(cell: shopCell, color: #colorLiteral(red: 0.501960814, green: 0.501960814, blue: 0.501960814, alpha: 1), width: 3)
        
        shopCell.tapHandler = {
            
            
            let commentsVC = CommentsForShopReview()
            commentsVC.postIDFromFeed = shopCell.postID
            
           
            
            self.performSegue(withIdentifier: "toCommentsPage", sender: shopCell.postID)
            
        
        
        }
        
        return shopCell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print(indexPath)
    }
    
   
    
    
}


