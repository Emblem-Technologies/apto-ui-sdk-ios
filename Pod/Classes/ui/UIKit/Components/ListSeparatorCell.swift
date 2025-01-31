//
//  ListSeparatorCell.swift
//  AptoSDK
//
//  Created by Ivan Oliver Martínez on 16/02/16.
//
//

import Foundation
import UIKit

class ListSeparatorCell: UITableViewCell {
  override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
    super.init(style: style, reuseIdentifier: reuseIdentifier)
    self.selectionStyle = .none
  }

  required init?(coder aDecoder: NSCoder) {
      fatalError("init(coder:) has not been implemented")
  }
}
