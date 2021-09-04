//
//  SuperMarketAllMainCategoriesVC.swift
//  My MM
//
//  Created by Kishore on 17/11/18.
//  Copyright © 2018 Kishore. All rights reserved.
//

import UIKit
import Shimmer
import CoreLocation


class SuperMarketAllMainCategoriesVC: UIViewController,UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout {
    
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var serverErrorView: UIView!
    
    @IBOutlet weak var noDataFoundLbl: UILabel!
    @IBOutlet weak var backButtonWidthConstraints: NSLayoutConstraint!
    @IBOutlet weak var noDataView: UIView!
    var itemCollectionview : UICollectionView!
    var allCategoryDataArray = NSMutableArray.init()
    var storeModel = StoreModel()
    var shimmerView = FBShimmeringView(frame: .zero)
    var bannerCollectionView : UICollectionView!
    var isShimmerOn = true
    var collectionViewCellWidth = 0.0
    var extra_height = 0.0
    var allBannersListData = NSMutableArray.init()
    var allMainCategoriesDataArray = NSMutableArray.init()
    
    @IBOutlet weak var titleLbl: UILabel!
    
    @IBAction func backButton(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var basketButton: CustomBadgeButton!
    @IBAction func basketButton(_ sender: CustomBadgeButton) {
        let viewController = self.storyboard?.instantiateViewController(withIdentifier: "CartVC") as! CartVC
        self.navigationController?.pushViewController(viewController, animated: true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
      
        
        if isAppVersionOutDated {
            let viewController = self.storyboard?.instantiateViewController(withIdentifier: "VersionVC") as! VersionVC
            self.present(viewController, animated: true, completion: nil)
            return
        }
       
        /////////////////////////////////////////
        
        
        if #available(iOS 11.0, *) {
            self.automaticallyAdjustsScrollViewInsets = true
        }
        else
        {
            self.automaticallyAdjustsScrollViewInsets = false
        }
        
        let itemNib = UINib(nibName: "SuperMarketCategoryTVCell", bundle: nil)
        self.tableView.register(itemNib, forCellReuseIdentifier: "SuperMarketCategoryTVCell")
        self.tableView.tableHeaderView = getTableHeaderViewForBannerData()
        SHADOW_EFFECT.makeBottomShadow(forView: noDataView)
        navigationController?.isNavigationBarHidden = true
        
        
        getAllCategoriesDataAPI(loader: false)
    }
    override func viewWillAppear(_ animated: Bool) {
        
        if storeModel.store_id.isEmpty {
            storeModel.store_id = store_id
            storeModel.store_title = store_name
        }
        else
        {
            store_name = storeModel.store_title
            store_id = storeModel.store_id
        }
        
        
        if COMMON_FUNCTIONS.calculateTotalNumberOfItemsInCart() == "0" {
            basketButton.badgeValue = ""
        }
        else
        {
            basketButton.badgeValue = COMMON_FUNCTIONS.calculateTotalNumberOfItemsInCart()
        }
        
        if storeTypeCode == "00" {
            self.tabBarController?.tabBar.isHidden = false
            self.backButtonWidthConstraints.constant = 0
            backButton.isHidden = true
            getBannerData()
            self.titleLbl.text = store_name
        }
        else
        {
            self.backButtonWidthConstraints.constant = 44
            self.tabBarController?.tabBar.isHidden = true
            backButton.isHidden = false
            self.titleLbl.text = storeModel.store_title
        }
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    
    @objc func viewAllButtonAction(_ sender: UIButton)
    {
        if ((allCategoryDataArray[sender.tag] as! MainCategoryModel).subCategories).count == 0 {
            return
        }
        let viewController = self.storyboard?.instantiateViewController(withIdentifier: "SuperMarketItemsVC") as! SuperMarketItemsVC
        viewController.mainCategoryModel = (allCategoryDataArray[sender.tag] as! MainCategoryModel) 
        self.navigationController?.pushViewController(viewController, animated: true)
    }
    
    func getTableHeaderViewForBannerData() -> UIView {
        
        var mainViewHeight = 0.0
        
        mainViewHeight = getBannerViewHeight()
        
        let bannerMainView = UIView(frame: CGRect(x: 0.0, y: 0.0, width: Double(self.view.frame.size.width), height: mainViewHeight + extra_height))
        bannerMainView.backgroundColor = UIColor.groupTableViewBackground
        
        //Collection View Coding
        
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.scrollDirection = .horizontal
        
        bannerCollectionView = UICollectionView(frame: CGRect(x: 0.0, y: 0, width: Double(self.view.frame.size.width), height:Double(bannerMainView.frame.size.height) ), collectionViewLayout: flowLayout)
        bannerCollectionView.showsHorizontalScrollIndicator = false
        bannerCollectionView.delegate = self
        bannerCollectionView.dataSource = self
        bannerCollectionView.backgroundColor = UIColor.groupTableViewBackground
        let nib = UINib(nibName: "BannerCollectionViewCell", bundle: nil)
        self.bannerCollectionView.register(nib, forCellWithReuseIdentifier: "BannerCollectionViewCell")
        self.bannerCollectionView.reloadData()
        
        //if allBannersListData.count > 0 {
        bannerMainView.addSubview(bannerCollectionView)
        
        //}
        
        return bannerMainView
    }
    
    //MARK: - get BannerView Height
    
    func getBannerViewHeight() -> Double {
        
        if UIDevice.current.userInterfaceIdiom == .pad
        {
            
            return BANER_VIEW_HEIGHT + 150.0
        }
        return BANER_VIEW_HEIGHT
    }
    
    
    /////collectionView Methods
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if bannerCollectionView == collectionView {
            if self.allBannersListData.count == 0
            {
                return 1
            }
            return self.allBannersListData.count
        }
        
        return ((allCategoryDataArray[collectionView.tag] as! MainCategoryModel).subCategories).count
        
    }
    
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        print("hello")
        
        if bannerCollectionView == collectionView {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "BannerCollectionViewCell", for: indexPath) as! BannerCollectionViewCell
            
            
            if allBannersListData.count > 0
            {
                let tempDataDictionary = self.allBannersListData.object(at: indexPath.row) as! NSDictionary
                
                let imageUrl = URL(string: IMAGE_BASE_URL + "banners/" + (tempDataDictionary.object(forKey: "photo") as! String))
                
                cell.imageView1.sd_setImage(with: imageUrl, placeholderImage: #imageLiteral(resourceName: "banner-placeholder"), options: .refreshCached, completed: nil)
            }
            else
            {
                cell.imageView1.image = #imageLiteral(resourceName: "banner-placeholder")
            }
            
            cell.imageView1.clipsToBounds = true
            collectionViewCellWidth = Double(cell.frame.size.width)
            return cell
        }
        else
        {
            let nib = UINib(nibName: "SuperMarketCategoryCVCell", bundle: nil)
            collectionView.register(nib, forCellWithReuseIdentifier: "SuperMarketCategoryCVCell")
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "SuperMarketCategoryCVCell", for: indexPath) as! SuperMarketCategoryCVCell
            let subCategoryModel = ((allCategoryDataArray[collectionView.tag] as! MainCategoryModel).subCategories[indexPath.row] )
            var imageUrl : URL!
            imageUrl = URL(string: IMAGE_BASE_URL + "category/" + subCategoryModel.photo)
            cell.itemImagV.sd_setImage(with: imageUrl, placeholderImage: #imageLiteral(resourceName: "empty_item"), options: .refreshCached, completed: nil)
            cell.itemNameLbl.text = subCategoryModel.title
            cell.itemPriceLbl.text = ""
            return cell
            
        }
        
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        if bannerCollectionView == collectionView {
            return
        }
        
        let viewController = self.storyboard?.instantiateViewController(withIdentifier: "SuperMarketItemsVC") as! SuperMarketItemsVC
        viewController.selectedIndex = indexPath.row
        viewController.mainCategoryModel = (allCategoryDataArray[collectionView.tag] as! MainCategoryModel)
        self.navigationController?.pushViewController(viewController, animated: true)
        
       
    }
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize
    {
        
        if collectionView == itemCollectionview {
            return CGSize(width: 120, height: 166)
        }
        
        let height = getBannerViewHeight()
        
        if UIDevice.current.userInterfaceIdiom == .pad
        {
           
            return CGSize(width: height * 1.9, height: height)
            
        }
        
        return CGSize(width: height * 1.9, height: height)
    }
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        if collectionView == itemCollectionview {
            return UIEdgeInsetsMake(0, 0, 0, 0)
        }
        return UIEdgeInsetsMake(0, 5, 0, 5)
        
    }
    
    
    //MARK: API Call
    
    //MARK: Get Banner Data
    
    func getBannerData()  {
        let api_name = APINAME().BANNERS_API 
        WebService.requestGetUrl(strURL: api_name, params: NSDictionary.init(), is_loader_required: false, success: { (response) in
            
            
            
            if response["status_code"] as! NSNumber == 1
            {
                if (response["data"]  as! NSArray).count > 0
                {
                    self.allBannersListData = ((response["data"] as! NSArray).mutableCopy() as! NSMutableArray)
                    DispatchQueue.main.async {
                        let imgPath = (self.allBannersListData[0] as! NSDictionary)["photo"] as! String
                        
                        print(URL(string: IMAGE_BASE_URL + "banners/" + imgPath)!)
                        if self.bannerCollectionView != nil
                        {
                            self.bannerCollectionView.reloadData()
                        }
                        else
                        {
                            self.tableView.reloadData()
                        }
                        
                        self.view.updateFocusIfNeeded()
                        
                    }
                    
                }
                
            }
        }) { (failure) in
            
        }
    }
    
    
    
    func getAllCategoriesDataAPI(loader:Bool)  {
        
        let api_name = APINAME().CATEGORY_API + "?include_subcategories=true&include_empty_categories=false&include_items=false&store_id=\(store_id)"
        
        WebService.requestGetUrl(strURL: api_name, params: NSDictionary.init(), is_loader_required: loader, success: { (response) in
            print(response)
            self.isShimmerOn = false
            
            
            
            
            if response["status_code"] as! NSNumber == 1
            {
               let dataArray = (response["data"] as! NSArray).mutableCopy() as! NSMutableArray
                
                if  dataArray.count > 0
                {
                     self.allCategoryDataArray.removeAllObjects()
                    for (mainIndex,mainCategory) in (dataArray as!  [NSDictionary]).enumerated()
                    {
                        let mainCategoryModel = MainCategoryModel()
                        mainCategoryModel.id = COMMON_FUNCTIONS.checkForNull(string: mainCategory["category_id"] as AnyObject).1
                        mainCategoryModel.title = COMMON_FUNCTIONS.checkForNull(string: mainCategory["category_title"] as AnyObject).1
                        mainCategoryModel.photo = COMMON_FUNCTIONS.checkForNull(string: mainCategory["category_photo"] as AnyObject).1
                        mainCategoryModel.status = COMMON_FUNCTIONS.checkForNull(string: mainCategory["status"] as AnyObject).1
                        mainCategoryModel.main_category_description = COMMON_FUNCTIONS.checkForNull(string: mainCategory["description"] as AnyObject).1
                        var subCategories = [SubCategoryModel]()
                        for subcategory in (mainCategory["subcategories"] as! [NSDictionary])
                        {
                            let subCategoryModel = SubCategoryModel()
                            subCategoryModel.id = COMMON_FUNCTIONS.checkForNull(string: subcategory["category_id"] as AnyObject).1
                            subCategoryModel.title = COMMON_FUNCTIONS.checkForNull(string: subcategory["category_title"] as AnyObject).1
                            subCategoryModel.parent_id = COMMON_FUNCTIONS.checkForNull(string: subcategory["parent_id"] as AnyObject).1
                            subCategoryModel.store_id = COMMON_FUNCTIONS.checkForNull(string: subcategory["store_id"] as AnyObject).1
                            subCategoryModel.photo = COMMON_FUNCTIONS.checkForNull(string: subcategory["category_photo"] as AnyObject).1
                            subCategoryModel.status = COMMON_FUNCTIONS.checkForNull(string: subcategory["status"] as AnyObject).1
                            subCategoryModel.sub_category_description = COMMON_FUNCTIONS.checkForNull(string: subcategory["description"] as AnyObject).1
                            subCategories.append(subCategoryModel)
                            //  subCategories[subIndex] = subCategoryModel
                        }
                        mainCategoryModel.subCategories = subCategories
                        
                        self.allCategoryDataArray[mainIndex] = mainCategoryModel
                    }
                    
                    
                    self.noDataView.isHidden = true
                }
                else
                {
                    self.noDataView.isHidden = false
                }
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                    
                }
                
            }
            else
            {
                
                self.isShimmerOn = false
                self.shimmerView.isShimmering = false
                if self.allCategoryDataArray.count == 0
                {
                    self.noDataView.isHidden = false
                    self.tableView.isScrollEnabled = false
                }
                self.tableView.reloadData()
                
            }
        }) { (failure) in
            self.isShimmerOn = false
            self.shimmerView.isShimmering = false
            if self.allCategoryDataArray.count == 0
            {
                self.noDataView.isHidden = false
                self.tableView.isScrollEnabled = false
            }
        }
        
    }
    
    
}


