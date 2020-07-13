//
//  likedPostTableViewCell.swift
//  MoJoe
//
//  Created by Daniel Grant on 3/24/20.
//  Copyright © 2020 Daniel Grant. All rights reserved.
//

import UIKit
import Firebase

class likedPostTableViewCell: UITableViewCell {
    
    //MARK: Constants/Variables
    private let user = Auth.auth().currentUser?.uid
    var postID: String = ""
    var commentsPageClosure: (() -> Void)?
    private var likedPostsByUser: [String] = []
    
    private let userRef = Database.database().reference(withPath: "Users")
    private let postsRef = Database.database().reference(withPath: "GenericPosts")
    private let shopReviewRef = Database.database().reference(withPath: "ShopReview")
    private let brewDebutRef = Database.database().reference(withPath: "BrewDebut")
    private let postLikesRef = Database.database().reference(withPath: "PostLikes")
    
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
    @IBOutlet private weak var nameLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet private weak var postExplanationLabel: UILabel!
    @IBOutlet private weak var ratingLabel: UILabel!
    @IBOutlet weak var postAccentLine: UIView!
    @IBOutlet private weak var postImage: UIImageView!
    @IBOutlet weak var profilePic: UIImageView!
    @IBOutlet private weak var likesButton: UIButton!
    @IBOutlet private weak var likesLabel: UILabel!
    @IBOutlet private weak var commentsButton: UIButton!
    
    //MARK: Completion Closure
    @IBAction func commentsButtonFunction(_ sender: Any) {
        self.commentsPageClosure?()
        
    }
    
    
    
    func setGenericPostLikeCell(post: GenericPostForLikes) {
        
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
                    self.nameLabel.text = child
                case "br":
                    self.nameLabel.text = child
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
        
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        
    }
    
    
    @objc func likeButtonTapped(sender: UIButton) {
        
        //get # of likes from database
        self.postLikesRef.child("\(postID)").child("likesAmount").observeSingleEvent(of: .value, with: { (dataSnapshot) in
            
            guard let numberOfLikes = dataSnapshot.value as? Int else {
                return
            }
            //check through the users liked posts and put them in an array
            self.userRef.child("\(String(self.user!))").child("likedPosts").observeSingleEvent(of: .value, with: { (snapshot) in
                var likedPostsArray : [String] = []
                //users first like (what has to happen in cse of empty likedPosts list.)
                 
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
                
                    for post in self.likedPostsByUser {
                        if post == self.postID {
                            
                            self.postLikesRef.child("\(self.postID)").updateChildValues(["likesAmount": numberOfLikes - 1] )
                            
                            self.userRef.child("\(String(self.user!))").child("likedPosts").child("\(self.postID)").removeValue()
                            
                            continue
                        }
                    }

            })
        })
    }
    
    
    
}
