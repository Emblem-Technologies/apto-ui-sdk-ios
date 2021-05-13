//
//  AptoMonthlySpending.swift
//  AptoSDK
//
//  Created by Takeichi Kanzaki on 24/07/2019.
//

import Foundation
import AptoSDK

@objc public class AptoMonthlySpending: NSObject {
  public let previousSpendingExists: Bool
  public let nextSpendingExists: Bool
  public let spending: [AptoCategorySpending]
  public let date: Date?

  init(from monthlySpending: MonthlySpending, date: Date) {
    self.previousSpendingExists = monthlySpending.previousSpendingExists
    self.nextSpendingExists = monthlySpending.nextSpendingExists
    self.spending = monthlySpending.spending.map{ AptoCategorySpending(from: $0) }
    self.date = monthlySpending.date ?? date
  }
}