extension SuperMarketAllMainCategoriesVC : UITableViewDelegate,UITableViewDataSource
{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if isShimmerOn
        {
            let deviceHeight = self.view.frame.size.height
            return  Int(deviceHeight / 130)
        }
        else
        {
            if allCategoryDataArray.count > 0 {
                return allCategoryDataArray.count
            }
        }
        
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if self.isShimmerOn {
            let nib1 = UINib(nibName: "SuperMarketCategoryShimmerTableCell", bundle: nil)
            
            tableView.register(nib1, forCellReuseIdentifier: "SuperMarketCategoryShimmerTableCell")
            
            let cell = tableView.dequeueReusableCell(withIdentifier:"SuperMarketCategoryShimmerTableCell") as! SuperMarketCategoryShimmerTableCell
            cell.isUserInteractionEnabled = false
            shimmerView = FBShimmeringView(frame: cell.frame)
            shimmerView.contentView = cell
            shimmerView.isShimmering = true
            return cell
            
        }
        else
        {
            
            shimmerView.isShimmering = false
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "SuperMarketCategoryTVCell", for: indexPath) as! SuperMarketCategoryTVCell
            cell.categoryNameLbl.text = (allCategoryDataArray[indexPath.row] as! MainCategoryModel).title
            cell.viewAllButton.layer.cornerRadius = cell.viewAllButton.frame.size.height/2
            self.itemCollectionview = cell.collectionView
            self.itemCollectionview.delegate = self
            self.itemCollectionview.dataSource = self
            self.itemCollectionview.tag = indexPath.row
            cell.viewAllButton.tag = indexPath.row
            cell.viewAllButton.addTarget(self, action: #selector(viewAllButtonAction(_:)), for: .touchUpInside)
            cell.selectionStyle = .none
            cell.collectionView.reloadData()
            return cell
        }
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if isShimmerOn {
            return 200
        }
        return 225
    }
    
    
}


