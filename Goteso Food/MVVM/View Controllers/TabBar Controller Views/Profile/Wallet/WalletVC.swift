//
//  WalletVC.swift
//  My MM
//
//  Created by Kishore on 18/02/19.
//  Copyright © 2019 Kishore. All rights reserved.
//

import UIKit
import Shimmer
import CRRefresh


class WalletVC: UIViewController {

    @IBOutlet weak var totalPointLbl: UILabel!
    
    @IBOutlet weak var noDataFoundLbl: UILabel!
    @IBOutlet weak var pageTitleLbl: UILabel!
    
    @IBOutlet weak var noDataFoundDescLbl: UILabel!
    var currentPage = 1
    var total_page = 0
    var to_page = 0
    @IBOutlet weak var noDataview: UIView!
    @IBOutlet weak var backV: UIView!
    var allHistoryDataArray = NSMutableArray.init()
    var user_id = ""
    var isShimmerOn = true
     var shimmerView = FBShimmeringView(frame: .zero)
    @IBOutlet weak var serverErrorView: UIView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var pointsInfoLbl: UILabel!
    @IBOutlet weak var pointsLbl: UILabel!
    @IBAction func backButton(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    override func viewDidLoad() {
        super.viewDidLoad()

        
        pageTitleLbl.text = "z_wallet".getLocalizedValue()
        totalPointLbl.text = "y_wallet_total".getLocalizedValue()
        noDataFoundLbl.text = "e_history_title".getLocalizedValue()
        noDataFoundDescLbl.text = "e_history_desc".getLocalizedValue()
        
        let nib = UINib(nibName: "WalletTableViewCell", bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: "WalletTableViewCell")
        tableView.tableFooterView = UIView(frame: .zero)
       // tableView.tableHeaderView = UIView(frame: CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: 10))
        SHADOW_EFFECT.makeBottomShadow(forView: noDataview)
        addRefreshFunctionality()
        getHistoryData(loader: true, page: 1)
        
    }
   
    
    //MARK: -Add Pull To Down and Pull To Up Refresh
    func addRefreshFunctionality()  {
        
        tableView.cr.addHeadRefresh(animator: NormalHeaderAnimator()) { [weak self] in
            self?.getHistoryData(loader: false, page: 1)
            self?.tableView.cr.resetNoMore()
            
        }
        
        
        tableView.cr.addFootRefresh(animator: NormalFooterAnimator()) {
            [weak self] in
            if (self?.to_page)! == (self?.total_page)!
            {
                self?.tableView.cr.noticeNoMoreData()
                return
            }
            self?.getHistoryData(loader: false, page: self!.currentPage)
            
        }
    }
    
    //MARK: Call API
    func getHistoryData(loader:Bool,page:Int)  {
        let api_name = APINAME().WALLET_API + "/\(user_id)?timezone=\(localTimeZoneName)&page=\(page)"
        WebService.requestGetUrl(strURL: api_name, params: NSDictionary.init(), is_loader_required: loader, success: { (response) in
            print(response)
            self.isShimmerOn = false
            if !self.serverErrorView.isHidden
            {
                COMMON_FUNCTIONS.setView(view: self.serverErrorView, hidden: true, option: .transitionCurlUp)
            }
         
            
             if response["status_code"] as! NSNumber == 1
            {
                self.pointsLbl.text = COMMON_FUNCTIONS.checkForNull(string: (response["points"] as AnyObject)).1
                self.pointsInfoLbl.text = COMMON_FUNCTIONS.checkForNull(string: (response["desc"] as AnyObject)).1
                
                if page == 1
                {
                    
                    self.allHistoryDataArray.removeAllObjects()
                    self.currentPage = 1
                }
             let  array = ((response["data"] as! NSDictionary).object(forKey: "data") as! NSArray)
                
                if array.count == 0
                {
                    self.noDataview.isHidden = false
                    self.tableView.reloadData()
                    self.tableView.cr.endHeaderRefresh()
                    self.tableView.cr.endFooterRefresh()
                    return
                }
                else
                {
                    self.allHistoryDataArray.addObjects(from: array as! [Any])
                }
                
                if (((response["data"] as! NSDictionary).mutableCopy() as! NSMutableDictionary).object(forKey: "next_page_url") as? String) != nil
                {
                    self.currentPage += 1
                }
                
                if let totalPage = (((response["data"] as! NSDictionary).mutableCopy() as! NSMutableDictionary).object(forKey: "total") as? NSNumber)
                {
                    self.total_page = Int(truncating: totalPage)
                }
                
                if let toPage = (((response["data"] as! NSDictionary).mutableCopy() as! NSMutableDictionary).object(forKey: "to") as? NSNumber)
                {
                     self.to_page = Int(truncating: toPage)
                }
                
              
                if self.allHistoryDataArray.count == 0
                {
                    self.tableView.isScrollEnabled = false
                     self.noDataview.isHidden = false
                }
                else
                {
                    self.tableView.isScrollEnabled = true
                     self.noDataview.isHidden = true
                }
                
           
                DispatchQueue.main.async {
                    self.tableView.cr.endHeaderRefresh()
                    self.tableView.cr.endFooterRefresh()
                    self.tableView.reloadData()
                }
                
                
            }
            else
             {
                
                self.noDataview.isHidden = false
                self.tableView.cr.endHeaderRefresh()
                self.tableView.cr.endFooterRefresh()
                self.tableView.reloadData()
                
            }
        }) { (failure) in
            self.tableView.cr.endHeaderRefresh()
            self.tableView.cr.endFooterRefresh()
            self.tableView.reloadData()
            self.isShimmerOn = false
             self.view.makeToast("a_internet".getLocalizedValue(), duration: 5, position: .bottom, title: "", image: nil, style: .init(), completion: { (result) in
               return
            })
        }
    }
    
}

extension WalletVC : UITableViewDataSource, UITableViewDelegate
{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isShimmerOn
        {
            let deviceHeight = self.view.frame.size.height
            return  Int(deviceHeight / 88)
        }
        return allHistoryDataArray.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if self.isShimmerOn {
            let nib1 = UINib(nibName: "OfferShimmerTableCell", bundle: nil)
            
            tableView.register(nib1, forCellReuseIdentifier: "OfferShimmerTableCell")
            
            let cell = tableView.dequeueReusableCell(withIdentifier:"OfferShimmerTableCell") as! OfferShimmerTableCell
            
            cell.isUserInteractionEnabled = false
            shimmerView = FBShimmeringView(frame: cell.frame)
            shimmerView.contentView = cell
            shimmerView.isShimmering = true
            return cell
            
        }
        else
        {
        shimmerView.isShimmering = false
        let cell = tableView.dequeueReusableCell(withIdentifier: "WalletTableViewCell", for: indexPath) as! WalletTableViewCell
            let dataDic = (allHistoryDataArray[indexPath.row] as! NSDictionary)
            let points = COMMON_FUNCTIONS.checkForNull(string: dataDic["points"] as AnyObject).1
//            if points == "1"
//            {
//               cell.pointsLbl.text = "\(points) point " + COMMON_FUNCTIONS.checkForNull(string: dataDic["text"] as AnyObject).1
//            }
//            else
//            {
//               cell.pointsLbl.text = "\(points) points " + COMMON_FUNCTIONS.checkForNull(string: dataDic["text"] as AnyObject).1
//            }
            cell.pointsLbl.text = "\(points)"
            cell.pointsLblWidthConstraints.constant = cell.pointsLbl.optimalWidth + 10
            cell.msgLbl.text = COMMON_FUNCTIONS.checkForNull(string: dataDic["text"] as AnyObject).1
             cell.dateLbl.text = COMMON_FUNCTIONS.checkForNull(string: dataDic["date"] as AnyObject).1
            let status = COMMON_FUNCTIONS.checkForNull(string: dataDic["earn"] as AnyObject).1
            if status == "0"
            {
                cell.arrowImg.image = #imageLiteral(resourceName: "arrow_red")
            }
            else
            {
                cell.arrowImg.image = #imageLiteral(resourceName: "arrow_green")
            }
            
            if indexPath.row == tableView.numberOfRows(inSection: indexPath.section) - 1
            {
                cell.separatorLbl.isHidden = true
            }
            else
            {
                cell.separatorLbl.isHidden = false
            }
            
        cell.selectionStyle = .none
        return cell
        }
    }
    
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        if isShimmerOn {
            return nil
        }
        let headerView:UIView = UIView(frame: CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: 56))
        let backV = UIView(frame: CGRect(x: 0, y: 12, width: self.view.frame.size.width, height: 44))
        
        headerView.backgroundColor = UIColor.groupTableViewBackground
        backV.backgroundColor = UIColor.white
        let infoLabel:UILabel = UILabel(frame: CGRect(x: 16, y: 10, width: self.view.frame.size.width - 32, height: 24))
        
        infoLabel.text = "z_history".getLocalizedValue()
        //infoLabel.alpha = 0.80
        
        infoLabel.font = UIFont(name: SEMIBOLD, size: 17)
        backV.addSubview(infoLabel)
        headerView.addSubview(backV)
        return headerView
    }
    
    
    
    
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if isShimmerOn {
            return 0
        }
        return 56
    }
    
}
