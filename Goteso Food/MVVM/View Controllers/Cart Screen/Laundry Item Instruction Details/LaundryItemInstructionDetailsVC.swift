//
//  LaundryItemInstructionDetailsVC.swift
//  My MM
//
//  Created by Kishore on 23/10/18.
//  Copyright © 2018 Kishore. All rights reserved.
//

import UIKit

class LaundryItemInstructionDetailsVC: UIViewController {

    
    @IBOutlet weak var instructionVeiw: UIView!
    @IBOutlet weak var closeInstructionViewButton: UIButton!
    @IBAction func closeInstructionViewButton(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
    @IBOutlet weak var tableView: UITableView!
    var item_id : NSNumber!
    var itemDataDic = NSMutableDictionary.init()
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        let touch = touches.first!
        if touch.view == self.view {
            dismiss(animated: true, completion: nil)
        }
        super.touchesBegan(touches, with: event)
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
       self.instructionVeiw.layer.masksToBounds = true
        self.instructionVeiw.layer.cornerRadius = 10
        self.closeInstructionViewButton.layer.cornerRadius = 10
        
        if getMatchedRecordFromCartArray().count > 0 {
            itemDataDic = getMatchedRecordFromCartArray().mutableCopy() as! NSMutableDictionary
            tableView.tableHeaderView = getHeader()
        }
       
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
 
    
    //MARK: Get Matched Data From Product Array
    
    func getMatchedRecordFromCartArray() -> NSDictionary {
        for value in productCartArray {
           
            let dataDic = value as! NSDictionary
            print("\(dataDic) \n \(item_id)" )
            if (dataDic["item_id"] as! NSNumber) == item_id
            {
               return dataDic
            }
        }
        return NSDictionary.init()
    }
}

extension LaundryItemInstructionDetailsVC : UITableViewDelegate,UITableViewDataSource
{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if itemDataDic.count > 0 {
            return (itemDataDic["order_item_instructions"] as! NSArray).count
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        var cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        if  cell.isEqual(nil) {
            cell = UITableViewCell(style: .subtitle, reuseIdentifier: "cell")
        }
        
        let dataDic = (itemDataDic["order_item_instructions"] as! NSArray)[indexPath.row] as! NSDictionary
        cell.textLabel?.text = (dataDic["title"] as! String)
        cell.detailTextLabel?.text = (dataDic["value"] as! String)
        cell.selectionStyle = .none
        return cell
        
    }
    
    
    //MARK: Get Header Veiw
    func getHeader() -> UIView {
        
        let headerView = UIView(frame: CGRect(x: 0, y: 0, width: self.tableView.frame.size.width, height: 60))
        let dotImag = UIImageView(frame: CGRect(x: 16, y: 20, width: 10, height: 10))
        dotImag.image = #imageLiteral(resourceName: "dot_icon")
        headerView.addSubview(dotImag)
        
        let itemNameLbl = UILabel(frame: CGRect(x: dotImag.frame.origin.x + dotImag.frame.size.width + 10, y: 13, width: self.tableView.frame.size.width - 100, height: 22))
        itemNameLbl.text = (itemDataDic["item_title"] as! String)
         headerView.addSubview(itemNameLbl)
        let deleteButton = UIButton(frame: CGRect(x: self.tableView.frame.size.width - 45 , y: 0, width: 40, height: 40))
        deleteButton.setImage(#imageLiteral(resourceName: "delete_color"), for: .normal)
        deleteButton.addTarget(self, action: #selector(deleteButtonAction(_:)), for: .touchUpInside)
        headerView.addSubview(deleteButton)
        
        
        let editButton = UIButton(frame: CGRect(x: self.tableView.frame.size.width - 85 , y: 0, width: 40, height: 40))
        editButton.setImage(#imageLiteral(resourceName: "edit (1)"), for: .normal)
        editButton.addTarget(self, action: #selector(editButtonAction(_:)), for: .touchUpInside)
        headerView.addSubview(editButton)
            return headerView
        
    }
    
    //MARK: Selector
    
    @objc func editButtonAction(_ sender: UIButton)
    {
        self.dismiss(animated: true, completion: nil)
        let userInfo = ["item_data_dictionary":itemDataDic,"isForEdit":true] as [String : Any]
        
        NotificationCenter.default.post(name:NSNotification.Name.init("itemInstructionNotificaion"), object: nil, userInfo: userInfo)
    }
    
    @objc func deleteButtonAction(_ sender: UIButton)
    {
        let alert = UIAlertController(title: nil, message: "Are you sure to delete this instruction?", preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { (action) in
            for (index,value) in productCartArray.enumerated() {
                let dataDic = (value as! NSDictionary).mutableCopy() as! NSMutableDictionary
                if dataDic["item_id"] as! NSNumber == self.itemDataDic["item_id"] as! NSNumber
                {
                    if (self.itemDataDic["order_item_instructions"] as? NSArray) != nil
                    {
                        dataDic["order_item_instructions"] = NSMutableArray.init()
                        productCartArray.replaceObject(at: index, with: dataDic)
                        print(productCartArray)
                        NotificationCenter.default.post(name: NSNotification.Name.init("itemInstructionNotificaion"), object: nil)
                        self.dismiss(animated: true, completion: nil)
                        return
                    }
                }
                
            }
            
        }))
        
        alert.addAction(UIAlertAction(title: "No", style: .destructive, handler: { (action) in
            return
        }))
        
        let popPresenter = alert.popoverPresentationController
        popPresenter?.sourceView = self.view
        popPresenter?.sourceRect = (self.view.bounds)
        self.present(alert, animated: true, completion: nil)
      
    }
    
    
}
