//
//  AddMoneyViewModel.swift
//  AptoSDK
//
//  Created by Fabio Cuomo on 8/2/21.
//

import Foundation
import UIKit

final class AddMoneyViewModel {
    private let loader: AptoPlatformProtocol
    private let analyticsManager: AnalyticsServiceProtocol
    private let cardId: String
    typealias Observer<T> = (T) -> Void

    var onCardLoadingStateChange: Observer<Bool>?
    var onErrorCardLoading: Observer<NSError>?

    init(cardId: String, loader: AptoPlatformProtocol, analyticsManager: AnalyticsServiceProtocol) {
        self.loader = loader
        self.cardId = cardId
        self.analyticsManager = analyticsManager
    }
    
    public func load() {
        onCardLoadingStateChange?(true)
        loader
            .fetchCard(cardId,
                       forceRefresh: false,
                       retrieveBalances: false,
                       callback: { [weak self] result in
                        if let error = result.error {
                            self?.onErrorCardLoading?(error)
                        }
                        self?.onCardLoadingStateChange?(false)
                       })
    }
    
    public func trackEvent() {
        analyticsManager.track(event: .addFundsSelectorStart)
    }    
}
