//
//  InitialViewController.swift
//  TattooAR
//
//  Created by MacbookPro on 23.02.18.
//  Copyright © 2018 SwiftFMI. All rights reserved.
//

import Foundation
import UIKit
import Firebase
import FirebaseDatabase
import Alamofire
class InitialViewController : UIViewController{
    @IBOutlet var parentView: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    var images = [UIImage]()
    //var tempImageView: UIImageView?
    var ref: DatabaseReference!
    var childrenCount: UInt = 0
    override func viewDidLoad() {
        titleLabel.center = CGPoint(x: parentView.frame.width / 2, y: parentView.frame.height / 2)
        //titleLabel.size
        ref  = Database.database().reference()
        print("ti ebavash li se s mene ________________")
        print( ref.child("photos"))
        let childRef = Database.database().reference(withPath: "photos")
        //print(childRef.value(forKey: "0") ?? "smth");
        childRef.observe(.value, with: { snapshot in
            //snapshot.childrenCount
            for item in snapshot.children {
                // 4
                self.childrenCount = snapshot.childrenCount
                let theItem = item as! DataSnapshot
                let str = String(describing: theItem.value as! String)
                Alamofire.request(URL(string: str)!).responseData { (response) in
                    if response.error == nil {
                        print(response.result)
                        // Show the downloaded image:
                        if let data = response.data {
                            print("adding images")
                            self.images.append(UIImage(data: data)!)
                            ////self.images = newItems
                            //self.myCollView.reloadData()
                            print(self.images.count)
                            if(self.images.count >= self.childrenCount){
                                self.performSegue(withIdentifier: "toCollectionView", sender: self)
                            }
                            print("really though")
                        }
                    }
                    print("mmhm")
                }
                ///////
            }
        })
        //print(images.count)
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        //assert(sender as? UICollectionViewCell != nil, "sender is not a collection view")
        
        if segue.identifier == "toCollectionView" {
            let detailVC: TattooCollectionViewController = segue.destination as! TattooCollectionViewController
            detailVC.images = images
            //detailVC.selectedLabel = cellLabels[indexPath.row]
        }
        
    }
}
