//
//  ChangePasscodeContract.swift
//  AptoSDK
//
//  Created by Takeichi Kanzaki on 28/11/2019.
//

import UIKit
import Bond

protocol ChangePasscodeModuleProtocol: UIModuleProtocol {
  func showForgotPasscode()
}

protocol ChangePasscodeInteractorProtocol: VerifyPasscodeInteractorProtocol, CreatePasscodeInteractorProtocol {
}

enum ChangePasscodeViewStep {
  case verifyPasscode
  case setPasscode
  case confirmPasscode
}

class ChangePasscodeViewModel {
  let step: Observable<ChangePasscodeViewStep> = Observable(.verifyPasscode)
  let error: Observable<NSError?> = Observable(nil)
}

protocol ChangePasscodePresenterProtocol: class {
  var router: ChangePasscodeModuleProtocol? { get set }
  var interactor: ChangePasscodeInteractorProtocol? { get set }
  var viewModel: ChangePasscodeViewModel { get }
  var analyticsManager: AnalyticsServiceProtocol? { get set }

  func viewLoaded()
  func closeTapped()
  func passcodeEntered(_ passcode: String)
  func forgotPasscodeTapped()
}

class PasscodeDoNotMatchError: NSError {
  init() {
    let errorMessage = "biometric.create_pin.error.pin_not_match".podLocalized()
    let userInfo: [String: Any] = [NSLocalizedDescriptionKey: errorMessage]
    super.init(domain: "com.aptopayments.sdk.error.passcode_not_match", code: 1007, userInfo: userInfo)
  }

  required public init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}
