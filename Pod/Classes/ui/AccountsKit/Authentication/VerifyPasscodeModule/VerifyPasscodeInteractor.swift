//
//  VerifyPasscodeInteractor.swift
//  AptoSDK
//
//  Created by Takeichi Kanzaki on 26/11/2019.
//

import UIKit

class VerifyPasscodeInteractor: VerifyPasscodeInteractorProtocol {
  private let authenticationManager: AuthenticationManagerProtocol

  init(authenticationManager: AuthenticationManagerProtocol) {
    self.authenticationManager = authenticationManager
  }

  func verify(code: String, callback: @escaping Result<Bool, Never>.Callback) {
    let isValid = authenticationManager.isValid(code: code)
    callback(.success(isValid))
  }
}
