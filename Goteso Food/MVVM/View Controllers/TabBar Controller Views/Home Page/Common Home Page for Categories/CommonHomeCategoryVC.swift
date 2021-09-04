//
//  CommonHomeCategoryVC.swift
//  My MM
//
//  Created by Kishore on 17/10/18.
//  Copyright © 2018 Kishore. All rights reserved.
//

import UIKit
import CRRefresh
import Shimmer
import CoreLocation
import MaterialComponents.MaterialBottomSheet
import ListPlaceholder
import NotificationCenter

var BANER_VIEW_HEIGHT = 180.0

class CommonHomeCategoryVC: UIViewController {
    
    var user_data:UserDataClass!
    var bannerV : UIView!
    var bannerCollectionView : UICollectionView!
   
    @IBOutlet weak var noStoreDescLbl: UILabel!
    @IBOutlet weak var noStoreLbl: UILabel!
    let locationManager = CLLocationManager()
    @IBOutlet weak var addressLbl: UILabel!
    var bannersImgDataArray = NSMutableArray.init()
    @IBOutlet weak var searchUserLocationButton: UIButton!
    @IBAction func searchUserLocationButton(_ sender: UIButton) {
        let viewController = self.storyboard?.instantiateViewController(withIdentifier: "SearchUserLocationVC") as! SearchUserLocationVC
        self.navigationController?.pushViewController(viewController, animated: true)
        
    }
    
    @IBOutlet weak var serverErrorView: UIView!
    var bannerImgV: UIImageView!
    @IBOutlet weak var changeButton: UIButton!
    
    @IBAction func changeButton(_ sender: UIButton) {
        let viewController = self.storyboard?.instantiateViewController(withIdentifier: "SearchUserLocationVC") as! SearchUserLocationVC
        self.navigationController?.pushViewController(viewController, animated: true)
    }
    
    @IBOutlet weak var noDataView: UIView!
    var shimmerView = FBShimmeringView(frame: .zero)
    
    var isShimmerOn = true
    var currentPage = 1
    var total_page = 0
    var to_page = 0
    var isGPSLocationOn = false
    
    
    var allStoresDataArray = NSMutableArray.init()
    var storeLat = "0.0", storeLong = "0.0"
    
    @IBAction func basketButton(_ sender: CustomBadgeButton) {
        let viewController = self.storyboard?.instantiateViewController(withIdentifier: "CartVC") as! CartVC
        self.navigationController?.pushViewController(viewController, animated: true)
    }
    
    
    @IBOutlet weak var backButtonWidthContstraints: NSLayoutConstraint!
    @IBOutlet weak var basketButton: CustomBadgeButton!
    @IBAction func searchButton(_ sender: UIButton) {
        let viewController = self.storyboard?.instantiateViewController(withIdentifier: "SearchStoreVC") as! SearchStoreVC
        if super_app_type == "supermarket" {
            viewController.bannerDataArray = self.bannersImgDataArray
        }
        self.navigationController?.pushViewController(viewController, animated: true)
    }
    @IBOutlet weak var searchButton: UIButton!
    
