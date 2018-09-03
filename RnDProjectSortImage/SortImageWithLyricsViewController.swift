//
//  ViewController.swift
//  RnDProjectSortImage
//
//  Created by sulayman on 17/7/18.
//  Copyright © 2018 sulayman. All rights reserved.
//
import Foundation
import UIKit

struct ViewControllerConstants {
    static let kViewControllerIdentifier = "SortImageViewController"
    static let kCellIdentifier = "LyricsTableViewCell"
    static let kNibName = "TableViewCell"
}

struct DraggableCell{
    var dummyCellView : UIView? = nil
    var initialIndexPath : IndexPath? = nil
}

class SortImageWithLyricsViewController: UIViewController {
   
    
    //MARK: Initial Variables Declarations + Class Functions
    
     fileprivate var lyricsImageModel : [LyricsImageModel] = []
    
     fileprivate var lyricStrings:[String] = ["ずっと見ないフリし てわからないフリがっ て背伸びて平気なフリしてた"
        ,"I'm goody-goody","わたしの頭をなでる大きな手も優しい眼差しも",
         "彼女のものだってわかってたわかってたよ、ずっとね","生ぬるい時間（トキ）が永遠と流れ"]
    


    lazy var draggableCell:DraggableCell = DraggableCell.init()

    
    @IBOutlet weak var tableView: UITableView!
    
    class func initFromStoryboard(with lyrics:[String] , and imageNames:[String]) -> SortImageWithLyricsViewController {
        let viewController = UIStoryboard.mainStoryBoard().instantiateViewController(withIdentifier: ViewControllerConstants.kViewControllerIdentifier) as! SortImageWithLyricsViewController
        
        if lyrics.count>0 {
            viewController.lyricStrings.removeAll()
            viewController.lyricStrings.append(contentsOf: lyrics)
        }
        
        for i in 0..<imageNames.count {
            let modelItem = LyricsImageModel.init(imageName: imageNames.count>i ? imageNames[i] : "")
            viewController.lyricsImageModel.append(modelItem)
        }
        
        return viewController
    }

