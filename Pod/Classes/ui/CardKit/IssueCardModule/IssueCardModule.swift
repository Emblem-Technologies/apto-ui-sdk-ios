//
//  IssueCardModule.swift
//  AptoSDK
//
//  Created by Takeichi Kanzaki on 25/06/2018.
//
//

import UIKit

class IssueCardModule: UIModule, IssueCardModuleProtocol {
    private let application: CardApplication
    private let initializationData: InitializationData?
    
    init(serviceLocator: ServiceLocatorProtocol, application: CardApplication, initializationData: InitializationData?) {
        self.application = application
        self.initializationData = initializationData
        super.init(serviceLocator: serviceLocator)
    }
    
    override func initialize(completion: @escaping Result<UIViewController, NSError>.Callback) {
        let viewController = buildIssueCardViewController(uiConfig: uiConfig)
        completion(.success(viewController))
    }
    
    private func buildIssueCardViewController(uiConfig: UIConfig) -> UIViewController {
        let interactor = serviceLocator.interactorLocator.issueCardInteractor(application: application, initializationData: initializationData)
        let configuration = (application.nextAction.configuration as? IssueCardActionConfiguration) ?? nil
        let presenter = serviceLocator.presenterLocator.issueCardPresenter(router: self, interactor: interactor,
                                                                           configuration: configuration)
        presenter.analyticsManager = serviceLocator.analyticsManager
        return serviceLocator.viewLocator.issueCardView(uiConfig: uiConfig, eventHandler: presenter)
    }
    
    func cardIssued(_ card: Card) {
        finish(result: card)
    }
    
    func closeTapped() {
        close()
    }
    
    func show(url: TappedURL) {
        showExternal(url: url.url, alternativeTitle: url.title)
    }
}
