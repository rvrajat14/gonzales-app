//
//  SocialMediaVC.swift
//  FoodApplication
//
//  Created by Kishore on 20/07/18.
//  Copyright © 2018 Kishore. All rights reserved.
//

import UIKit

class SocialMediaVC: UITableViewController {

    var socialMediaDataArray = NSMutableArray.init()
    
    @IBAction func backButton(_ sender: UIButton) {
        
        self.navigationController?.popViewController(animated: true)
    }
    @IBOutlet weak var backButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if #available(iOS 11.0, *) {
            self.automaticallyAdjustsScrollViewInsets = true
        }
        else
        {
            self.automaticallyAdjustsScrollViewInsets = false
        }
         getSocialDataAPI()
        let left_button:GotesoButtonSwift = GotesoButtonSwift(frame: CGRect(x: 0, y: 4, width: 40, height: 40))
        left_button.addTarget(self, action: #selector(popVC(_:)), for: UIControlEvents.touchUpInside)
        
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(customView: left_button)
   
        self.tableView.tableHeaderView = UIView(frame: CGRect(x: 0, y: 0, width: self.tableView.frame.size.width, height: 10))
        self.tableView.tableFooterView = UIView(frame: CGRect.zero)
     navigationItem.title = "Social Media"
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        self.tabBarController?.tabBar.isHidden = true
    }
    
    //MARK: - Selector Methods//////////
    
    @objc func popVC(_ sender: UIBarButtonItem)
    {
        
        self.navigationController?.popViewController(animated: true)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
          if socialMediaDataArray.count > 0 {
        return socialMediaDataArray.count
        }
        return 0
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        var cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        
        if cell.isEqual(nil)
        {
            cell = UITableViewCell(style: .default, reuseIdentifier: "cell")
        }
        
        if socialMediaDataArray.count > 0 {
        cell.textLabel?.font = UIFont(name: "Open Sans", size: 15)
        cell.textLabel?.text = ((socialMediaDataArray.object(at: indexPath.row) as! NSDictionary).object(forKey: "key_display_title") as! String)
        cell.accessoryType = .disclosureIndicator
             }
        cell.selectionStyle = .none
        return cell
    }
    

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let url = ((socialMediaDataArray.object(at: indexPath.row) as! NSDictionary).object(forKey: "key_value") as! String)
        UIApplication.shared.open(URL(string : url)!, options: [:], completionHandler: { (status) in
            
        })
        
    }
    
    
    //MARK: Call API
    
    func getSocialDataAPI() {
        
        let api_name = APINAME().SETTINGS_API + "?type=social"
        
        WebService.requestGetUrlWithoutParameters(strURL: api_name + "&auth_app_type=laundry", is_loader_required: true, success: { (response) in
            
            if response["status_text"] as! String == "Success"
            {
                self.socialMediaDataArray = (response["data"] as! NSArray).mutableCopy() as! NSMutableArray
                self.tableView.reloadData()
            }
            else
            {
                 COMMON_FUNCTIONS.showAlert(msg: response["message"] as! String)
            }
        }) { (failure) in
             COMMON_FUNCTIONS.showAlert(msg: "Request Time Out !")
            print(failure.debugDescription)
        }
        
    }
}