    //MARK: ViewController's Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupViews()
        self.populateDataModel()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.tableView.reloadData()
    }
    
    
    //MARK: Internnal methods for functionalities
    
    private func setupViews() -> Void {
        self.tableView.register(UINib.init(nibName: ViewControllerConstants.kNibName, bundle: Bundle.main), forCellReuseIdentifier: ViewControllerConstants.kCellIdentifier)
        
        self.tableView.separatorStyle = .none
        
        let longPressGesture = UILongPressGestureRecognizer.init(target: self, action: #selector(onLongPress(gesture:)))
        self.tableView.addGestureRecognizer(longPressGesture)
    }
    
    private func populateDataModel() {
        let imageItemsName : [String] = ["nature1","nature2","nature4","",""]
        let lyricStrings:[String] = ["ずっと見ないフリし てわからないフリがっ て背伸びて平気なフリしてた"
            ,"I'm goody-goody","わたしの頭をなでる大きな手も優しい眼差しも",
             "彼女のものだってわかってたわかってたよ、ずっとね","生ぬるい時間（トキ）が永遠と流れ"]
        
        for i in 0..<lyricStrings.count {
            let modelItem = LyricsImageModel.init(imageName: imageItemsName.count>i ? imageItemsName[i] : "")
            self.lyricsImageModel.append(modelItem)
        }
        
    }
    
    @objc fileprivate func onLongPress(gesture: UIGestureRecognizer) -> Void{
        
        let longPress = gesture as! UILongPressGestureRecognizer
        let state = longPress.state
        
        let locationInView = longPress.location(in: self.tableView)
        let currentIndexPath = tableView.indexPathForRow(at: locationInView)
        
        switch  state {
        case .began:
            if let path = currentIndexPath {
                let model = self.lyricsImageModel[path.row]

                if model.imageName?.count == 0 {
                    return
                }
                
                draggableCell.initialIndexPath = path
                
                let tableViewCell = tableView.cellForRow(at: path) as! TableViewCell
                
                let copyCell = self.tableView.dequeueReusableCell(withIdentifier: ViewControllerConstants.kCellIdentifier) as! TableViewCell
                copyCell.contentImageView.image = UIImage.init(named: model.imageName!)
                copyCell.imageContainerFrame.tintColor = model.tintcolor
                copyCell.dividerLine.isHidden = true
                copyCell.dividerCircle.isHidden = true
                copyCell.lyricsTextViewContainer.isHidden = true
                
                draggableCell.dummyCellView = copyCellImageToDummyView(inputView: copyCell)
                var center = tableViewCell.center
                draggableCell.dummyCellView?.center = center
                draggableCell.dummyCellView?.alpha = 0.0
                
                if let view = draggableCell.dummyCellView{
                    tableView.addSubview(view)
                }
                
                UIView.animate(withDuration: 0.25, animations: {
                    () -> Void in
                    print("Animation on Dummy cell is started now ")
                    center.y = locationInView.y
                    self.draggableCell.dummyCellView?.center = center
                    self.draggableCell.dummyCellView?.transform = CGAffineTransform.init(scaleX: 1.05, y: 1.05)
                    self.draggableCell.dummyCellView?.alpha = 0.98
                    
                }, completion : {
                    (finished) -> Void in
                    if finished {
                        print("Scale and Zoom animation on dummy cell is finished")
                        tableViewCell.imageContainerView.isHidden = true
                    }
                })
            }
            
        case .changed:
            if let cell = self.draggableCell.dummyCellView {
                var center = cell.center
                center.y = locationInView.y
                cell.center = center
            }
            
        default:

            if let initialIndexPath = draggableCell.initialIndexPath {
                let cell = tableView.cellForRow(at: initialIndexPath) as! TableViewCell
                cell.imageContainerView.isHidden = false
                cell.alpha = 0.0
                
                UIView.animate(withDuration: 0.25, animations: {
                    () -> Void in
                    self.draggableCell.dummyCellView?.center = cell.center
                    self.draggableCell.dummyCellView?.transform = CGAffineTransform.identity
                    self.draggableCell.dummyCellView?.alpha = 0.0
                    cell.alpha = 1.0
                }, completion : {
                    (finished) -> Void in

                    if finished {
                        cell.imageContainerView.isHidden = false
                        self.draggableCell.initialIndexPath = nil
                        self.draggableCell.dummyCellView?.removeFromSuperview()
                        self.draggableCell.dummyCellView = nil

                        if let destinationPath = currentIndexPath {
                            if initialIndexPath != destinationPath{
                                
                                let model = self.lyricsImageModel[destinationPath.row]
                                
                                if (model.imageName ?? "").count > 0 {
                                    self.sortDataFrom(array: &self.lyricsImageModel, startIndex: initialIndexPath.row, and: destinationPath.row)
                                    UIView.animate(withDuration: 0.25, animations: {
                                        () -> Void in
                                        DispatchQueue.main.async {
                                            self.tableView.reloadData()
                                        }
                                    })

                                }
                            }
                        }
                    }
                })
            }
        }
        
    }
    
    private func copyCellImageToDummyView(inputView: UIView ) -> UIView {
        
        UIGraphicsBeginImageContextWithOptions(inputView.bounds.size, false, 0.0)
        inputView.layer.render(in: UIGraphicsGetCurrentContext()!)
        
        let image = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        
        let cellSnapshot : UIView = UIImageView.init(image: image)
        cellSnapshot.layer.masksToBounds = true
        cellSnapshot.layer.cornerRadius = 0.0
        cellSnapshot.layer.shadowOffset = CGSize.init(width: -5, height: 0)
        cellSnapshot.layer.shadowRadius = 5
        cellSnapshot.layer.shadowOpacity = 0.4
        
        return cellSnapshot
    }
    

    
    private func sortDataFrom( array: inout [LyricsImageModel], startIndex: Int, and destinationIndex: Int) /*-> [Any] */{
        
        //as dragged image is already placed correctly on position and start position image is changed with destionation
//        var dataArray = array
        var destinationDataModel = array[destinationIndex]
        
        array[destinationIndex] = array[startIndex]
        
        if startIndex < destinationIndex {
            //data move from top to bottom
            var loopIterator = destinationIndex-1
            var tempDataModel = array[loopIterator]
            
            while(loopIterator > startIndex) {
                array[loopIterator] = destinationDataModel
                loopIterator -= 1
                destinationDataModel = tempDataModel
                tempDataModel = array[loopIterator]
            }
            array[loopIterator] = destinationDataModel
            
        } else {
            //data move from bottom to top
            var loopIterator = destinationIndex + 1
            var tempDataModel = array[loopIterator]
            
            while(loopIterator < startIndex) {
                array[loopIterator] = destinationDataModel
                
                loopIterator += 1
                destinationDataModel = tempDataModel
                tempDataModel = array[loopIterator]
            }
            array[loopIterator] = destinationDataModel
        }
    }
    

    
    private func createImageFrom(image: UIImage, and color: UIColor) -> UIImage {
        let newImageFromCell = image.withRenderingMode(.alwaysTemplate)
        var newImage = newImageFromCell
        UIGraphicsBeginImageContextWithOptions(image.size, false, newImage.scale)
        color.set()
        newImage.draw(in: CGRect.init(x: 0, y: 0, width: image.size.width, height: newImage.size.height))
        newImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        
        return newImage
    }

    
}

//MARK: Data Source method implementation
extension SortImageWithLyricsViewController : UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return lyricStrings.count
    }
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: ViewControllerConstants.kCellIdentifier, for: indexPath) as? TableViewCell
   
        let model = self.lyricsImageModel[indexPath.row]
        
      
        if model.image != nil {
            cell?.contentImageView.image = model.image
            cell?.imageContainerFrame.tintColor = model.tintcolor
            cell?.dividerLine.tintColor = model.tintcolor
            cell?.dividerCircle.tintColor = model.tintcolor
        } else  {
            cell?.imageContainerView.isHidden = true
        }
        
        cell?.lyricsTextView.text = self.lyricStrings[indexPath.row]
        cell?.lyricsTextView.textContainer.maximumNumberOfLines = 4
        
        return cell!
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.tableView.deselectRow(at: indexPath, animated: true
        )
    }
    
    
}

extension SortImageWithLyricsViewController : UITableViewDelegate {
    
}

