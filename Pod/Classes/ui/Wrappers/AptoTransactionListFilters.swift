//
//  AptoTransactionListFilters.swift
//  AptoSDK
//
//  Created by Takeichi Kanzaki on 24/07/2019.
//

import Foundation
import AptoSDK

@objc public class AptoTransactionListFilters: NSObject {
  let page: Int?
  let rows: Int?
  let lastTransactionId: String?
  let startDate: Date?
  let endDate: Date?
  let mccCode: String?
  let states: [TransactionState]?

  public init(page: Int? = nil, rows: Int? = nil, lastTransactionId: String? = nil, startDate: Date? = nil,
              endDate: Date? = nil, mccCode: String? = nil, states: [TransactionState]? = nil) {
    self.page = page
    self.rows = rows
    self.lastTransactionId = lastTransactionId
    self.startDate = startDate
    self.endDate = endDate
    self.mccCode = mccCode
    self.states = states
  }

  var swiftVersion: TransactionListFilters {
    return TransactionListFilters(page: page, rows: rows, lastTransactionId: lastTransactionId, startDate: startDate,
                                  endDate: endDate, mccCode: mccCode, states: states)
  }
}
