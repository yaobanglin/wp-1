//
//  HistoryDealVC.swift
//  wp
//
//  Created by 木柳 on 2017/1/4.
//  Copyright © 2017年 com.yundian. All rights reserved.
//

import UIKit
import RealmSwift
class HistoryDealCell: OEZTableViewCell{
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var winLabel: UILabel!
    @IBOutlet weak var failLabel: UILabel!
    // 盈亏
    @IBOutlet weak var statuslb: UILabel!
    override func update(_ data: Any!) {
        if let model: PositionModel = data as! PositionModel? {
            nameLabel.text = "\(model.name)"
            timeLabel.text = Date.yt_convertDateToStr(Date.init(timeIntervalSince1970: TimeInterval(model.positionTime)), format: "yyyy.MM.dd HH:mm:ss")
           //com.yundian.trip
            priceLabel.text = "¥" + String(format: "%.2f", model.openPrice)
      
            statuslb.backgroundColor = model.result   ? UIColor.init(hexString: "E9573F") : UIColor.init(hexString: "0EAF56")
            
            statuslb.text =  model.result   ?  "盈" :   "亏"
            
            print("\(model.result)")
//                model.result ? "盈" :  "亏"
            
//            let string : NSString =  "\(model.grossProfit)" as NSString
//            
//            let rangge : NSRange = string.range(of: "-")
            
//            print("\(model.grossProfit)")
//            if  model.grossProfit < 0{
//                statuslb.backgroundColor = UIColor.init(hexString: "0EAF56")
//                statuslb.text =  "亏"
//            }else{
//                statuslb.backgroundColor =  UIColor.init(hexString: "E9573F")
//                statuslb.text =  "盈"
//
//            }
            statuslb.layer.cornerRadius = 3
            
            statuslb.clipsToBounds = true
//            print(model.buySell)
            
            
//            winLabel.text = model.limit > 0 ? "止盈\(model.limit*10)%" : "止盈无"
//            failLabel.text = model.stop > 0 ? "止损\(model.stop*10)%" : "止损无"
        }
    }
}

class HistoryDealVC: BasePageListTableViewController {

    //MARK: --LIFECYCLE
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    override func didRequest(_ pageIndex: Int) {

        AppAPIHelper.deal().historyDeals(start: pageIndex, count: 10, complete: { [weak self](result) -> ()? in
            if let models: [PositionModel] = result as! [PositionModel]?{
                DealModel.cachePositionWithArray(positionArray: models)
                if pageIndex == 1 {
                    var newModels: [PositionModel] = []
                    let historyModels = DealModel.getHistoryPositionModel()
                    if historyModels.count == 0{
                        newModels = models
                    }else{
                        for historyModel in historyModels{
                            newModels.append(historyModel)
                        }
                        for model in models{
                            if model.positionTime > historyModels.first!.positionTime{
                                newModels.append(model)
                            }
                        }
                    }
                    self?.didRequestComplete(newModels as AnyObject?)
                }else{
                    var moreModels: [PositionModel] = []
                    let historyModels = DealModel.getHistoryPositionModel()
                    if historyModels.count == 0{
                        moreModels = models
                    }else{
                        for model in models{
                            if model.positionTime < historyModels.last!.positionTime{
                                moreModels.append(model)
                            }
                        }
                    }
                    self?.didRequestComplete(moreModels as AnyObject?)                }
            }
            return nil
        }, error: errorBlockFunc())
            
    }


   

}
