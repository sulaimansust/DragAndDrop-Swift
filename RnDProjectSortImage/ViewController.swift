//
//  ViewController.swift
//  RnDProjectSortImage
//
//  Created by sulayman on 17/7/18.
//  Copyright © 2018 sulayman. All rights reserved.
//

import UIKit
//import Tab

struct ViewControllerConstants {
    static let kCellIdentifier = "TableViewCellID"
    static let kNibName = "TableViewCell"
}

struct DraggableCell{
     var dummyCellView : UIView? = nil
     var cellIsAnimating : Bool = false
//     var cellNeedToShow : Bool = false
}
struct DraggableCellPath {
    static var initialIndexPath : IndexPath? = nil
}

class ViewController: UIViewController {
   
    var cellImageItemsName : [String] = ["image1","image2","","image5","image6"]
    var lyrics:[String] = ["Lyrics 1","Lyrics 2","Lyrics 3","Lyrics 4","Lyrics 5"]
    
    @IBOutlet weak var tableView: UITableView!
    
    lazy var draggableCell:DraggableCell = DraggableCell.init()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        self.tableView.register(UINib.init(nibName: ViewControllerConstants.kNibName, bundle: Bundle.main), forCellReuseIdentifier: ViewControllerConstants.kCellIdentifier)
        
