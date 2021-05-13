//
//  AptoCardProduct.swift
//  AptoSDK
//
//  Created by Takeichi Kanzaki on 21/08/2019.
//

import Foundation
import AptoSDK

@objc public class AptoCardProduct: NSObject {
  public let cardProductId: String
  public let teamId: String
  public let name: String

  @objc public init(cardProductId: String, teamId: String, name: String) {
    self.cardProductId = cardProductId
    self.teamId = teamId
    self.name = name
    super.init()
  }

  var swiftVersion: CardProduct { return CardProduct(id: cardProductId, teamId: teamId, name: name) }
}
