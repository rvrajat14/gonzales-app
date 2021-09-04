//
//  SocialMediaVC1.swift
//  My MM
//
//  Created by Kishore on 02/11/18.
//  Copyright © 2018 Kishore. All rights reserved.
//

import UIKit

class SocialMediaVC1: UIViewController,UITableViewDelegate,UITableViewDataSource {

    @IBOutlet weak var tableView: UITableView!
    var socialMediaDataArray = NSMutableArray.init()
    
    @IBOutlet weak var pageTitleLbl: UILabel!
    @IBOutlet weak var serverErrorView: UIView!
    @IBAction func backButton(_ sender: UIButton) {
        
        self.navigationController?.popViewController(animated: true)
    }
    @IBOutlet weak var backButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        pageTitleLbl.text = "y_profile_social_media".getLocalizedValue()
        self.serverErrorView.isHidden = true
        if #available(iOS 11.0, *) {
            self.automaticallyAdjustsScrollViewInsets = true
        }
        else
        {
            self.automaticallyAdjustsScrollViewInsets = false
        }
        getSocialDataAPI()
         
        
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
    
    func numberOfSections(in tableView: UITableView) -> Int {
        
        return 1
    }
    
     func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if socialMediaDataArray.count > 0 {
            return socialMediaDataArray.count
        }
        return 0
    }
    
    
      func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        var cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        
        if cell.isEqual(nil)
        {
            cell = UITableViewCell(style: .default, reuseIdentifier: "cell")
        }
        
        if socialMediaDataArray.count > 0 {
            cell.textLabel?.font = UIFont(name: REGULAR_FONT, size: 15)
            cell.textLabel?.text = ((socialMediaDataArray.object(at: indexPath.row) as! NSDictionary).object(forKey: "key_title") as! String).capitalizingFirstLetter()
            cell.imageView?.image = ((socialMediaDataArray.object(at: indexPath.row) as! NSDictionary).object(forKey: "image") as! UIImage)
            cell.imageView?.contentMode = .scaleAspectFit
            cell.imageView?.clipsToBounds = true
            cell.accessoryType = .disclosureIndicator
        }
        cell.selectionStyle = .none
        return cell
    }
    
    
     func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let url = ((socialMediaDataArray.object(at: indexPath.row) as! NSDictionary).object(forKey: "key_value") as! String)
        UIApplication.shared.open(URL(string : url)!, options: [:], completionHandler: { (status) in
            
        })
        
    }
    
    
    //MARK: Call API
    
    func getSocialDataAPI() {
        
        let api_name = APINAME().SOCIAL_MEDIA_SETTINGS
        
        WebService.requestGetUrl(strURL: api_name, params: NSDictionary.init(), is_loader_required: true, success: { (response) in
            if !self.serverErrorView.isHidden
            {
                COMMON_FUNCTIONS.setView(view: self.serverErrorView, hidden: true, option: .transitionCurlUp)
            }
            
             
            
            if response["status_code"] as! NSNumber == 1
            {
                let dataArray = (response["data"] as! NSArray).mutableCopy() as! NSMutableArray
                self.socialMediaDataArray.removeAllObjects()
                for value in dataArray as! [NSDictionary]
                {
                    let dataDic = value.mutableCopy() as! NSMutableDictionary
                    if dataDic["key_title"] as! String == "facebook"
                    {
                      
                        dataDic.setObject(#imageLiteral(resourceName: "social_facebook_icon"), forKey: "image" as NSCopying)
                    }
                    if dataDic["key_title"] as! String == "instagram"
                    {
                         dataDic.setObject(#imageLiteral(resourceName: "instagram"), forKey: "image" as NSCopying)
                    }
                    if dataDic["key_title"] as! String == "twitter"
                    {
                         dataDic.setObject(#imageLiteral(resourceName: "social_twitter_icon"), forKey: "image" as NSCopying)
                    }
                    self.socialMediaDataArray.add(dataDic)
                }
                
                self.tableView.reloadData()
            }
            else
            {
                COMMON_FUNCTIONS.showAlert(msg: response["message"] as! String)
            }
        }) { (failure) in
             self.view.makeToast("a_internet".getLocalizedValue(), duration: 5, position: .bottom, title: "", image: nil, style: .init(), completion: { (result) in
               return
            })
        }
        
    }
}
