import Foundation
import UIKit

/// AptoPlatformDelegate is in charge of receiving different events from the SDK
@objc public protocol AptoPlatformDelegate {
  /// Called when the user authentication status changed, i.e., on sign up, sign in and logout processes.
  /// - Parameter userToken: authentication token received or `nil` if the triggering action is a logout.
  func newUserTokenReceived(_ userToken: String?)
  
  /// Called once the SDK has been completely initialised.
  /// - Parameter apiKey: project API key
  func sdkInitialized(apiKey: String)

  /**
   Called when a network request fails because the device is not connected to the Internet. The failed request will be sent again once the connection is restored.
   
   - Warning:
   When using the AptoUISDK this error will be automatically handled by the SDK.
   */
  @objc optional func networkConnectionError()
  
  /// Called when the network connection is restored. ``When using the AptoUISDK this error will be automatically handled by the SDK.``
  @objc optional func networkConnectionRestored()
  
  /**
   Called when a network request fails because our server is not available. Once the connection with the server is you should call

   ```
   AptoPlatform.defaultManager().runPendingNetworkRequests()
   ```
   
   - Warning:
   When using the AptoUISDK this error will be automatically handled by the SDK.
   */
  @objc optional func serverMaintenanceError()
 
  /// This method is called when a network request fails because the current SDK version has been deprecated. To know the version of the SDK use `ShiftSDK.version`.
  @objc func sdkDeprecated()
}

public protocol AptoPlatformProtocol {
  var delegate: AptoPlatformDelegate? { get set }
    var currentPCIAuthenticationType: PCIAuthType { get }

  func initializeWithApiKey(_ apiKey: String, environment: AptoPlatformEnvironment, setupCertPinning: Bool)
  func initializeWithApiKey(_ apiKey: String, environment: AptoPlatformEnvironment)
  func initializeWithApiKey(_ apiKey: String)
  
  // Configuration handling
  func setCardOptions(_ cardOptions: CardOptions?)
  func fetchContextConfiguration(_ forceRefresh: Bool,
                                 callback: @escaping Result<ContextConfiguration, NSError>.Callback)
  func fetchUIConfig() -> UIConfig?
  func fetchCardProducts(callback: @escaping Result<[CardProductSummary], NSError>.Callback)
  func fetchCardProduct(cardProductId: String, forceRefresh: Bool,
                        callback: @escaping Result<CardProduct, NSError>.Callback)
  func isFeatureEnabled(_ featureKey: FeatureKey) -> Bool
    func isAuthTypePinOrBiometricsEnabled() -> Bool
  func isShowDetailedCardActivityEnabled() -> Bool
  func setShowDetailedCardActivityEnabled(_ isEnabled: Bool)
  func isBiometricEnabled() -> Bool
  func setIsBiometricEnabled(_ isEnabled: Bool)
  
  // User tokens handling
  func currentToken() -> AccessToken?
  func setUserToken(_ userToken: String)
  func clearUserToken()
  func currentPushToken() -> String?
  
  // User handling
  func createUser(userData: DataPointList, custodianUid: String?,
                  metadata: String?,
                  callback: @escaping Result<ShiftUser, NSError>.Callback)
  func loginUserWith(verifications: [Verification], callback: @escaping Result<ShiftUser, NSError>.Callback)
  func fetchCurrentUserInfo(forceRefresh: Bool, filterInvalidTokenResult: Bool,
                            callback: @escaping Result<ShiftUser, NSError>.Callback)
  func updateUserInfo(_ userData: DataPointList, callback: @escaping Result<ShiftUser, NSError>.Callback)
  func logout()
  
  // Oauth handling
  func startOauthAuthentication(balanceType: AllowedBalanceType,
                                callback: @escaping Result<OauthAttempt, NSError>.Callback)
  func verifyOauthAttemptStatus(_ attempt: OauthAttempt,
                                callback: @escaping Result<OauthAttempt, NSError>.Callback)
  func saveOauthUserData(_ userData: DataPointList, custodian: Custodian,
                         callback: @escaping Result<OAuthSaveUserDataResult, NSError>.Callback)
  func fetchOAuthData(_ custodian: Custodian, callback: @escaping Result<OAuthUserData, NSError>.Callback)
  
