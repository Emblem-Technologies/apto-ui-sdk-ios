//
//  ExternalOAuthModuleConfig.swift
//  AptoSDK
//
//  Created by Ivan Oliver Martínez on 23/06/2018.
//

import UIKit

struct ExternalOAuthModuleConfig {
  let title: String
  let explanation: String
  let callToAction: String
  let newUserAction: String
  let allowedBalanceTypes: [AllowedBalanceType]
  let assetUrl: URL?
  let oauthErrorMessageKeys: [String]?
}
