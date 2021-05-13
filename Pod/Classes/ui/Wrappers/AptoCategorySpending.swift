//
//  AptoCategorySpending.swift
//  AptoSDK
//
//  Created by Takeichi Kanzaki on 24/07/2019.
//

import Foundation
import AptoSDK

@objc public class AptoCategorySpending: NSObject {
  public let categoryId: AptoMCCIcon
  public let spending: Amount
  public let difference: Double?

  init(from categorySpending: CategorySpending) {
    self.categoryId = AptoMCCIcon(from: categorySpending.categoryId)
    self.spending = categorySpending.spending
    self.difference = categorySpending.difference
  }
}
