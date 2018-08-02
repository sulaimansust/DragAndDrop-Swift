//
//  ViewController.swift
//  RnDProjectSortImage
//
//  Created by sulayman on 17/7/18.
//  Copyright © 2018 sulayman. All rights reserved.
//

import UIKit

struct ViewControllerConstants {
    static let kCellIdentifier = "TableViewCellID"
    static let kNibName = "TableViewCell"
}

struct DraggableCell{
    var dummyCellView : UIView? = nil
    var initialIndexPath : IndexPath? = nil
}

class ViewController: UIViewController {
   
    var imageItemsName : [String] = ["one","two","","four","five"]
    var lyricStrings:[String] = ["Lyrics 1","Lyrics 2","Lyrics 3","Lyrics 4","Lyrics 5"]
    
    @IBOutlet weak var tableView: UITableView!
    
    lazy var draggableCell:DraggableCell = DraggableCell.init()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupViews()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    override func viewWillAppear(_ animated: Bool) {
        self.tableView.reloadData()
    }
    
    private func setupViews() -> Void {
        self.tableView.register(UINib.init(nibName: ViewControllerConstants.kNibName, bundle: Bundle.main), forCellReuseIdentifier: ViewControllerConstants.kCellIdentifier)
        
        let longPressGesture = UILongPressGestureRecognizer.init(target: self, action: #selector(onLongPress(gesture:)))
        self.tableView.addGestureRecognizer(longPressGesture)
    }
    
    @objc fileprivate func onLongPress(gesture: UIGestureRecognizer) -> Void{
        
        let longPress = gesture as! UILongPressGestureRecognizer
        let state = longPress.state
        
        let locationInView = longPress.location(in: self.tableView)
        let currentIndexPath = tableView.indexPathForRow(at: locationInView)
        
        switch  state {
        case .began:
            print("state: began ")
            if let path = currentIndexPath {
                
                if self.imageItemsName[path.row] == "" {
                    return
                }
                
                draggableCell.initialIndexPath = path
                
                let tableViewCell = tableView.cellForRow(at: path) as! TableViewCell
                
                let copyCell = self.tableView.dequeueReusableCell(withIdentifier: ViewControllerConstants.kCellIdentifier) as! TableViewCell
                copyCell.contentImageView.image = UIImage.init(named: self.imageItemsName[path.row])
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
                    self.draggableCell.dummyCellView?.center = center
                    self.draggableCell.dummyCellView?.transform = CGAffineTransform.init(scaleX: 1.05, y: 1.05)
                    self.draggableCell.dummyCellView?.alpha = 0.98
                    
                }, completion : {
                    (finished) -> Void in
                    if finished {
                        tableViewCell.contentImageView.isHidden = true
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
            print("state: default - \(state) currentIndex: \(currentIndexPath ?? IndexPath.init(row: 0, section: 0)) initialIndex: \(draggableCell.initialIndexPath ?? IndexPath.init(row: 0, section: 0))")

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
                        cell.contentImageView.isHidden = false
                        self.draggableCell.initialIndexPath = nil
                        self.draggableCell.dummyCellView?.removeFromSuperview()
                        self.draggableCell.dummyCellView = nil
                      
                        if let destinationPath = currentIndexPath {
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
        for i in 1 ..< self.imageItemsName.count {
            if self.imageItemsName[i].count > 0 {
                self.imageItemsName[0] = self.imageItemsName[i]
                self.imageItemsName[i] = ""
                break
            }
        }
    }
    
    fileprivate func sortDataSourceWith(startIndex: Int, and destinationIndex: Int){

        //as dragged image is already placed correctly on position and start position image is changed with destionation
        
        var destinationImageName = self.imageItemsName[destinationIndex]
        
        self.imageItemsName[destinationIndex] = self.imageItemsName[startIndex]
        self.imageItemsName[startIndex] = ""
        
        if startIndex < destinationIndex {
            //data move from top to bottom
            var loopIterator = destinationIndex-1
            var tempString = imageItemsName[loopIterator]
            
            while(loopIterator > startIndex) {
                imageItemsName[loopIterator] = destinationImageName
                loopIterator -= 1
                destinationImageName = tempString
                tempString = imageItemsName[loopIterator]
                print(imageItemsName)
            }
            imageItemsName[loopIterator] = destinationImageName
            
        } else {
            //data move from bottom to top
            var loopIterator = destinationIndex + 1
            var tempString = imageItemsName[loopIterator]

            while(loopIterator < startIndex) {
                imageItemsName[loopIterator] = destinationImageName

                loopIterator += 1
                destinationImageName = tempString
                tempString = imageItemsName[loopIterator]
                print(imageItemsName)
            }
            imageItemsName[loopIterator] = destinationImageName

        }
        if  self.imageItemsName[0].count == 0 {
            self.rearrangeData()
        }
        
        self.reloadTableViewsWithAnimation()
    }

}

extension ViewController : UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return lyricStrings.count
    }
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: ViewControllerConstants.kCellIdentifier, for: indexPath) as? TableViewCell
   
        if self.imageItemsName[indexPath.row].count > 0{
            cell?.contentImageView.image = UIImage.init(named: imageItemsName[indexPath.row])
        } else {
            cell?.contentImageView.image = nil
        }
        
        cell?.lyricsText.text = self.lyricStrings[indexPath.row]
        
//        cell?.lyricsText
        
        
        cell?.contentImageView.isHidden = false
        
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

