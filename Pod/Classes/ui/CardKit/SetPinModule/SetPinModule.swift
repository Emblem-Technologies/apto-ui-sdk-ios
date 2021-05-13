//
// SetPinModule.swift
// AptoSDK
//
// Created by Takeichi Kanzaki on 17/06/2019.
//

import Foundation
import UIKit

class SetPinModule: UIModule, SetCodeModuleProtocol {
  private let card: Card
  private var presenter: SetCodePresenterProtocol?

  init(serviceLocator: ServiceLocatorProtocol, card: Card) {
    self.card = card
    super.init(serviceLocator: serviceLocator)
  }

  override func initialize(completion: @escaping Result<UIViewController, NSError>.Callback) {
    completion(.success(buildViewController()))
  }

  private func buildViewController() -> UIViewController {
    let presenter = serviceLocator.presenterLocator.setCodePresenter()
    let interactor = serviceLocator.interactorLocator.setPinInteractor(card: card)
    let analyticsManager = serviceLocator.analyticsManager
    presenter.router = self
    presenter.interactor = interactor
    presenter.analyticsManager = analyticsManager
    self.presenter = presenter
    let texts = SetCodeViewControllerTexts(
      setCode: SetCodeViewControllerTexts.SetCode(
        title: "manage_card.set_pin.title".podLocalized(),
        explanation: "manage_card.set_pin.explanation".podLocalized(),
        wrongCodeTitle: "manage_card.confirm_pin.error_wrong_code.title".podLocalized(),
        wrongCodeMessage: "manage_card.confirm_pin.error_wrong_code.message".podLocalized()
      ),
      confirmCode: SetCodeViewControllerTexts.ConfirmCode(
        title: "manage_card.confirm_pin.title".podLocalized(),
        explanation: "manage_card.confirm_pin.explanation".podLocalized()
      )
    )
    return serviceLocator.viewLocator.setCodeView(presenter: presenter, texts: texts)
  }

  func codeChanged() {
    finish()
  }
}
