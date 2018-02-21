import UIKit
import Firebase
import FirebaseDatabase
import Alamofire
class TattooCollectionViewController: UICollectionViewController {
    var ref: DatabaseReference!
    let reuseIdentifier = "TattooCell" // also enter this string as the cell identifier in the storyboard
    
    @IBOutlet var myCollView: UICollectionView!
    var items = [String]()
    var images = [UIImage]()
    var tempImageView: UIImageView?
    
    override func viewDidLoad() {
        ref  = Database.database().reference()
        print("ti ebavash li se s mene ________________")
        print( ref.child("photos"))
        let childRef = Database.database().reference(withPath: "photos")
        //print(childRef.value(forKey: "0") ?? "smth");
        childRef.observe(.value, with: { snapshot in
            
            for item in snapshot.children {
                // 4
                let theItem = item as! DataSnapshot
                let str = String(describing: theItem.value as! String)
                Alamofire.request(URL(string: str)!).responseData { (response) in
                    if response.error == nil {
                       print(response.result)
                         // Show the downloaded image:
                         if let data = response.data {
                            print("adding images")
                            self.images.append(UIImage(data: data)!)
                            //self.images = newItems
                            self.myCollView.reloadData()
                            print("really though")
                        }
                    }
                    print("mmhm")
                }
    ///////
            }
        })
    }
    // MARK: - UICollectionViewDataSource protocol
    
    // tell the collection view how many cells to make
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.images.count
    }
    
    // make a cell for each cell index path
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        // get a reference to our storyboard cell
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath as IndexPath) as! TattooCell
//        if let filePath = Bundle.main.path(forResource: self.items[indexPath.item], ofType: "jpg"), let image = UIImage(contentsOfFile: filePath) {
//            cell.imageView.contentMode = .scaleAspectFit
//            cell.imageView.image = image
//            cell.backgroundColor = UIColor.cyan
//        }
        
        //cell.label.text = self.items[indexPath.item]
        cell.backgroundColor = UIColor.cyan
        // Use the outlet in our custom class to get a reference to the UILabel in the cell
//        cell.label.text = self.items[indexPath.item]
//        cell.backgroundColor = UIColor.cyan // make cell more visible in our example project
//
        cell.imageView.contentMode = .scaleAspectFit
        cell.imageView.image = self.images[indexPath.item]
        return cell
    }
    
    // MARK: - UICollectionViewDelegate protocol
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if let cell = collectionView.cellForItem(at: indexPath) {
            performSegue(withIdentifier: "ARSceneViewControllerID", sender: cell)
        } else {
            // Error indexPath is not on screen: this should never happen.
        }
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        assert(sender as? UICollectionViewCell != nil, "sender is not a collection view")
        
        if let indexPath = self.myCollView?.indexPath(for: sender as! UICollectionViewCell) {
            if segue.identifier == "ARSceneViewControllerID" {
                let detailVC: ARSceneViewController = segue.destination as! ARSceneViewController
                detailVC.selectedImage = images[indexPath.row]
                //detailVC.selectedLabel = cellLabels[indexPath.row]
            }
        } else {
            // Error sender is not a cell or cell is not in collectionView.
        }
    }
}
