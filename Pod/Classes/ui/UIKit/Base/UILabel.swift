//
//  UILabel.swift
//  AptoSDK
//
//  Created by Ivan Oliver Martínez on 08/06/16.
//
//

import Foundation
import UIKit

extension UILabel {
  func updateAttributedText(_ text: String?) {
    guard let text = text else {
      self.text = ""
      return
    }
    guard let attributedText = self.attributedText else {
      self.text = text
      return
    }
    let mutableAttributedString = NSMutableAttributedString(attributedString: attributedText)
    mutableAttributedString.mutableString.setString(text)
    self.attributedText = mutableAttributedString
  }
}