    @IBAction func backButton(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var navTitleLbl: UILabel!
    @IBOutlet weak var tableView: UITableView!
    var isForLaundry = false
    var isForSupermarket = false
    var isForCourier = false
    var isForCarCare = false
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
       noStoreLbl.text = "e_store".getLocalizedValue()
        noStoreDescLbl.text = "e_store_desc".getLocalizedValue()
        changeButton.setTitle("z_change".getLocalizedValue(), for: .normal)
        
        NotificationCenter.default.addObserver(self, selector: #selector(locationUpdateNotification(_:)), name: NSNotification.Name?.init(NSNotification.Name.init(rawValue: "locationUpdateNotification")), object: nil)
        if CLLocationManager.locationServicesEnabled() {
            switch CLLocationManager.authorizationStatus() {
            case .notDetermined, .restricted, .denied:
                self.isGPSLocationOn = false
                UserDefaults.standard.set(false, forKey: "locationStatus")
                
            case .authorizedAlways, .authorizedWhenInUse:
                self.isGPSLocationOn = true
                UserDefaults.standard.set(true, forKey: "locationStatus")
                print("Access")
            }
        } else {
            
        }
        CLLocationManager.init().startUpdatingHeading()
        NotificationCenter.default.addObserver(self, selector: #selector(updateVersionAction), name: NSNotification.Name("NewVersionUpdatedNotification"), object: nil)
        
        
        if isAppVersionOutDated {
            let viewController = self.storyboard?.instantiateViewController(withIdentifier: "VersionVC") as! VersionVC
            self.present(viewController, animated: true, completion: nil)
            return
        }
       
        
        self.serverErrorView.isHidden = true
        
        
        changeButton.layer.borderWidth = 1
        changeButton.layer.borderColor = MAIN_COLOR.cgColor
        changeButton.layer.cornerRadius = 2
        NotificationCenter.default.addObserver(self, selector: #selector(UserLocationNotification(notification:)), name: NSNotification.Name?.init(NSNotification.Name.init("UserLocationNotification")), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(filterNotification(notification:)), name: NSNotification.Name?.init(NSNotification.Name.init("filterNotification")), object: nil)
        
        if #available(iOS 11.0, *) {
            self.automaticallyAdjustsScrollViewInsets = true
        }
        else
        {
            self.automaticallyAdjustsScrollViewInsets = false
        }
        
        self.addRefreshFunctionality()
        
        let nib = UINib(nibName: "StoreTableCell", bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: "StoreTableCell")
        self.tabBarController?.setNeedsStatusBarAppearanceUpdate()
        self.tabBarController?.selectedIndex = 0
        self.viewWillAppear(true)
        self.tableView.tableHeaderView = getTableViewHeader()
        getAppData()
        getAllDataFromAPI(loader: false, page: 1)
        getBannerData()
        
       
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        
        
            if selectedLocation.isNotEmpty {
                self.addressLbl.text = selectedLocation
            }
            else if !isGPSLocationOn {
                self.addressLbl.text = appDefaultLocation
            }
            else
            {
                if user_current_location.isEmpty
                {
                   self.addressLbl.text = appDefaultLocation
                }
                else
                {
                  self.addressLbl.text = user_current_location
                }
                
            }
       
        tableView.backgroundColor = UIColor.groupTableViewBackground
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
      
        self.backButtonWidthContstraints.constant = 0
        self.backButton.isHidden = true
        if COMMON_FUNCTIONS.calculateTotalNumberOfItemsInCart() == "0" {
            basketButton.badgeValue = ""
        }
        else
        {
            basketButton.badgeValue = COMMON_FUNCTIONS.calculateTotalNumberOfItemsInCart()
        }
        
        DispatchQueue.main.async {
             self.updateViewConstraints()
        }
        
    }
    
    
    //MARK: Add Table HeaderView
    
    
    //MARK: Get AppData
    func getAppData() {
        let api_name = APINAME().STORE_FILTER + "?class_identifier=\(app_type)"
        WebService.requestGetUrl(strURL: api_name, params: NSDictionary.init(), is_loader_required: false, success: { (response) in
            print(response)
            if response["status_code"] as! NSNumber == 1
            {
            appDataDic = (response["data"] as! NSDictionary)
            }
            else
            {
                self.view.makeToast((response["message"] as! String))
            }
        }) { (failure) in
            print(failure)
        }
        
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK: -Add Pull To Down and Pull To Up Refresh
    func addRefreshFunctionality()  {
        print(Locale.current.languageCode!)
        print(Locale.preferredLanguages)
        tableView.cr.addHeadRefresh(animator: NormalHeaderAnimator()) { [weak self] in
            
            if appDataDic.count == 0
            {
                self?.getAppData()
            }
            if self?.bannersImgDataArray.count == 0
            {
                self?.getBannerData()
            }
            self?.getAllDataFromAPI(loader: false, page: 1)
            self?.tableView.cr.resetNoMore()
        }
        
        tableView.cr.addFootRefresh(animator: NormalFooterAnimator()) {
            [weak self] in
            
            if (self?.to_page)! == (self?.total_page)!
            {
                self?.tableView.cr.noticeNoMoreData()
                return
            }
            self?.getAllDataFromAPI(loader: false, page: (self?.currentPage)!)
            
        }
    }
    
    
    //MARK: Table View Header
    
    func getTableViewHeader() -> UIView {
        var mainViewHeight = 0.0
        
        mainViewHeight = getBannerViewHeight()
        
        let bannerMainView = UIView(frame: CGRect(x: 0.0, y: 0.0, width: Double(self.view.frame.size.width), height: mainViewHeight  ))
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
                    self.bannersImgDataArray = (response["data"] as! NSArray).mutableCopy() as! NSMutableArray
                    DispatchQueue.main.async {
                        self.tableView.tableHeaderView =  self.getTableViewHeader()
                        self.view.updateFocusIfNeeded()
                        
                    }
                    
                }
                
            }
        }) { (failure) in
            
        }
    }
    
    
    //MARK: Call API
    func getAllDataFromAPI(loader:Bool,page:Int)  {
        let api_name = APINAME()
        var lat = "", long = ""
        
        
//        #if targetEnvironment(simulator)
//        lat = "30.7135"
//        long = "76.6972"
//        #else
        
        if storeLat == "0.0" && storeLong == "0.0" {
            if !isGPSLocationOn {
                lat = appDefaultLati
                long = appDefaultLong
            }
            else
            {
                lat = latitude
                long = longitude
            }
        }
        else
        {
            lat = storeLat
            long = storeLong
        }
        
        
//        #endif
    
        
        let str = filterURL.trimmingCharacters(in: CharacterSet(charactersIn: " "))
        
        
        var url :String!
        if str.isEmpty {
            url = api_name.STORES_API + "?page=\(page)&coordinates=\(lat),\(long)&order=ASC&include_meta=true"
        }
        else
        {
            url = api_name.STORES_API + "?page=\(page)&coordinates=\(lat),\(long)&order=ASC&include_meta=true\(str)"
        }
     
        
        WebService.requestGetUrl(strURL: url, params: NSDictionary.init(), is_loader_required: loader, success: { (response) in
            print(response)
            if !self.serverErrorView.isHidden
            {
                COMMON_FUNCTIONS.setView(view: self.serverErrorView, hidden: true, option: .transitionCurlUp)
            }
            
          
            
            if response["status_code"] as! NSNumber == 1
            {
                self.isShimmerOn = false
                self.tableView.isScrollEnabled = true
                self.noDataView.isHidden = true
                self.tableView.backgroundColor = UIColor.groupTableViewBackground
                if page == 1
                {
                    self.allStoresDataArray.removeAllObjects()
                    self.currentPage = 1
                }
                
                let dataArray = ((response["data"] as! NSDictionary).object(forKey: "data") as! NSArray)
                
                
                
                
                if  dataArray.count == 0
                {
                    self.tableView.cr.endHeaderRefresh()
                    self.tableView.cr.endFooterRefresh()
                    if self.shimmerView.isShimmering
                    {
                        self.shimmerView.isShimmering = false
                        self.isShimmerOn = false
                        self.tableView.reloadData()
                    }
                    if self.allStoresDataArray.count == 0
                    {
                        self.tableView.isScrollEnabled = false
                    }
                    else
                    {
                        self.tableView.isScrollEnabled = true
                    }
                    self.noDataView.isHidden = false
                     self.tableView.backgroundColor = UIColor.white
                }
                else
                {
                    
                    for storeData in dataArray as! [NSDictionary]
                    {
                        let storeModel = StoreModel()
                        storeModel.store_id = COMMON_FUNCTIONS.checkForNull(string: storeData["store_id"] as AnyObject).1
                        storeModel.store_title = COMMON_FUNCTIONS.checkForNull(string: storeData["store_title"] as AnyObject).1
                        storeModel.store_description = COMMON_FUNCTIONS.checkForNull(string: storeData["store_description"] as AnyObject).1
                        storeModel.store_photo = COMMON_FUNCTIONS.checkForNull(string: storeData["store_photo"] as AnyObject).1
                        storeModel.store_rating = COMMON_FUNCTIONS.checkForNull(string: storeData["store_rating"] as AnyObject).1
                        storeModel.address = COMMON_FUNCTIONS.checkForNull(string: storeData["address"] as AnyObject).1
                        storeModel.available_status = COMMON_FUNCTIONS.checkForNull(string: storeData["available_status"] as AnyObject).1
                        storeModel.featured = COMMON_FUNCTIONS.checkForNull(string: storeData["featured"] as AnyObject).1
                        self.allStoresDataArray.add(storeModel)
                    }
                    
                    
                    
                    self.total_page = Int(truncating: ((response["data"] as! NSDictionary).mutableCopy() as! NSMutableDictionary).object(forKey: "total") as! NSNumber)
                    self.to_page = Int(truncating: ((response["data"] as! NSDictionary).mutableCopy() as! NSMutableDictionary).object(forKey: "to") as! NSNumber)
                    if (((response["data"] as! NSDictionary).mutableCopy() as! NSMutableDictionary).object(forKey: "next_page_url") as? String) != nil
                    {
                        self.currentPage += 1
                    }
                    
                    DispatchQueue.main.async {
                        
                        if self.allStoresDataArray.count == 0
                        {
                            self.tableView.isScrollEnabled = false
                        }
                        else
                        {
                            self.tableView.isScrollEnabled = true
                        }
                        self.tableView.cr.endHeaderRefresh()
                        self.tableView.cr.endFooterRefresh()
                        self.tableView.reloadData()
                    }
                    
                    
                }
                
            }
            else
            {
                self.noDataView.isHidden = false
                 self.tableView.backgroundColor = UIColor.white
                self.tableView.cr.endHeaderRefresh()
                self.tableView.cr.endFooterRefresh()
                if self.shimmerView.isShimmering
                {
                    self.shimmerView.isShimmering = false
                    self.isShimmerOn = false
                    self.tableView.reloadData()
                }
                if self.allStoresDataArray.count == 0
                {
                    self.tableView.isScrollEnabled = false
                }
                else
                {
                    self.tableView.isScrollEnabled = true
                }
                
                
                print(response)
            }
        }) { (failure) in
            self.tableView.cr.endHeaderRefresh()
            self.tableView.cr.endFooterRefresh()
            if self.allStoresDataArray.count == 0
            {
                self.tableView.isScrollEnabled = false
            }
            else
            {
                self.tableView.isScrollEnabled = true
            }
            if self.shimmerView.isShimmering
            {
                self.shimmerView.isShimmering = false
                self.isShimmerOn = false
                self.tableView.reloadData()
            }
             self.tableView.isScrollEnabled = true
             self.view.makeToast("a_internet".getLocalizedValue(), duration: 5, position: .bottom, title: "", image: nil, style: .init(), completion: { (result) in
               return
            })
            
        }
        
    }
    
   
    
    //MARK: Selector
    
    
    
    @objc func locationUpdateNotification(_ notification: Notification)
    {
        if notification.userInfo != nil {
            self.isGPSLocationOn = false
        }
        else
        {
            viewDidLoad()
        }
        
    }
    
    @objc func updateVersionAction()
    {
        let viewController = self.storyboard?.instantiateViewController(withIdentifier: "VersionVC") as! VersionVC
        self.present(viewController, animated: true, completion: nil)
        return
    }
    
    
    
    @objc func filterButtonAction(sender: UIButton)
    {
        let viewController = self.storyboard?.instantiateViewController(withIdentifier: "SortAndFilterVC") as! SortAndFilterVC
        let bottomSheet = MDCBottomSheetController(contentViewController: viewController)
        let size = CGSize(width: self.view.frame.size.width, height: self.view.frame.size.height - 80)
        bottomSheet.contentViewController.preferredContentSize = size
        self.present(bottomSheet, animated: true, completion: nil)
    }
    
    
    
    @objc func UserLocationNotification(notification:Notification)
    {
        if notification.userInfo != nil {
            storeLat  = (notification.userInfo!["lat"] as! String)
            storeLong  = (notification.userInfo!["long"] as! String)
            self.addressLbl.text = (notification.userInfo!["location"] as! String)
            isShimmerOn = true
            self.allStoresDataArray.removeAllObjects()
            self.tableView.reloadData()
            getAllDataFromAPI(loader: false, page: 1)
            getBannerData()
            
        }
    }
    
    @objc func filterNotification(notification:Notification)
    {
        if notification.userInfo != nil {
            filterURL = notification.userInfo!["url"] as! String
            print(filterURL)
            isShimmerOn = true
            self.allStoresDataArray.removeAllObjects()
            self.tableView.reloadData()
            getAllDataFromAPI(loader: false, page: 1)
            getBannerData()
        }
    }
    
    @objc func ratingButtonAction(sender: UIButton)
    {
        let viewController = self.storyboard?.instantiateViewController(withIdentifier: "RatingVC") as! RatingVC
        viewController.storeModel = allStoresDataArray[sender.tag] as! StoreModel
        self.navigationController?.pushViewController(viewController, animated: true)
        
    }
    
    //MARK: Local Json
    func getLocalJSON()  {
        if let path = Bundle.main.path(forResource: "AllStoreLocalJson", ofType: "json")
        {
            do
            {
                let data = try Data(contentsOf: URL(fileURLWithPath: path), options: .mappedIfSafe)
                let jsonResult = try JSONSerialization.jsonObject(with: data, options: .mutableLeaves)
                if let jsonResult = jsonResult as? Dictionary<String,AnyObject>
                {
                    
                    self.isShimmerOn = false
                    self.tableView.isScrollEnabled = true
                    self.noDataView.isHidden = true
                     self.tableView.backgroundColor = UIColor.groupTableViewBackground
                    self.allStoresDataArray = (((jsonResult as NSDictionary)["data"] as! NSDictionary).object(forKey: "data") as! NSArray).mutableCopy() as! NSMutableArray
                    
                    
                    // self.removeEmptyCategoryFromData()
                    self.total_page = Int(truncating: (((jsonResult as NSDictionary)["data"] as! NSDictionary).mutableCopy() as! NSMutableDictionary).object(forKey: "total") as! NSNumber)
                    self.to_page = Int(truncating: (((jsonResult as NSDictionary)["data"] as! NSDictionary).mutableCopy() as! NSMutableDictionary).object(forKey: "to") as! NSNumber)
                    if ((((jsonResult as NSDictionary)["data"] as! NSDictionary).mutableCopy() as! NSMutableDictionary).object(forKey: "next_page_url") as? String) != nil
                    {
                        self.currentPage += 1
                    }
                    
                    DispatchQueue.main.async {
                        
                        if self.allStoresDataArray.count == 0
                        {
                            self.tableView.isScrollEnabled = false
                        }
                        else
                        {
                            self.tableView.isScrollEnabled = true
                        }
                        self.tableView.cr.endHeaderRefresh()
                        self.tableView.cr.endFooterRefresh()
                        self.tableView.reloadData()
                    }
                    
                    
                }
                
            }
            catch
            {
                
            }
        }
        
    }
    
    
    
}
extension CommonHomeCategoryVC : UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 44
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView:UIView = UIView(frame: CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: 44))
        headerView.backgroundColor = UIColor.white
        
        let storesLbl = UILabel()
        headerView.addSubview(storesLbl)
        storesLbl.translatesAutoresizingMaskIntoConstraints = false

        storesLbl.leadingAnchor.constraint(equalTo: headerView.leadingAnchor, constant: 16).isActive = true
        storesLbl.heightAnchor.constraint(equalToConstant: 24).isActive = true
        storesLbl.widthAnchor.constraint(equalToConstant: 120).isActive = true
        storesLbl.topAnchor.constraint(equalTo: headerView.topAnchor, constant: 10).isActive = true
        if allStoresDataArray.count == 1 {
            storesLbl.text = "\(allStoresDataArray.count) " + "z_store".getLocalizedValue()
        }
        else
        {
            storesLbl.text = "\(allStoresDataArray.count)  " + "z_stores".getLocalizedValue()
        }
        storesLbl.textColor = UIColor.lightGray
        storesLbl.font = UIFont(name: REGULAR_FONT, size: 17)
        storesLbl.alpha = 0.80
        
        
