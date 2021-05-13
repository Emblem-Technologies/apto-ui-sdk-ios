//
//  AptoPhysicalCardActivationResult.swift
//  AptoSDK
//
//  Created by Takeichi Kanzaki on 24/07/2019.
//

import Foundation
import AptoSDK

public class AptoPhysicalCardActivationResult: NSObject {
  public let isCardActive: Bool
  public let errorCode: Int?

  init(from result: PhysicalCardActivationResult) {
    self.isCardActive = result.type == .activated
    self.errorCode = result.errorCode
  }
}
