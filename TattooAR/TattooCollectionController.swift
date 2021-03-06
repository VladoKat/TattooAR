import UIKit

class TattooCollectionViewController: UICollectionViewController {
    
    let reuseIdentifier = "TattooCell" // also enter this string as the cell identifier in the storyboard
    
    @IBOutlet var myCollView: UICollectionView!
    var images = [UIImage]()
    
    override func viewDidLoad() {
       myCollView.backgroundColor = UIColor.gray
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
        cell.backgroundColor = UIColor.brown
        cell.layer.cornerRadius = 15
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
                detailVC.images = images
            }
        } else {
            // Error sender is not a cell or cell is not in collectionView.
        }
    }
}
