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

class ViewController: UIViewController {

    var cellImageNames : [String] = ["image1","image2","image3","image4","image5","image6"]
    
    @IBOutlet weak var tableView: UITableView!
    
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
    
    
}

extension ViewController : UITableViewDelegate {
    
}