//        let infoLabel:UILabel = UILabel(frame: CGRect(x: 16, y: 10, width: self.view.frame.size.width - 32, height: 24))
//        infoLabel.textColor = UIColor.lightGray
//
//        if allStoresDataArray.count == 1 {
//             infoLabel.text = "\(allStoresDataArray.count) Store"
//        }
//        else
//        {
//             infoLabel.text = "\(allStoresDataArray.count) Stores"
//        }
//
//
//        //infoLabel.alpha = 0.80
//        //let fontD:UIFontDescriptor = infoLabel.font.fontDescriptor.withSymbolicTraits(UIFontDescriptorSymbolicTraits.traitItalic)!
//        infoLabel.font = UIFont(name: REGULAR_FONT, size: 17)
        let sortView = UIView()
        headerView.addSubview(sortView)
        sortView.translatesAutoresizingMaskIntoConstraints = false
        
        sortView.centerYAnchor.constraint(equalTo: storesLbl.centerYAnchor).isActive = true
        sortView.trailingAnchor.constraint(equalTo: headerView.trailingAnchor, constant: 0).isActive = true
        sortView.widthAnchor.constraint(equalToConstant: 120).isActive = true
        sortView.heightAnchor.constraint(equalToConstant: 44).isActive = true
        sortView.backgroundColor = .white
        
        
        let sortButton = UIButton()
        sortView.addSubview(sortButton)
        sortButton.translatesAutoresizingMaskIntoConstraints = false

        sortButton.leadingAnchor.constraint(equalTo: sortView.leadingAnchor).isActive = true
        sortButton.centerYAnchor.constraint(equalTo: sortView.centerYAnchor).isActive = true
        sortButton.widthAnchor.constraint(equalToConstant: 100).isActive = true
        sortButton.heightAnchor.constraint(equalToConstant: 44).isActive = true
         let attributedTitle = [NSAttributedStringKey.font:UIFont(name: REGULAR_FONT, size: 16),NSAttributedStringKey.foregroundColor:MAIN_COLOR]
        sortButton.setAttributedTitle((NSAttributedString(string: "y_homepage_filter".getLocalizedValue(), attributes: attributedTitle as [NSAttributedStringKey : Any])), for: .normal)
        sortButton.setTitleColor(MAIN_COLOR, for: .normal)
        sortButton.addTarget(self, action: #selector(filterButtonAction(sender:)), for: .touchUpInside)
        
        let topDotLbl = UILabel()
       if !filterURL.isEmpty {
            headerView.addSubview(topDotLbl)
        topDotLbl.translatesAutoresizingMaskIntoConstraints = false
        headerView.bringSubview(toFront: topDotLbl)
            topDotLbl.heightAnchor.constraint(equalToConstant: 7).isActive = true
            topDotLbl.widthAnchor.constraint(equalToConstant: 7).isActive = true
            topDotLbl.centerXAnchor.constraint(equalTo: sortButton.centerXAnchor, constant: 38).isActive = true
            topDotLbl.topAnchor.constraint(equalTo: headerView.topAnchor, constant: 7).isActive = true
            topDotLbl.clipsToBounds = true
            topDotLbl.layer.cornerRadius = 3.5
            topDotLbl.backgroundColor = MAIN_COLOR
                    }
       
        
//        let filterView = UIView(frame: CGRect(x: self.view.frame.size.width - 120, y: 0, width: 120, height: 44))
//        filterView.backgroundColor = .white
//        let filterButton = UIButton(frame: CGRect(x: filterView.frame.origin.x, y: filterView.frame.origin.y, width: filterView.frame.size.width - 20, height: filterView.frame.size.height))
//        let topLbl = UILabel(frame: CGRect(x: (filterButton.frame.size.width + filterButton.frame.origin.x) - 9, y: 8, width: 7, height: 7))
//        topLbl.clipsToBounds = true
//        topLbl.layer.cornerRadius = 3.5
//        topLbl.backgroundColor = MAIN_COLOR
//
//        filterButton.setAttributedTitle((NSAttributedString(string: "Sort / Filter", attributes: attributedTitle as [NSAttributedStringKey : Any])), for: .normal)
//        filterButton.setTitleColor(MAIN_COLOR, for: .normal)
//        filterButton.addTarget(self, action: #selector(filterButtonAction(sender:)), for: .touchUpInside)
//        headerView.addSubview(filterButton)
//        if !filterURL.isEmpty {
//            headerView.addSubview(topLbl)
//        }
//
//
        //headerView.addSubview(filterView)
       // headerView.addSubview(infoLabel)
        return headerView
        
    } 
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        if isShimmerOn
        {
            let deviceHeight = self.view.frame.size.height
            return  Int(deviceHeight / 88)
        }
        else
        {
            
            return allStoresDataArray.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        
        if self.isShimmerOn {
            let nib1 = UINib(nibName: "ShimmerTableCell", bundle: nil)
            
            tableView.register(nib1, forCellReuseIdentifier: "ShimmerTableCell")
            
            let cell = tableView.dequeueReusableCell(withIdentifier:"ShimmerTableCell") as! ShimmerTableCell
            cell.isUserInteractionEnabled = false
            shimmerView = FBShimmeringView(frame: cell.frame)
            shimmerView.contentView = cell
            shimmerView.isShimmering = true
            return cell
            
        }
        else
        {
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "StoreTableCell", for: indexPath) as! StoreTableCell
            
            let storeModel = allStoresDataArray.object(at: indexPath.row) as! StoreModel
           
            cell.storeNameLbl.text = storeModel.store_title
            let description = storeModel.store_description
            if !description.isEmpty {
                cell.storeInfoLbl.text = description
                cell.storeInfoHeightConstraints.constant = 20
            }
            else
            {
                cell.storeInfoHeightConstraints.constant = 0
                //cell.storeInfoLbl.numberOfLines = 0
                cell.storeInfoLbl.text = ""
                // cell.storeInfoLbl.numberOfLines = 0
                // cell.storeInfoLbl.isHidden = true
                
            }
            
            let featured = storeModel.featured
                       if featured != "1" {
                        cell.featuredLbl.isHidden = true
                       }
                       else
                       {
                          cell.featuredLbl.isHidden = false
                       }
            
            
            cell.storeAddressNameLbl.text = storeModel.address
            cell.ratingLbl.text = storeModel.store_rating
            cell.ratingView.layer.cornerRadius = 13
            let imageUrl = URL(string: IMAGE_BASE_URL + "store/" + storeModel.store_photo)
             var img = #imageLiteral(resourceName: "store_placeholder")
             let store_status = storeModel.available_status
            cell.imageV.sd_setImage(with: imageUrl, placeholderImage: #imageLiteral(resourceName: "store_placeholder"), options: .refreshCached) { (image, error, cacheType, imageURL) in
                
                
                if image == nil
                {
                    img = #imageLiteral(resourceName: "store_placeholder")
                }
                else
                {
                    img = image!
                }
                
                if store_status == "1"
                {
                    cell.imageV.image = img
                    cell.locationImgV.image = #imageLiteral(resourceName: "location_placeholder")
                    cell.ratingView.isHidden = false
                    cell.storeStatusView.isHidden = true
                }
                else
                {
                     cell.imageV.image = img.noir
                    cell.locationImgV.image = #imageLiteral(resourceName: "dark_location")
                    cell.ratingView.isHidden = true
                    cell.storeStatusView.isHidden = false
                }
                
            }
            
//            cell.imageV.sd_setImage(with: imageUrl, placeholderImage: #imageLiteral(resourceName: "store_placeholder"), options: .refreshCached, completed: nil)
//
//            if store_status == "1"
//            {
//                cell.imageV.sd_setImage(with: imageUrl,  placeholderImage: #imageLiteral(resourceName: "store_placeholder"), options: .refreshCached, completed: nil)
//                cell.locationImgV.image = #imageLiteral(resourceName: "location_placeholder")
//                cell.ratingView.isHidden = false
//                cell.storeStatusView.isHidden = true            }
//            else
//            {
//                cell.imageV.sd_setImage(with: imageUrl,  placeholderImage: #imageLiteral(resourceName: "store_placeholder"), options: .refreshCached, completed: nil)
//
//                cell.locationImgV.image = #imageLiteral(resourceName: "dark_location")
//                cell.ratingView.isHidden = true
//                cell.storeStatusView.isHidden = false
//            }
            cell.ratingButton.tag = indexPath.row
            cell.ratingButton.addTarget(self, action: #selector(ratingButtonAction(sender:)), for:  .touchUpInside)
            cell.selectionStyle = .none
            return cell
        }
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let storeModel = allStoresDataArray.object(at: indexPath.row) as! StoreModel
      
        if storeModel.store_id.isEmpty {
            storeModel.store_id = store_id
            storeModel.store_title = store_name
        }
        else
        {
            store_name = storeModel.store_title
            store_id = storeModel.store_id
        }
        
        let store_status = storeModel.available_status
        if store_status == "0"
        {
            COMMON_FUNCTIONS.showAlert(msg: "a_store_closed".getLocalizedValue())
            return
        }
        
        if super_app_type == "supermarket" {
            let viewController = self.storyboard?.instantiateViewController(withIdentifier: "SuperMarketAllMainCategoriesVC") as! SuperMarketAllMainCategoriesVC
            viewController.allBannersListData = self.bannersImgDataArray
            viewController.storeModel = storeModel
            self.navigationController?.pushViewController(viewController, animated: true)
        }
        else
        {
            let viewController = self.storyboard?.instantiateViewController(withIdentifier: "LaundryHomePageVC") as! LaundryHomePageVC
            viewController.storeModel = storeModel
            self.navigationController?.pushViewController(viewController, animated: true)
        }
    }
    
}


extension CommonHomeCategoryVC : UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout
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
