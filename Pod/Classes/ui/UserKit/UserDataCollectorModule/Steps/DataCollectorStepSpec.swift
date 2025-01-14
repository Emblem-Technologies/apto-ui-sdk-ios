//
//  DataCollectorStepSpec.swift
//  AptoSDK
//
//  Created by Ivan Oliver Martínez on 02/02/16.
//
//

import Foundation
import UIKit
import Bond
import ReactiveKit
import TTTAttributedLabel

protocol DataCollectorStepProtocol {
  var title: String { get }
  var rows: [FormRowView] { get }
  var validatableRows: [FormRowView] { get set }
  var valid: Observable<Bool> { get }
}

open class DataCollectorBaseStep {
  private let disposeBag = DisposeBag()
  var uiConfig: UIConfig
  var rows: [FormRowView] = []
  var validatableRows: [FormRowView] = []

  // Observable flag indicating that this row has passed validation
  public let valid = Observable(false)

  init(uiConfig: UIConfig) {
    self.uiConfig = uiConfig
    self.rows = self.setupRows()
    self.setupStepValidation()
  }

  func setupRows() -> [FormRowView] {
    return []
  }

  func setupStepValidation() {
    // The default implementation combines all the form rows valid flag added to this step
    // The bond library doesn't support a more generic approach to combine the values, so an
    // ugly (but functional) method is used here:
    if validatableRows.isEmpty {
      self.valid.send(true)
    }
    else {
      let signals = validatableRows.map {
        return $0.valid.toSignal()
      }
      Signal(combiningLatest: signals) { (arrayOfBool: [Bool]) in
        arrayOfBool.allSatisfy { $0 == true }
      }.bind(to: self.valid).dispose(in: disposeBag)
    }
  }
}
