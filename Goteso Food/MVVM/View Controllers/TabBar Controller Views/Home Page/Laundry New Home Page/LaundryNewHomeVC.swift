//
//  LaundryNewHomeVC.swift
//  GotesoMM2
//
//  Created by Kishore on 16/03/19.
//  Copyright © 2019 Kishore. All rights reserved.
//

import UIKit
import CoreLocation
import NotificationCenter

class LaundryNewHomeVC: UIViewController {

    
    var user_data:UserDataClass!
    var bannerV : UIView!
    var bannerCollectionView : UICollectionView!
    var collectionViewCellWidth = 0.0
    var extra_height = 0.0
    let locationManager = CLLocationManager()
    @IBOutlet weak var addressLbl: UILabel!
    var bannersImgDataArray = NSMutableArray.init()
    @IBOutlet weak var searchUserLocationButton: UIButton!
    @IBAction func searchUserLocationButton(_ sender: UIButton) {
        let viewController = self.storyboard?.instantiateViewController(withIdentifier: "SearchUserLocationVC") as! SearchUserLocationVC
        self.navigationController?.pushViewController(viewController, animated: true)
        
    }
     var storeLat = "0.0", storeLong = "0.0"
    @IBOutlet weak var serverErrorView: UIView!
    var bannerImgV: UIImageView!
    @IBAction func basketButton(_ sender: CustomBadgeButton) {
        let viewController = self.storyboard?.instantiateViewController(withIdentifier: "CartVC") as! CartVC
        self.navigationController?.pushViewController(viewController, animated: true)
    }
     @IBOutlet weak var basketButton: CustomBadgeButton!
    
    @IBOutlet weak var navTitleLbl: UILabel!
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        searchUserLocationButton.isEnabled = false
        self.addressLbl.isHidden = true
        NotificationCenter.default.addObserver(self, selector: #selector(updateVersionAction), name: NSNotification.Name("NewVersionUpdatedNotification"), object: nil)
        
        if isAppVersionOutDated {
            let viewController = self.storyboard?.instantiateViewController(withIdentifier: "VersionVC") as! VersionVC
            
            self.present(viewController, animated: true, completion: nil)
            return
        }
        
        
        
        
        self.serverErrorView.isHidden = true
         NotificationCenter.default.addObserver(self, selector: #selector(UserLocationNotification(notification:)), name: NSNotification.Name?.init(NSNotification.Name.init("UserLocationNotification")), object: nil)
        if #available(iOS 11.0, *) {
            self.automaticallyAdjustsScrollViewInsets = true
        }
        else
        {
            self.automaticallyAdjustsScrollViewInsets = false
        }
         NotificationCenter.default.addObserver(self, selector: #selector(viewWillAppear(_:)), name: NSNotification.Name("login_update_notitfication"), object: nil)
        tableView.register(UINib(nibName: "LaundryNewHomeTableViewCell", bundle: nil), forCellReuseIdentifier: "LaundryNewHomeTableViewCell")
        
          self.tableView.tableHeaderView = getTableViewHeader()
         getBannerData()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        if selectedLocation.isEmpty {
             self.addressLbl.text = user_current_location
        }
       
    }
 
    
    override func viewWillAppear(_ animated: Bool) {
        tableView.backgroundColor = UIColor.white
        self.tabBarController?.tabBar.isHidden = false
        navigationController?.isNavigationBarHidden = true
        //  getLocalJSON()
        let userDefaults = UserDefaults.standard
       
        if let data = userDefaults.object(forKey: "user_data") as? Data {
              NSKeyedUnarchiver.setClass(UserDataClass.self, forClassName: "UserDataClass")
            user_data = (NSKeyedUnarchiver.unarchiveObject(with: data) as! UserDataClass)
            self.tableView.reloadData()
            self.navTitleLbl.text = "Hi " +  user_data.user_first_name!
        }
        else
        {
            self.navTitleLbl.text = "Hi, "
        }
       
        if COMMON_FUNCTIONS.calculateTotalNumberOfItemsInCart() == "0" {
            basketButton.badgeValue = ""
        }
        else
        {
            basketButton.badgeValue = COMMON_FUNCTIONS.calculateTotalNumberOfItemsInCart()
        }
        
    }
    
    //MARK: Table View Header
    
    func getTableViewHeader() -> UIView {
        var mainViewHeight = 0.0
        
        mainViewHeight = getBannerViewHeight()
        
        let bannerMainView = UIView(frame: CGRect(x: 0.0, y: 0.0, width: Double(self.view.frame.size.width), height: mainViewHeight + extra_height))
        bannerMainView.backgroundColor = UIColor.groupTableViewBackground
        
        //Collection View Coding
        
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.scrollDirection = .horizontal
        
        bannerCollectionView = UICollectionView(frame: CGRect(x: 0.0, y: 0, width: Double(self.view.frame.size.width), height:Double(bannerMainView.frame.size.height) ), collectionViewLayout: flowLayout)
        bannerCollectionView.delegate = self
        bannerCollectionView.dataSource = self
        bannerCollectionView.showsHorizontalScrollIndicator = false
        bannerCollectionView.backgroundColor = UIColor.groupTableViewBackground
        let nib = UINib(nibName: "BannerCollectionViewCell", bundle: nil)
        self.bannerCollectionView.register(nib, forCellWithReuseIdentifier: "BannerCollectionViewCell")
        self.bannerCollectionView.reloadData()
        
        //if allBannersListData.count > 0 {
        bannerMainView.addSubview(bannerCollectionView)
        
        //}
        
        return bannerMainView
    }
    
    func getBannerViewHeight() -> Double {
        
        if UIDevice.current.userInterfaceIdiom == .pad
        {
            
            return BANER_VIEW_HEIGHT + 150.0
        }
        return BANER_VIEW_HEIGHT
    }
    
    
    //MARK: Get Banner Data
    
    func getBannerData()  {
        let api_name = APINAME().BANNERS_API 
        WebService.requestGetUrl(strURL: api_name, params: NSDictionary.init(), is_loader_required: false, success: { (response) in
            print(response)
            
            
            
            if response["status_code"] as! NSNumber == 1
            {
                if (response["data"] as! NSArray).count > 0
                {
                    self.bannersImgDataArray = (response["data"]  as! NSArray).mutableCopy() as! NSMutableArray
                    DispatchQueue.main.async {
                        self.tableView.tableHeaderView =  self.getTableViewHeader()
                        self.view.updateFocusIfNeeded()
                        
                    }
                    
                }
                
            }
        }) { (failure) in
            
        }
    }
    
    
    //MARK: Selector
    
    @objc func updateVersionAction()
    {
        let viewController = self.storyboard?.instantiateViewController(withIdentifier: "VersionVC") as! VersionVC
        self.present(viewController, animated: true, completion: nil)
        return
    }
    
    @objc func selectClothesButtonAction(_ sender : UIButton)
    {
        let viewController = self.storyboard?.instantiateViewController(withIdentifier: "LaundryHomePageVC") as! LaundryHomePageVC
        let storeModel = StoreModel()
        storeModel.store_id = store_id
        storeModel.store_title =  store_name
        viewController.storeModel = storeModel
        self.navigationController?.pushViewController(viewController, animated: true)
    }
    
    @objc func requestPickUpButtonAction(_ sender : UIButton)
    {
        
        if UserDefaults.standard.object(forKey: "user_data") != nil {
            let viewController = self.storyboard?.instantiateViewController(withIdentifier: "CheckOutVC") as! CheckOutVC
            viewController.total_amount = "0.00"
            viewController.sub_total = "0.00"
            viewController.paymentSummaryDataDic = NSMutableDictionary.init()
            self.navigationController?.pushViewController(viewController, animated: true)
        }
        else
        {
            let alert = UIAlertController(title: "Login Required", message: "You have to login first to continue", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Login", style: .default, handler: { (action) in
                let viewController = self.storyboard?.instantiateViewController(withIdentifier: "LoginVC") as! UINavigationController
                
                isFromAppdelegate = false
                self.present(viewController, animated: true, completion: nil)
                
            }))
            
            alert.addAction(UIAlertAction(title: "Cancel", style: .destructive, handler: { (action) in
                self.tabBarController?.selectedIndex = 0
            }))
            
            let popPresenter = alert.popoverPresentationController
            popPresenter?.sourceView = self.view
            popPresenter?.sourceRect = self.view.bounds
            self.present(alert, animated: true, completion: nil)
            return
        }
        
        
    }
    
    
    
    
    
    
    @objc func UserLocationNotification(notification:Notification)
    {
        if notification.userInfo != nil {
            storeLat  = (notification.userInfo!["lat"] as! String)
            storeLong  = (notification.userInfo!["long"] as! String)
            DispatchQueue.main.async {
                 self.addressLbl.text = (notification.userInfo!["location"] as! String)
            }
            print((notification.userInfo!["location"] as! String))
            self.tableView.reloadData()
            getBannerData()
            
        }
    }
    
    
    
}


