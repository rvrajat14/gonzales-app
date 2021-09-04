//
//  RatingVC.swift
//  My MM
//
//  Created by Kishore on 02/11/18.
//  Copyright © 2018 Kishore. All rights reserved.
//

import UIKit
import CRRefresh
import Shimmer

class RatingVC: UIViewController {
    
    @IBOutlet weak var noDataFoundLbl: UILabel!
    
    @IBOutlet weak var noDataFoundDescLbl: UILabel!
    @IBOutlet weak var revieLbl: UILabel!
    
    @IBOutlet weak var serverErrorView: UIView!
    @IBAction func okayButton(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    @IBOutlet weak var okayButton: UIButton!
    @IBOutlet weak var titleNameLbl: UILabel!
    var shimmerView = FBShimmeringView(frame: .zero)
    var isShimmerOn = true
    var currentPage = 1
    var total_page = 0
    var to_page = 0
    var allDataArray = NSMutableArray.init()
    var evenColor = UIColor(red: 255/255.0, green: 147/255.0, blue: 0/255.0, alpha: 1)
    var oddColor = UIColor(red: 80/255.0, green: 104/255.0, blue: 255/255.0, alpha: 1)
    
    @IBOutlet weak var noDataView: UIView!
    var storeModel = StoreModel()
    
    @IBOutlet weak var tableView: UITableView!
    @IBAction func backButton(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        noDataFoundDescLbl.text = "e_review_desc_c".getLocalizedValue()
        noDataFoundLbl.text = "e_reviews".getLocalizedValue()
        okayButton.setTitle("z_okay".getLocalizedValue(), for: .normal)
        self.serverErrorView.isHidden = true
        okayButton.layer.borderWidth = 1
        okayButton.layer.borderColor = MAIN_COLOR.cgColor
        okayButton.layer.cornerRadius = 2
        let ratingNib = UINib(nibName: "StoreRatingTableViewCell", bundle: nil)
        tableView.register(ratingNib, forCellReuseIdentifier: "StoreRatingTableViewCell") 
        self.tableView.tableHeaderView = UIView(frame: CGRect(x: 0, y: 0, width: self.view.frame.size.height, height: 10))
        self.tableView.backgroundColor = .groupTableViewBackground
        self.addRefreshFunctionality()
        self.getReviewsDataAPI(page: 1, loader: false)
        self.titleNameLbl.text = storeModel.store_title
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK: -Call API
    
    func getReviewsDataAPI(page:Int,loader:Bool)  {
        
        
        let api_name = APINAME()
       let url = api_name.GET_REVIEW_LIST + "/\(storeModel.store_id)?timezone=\(localTimeZoneName)"
         WebService.requestGetUrl(strURL: url, params: NSDictionary.init(), is_loader_required: loader, success: { (response) in
           
            if !self.serverErrorView.isHidden
            {
                 COMMON_FUNCTIONS.setView(view: self.serverErrorView, hidden: true, option: .transitionCurlUp)
            }
            
            print(response)
             self.isShimmerOn = false
            
            
          
            
             if response["status_code"] as! NSNumber == 1
            {
                self.tableView.isScrollEnabled = true
                self.noDataView.isHidden = true
                self.tableView.isScrollEnabled = true
                if page == 1
                {
                    
                    self.allDataArray.removeAllObjects()
                    self.currentPage = 1
                }
                
                self.allDataArray.addObjects(from: ((response["data"] as! NSDictionary).object(forKey: "data") as! NSArray).mutableCopy() as! NSMutableArray as! [Any])
                
                if self.allDataArray.count == 0
                {
                    self.noDataView.isHidden = false
                    self.tableView.reloadData()
                    self.tableView.cr.endHeaderRefresh()
                    self.tableView.cr.endFooterRefresh()
                    
                    return
                }
                
                
                self.total_page = Int(truncating: ((response["data"] as! NSDictionary).mutableCopy() as! NSMutableDictionary).object(forKey: "total") as! NSNumber)
                self.to_page = Int(truncating: ((response["data"] as! NSDictionary).mutableCopy() as! NSMutableDictionary).object(forKey: "to") as! NSNumber)
                if (((response["data"] as! NSDictionary).mutableCopy() as! NSMutableDictionary).object(forKey: "next_page_url") as? String) != nil
                {
                    self.currentPage += 1
                }
                
                DispatchQueue.main.async {
                    self.revieLbl.text = "\(self.allDataArray.count) " + "z_reviews".getLocalizedValue()
                    self.tableView.reloadData()
                    self.tableView.cr.endHeaderRefresh()
                    self.tableView.cr.endFooterRefresh()
                    
                }
                
            }
            else
             {
                
                self.tableView.reloadData()
                self.tableView.cr.endHeaderRefresh()
                self.tableView.cr.endFooterRefresh()
                self.noDataView.isHidden = false
                self.tableView.isScrollEnabled = false
            }
         
        }) { (failure) in
              self.view.makeToast("a_internet".getLocalizedValue(), duration: 5, position: .bottom, title: "", image: nil, style: .init(), completion: { (result) in
               return
            })
            
        }
    }
    
    
    //MARK: -Add Pull To Down and Pull To Up Refresh
    
    func addRefreshFunctionality()  {
        
        tableView.cr.addHeadRefresh(animator: NormalHeaderAnimator()) { [weak self] in
            
            self?.getReviewsDataAPI(page: 1, loader: false)
            self?.tableView.cr.resetNoMore()
        }
        
        
        tableView.cr.addFootRefresh(animator: NormalFooterAnimator()) {
            [weak self] in
            if (self?.to_page)! == (self?.total_page)!
            {
                self?.tableView.cr.noticeNoMoreData()
                return
            }
            self?.getReviewsDataAPI(page: (self?.currentPage)!, loader: false)
         
        }
    }
    
}


extension RatingVC : UITableViewDelegate,UITableViewDataSource
{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isShimmerOn
        {
            let deviceHeight = self.view.frame.size.height
            return  Int(deviceHeight / 88)
        }
        else
        {
        return allDataArray.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
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
              self.shimmerView.isShimmering = false
            
        let cell = tableView.dequeueReusableCell(withIdentifier: "StoreRatingTableViewCell", for: indexPath) as! StoreRatingTableViewCell
        
        let dataDic = allDataArray[indexPath.row] as! NSDictionary
        
        var imageUrl:URL!
        if let store_image = dataDic.object(forKey: "customer_photo") as? String
        {
            imageUrl = URL(string: IMAGE_BASE_URL + "user/" + store_image)
        }
        cell.ratingButton.layer.cornerRadius = 2
        cell.userImgV.sd_setImage(with: imageUrl, placeholderImage: #imageLiteral(resourceName: "user_placeholder"), options: .refreshCached, completed: nil)
        cell.userImgV.layer.cornerRadius = cell.userImgV.frame.size.width/2
        cell.userNameLbl.text = (dataDic["customer_name"] as! String)
        cell.reviewDateLbl.text = (dataDic["created_at_formatted"] as! String)
        var rating =  COMMON_FUNCTIONS.checkForNull(string: dataDic["rating"] as AnyObject).1
        if rating.count == 1 {
            rating += ".0"
        }
        cell.ratingButton.setTitle(rating, for: .normal)
        cell.commentsLbl.text = (dataDic["review"] as! String)
        cell.selectionStyle = .none
        if indexPath.row == tableView.numberOfRows(inSection: 0) - 1 {
            cell.separatorView.isHidden = true
        }
        else
        {
            cell.separatorView.isHidden = false
            }
        return cell
        }
    }
    
    //MARK: Get Short Form Of Name
    func getUserName(name:String) -> String {
        if name.isEmpty {
            return ""
        }
        let firstChar = String(name.first!)
        var secondChar = ""
        
        if name.contains(" ") {
            let index = name.index(after: name.index(of: " ")!)
            secondChar =  String(name[index])
        }
        return secondChar.isEmpty ? firstChar : firstChar + secondChar
    }
    
}
