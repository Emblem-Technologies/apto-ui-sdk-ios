//
//  ContentPresenterModule.swift
//  AptoSDK
//
//  Created by Takeichi Kanzaki on 17/09/2018.
//
//

import UIKit

class ContentPresenterModule: UIModule, ContentPresenterModuleProtocol {
  private let content: Content
  private let title: String
  private var presenter: ContentPresenterPresenterProtocol?

  init(serviceLocator: ServiceLocatorProtocol, content: Content, title: String) {
    self.content = content
    self.title = title
    super.init(serviceLocator: serviceLocator)
  }

  override func initialize(completion: @escaping Result<UIViewController, NSError>.Callback) {
    let viewController = buildViewController(uiConfig)
    addChild(viewController: viewController, completion: completion)
  }

  private func buildViewController(_ uiConfig: UIConfig) -> UIViewController {
    let presenter = serviceLocator.presenterLocator.contentPresenterPresenter()
    let interactor = serviceLocator.interactorLocator.contentPresenterInteractor(content: content)
    let viewController = serviceLocator.viewLocator.contentPresenterView(uiConfig: uiConfig, presenter: presenter)
    viewController.title = title
    presenter.interactor = interactor
    presenter.router = self
    self.presenter = presenter

    return viewController
  }

  func show(url: URL) {
    showExternal(url: url)
  }
}