  // Verifications
  func startPrimaryVerification(callback: @escaping Result<Verification, NSError>.Callback)
  func startPhoneVerification(_ phone: PhoneNumber, callback: @escaping Result<Verification, NSError>.Callback)
  func startEmailVerification(_ email: Email, callback: @escaping Result<Verification, NSError>.Callback)
  func startBirthDateVerification(_ birthDate: BirthDate, callback: @escaping Result<Verification, NSError>.Callback)
  func startDocumentVerification(documentImages: [UIImage], selfie: UIImage?, livenessData: [String: AnyObject]?,
                                 associatedTo workflowObject: WorkflowObject?,
                                 callback: @escaping Result<Verification, NSError>.Callback)
  func fetchDocumentVerificationStatus(_ verification: Verification,
                                       callback: @escaping Result<Verification, NSError>.Callback)
  func fetchVerificationStatus(_ verification: Verification, callback: @escaping Result<Verification, NSError>.Callback)
  func restartVerification(_ verification: Verification, callback: @escaping Result<Verification, NSError>.Callback)
  func completeVerification(_ verification: Verification, callback: @escaping Result<Verification, NSError>.Callback)
  
  // Card application handling
  func nextCardApplications(page: Int, rows: Int, callback: @escaping Result<[CardApplication], NSError>.Callback)
  func applyToCard(cardProduct: CardProduct, callback: @escaping Result<CardApplication, NSError>.Callback)
  func fetchCardApplicationStatus(_ applicationId: String,
                                  callback: @escaping Result<CardApplication, NSError>.Callback)
  func setBalanceStore(applicationId: String, custodian: Custodian,
                       callback: @escaping Result<SelectBalanceStoreResult, NSError>.Callback)
  func acceptDisclaimer(workflowObject: WorkflowObject, workflowAction: WorkflowAction,
                        callback: @escaping Result<Void, NSError>.Callback)
  func cancelCardApplication(_ applicationId: String, callback: @escaping Result<Void, NSError>.Callback)
    func issueCard(applicationId: String,
                   additionalFields: [String: AnyObject]?,
                   metadata: String?,
                   design: IssueCardDesign?,
                   callback: @escaping Result<Card, NSError>.Callback)
  func issueCard(cardProduct: CardProduct, custodian: Custodian?, additionalFields: [String: AnyObject]?,
                 initialFundingSourceId: String?, callback: @escaping Result<Card, NSError>.Callback)
  
  // Card handling
  func fetchCards(page: Int, rows: Int, callback: @escaping Result<[Card], NSError>.Callback)
  func fetchCard(_ cardId: String, forceRefresh: Bool, retrieveBalances: Bool,
                 callback: @escaping Result<Card, NSError>.Callback)
  /// Deprecated, please use Apto PCI-SDK instead
  func fetchCardDetails(_ cardId: String, callback: @escaping Result<CardDetails, NSError>.Callback)
  func activatePhysicalCard(_ cardId: String, code: String,
                            callback: @escaping Result<PhysicalCardActivationResult, NSError>.Callback)
  func activateCard(_ cardId: String, callback: @escaping Result<Card, NSError>.Callback)
  func unlockCard(_ cardId: String, callback: @escaping Result<Card, NSError>.Callback)
  func lockCard(_ cardId: String, callback: @escaping Result<Card, NSError>.Callback)
  func changeCardPIN(_ cardId: String, pin: String, callback: @escaping Result<Card, NSError>.Callback)
  func setCardPassCode(_ cardId: String, passCode: String, verificationId: String?,
                       callback: @escaping Result<Void, NSError>.Callback)
  func fetchCardTransactions(_ cardId: String, filters: TransactionListFilters, forceRefresh: Bool,
                             callback: @escaping Result<[Transaction], NSError>.Callback)
  @available(*, deprecated, renamed: "fetchMonthlySpending(cardId:month:year:callback:)")
  func cardMonthlySpending(_ cardId: String, date: Date, callback: @escaping Result<MonthlySpending, NSError>.Callback)
  func fetchMonthlySpending(cardId: String, month: Int, year: Int,
                            callback: @escaping Result<MonthlySpending, NSError>.Callback)
  func fetchMonthlyStatementsPeriod(callback: @escaping Result<MonthlyStatementsPeriod, NSError>.Callback)
  func fetchMonthlyStatementReport(month: Int, year: Int,
                                   callback: @escaping Result<MonthlyStatementReport, NSError>.Callback)
  
