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
     var cellSnapshot : UIView? = nil
     var cellIsAnimating : Bool = false
     var cellNeedToShow : Bool = false
}
struct DraggableCellPath {
    static var initialIndexPath : IndexPath? = nil
}

class ViewController: UIViewController {

    var cellImageNames : [String] = ["image1","image2","image3","image4","image5","image6"]
    
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
        
        if self.cellImageNames.count <= 1 {
            return
        }
        
        let longPress = gesture as! UILongPressGestureRecognizer
        let state = longPress.state
        
        let locationInView = longPress.location(in: self.tableView)
        let indexPath = tableView.indexPathForRow(at: locationInView)
        
        
        switch  state {
        case .began:
            print("state: began ")
            if let path = indexPath {
                DraggableCellPath.initialIndexPath = path
                
                let tableViewCell = tableView.cellForRow(at: path) as! TableViewCell
//                draggableCell.cellSnapshot = copy
                
                let copyCell = self.tableView.dequeueReusableCell(withIdentifier: ViewControllerConstants.kCellIdentifier) as! TableViewCell
                copyCell.contentImageView.image = tableViewCell.contentImageView.image
                copyCell.dividerPlaceHolder.isHidden = true
                copyCell.lyricsText.isHidden = true
                
                draggableCell.cellSnapshot = copyCellSnapshot(inputView: copyCell)
                var center = tableViewCell.center
                draggableCell.cellSnapshot?.center = center
                draggableCell.cellSnapshot?.alpha = 0.0
                
                
                
                if let view = draggableCell.cellSnapshot{
                    tableView.addSubview(view)
                }
                
                UIView.animate(withDuration: 0.25, animations: {
                    () -> Void in
                    center.y = locationInView.y

                    self.draggableCell.cellIsAnimating = true
                    self.draggableCell.cellSnapshot?.center = center
                    self.draggableCell.cellSnapshot?.transform = CGAffineTransform.init(scaleX: 1.05, y: 1.05)
                    self.draggableCell.cellSnapshot?.alpha = 0.98
//                    cell.alpha = 0.0
                    
                }, completion : {
                    (finished) -> Void in
                    
                    if finished {
                        self.draggableCell.cellIsAnimating = false
                        if self.draggableCell.cellNeedToShow {
                            self.draggableCell.cellNeedToShow = false
                            UIView.animate(withDuration: 0.25, animations: {
                                () -> Void in
                                    tableViewCell.alpha = 1.0
                                })
                        } else {
                            tableViewCell.isHidden = true
                        }
                    }
                })
            }
            
        case .changed:
            print("state: changed ")

            if let cell = self.draggableCell.cellSnapshot {
                var center = cell.center
                center.y = locationInView.y
                cell.center = center
            }
            
            if let path = indexPath, path != DraggableCellPath.initialIndexPath {
                if let initialPath = DraggableCellPath.initialIndexPath {
                    cellImageNames.insert(cellImageNames.remove(at: initialPath.row), at: path.row)
                    
//                    self.tableView.moveRow(at: initialPath, to: path)
                    DraggableCellPath.initialIndexPath = path
                }
            }
            
        default:
            print("state: default - \(state) ")

            if let initialIndexPath = DraggableCellPath.initialIndexPath {
                let cell = tableView.cellForRow(at: initialIndexPath) as! TableViewCell
                
                if self.draggableCell.cellIsAnimating {
                    self.draggableCell.cellNeedToShow = true
                } else {
                    cell.isHidden = false
                    cell.alpha = 0.0
                }
                
                UIView.animate(withDuration: 0.25, animations: {
                    () -> Void in
                    
                    self.draggableCell.cellSnapshot?.center = cell.center
                    self.draggableCell.cellSnapshot?.transform = CGAffineTransform.identity
                    self.draggableCell.cellSnapshot?.alpha = 0.0
                    cell.alpha = 1.0
                    
                }, completion : {
                    (finished) -> Void in
                    
                    if finished {
                        DraggableCellPath.initialIndexPath = nil
                        self.draggableCell.cellSnapshot?.removeFromSuperview()
                        self.draggableCell.cellSnapshot = nil
                    }
                    
                })
                
                
            }
        }
        
    }
    
    fileprivate func copyCellSnapshot(inputView: UIView ) -> UIView {
        
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

}

extension ViewController : UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return cellImageNames.count
    }
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if let cell = tableView.dequeueReusableCell(withIdentifier: ViewControllerConstants.kCellIdentifier, for: indexPath) as? TableViewCell {
            
            cell.contentImageView.image = UIImage.init(named: cellImageNames[indexPath.row])
            return cell
            
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

