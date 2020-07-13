//
//  GenericPostTableViewCell.swift
//  MoJoe
//
//  Created by Daniel Grant on 2/11/20.
//  Copyright © 2020 Daniel Grant. All rights reserved.
//

import UIKit
import Firebase

class GenericPostTableViewCell: UITableViewCell {
    
    //MARK: Constants/Variables
    private let user = Auth.auth().currentUser?.uid
    private var likedPostsByUser: [String] = []
    var postID: String = "a"
    var genericReview: GenericPostForLikes = GenericPostForLikes(date: "", imageURL: "", postID: "", userID: "", postExplanation: "", rating: 0, reviewType: "", likeDate: "")
    
    
    var commentsPageClosure: (() -> Void)?
    var reportButton: (() -> Void)?
    var toUserProfileTapHandler: (() -> Void)?
    
    private let userRef = Database.database().reference(withPath: "Users")
    private let postsRef = Database.database().reference(withPath: "GenericPosts")
    private let shopReviewRef = Database.database().reference(withPath: "ShopReview")
    private let brewDebutRef = Database.database().reference(withPath: "BrewDebut")
    private let postLikesRef = Database.database().reference(withPath: "PostLikes")
    private let reportRef = Database.database().reference(withPath: "Reports")
    
    
    private var date: String {
        get {
            let postDate = Date()
            let dateFormat = DateFormatter()
            dateFormat.dateFormat = "YYYY-MM-dd HH:mm:ss"
            let stringDate = dateFormat.string(from: postDate)
            return stringDate
        }
    }
    
    
    //MARK: Connections
    @IBOutlet private weak var nameButton: UIButton!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet private weak var postExplanationLabel: UILabel!
    @IBOutlet private weak var ratingLabel: UILabel!
    @IBOutlet weak var postAccentLine: UIView!
    @IBOutlet private weak var postImage: UIImageView!
    @IBOutlet weak var profilePic: UIImageView!
    @IBOutlet private weak var likesButton: UIButton!
    @IBOutlet private weak var likesLabel: UILabel!
    @IBOutlet private weak var commentsButton: UIButton!
    
    @IBAction func commentsButtonFunction(_ sender: Any) {
        
        self.commentsPageClosure?()
    }
    
    @IBAction func reportButtonPressed(_ sender: Any) {
        
        let reportLocation = reportRef.child("\(self.postID)")
        reportLocation.setValue(["\(self.postID)": date])
        
        self.reportButton?()
    }
    
    @IBAction func userButtonAction(_ sender: Any) {
        
        self.toUserProfileTapHandler?()
    }
    
    
    