        let longPressGesture = UILongPressGestureRecognizer.init(target: self, action: #selector(onLongPress(gesture:)))
        self.tableView.addGestureRecognizer(longPressGesture)
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override func viewWillAppear(_ animated: Bool) {
        self.tableView.reloadData()
    }
    
    
    @objc fileprivate func onLongPress(gesture: UIGestureRecognizer) -> Void{
        
        let longPress = gesture as! UILongPressGestureRecognizer
        let state = longPress.state
        
        let locationInView = longPress.location(in: self.tableView)
        let indexPath = tableView.indexPathForRow(at: locationInView)
        
        
        
        switch  state {
        case .began:
            print("state: began ")
            if let path = indexPath {
                
                if self.cellImageItemsName[path.row] == "" {
                    return
                }
                
                DraggableCellPath.initialIndexPath = path
                
                let tableViewCell = tableView.cellForRow(at: path) as! TableViewCell
                
                let copyCell = self.tableView.dequeueReusableCell(withIdentifier: ViewControllerConstants.kCellIdentifier) as! TableViewCell
                copyCell.contentImageView.image = UIImage.init(named: self.cellImageItemsName[path.row])
                copyCell.dividerPlaceHolder.isHidden = true
                copyCell.lyricsText.isHidden = true
                
                draggableCell.dummyCellView = copyCellImageToDummyView(inputView: copyCell)
                var center = tableViewCell.center
                draggableCell.dummyCellView?.center = center
                draggableCell.dummyCellView?.alpha = 0.0
                
                
                if let view = draggableCell.dummyCellView{
                    tableView.addSubview(view)
                }
                
                UIView.animate(withDuration: 0.25, animations: {
                    () -> Void in
                    center.y = locationInView.y

                    self.draggableCell.cellIsAnimating = true
                    self.draggableCell.dummyCellView?.center = center
                    self.draggableCell.dummyCellView?.transform = CGAffineTransform.init(scaleX: 1.05, y: 1.05)
                    self.draggableCell.dummyCellView?.alpha = 0.98
//                    cell.alpha = 0.0
                    
                }, completion : {
                    (finished) -> Void in
                    if finished {
                        self.draggableCell.cellIsAnimating = false
                        tableViewCell.imageContainerView.isHidden = true
                    }
                })
            }
            
        case .changed:
//            print("state: changed ")

            if let cell = self.draggableCell.dummyCellView {
                var center = cell.center
                center.y = locationInView.y
                cell.center = center
            }
            
        default:
            print("state: default - \(state) currentIndex: \(indexPath ?? IndexPath.init(row: 0, section: 0)) initialIndex: \(DraggableCellPath.initialIndexPath ?? IndexPath.init(row: 0, section: 0))")

            if let initialIndexPath = DraggableCellPath.initialIndexPath {
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
                        DraggableCellPath.initialIndexPath = nil
                        self.draggableCell.dummyCellView?.removeFromSuperview()
                        self.draggableCell.dummyCellView = nil
                      
                        if let destinationPath = indexPath {
                            if initialIndexPath != destinationPath{
                                self.sortDataSourceWith(startIndex: initialIndexPath.row, and: destinationPath.row)
                            }
                        }
                    }
                })
            }
        }
        
    }
    
    fileprivate func copyCellImageToDummyView(inputView: UIView ) -> UIView {
        
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
    fileprivate func reloadTableViewsWithAnimation() {
        print("reloadTableViewsWithAnimation ")
        DispatchQueue.main.async {
            UIView.animate(withDuration: 0.25, animations: {
                () -> Void in
                self.tableView.reloadData()
            }
            )
        }
    }
    fileprivate func rearrangeData() {
        
        print("rearrangeData called -> ")

        
//        if isUpward {
//            var emptyCount = 1
//            while(self.cellImageItemsName[0].count == 0) {
//                let tempImage = self.cellImageItemsName[0]
//                self.cellImageItemsName[0] = self.cellImageItemsName[1]
//                for i in 2..<self.cellImageItemsName.count {
//                    print("loop \(i)")
//                    self.cellImageItemsName[i-1] = self.cellImageItemsName[i]
//                }
//                print(" rearrangeData ->> : \(self.cellImageItemsName) ")
//                self.cellImageItemsName[self.cellImageItemsName.count - emptyCount] = tempImage
//                emptyCount = emptyCount + 1
//            }
        
        for i in 1 ..< self.cellImageItemsName.count {
            if self.cellImageItemsName[i].count > 0 {
                self.cellImageItemsName[0] = self.cellImageItemsName[i]
                self.cellImageItemsName[i] = ""
                break
            }
            
        }
        
        print("final values after rearrangeData ")
        print(cellImageItemsName)

    }
    
    fileprivate func sortDataSourceWith(startIndex: Int, and destinationIndex: Int){

        print("sortDataSourceWith -> source:  \(startIndex)  dest: \(destinationIndex)")
        print("initial data ")
        print(cellImageItemsName)
        //as dragged image is already placed correctly on position and start position image is changed with destionation
        
        var destinationImageName = self.cellImageItemsName[destinationIndex]
        
        self.cellImageItemsName[destinationIndex] = self.cellImageItemsName[startIndex]
        self.cellImageItemsName[startIndex] = ""
        
        
        if startIndex < destinationIndex {
            //data move from top to bottom
            var loopIterator = destinationIndex-1
            var tempString = cellImageItemsName[loopIterator]
            
            while(loopIterator > startIndex) {
                cellImageItemsName[loopIterator] = destinationImageName
//                if tempString == "" {
//                    break
//                }
                loopIterator -= 1
                destinationImageName = tempString
                tempString = cellImageItemsName[loopIterator]
                print(cellImageItemsName)
            }
            cellImageItemsName[loopIterator] = destinationImageName
            print("final values after changing data top to bottom")
            print(cellImageItemsName)
            
        } else {
            //data move from bottom to top
            var loopIterator = destinationIndex + 1
            var tempString = cellImageItemsName[loopIterator]

            while(loopIterator < startIndex) {
                cellImageItemsName[loopIterator] = destinationImageName
//                if tempString == "" {
//                    break
//                }
                loopIterator += 1
                destinationImageName = tempString
                tempString = cellImageItemsName[loopIterator]
                print(cellImageItemsName)
            }
            cellImageItemsName[loopIterator] = destinationImageName
            print("final values after changing data bottom to top")
            print(cellImageItemsName)
        }
        
        if  self.cellImageItemsName[0].count == 0 {
            self.rearrangeData()
        }
        
        self.reloadTableViewsWithAnimation()

    }
    
    

}

extension ViewController : UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return lyrics.count
    }
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: ViewControllerConstants.kCellIdentifier, for: indexPath) as? TableViewCell
//        if cellImageItemsName[indexPath.row].count > 0 {
        cell?.contentImageView.image = UIImage.init(named: cellImageItemsName[indexPath.row])
//        } else {
//            cell?.imageContainerView.isHidden = true
//        }
        cell?.lyricsText.text = self.lyrics[indexPath.row]
        
        if cell != nil {
            return cell!
        }
        return UITableViewCell.init()
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 125
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.tableView.deselectRow(at: indexPath, animated: true
        )
    }
    
    
}

extension ViewController : UITableViewDelegate {
    
}

