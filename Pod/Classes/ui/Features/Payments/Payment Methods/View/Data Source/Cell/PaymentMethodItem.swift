import Foundation
import UIKit

enum PaymentMethodType {
  case card
  case bankAccount
  case addCard
}

struct PaymentMethodItem {
 
  let id: String
  let type: PaymentMethodType
  let title: String
  let subtitle: String?
  let isSelected: Bool
  let icon: UIImage?
  let action: ((PaymentMethodItem) -> Void)?
  
  init(id: String, type: PaymentMethodType, title: String, subtitle: String?, isSelected: Bool = false, icon: UIImage?, action: ((PaymentMethodItem) -> Void)?) {
    self.id = id
    self.type = type
    self.title = title
    self.subtitle = subtitle
    self.isSelected = isSelected
    self.icon = icon
    self.action = action
  }
}