    //MARK: Set Generic Cell
    func setGenericCell(post: UserGenericPost) {
        
        genericReview = GenericPostForLikes(date: post.date, imageURL: post.imageURL, postID: post.postID, userID: post.userID, postExplanation: post.postExplanation, rating: post.rating, reviewType: post.reviewType, likeDate: date)
        ratingLabel.text = String(post.rating) + "/10"
        postExplanationLabel.text = post.postExplanation
        
        self.postID = post.postID
        
        postImage.setImage(from: post.imageURL)
        
        userRef.child("\(post.userID)").child("UserPhoto").observe(.value, with: { (snapshot) in
            guard let child = snapshot.value as? String else {
                return
            }
            
            self.profilePic.setImage(from: child)
            
        })
        
        
        userRef.child("\(post.userID)").child("UserName").observe(.value, with: { (snapshot) in
            
            if let child = snapshot.value as? String {
                
                let postIDPre = post.postID.prefix(2)
                switch postIDPre {
                    
                case "sh":
                    self.nameButton.setTitle("\(child)" + " visited...", for: .normal)
                    
                case "br":
                    self.nameButton.setTitle("\(child)" + " brewed...", for: .normal)
                    
                default:
                    print("nameButtonSwitch")
                }
            }
        })
        
        postLikesRef.child("\(post.postID)").child("likesAmount").observe(.value, with: {
            (snapshot) in
            
            guard let likesNumber = snapshot.value as? Int else {
                return
            }
            
            self.likesLabel.text = String(likesNumber)
            
        })
        
        
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        likesButton.setImage(#imageLiteral(resourceName: "upload"), for: .normal)
        likesButton.addTarget(self, action: #selector(likeButtonTapped), for: .touchUpInside)
        
        commentsButton.setImage(#imageLiteral(resourceName: "note"), for: .normal)
        
        
        profilePic.layer.cornerRadius = profilePic.frame.height / 2
        profilePic.contentMode = .scaleAspectFill
        
        postImage.contentMode = .scaleAspectFill
        
        self.isUserInteractionEnabled = true
        
        userRef.child("\(String(self.user!))").child("likedPosts").observe(.value, with: { (snapshot) in
            
            var likedPostsArray : [String] = []
            
            for child in snapshot.children {
                
                if let snapshot = child as? DataSnapshot, let valueDictionary = snapshot.value as? [String: AnyObject] {
                    
                    likedPostsArray.append(valueDictionary["postID"] as! String)
                    
                }
                //set the glabal var likedPostsByUser equal to the local array likedPostsArray
                self.likedPostsByUser = likedPostsArray
            }
            if likedPostsArray.contains(self.postID) {
                
                self.likesButton.layer.borderWidth = 1
                self.likesButton.layer.borderColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
                
            } else {
                
                self.likesButton.layer.borderWidth = 0
                
            }
        })
        
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
    }
    
    
    @objc private func likeButtonTapped(sender: UIButton) {
        
        //get # of likes from database
        self.postLikesRef.child("\(postID)").child("likesAmount").observeSingleEvent(of: .value, with: { (dataSnapshot) in
            
            guard let numberOfLikes = dataSnapshot.value as? Int else {
                return
            }
            //check through the users liked posts and put them in an array
            self.userRef.child("\(String(self.user!))").child("likedPosts").observeSingleEvent(of: .value, with: { (snapshot) in
                var likedPostsArray : [String] = []
                //users first like (what has to happen in cse of empty likedPosts list.)
                if snapshot.childrenCount == 0 {
                    self.postLikesRef.child("\(self.postID)").updateChildValues(["likesAmount": numberOfLikes + 1] )
                    //make the tab in firebase for that postID in the users likedposts
                    let likedPostDatabasePoint = self.userRef.child("\(String(self.user!))").child("likedPosts").child("\(self.postID)")
                    let genericLikedPost = self.genericReview
                    
                    //set the value of the^ above point to postID: date
                    likedPostDatabasePoint.setValue(genericLikedPost.makeDictionary())
                    
                } else {
                    for child in snapshot.children
                    {
                        
                        if let snapshot = child as? DataSnapshot,
                            
                            let value = snapshot.value as? [String: AnyObject]
                            
                        {
                            likedPostsArray.append(value["postID"] as! String)
                        }
                        self.likedPostsByUser = likedPostsArray
                    }
                    //iterate through the users liked posts, if post is in the likedPosts of user, it will not run the code to add a like/add post to users liked posts
                    var hasPostBeenLiked: Bool = false
                    for post in self.likedPostsByUser {
                        if post == self.postID {
                            
                            self.postLikesRef.child("\(self.postID)").updateChildValues(["likesAmount": numberOfLikes - 1] )
                            
                            self.userRef.child("\(String(self.user!))").child("likedPosts").child("\(self.postID)").removeValue()
                            
                            hasPostBeenLiked = true
                            continue
                        }
                    }
                    
                    if hasPostBeenLiked == false {
                        
                        self.postLikesRef.child("\(self.postID)").updateChildValues(["likesAmount": numberOfLikes + 1] )
                        
                        let likedPostDatabasePoint = self.userRef.child("\(String(self.user!))").child("likedPosts").child("\(self.postID)")
                        let genericLikedPost = self.genericReview
                        
                        //set the value of the^ above point to postID: date
                        likedPostDatabasePoint.setValue(genericLikedPost.makeDictionary())
                    }
                }
            })
        })
    }
}
