//
// SetPinPresenter.swift
// AptoSDK
//
// Created by Takeichi Kanzaki on 16/06/2019.
//

import Foundation
import UIKit
import Bond

class SetCodePresenter: SetCodePresenterProtocol {
  let viewModel = SetCodeViewModel()
  var router: SetCodeModuleProtocol?
  var interactor: SetCodeInteractorProtocol?
  var analyticsManager: AnalyticsServiceProtocol?

  func viewLoaded() {
    analyticsManager?.track(event: .setPin)
  }

  func codeEntered(_ pin: String) {
    analyticsManager?.track(event: .setPinConfirmed)
    viewModel.showLoading.send(true)
    interactor?.changeCode(pin) { [weak self] result in
      self?.viewModel.showLoading.send(false)
      switch result {
      case .failure(let error):
        self?.viewModel.error.send(error)
      case .success:
        self?.router?.codeChanged()
      }
    }
  }

  func closeTapped() {
    router?.close()
  }
}
