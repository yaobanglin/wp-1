//
//  WithdrawModel.swift
//  wp
//
//  Created by macbook air on 17/1/4.
//  Copyright © 2017年 com.yundian. All rights reserved.
//

import UIKit
// 提现moedel
class WithdrawModel: BaseModel {
    
    // 提现订单流水号  
      var wid: Int64 = 0
    // 用户id	  
      var id: Int64 = 0
    // 提现金额   
      var amount: Double = 0
    // 提现手续费		  
      var charge: Int64 = 0
    // 提现时间	  
     var withdrawTime: Int64 = 0
    //提现时间	  
      var handleTime: Int64 = 0
    // 银行名称	  
      var bank: String?
    //支行名称
      var branchBank: String?
    // 	省	  
      var province: String?
    // 	城市	  
      var city: String?
    // 	银行卡号	  
      var cardNo: String?
    // 姓名	  
      var name: String?
    //	备注	  
      var comment: String?
    // 状态	1-处理中，2-成功，3-失败
      var status: Int8 = 0

}
// 提现列表的listmodel
class WithdrawListModel: BaseModel {
    
    var listItem : [WithdrawModel]?
    
}
// 银行卡提现moedel
class WithdrawBankCashModel: BaseModel {
    
    // 提现订单流水号
      var wid: Int64 = 0
    // 用户id
      var id: Int64 = 0
    // 提现金额
      var amount: Double = 0
    // 提现手续费
      var charge: Int64 = 0
    // 提现时间
      var withdrawTime: Int64 = 0
    //提现时间
      var handleTime: Int64 = 0
    // 银行名称
      var bank: String?
    //支行名称
      var branchBank: String?
    // 	省
      var province: String?
    // 	城市
      var city: String?
    // 	银行卡号
      var cardNo: String?
    // 姓名
      var name: String?
    //	备注
      var comment: String?
    // 状态	1-处理中，2-成功，3-失败
      var status: Int8 = 0
    
}

