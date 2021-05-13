//
//  BiometricPermissionInteractor.swift
//  AptoSDK
//
//  Created by Takeichi Kanzaki on 11/02/2020.
//

import UIKit

class BiometricPermissionInteractor: BiometricPermissionInteractorProtocol {
  private let platform: AptoPlatformProtocol

  init(platform: AptoPlatformProtocol) {
    self.platform = platform
  }

  func setBiometricPermissionEnabled(_ isEnabled: Bool) {
    platform.setIsBiometricEnabled(isEnabled)
  }
}
