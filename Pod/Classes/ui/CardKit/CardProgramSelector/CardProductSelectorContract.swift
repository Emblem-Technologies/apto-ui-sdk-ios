//
//  CardProductSelectorContract.swift
//  AptoSDK
//
//  Created by Takeichi Kanzaki on 15/05/2019.
//

import Foundation
import UIKit

protocol CardProductSelectorModuleProtocol: UIModuleProtocol {
  var onCardProductSelected: ((_ cardProduct: CardProductSummary) -> Void)? { get set }
}