extension LaundryNewHomeVC : UITableViewDelegate, UITableViewDataSource
{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell  = tableView.dequeueReusableCell(withIdentifier: "LaundryNewHomeTableViewCell", for: indexPath) as! LaundryNewHomeTableViewCell
        cell.selectionStyle = .none
        cell.selectClothesButton.layer.cornerRadius = cell.selectClothesButton.frame.size.height/2
        cell.requestPickUpButton.layer.cornerRadius = cell.requestPickUpButton.frame.size.height/2
        
        cell.selectClothesButton.addTarget(self, action: #selector(selectClothesButtonAction(_:)), for: .touchUpInside)
         cell.requestPickUpButton.addTarget(self, action: #selector(requestPickUpButtonAction(_:)), for: .touchUpInside)
        
        return cell
    }
    
    
}


extension LaundryNewHomeVC : UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout
{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if bannerCollectionView == collectionView {
            return  self.bannersImgDataArray.count
        }
        
        return 0
        
    }
    
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        print("hello")
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "BannerCollectionViewCell", for: indexPath) as! BannerCollectionViewCell
        
        if self.bannersImgDataArray.count > 0
        {
            let tempDataDictionary =  self.bannersImgDataArray.object(at: indexPath.row) as! NSDictionary
            
            let imageUrl = URL(string: IMAGE_BASE_URL + "banners/" + (tempDataDictionary.object(forKey: "photo") as! String))
            
            cell.imageView1.sd_setImage(with: imageUrl, placeholderImage: UIImage.init(), options: .refreshCached, completed: nil)
        }
        
        cell.imageView1.clipsToBounds = true
        collectionViewCellWidth = Double(cell.frame.size.width)
        return cell
        
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize
    {
        
        let height = getBannerViewHeight()
        if UIDevice.current.userInterfaceIdiom == .pad
        {
            
            return CGSize(width: height * 1.9, height: height)
            
        }
        
        return CGSize(width: height * 1.9, height: height)
    }
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        
        return UIEdgeInsetsMake(0, 5, 0, 5)
        
    }
    
    
}