  // Card funding sources handling
  func fetchCardFundingSources(_ cardId: String, page: Int?, rows: Int?, forceRefresh: Bool,
                               callback: @escaping Result<[FundingSource], NSError>.Callback)
  func fetchCardFundingSource(_ cardId: String, forceRefresh: Bool,
                              callback: @escaping Result<FundingSource?, NSError>.Callback)
  func setCardFundingSource(_ fundingSourceId: String, cardId: String,
                            callback: @escaping Result<FundingSource, NSError>.Callback)
  func addCardFundingSource(cardId: String, custodian: Custodian,
                            callback: @escaping Result<FundingSource, NSError>.Callback)
  
    func orderPhysicalCard(_ cardId: String, callback: @escaping (Result<Card, NSError>) -> Void)
    func getOrderPhysicalCardConfig(_ cardId: String, callback: @escaping (Result<PhysicalCardConfig, NSError>) -> Void)
    
  // Notification preferences handling
  func fetchNotificationPreferences(callback: @escaping Result<NotificationPreferences, NSError>.Callback)
  func updateNotificationPreferences(_ preferences: NotificationPreferences,
                                     callback: @escaping Result<NotificationPreferences, NSError>.Callback)
  
  // VoIP
  func fetchVoIPToken(cardId: String, actionSource: VoIPActionSource,
                      callback: @escaping Result<VoIPToken, NSError>.Callback)
  
    // Bank account handling
    func reviewAgreement(_ request: AgreementRequest, callback: @escaping (RecordedAgreementsResult) -> Void)
    
    // Assign a ACH account
    func assignAchAccount(balanceId: String, callback: @escaping (ACHAccountResult) -> Void)
    
  // MARK: - Payment Sources
  
  /// Adds a payment source for Loading funds into the account
  /// - Parameters:
  ///   - request: PaymentSourceRequest to be added to the list
  ///   - callback: callback containing the added PaymentSource or an Error
  func addPaymentSource(with request: PaymentSourceRequest, callback: @escaping Result<PaymentSource, NSError>.Callback)
   
  /// Retrieve a list of added payment sources
  /// - Parameter callback: callback containing the added [PaymentSource] or an Error
  func getPaymentSources(_ request: PaginationQuery?, callback: @escaping Result<[PaymentSource], NSError>.Callback)
  func deletePaymentSource(paymentSourceId: String, callback: @escaping Result<Void, NSError>.Callback)
  func pushFunds(with request: PushFundsRequest, callback: @escaping Result<PaymentResult, NSError>.Callback)

  // Miscelaneous
  func runPendingNetworkRequests()

  // MARK: Deprecated

  /// Deprecated, please use fetchCard instead
  func fetchFinancialAccount(_ accountId: String, forceRefresh: Bool, retrieveBalances: Bool,
                             callback: @escaping Result<FinancialAccount, NSError>.Callback)
}

public extension AptoPlatformProtocol {
  func fetchContextConfiguration(_ forceRefresh: Bool = false,
                                 callback: @escaping Result<ContextConfiguration, NSError>.Callback) {
    fetchContextConfiguration(forceRefresh, callback: callback)
  }
  
  func fetchCardProduct(cardProductId: String, forceRefresh: Bool = false,
                        callback: @escaping Result<CardProduct, NSError>.Callback) {
    fetchCardProduct(cardProductId: cardProductId, forceRefresh: forceRefresh, callback: callback)
  }
  
  func createUser(userData: DataPointList, custodianUid: String? = nil, metadata: String? = nil,
                  callback: @escaping Result<ShiftUser, NSError>.Callback) {
    createUser(userData: userData, custodianUid: custodianUid, metadata: metadata, callback: callback)
  }
  
  func fetchCurrentUserInfo(forceRefresh: Bool = false, filterInvalidTokenResult: Bool = false,
                            callback: @escaping Result<ShiftUser, NSError>.Callback) {
    fetchCurrentUserInfo(forceRefresh: forceRefresh, filterInvalidTokenResult: filterInvalidTokenResult,
                         callback: callback)
  }
  
  func issueCard(cardProduct: CardProduct, custodian: Custodian?, additionalFields: [String: AnyObject]? = nil,
                 initialFundingSourceId: String? = nil, callback: @escaping Result<Card, NSError>.Callback) {
    issueCard(cardProduct: cardProduct, custodian: custodian, additionalFields: additionalFields,
              initialFundingSourceId: initialFundingSourceId, callback: callback)
  }
  
  func fetchCard(_ cardId: String, forceRefresh: Bool = true, retrieveBalances: Bool = false,
                 callback: @escaping Result<Card, NSError>.Callback) {
    fetchCard(cardId, forceRefresh: forceRefresh, retrieveBalances: retrieveBalances, callback: callback)
  }
}
