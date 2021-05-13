//
//  AptoMCCIcon.swift
//  AptoSDK
//
//  Created by Takeichi Kanzaki on 24/07/2019.
//

import Foundation
import AptoSDK

@objc public enum AptoMCCIcon: Int {
  case plane
  case car
  case glass
  case finance
  case food
  case gas
  case bed
  case medical
  case camera
  case card
  case cart
  case road
  case other

  init(from icon: MCCIcon) {
    switch icon {
    case .plane: self = .plane
    case .car: self = .car
    case .glass: self = .glass
    case .finance: self = .finance
    case .food: self = .food
    case .gas: self = .gas
    case .bed: self = .bed
    case .medical: self = .medical
    case .camera: self = .camera
    case .card: self = .card
    case .cart: self = .cart
    case .road: self = .road
    case .other: self = .other
    }
  }
}
