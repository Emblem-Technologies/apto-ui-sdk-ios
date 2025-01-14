//
//  PresenterLocator.swift
//  AptoSDK
//
//  Created by Takeichi Kanzaki on 07/06/2018.
//
//

import UIKit

final class PresenterLocator: PresenterLocatorProtocol {
  private unowned let serviceLocator: ServiceLocatorProtocol

  init(serviceLocator: ServiceLocatorProtocol) {
    self.serviceLocator = serviceLocator
  }

  func fullScreenDisclaimerPresenter() -> FullScreenDisclaimerPresenterProtocol {
    return FullScreenDisclaimerPresenter()
  }

  func countrySelectorPresenter() -> CountrySelectorPresenterProtocol {
    return CountrySelectorPresenter()
  }

  func authPresenter(authConfig: AuthModuleConfig, uiConfig: UIConfig) -> AuthPresenterProtocol {
    return AuthPresenter(config: authConfig, uiConfig: uiConfig)
  }

  func verifyPhonePresenter() -> VerifyPhonePresenterProtocol {
    return VerifyPhonePresenter()
  }

  func verifyBirthDatePresenter() -> VerifyBirthDatePresenterProtocol {
    return VerifyBirthDatePresenter()
  }

  func externalOAuthPresenter(config: ExternalOAuthModuleConfig) -> ExternalOAuthPresenterProtocol {
    return ExternalOAuthPresenter(config: config)
  }

  // MARK: - Biometrics
  func createPasscodePresenter() -> CreatePasscodePresenterProtocol {
    return CreatePasscodePresenter()
  }

  func verifyPasscodePresenter(config: VerifyPasscodePresenterConfig) -> VerifyPasscodePresenterProtocol {
    return VerifyPasscodePresenter(config: config)
  }

  func changePasscodePresenter() -> ChangePasscodePresenterProtocol {
    return ChangePasscodePresenter()
  }

  func biometricPermissionPresenter() -> BiometricPermissionPresenterProtocol {
    return BiometricPermissionPresenter()
  }

  func issueCardPresenter(router: IssueCardRouter,
                          interactor: IssueCardInteractorProtocol,
                          configuration: IssueCardActionConfiguration?) -> IssueCardPresenterProtocol {
    return IssueCardPresenter(router: router, interactor: interactor, configuration: configuration)
  }

  func waitListPresenter(config: WaitListActionConfiguration?) -> CardApplicationWaitListPresenterProtocol {
    return WaitListPresenter(config: config, notificationHandler: serviceLocator.notificationHandler)
  }

  func cardWaitListPresenter(config: WaitListActionConfiguration?) -> CardWaitListPresenterProtocol {
    return CardWaitListPresenter(config: config, notificationHandler: serviceLocator.notificationHandler)
  }

  func serverMaintenanceErrorPresenter() -> ServerMaintenanceErrorPresenterProtocol {
    return ServerMaintenanceErrorPresenter()
  }

  func accountSettingsPresenter(config: AccountSettingsPresenterConfig) -> AccountSettingsPresenterProtocol {
    return AccountSettingsPresenter(config: config)
  }

  func contentPresenterPresenter() -> ContentPresenterPresenterProtocol {
    return ContentPresenterPresenter()
  }

  func dataConfirmationPresenter() -> DataConfirmationPresenterProtocol {
    return DataConfirmationPresenter()
  }

  func webBrowserPresenter() -> WebBrowserPresenterProtocol {
    return WebBrowserPresenter()
  }

  // MARK: - Manage card
  func manageCardPresenter(config: ManageCardPresenterConfig) -> ManageCardPresenterProtocol {
    return ManageCardPresenter(config: config, notificationHandler: serviceLocator.notificationHandler)
  }

  func fundingSourceSelectorPresenter(config: FundingSourceSelectorPresenterConfig)
      -> FundingSourceSelectorPresenterProtocol {
    return FundingSourceSelectorPresenter(config: config)
  }

  func cardSettingsPresenter(card: Card, config: CardSettingsPresenterConfig, emailRecipients: [String?],
                             uiConfig: UIConfig) -> CardSettingsPresenterProtocol {
    return CardSettingsPresenter(platform: AptoPlatform.defaultManager(), card: card, config: config,
                                 emailRecipients: emailRecipients, uiConfig: uiConfig)
  }

  func kycPresenter() -> KYCPresenterProtocol {
    return KYCPresenter()
  }

  func cardMonthlyStatsPresenter() -> CardMonthlyStatsPresenterProtocol {
    return CardMonthlyStatsPresenter()
  }

  func transactionListPresenter(config: TransactionListModuleConfig) -> TransactionListPresenterProtocol {
    transactionListPresenter(config: config, transactionListEvents: nil)
  }
  
  func transactionListPresenter(config: TransactionListModuleConfig, transactionListEvents: TransactionListEvents?) -> TransactionListPresenterProtocol {
    return TransactionListPresenter(config: config, transactionListEvents: transactionListEvents)
  }

  func notificationPreferencesPresenter() -> NotificationPreferencesPresenterProtocol {
    return NotificationPreferencesPresenter()
  }

  func setCodePresenter() -> SetCodePresenterProtocol {
    return SetCodePresenter()
  }

  func voIPPresenter() -> VoIPPresenterProtocol {
    return VoIPPresenter(voIPCaller: TwilioVoIPClient())
  }

  func monthlyStatementsListPresenter() -> MonthlyStatementsListPresenterProtocol {
    return MonthlyStatementsListPresenter()
  }

  func monthlyStatementsReportPresenter() -> MonthlyStatementsReportPresenterProtocol {
    return MonthlyStatementsReportPresenter()
  }

  // MARK: - Physical card activation
  func physicalCardActivationPresenter() -> PhysicalCardActivationPresenterProtocol {
    return PhysicalCardActivationPresenter(notificationHandler: serviceLocator.notificationHandler)
  }

  func physicalCardActivationSucceedPresenter() -> PhysicalCardActivationSucceedPresenterProtocol {
    return PhysicalCardActivationSucceedPresenter()
  }

  // MARK: - Transaction Details
  func transactionDetailsPresenter() -> ShiftCardTransactionDetailsPresenterProtocol {
    return ShiftCardTransactionDetailsPresenter()
  }
}
