//
//  AuthEmailStep.swift
//  AptoSDK
//
//  Created by Ivan Oliver Martínez on 02/26/18.
//
//

import UIKit
import Bond
import ReactiveKit

class AuthEmailStep: DataCollectorBaseStep, DataCollectorStepProtocol {
  private let userData: DataPointList
  let title = "auth.input_email.title".podLocalized()

  init(userData: DataPointList, uiConfig: UIConfig) {
    self.userData = userData
    super.init(uiConfig: uiConfig)
  }

  override func setupRows() -> [FormRowView] {
    var retVal: [FormRowView] = []
    let emailDataPoint = userData.emailDataPoint
    let emailField = FormBuilder.emailRowWith(label: nil,
                                              placeholder: "email-collector.placeholder".podLocalized(),
                                              value: emailDataPoint.email.value,
                                              failReasonMessage: "email-collector.email.warning.empty".podLocalized(),
                                              uiConfig: uiConfig)
    emailField.textField.keyboardType = .emailAddress
    emailField.textField.adjustsFontSizeToFitWidth = true
    emailField.showSplitter = false
    _ = emailField.bndValue.observeNext { text in
      emailDataPoint.email.send(text)
    }
    retVal.append(emailField)
    validatableRows.append(emailField)

    return retVal
  }
}
