import Foundation
import UIKit

/// By default, AptoPlatform are provisioned with different environments. An environment provides a runtime execution context for our API, depending on the development process you may use any of the different stages below
@objc public enum AptoPlatformEnvironment: Int {
  /// Local environment
  case local
  /// Staging environment
  case staging
  /// Sandbox environment
  case sandbox
  /// Production environment (Required for release)
  case production
  public var description: String {
    switch self {
    case .local: return "local"
    case .staging: return "staging"
    case .sandbox: return "local"
    case .production: return "production"
    }
  }
}

/// AptoPlatform is the main entry point into our SDK
@objc public class AptoPlatform: NSObject, AptoPlatformProtocol {
  // swiftlint:disable:this type_body_length

  // MARK: Authentication attributes

  // swiftlint:disable implicitly_unwrapped_optional
  /// Developer api key that you can get from our [developer portal](https://www.aptopayments.com/developers)
  public private(set) var apiKey: String!
  /// Desired environment to use during development
  public private(set) var environment: AptoPlatformEnvironment!
  /// Check if the SDK has been initialised, by default this value is `false`
  public private(set) var initialized = false
  // swiftlint:enable implicitly_unwrapped_optional
  private var internalCurrentUser: ShiftUser?

  // MARK: Delegate

  public weak var delegate: AptoPlatformDelegate?

  // MARK: Transport

  private var transportEnvironment: JSONTransportEnvironment! // swiftlint:disable:this implicitly_unwrapped_optional

  // MARK: Storage

    public var currentPCIAuthenticationType: PCIAuthType {
        featuresStorage.currentPCIAuthType
    }
    
  // swiftlint:disable implicitly_unwrapped_optional
  private var userStorage: UserStorageProtocol!
  private var configurationStorage: ConfigurationStorageProtocol!
  private var cardApplicationsStorage: CardApplicationsStorageProtocol!
  private var financialAccountsStorage: FinancialAccountsStorageProtocol!
  private var pushTokenStorage: PushTokenStorageProtocol!
  private var oauthStorage: OauthStorageProtocol!
  private var notificationPreferencesStorage: NotificationPreferencesStorageProtocol!
  private var voIPStorage: VoIPStorageProtocol!
  private var paymentSourcesStorage: PaymentSourcesStorageProtocol!
    private var agreementStorage: AgreementStorageProtocol?
    private var achAccountStorage: ACHAccountStorageProtocol?
  // swiftlint:enable implicitly_unwrapped_optional
  private lazy var featuresStorage = serviceLocator.storageLocator.featuresStorage()
  private lazy var userPreferencesStorage = serviceLocator.storageLocator.userPreferencesStorage()
  private lazy var userTokenStorage = serviceLocator.storageLocator.userTokenStorage()
  private let pushNotificationsManager = PushNotificationsManager()
  private lazy var serviceLocator: ServiceLocatorProtocol = ServiceLocator.shared
  
  init(serviceLocator: ServiceLocatorProtocol = ServiceLocator.shared) {
    super.init()
    self.serviceLocator = serviceLocator
  }

  deinit {
    self.removeNotificationObservers()
  }

  // MARK: Setup Manager

  private static var sharedManager = AptoPlatform()
  
  /// Default `AptoPlatform`
  /// - Returns: Single instance of `AptoPlatform` class
  @objc public static func defaultManager() -> AptoPlatform {
    return sharedManager
  }

  /// Initialise the SDK in order to authenticate with our system and start making API calls
  /// - Parameters:
  ///   - apiKey: Developer api key that you can get from our [developer portal](https://www.aptopayments.com/#/developers)
  ///   - environment: Desired environment to use during development
  ///   - setupCertPinning: Configure SSL Pinning to avoid network MITM attacks
  @objc public func initializeWithApiKey(_ apiKey: String,
                                         environment: AptoPlatformEnvironment,
                                         setupCertPinning: Bool) {
    let certPinningConfig: [String: [String: AnyObject]]? = nil
    self.apiKey = apiKey
    self.environment = environment
    var allowSelfSignedCertificate = false
    switch environment {
    case .local:
      self.transportEnvironment = .local
      allowSelfSignedCertificate = true
    case .staging:
      self.transportEnvironment = .staging
    case .sandbox:
      self.transportEnvironment = .sandbox
    case .production:
      self.transportEnvironment = .live
    }
    let transport = serviceLocator.networkLocator.jsonTransport(environment: transportEnvironment,
                                                                baseUrlProvider: transportEnvironment,
                                                                certPinningConfig: certPinningConfig,
                                                                allowSelfSignedCertificate: allowSelfSignedCertificate)
    let storageLocator = serviceLocator.storageLocator
    self.userStorage = storageLocator.userStorage(transport: transport)
    self.configurationStorage = storageLocator.configurationStorage(transport: transport)
    self.cardApplicationsStorage = storageLocator.cardApplicationsStorage(transport: transport)
    self.financialAccountsStorage = storageLocator.financialAccountsStorage(transport: transport)
    self.pushTokenStorage = storageLocator.pushTokenStorage(transport: transport)
    self.oauthStorage = storageLocator.oauthStorage(transport: transport)
    self.notificationPreferencesStorage = storageLocator.notificationPreferencesStorage(transport: transport)
    self.voIPStorage = storageLocator.voIPStorage(transport: transport)
    self.paymentSourcesStorage = storageLocator.paymentSourcesStorage(transport: transport)
    self.agreementStorage = storageLocator.achAccountAgreementStorage(transport: transport)
    self.achAccountStorage = storageLocator.achAccountStorage(transport: transport)
    
    // Notify the delegate that the manager has already been initialized
    self.initialized = true
    self.delegate?.sdkInitialized(apiKey: apiKey)

    // Configure reachability notification observers
    self.setUpNotificationObservers()
  }

  /// Initialise the SDK in order to authenticate with our system and start making API calls
  /// - Parameters:
  ///   - apiKey: Developer api key that you can get from our [developer portal](https://www.aptopayments.com/#/developers)
  ///   - environment: Desired environment to use during development
  @objc public func initializeWithApiKey(_ apiKey: String, environment: AptoPlatformEnvironment) {
    self.initializeWithApiKey(apiKey, environment: environment, setupCertPinning: false)
  }

  /// Initialise the SDK in order to authenticate with our system and start making API calls
  /// - Parameters:
  ///   - apiKey: Developer api key that you can get from our [developer portal](https://www.aptopayments.com/#/developers)
  @objc public func initializeWithApiKey(_ apiKey: String) {
    self.initializeWithApiKey(apiKey, environment: .production)
  }
  
  /// Manually sets user token to use when making api calls
  /// - Parameter userToken: valid user token
  public func setUserToken(_ userToken: String) {
    let primaryCredential: DataPointType = userTokenStorage.currentTokenPrimaryCredential() ?? .phoneNumber
    let secondaryCredential: DataPointType = userTokenStorage.currentTokenSecondaryCredential() ?? .email
    userTokenStorage.setCurrent(token: userToken, withPrimaryCredential: primaryCredential,
                                andSecondaryCredential: secondaryCredential)
  }
  
  /// Current user token
  /// - Returns: optional instance of the current token being used by the SDK
  public func currentToken() -> AccessToken? {
    guard let token = self.userTokenStorage.currentToken() else {
      return nil
    }
    var primaryCredential: DataPointType = .phoneNumber
    var secondaryCredential: DataPointType = .email
    if let credential = self.userTokenStorage.currentTokenPrimaryCredential() {
      primaryCredential = credential
    }
    if let credential = self.userTokenStorage.currentTokenSecondaryCredential() {
      secondaryCredential = credential
    }
    return AccessToken(token: token, primaryCredential: primaryCredential, secondaryCredential: secondaryCredential)
  }

  /// Manually set `CardOptions` after initialising the SDK
  /// - Parameter cardOptions: `CardOptions` entity
  public func setCardOptions(_ cardOptions: CardOptions? = nil) {
    configurationStorage.cardOptions = cardOptions
    if let features = cardOptions?.features {
      featuresStorage.update(features: features)
    }
    if let authType = cardOptions?.authenticateOnPCI {
        featuresStorage.updateAuthenticationType(authType)
    }
  }
  
  /// Current push notification token
  /// - Returns: optional instance of the current push notification token used by the SDK
  public func currentPushToken() -> String? {
    return self.pushTokenStorage.currentPushToken()
  }

  /// Close session with our SDK and clean up all user session data
  public func logout() {
    serviceLocator.notificationHandler.postNotification(.UserTokenSessionClosedNotification)
    clearUserToken()
  }

  /// Clean up user token session
  @objc public func clearUserToken() {
    internalCurrentUser = nil
    try? serviceLocator.storageLocator.authenticatedLocalFileManager().invalidate()
    unregisterPushTokenIfNeeded()
    userTokenStorage.clearCurrentToken()
    delegate?.newUserTokenReceived(nil)
    serviceLocator.analyticsManager.logoutUser()
  }

  
  /// Once the primary credential has been verified, you can use the following SDK method to create a new user:
  /// - Parameters:
  ///   - userData: DataPointList with user data
  ///   - metadata: Medatata to be stored with the user. It can hold up to 256 characters. Optional parameter
  ///   - custodianUid: custodian uid. Optional parameter
  ///   - callback: callback with created user or optional error
  public func createUser(userData: DataPointList, custodianUid: String? = nil, metadata: String? = nil,
                         callback: @escaping Result<ShiftUser, NSError>.Callback) {
    guard let apiKey = self.apiKey else {
      let error = BackendError(code: .invalidSession, reason: nil)
      callback(.failure(error))
      return
    }

    userStorage.createUser(apiKey, userData: userData, custodianUid: custodianUid, metadata: metadata) { [weak self] result in
      guard let self = self else { return }
      switch result {
      case .failure(let error): callback(.failure(error))
      case .success(let user):
        self.configurationStorage.contextConfiguration(apiKey) { [weak self] result in
          guard let self = self else { return }
          switch result {
          case .failure(let error): callback(.failure(error))
          case .success(let contextConfiguration):
            let token = user.accessToken! // swiftlint:disable:this force_unwrapping
            self.serviceLocator.analyticsManager.createUser(userId: user.userId)
            let projectConfiguration = contextConfiguration.projectConfiguration
            self.userTokenStorage.setCurrent(token: token.token,
                                             withPrimaryCredential: projectConfiguration.primaryAuthCredential,
                                             andSecondaryCredential: projectConfiguration.secondaryAuthCredential)
            self.notifyPushTokenIfNeeded()
            self.internalCurrentUser = user
            callback(.success(user))
            self.delegate?.newUserTokenReceived(token.token)
          }
        }
      }
    }
  }
  
  /// Once the primary and secondary credentials have been verified, you can use the following SDK method to obtain a user token for an existing user
  /// - Parameters:
  ///   - verifications: verification methods to authenticate user
  ///   - callback: callback with the `ShiftUser` entity or optional error
  public func loginUserWith(verifications: [Verification], callback: @escaping Result<ShiftUser, NSError>.Callback) {
    guard let apiKey = self.apiKey else {
      let error = BackendError(code: .invalidSession, reason: nil)
      callback(.failure(error))
      return
    }

    userStorage.loginWith(apiKey, verifications: verifications) { [weak self] result in
      guard let self = self else { return }
      switch result {
      case .failure(let error): callback(.failure(error))
      case .success(let user):
        self.fetchContextConfiguration { [weak self] result in
          guard let self = self else { return }
          switch result {
          case .failure(let error):
            callback(.failure(error))
          case .success(let contextConfiguration):
            let token = user.accessToken! // swiftlint:disable:this force_unwrapping
            self.serviceLocator.analyticsManager.loginUser(userId: user.userId)
            let projectConfiguration = contextConfiguration.projectConfiguration
            self.userTokenStorage.setCurrent(token: token.token,
                                             withPrimaryCredential: projectConfiguration.primaryAuthCredential,
                                             andSecondaryCredential: projectConfiguration.secondaryAuthCredential)
            self.notifyPushTokenIfNeeded()
            self.internalCurrentUser = user
            callback(.success(user))
            self.delegate?.newUserTokenReceived(token.token)
          }
        }
      }
    }
  }
  
  /// Fetch remote server project configuration to configure your UI with the remote parameters
  /// - Parameters:
  ///   - forceRefresh: avoid using cached data
  ///   - callback: callback with the `ContextConfiguration` entity or optional error
  public func fetchContextConfiguration(_ forceRefresh: Bool = false,
                                        callback: @escaping Result<ContextConfiguration, NSError>.Callback) {
    guard let apiKey = self.apiKey else {
      let error = BackendError(code: .invalidSession, reason: nil)
      callback(.failure(error))
      return
    }
    configurationStorage.contextConfiguration(apiKey, forceRefresh: forceRefresh) { [weak self] result in
      callback(result)
      if let contextConfiguration = result.value {
        if contextConfiguration.projectConfiguration.isTrackerActive == true {
          if let trackerAccessToken = contextConfiguration.projectConfiguration.trackerAccessToken {
            self?.serviceLocator.analyticsManager.initialize(accessToken: trackerAccessToken)
          }
        }
      }
    }
  }
  
    /// Records whether a user accepted or declined a certain agreement.
    /// - Parameters:
    ///   - request: agreement keys and actions that a user took on the agreements.
    ///   - callback: callback with `[AgreementDetail]` or optional error
    public func reviewAgreement(_ request: AgreementRequest, callback: @escaping (RecordedAgreementsResult) -> Void) {
        guard let apiKey = self.apiKey, let accessToken = currentToken() else {
            let error = BackendError(code: .invalidSession, reason: nil)
            callback(.failure(error))
            return
        }

        agreementStorage?.recordAgreement(apiKey,
                                          userToken: accessToken.token,
                                          agreementRequest: request,
                                          completion: { result in
                                            switch result {
                                            case .failure(let error):
                                                callback(.failure(error))
                                            case .success(let agreements):
                                                callback(.success(agreements))
                                            }
                                          })
    }
    
    /// Assigns a bank account to this funding source. If the required agreements haven't been accepted, this will return an error.
    /// - Parameters:
    ///   - balanceId: agreement keys and actions that a user took on the agreements.
    ///   - callback: callback with `[ACHAccountResult]` or optional error
    public func assignAchAccount(balanceId: String, callback: @escaping (ACHAccountResult) -> Void) {
        guard let apiKey = self.apiKey, let accessToken = currentToken() else {
            let error = BackendError(code: .invalidSession, reason: nil)
            callback(.failure(error))
            return
        }

        achAccountStorage?.assignACHAccount(apiKey,
                                             userToken: accessToken.token,
                                             balanceId: balanceId,
                                             completion: { result in
                                                switch result {
                                                case .failure(let error):
                                                    callback(.failure(error))
                                                case .success(let agreements):
                                                    callback(.success(agreements))
                                                }
                                             })
    }
    
  /// Retrieve `UIConfig` entity from cache
  /// - Returns: returns nil if the configuration is not available yet
  public func fetchUIConfig() -> UIConfig? {
    return configurationStorage.uiConfig()
  }

  public func isFeatureEnabled(_ featureKey: FeatureKey) -> Bool {
    return featuresStorage.isFeatureEnabled(featureKey)
  }

    public func isAuthTypePinOrBiometricsEnabled() -> Bool {
        featuresStorage.isAuthenticationTypeEquals(to: .pinOrBiometrics)
    }
    
  public func isShowDetailedCardActivityEnabled() -> Bool {
    return userPreferencesStorage.shouldShowDetailedCardActivity
  }

  public func setShowDetailedCardActivityEnabled(_ isEnabled: Bool) {
    userPreferencesStorage.shouldShowDetailedCardActivity = isEnabled
  }
  
  /// Check if biometrics are enabled
  /// - Returns: biometrics status
  public func isBiometricEnabled() -> Bool {
    return userPreferencesStorage.shouldUseBiometric
  }
  
  /// Enable biometric authentication
  /// - Parameter isEnabled: status
  public func setIsBiometricEnabled(_ isEnabled: Bool) {
    userPreferencesStorage.shouldUseBiometric = isEnabled
  }
  
  /// Retrieve a list of all the available card programs that can be used to issue cards
  /// - Parameter callback: callback with a list of `CardProductSummary` or optional error
  public func fetchCardProducts(callback: @escaping Result<[CardProductSummary], NSError>.Callback) {
    guard let apiKey = self.apiKey, let accessToken = currentToken() else {
      return callback(.failure(BackendError(code: .invalidSession)))
    }
    configurationStorage.cardProducts(apiKey, userToken: accessToken.token, callback: callback)
  }

  /// Retrieve current `ShiftUser`
  /// - Parameters:
  ///   - forceRefresh: avoid cache results
  ///   - callback: callback with `ShiftUser` entity or optional error
  public func fetchCurrentUserInfo(forceRefresh: Bool, filterInvalidTokenResult: Bool,
                                   callback: @escaping Result<ShiftUser, NSError>.Callback) {
    guard let apiKey = self.apiKey, let accessToken = currentToken() else {
      callback(.failure(BackendError(code: .invalidSession)))
      return
    }
    if forceRefresh == false, let user = internalCurrentUser {
      callback(.success(user))
      return
    }
    userStorage.getUserData(apiKey, userToken: accessToken.token,
                            filterInvalidTokenResult: filterInvalidTokenResult) { [weak self] result in
      guard let self = self else { return }
      switch result {
      case .failure(let error):
        if let backendError = error as? BackendError {
          if backendError.invalidSessionError() || backendError.sessionExpiredError() {
            self.clearUserToken()
            callback(.failure(error))
            return
          }
        }
        callback(.failure(error))
      case .success(let user):
        self.notifyPushTokenIfNeeded()
        callback(.success(user))
      }
    }
  }
  
  /// Update user information with new user data
  /// - Parameters:
  ///   - userData: `DataPointList` entity
  ///   - callback: callback with the updated `ShiftUser` entity or optional error
  public func updateUserInfo(_ userData: DataPointList, callback: @escaping Result<ShiftUser, NSError>.Callback) {
    guard let apiKey = self.apiKey, let accessToken = currentToken() else {
      let error = BackendError(code: .invalidSession, reason: nil)
      callback(.failure(error))
      return
    }
    if userData.dataPoints.isEmpty {
      fetchCurrentUserInfo(forceRefresh: false, filterInvalidTokenResult: true, callback: callback)
      return
    }
    userStorage.updateUserData(apiKey, userToken: accessToken.token, userData: userData) { [weak self] result in
      switch result {
      case .failure(let error):
        callback(.failure(error))
      case .success(let user):
        self?.internalCurrentUser = user
        callback(.success(user))
      }
    }
  }
  
  /// Starts a new verification of the user's primary credential
  /// - Parameters:
  ///   - callback: callback with `Verification` entity or optional error
  public func startPrimaryVerification(callback: @escaping Result<Verification, NSError>.Callback) {
    guard let apiKey = self.apiKey, let accessToken = currentToken() else {
      let error = BackendError(code: .invalidSession, reason: nil)
      callback(.failure(error))
      return
    }
    userStorage.startPrimaryVerification(apiKey, userToken: accessToken.token, callback: callback)
  }

  /// Starts a new phone user verification
  /// - Parameters:
  ///   - phone: `PhoneNumber` entity with desired phone number
  ///   - callback: callback with `Verification` entity or optional error
  public func startPhoneVerification(_ phone: PhoneNumber, callback: @escaping Result<Verification, NSError>.Callback) {
    guard let apiKey = self.apiKey else {
      let error = BackendError(code: .invalidSession, reason: nil)
      callback(.failure(error))
      return
    }
    userStorage.startPhoneVerification(apiKey, phone: phone, callback: callback)
  }
  
  /// Starts a new email verification
  /// - Parameters:
  ///   - email: `Email` entity with desired email
  ///   - callback: callback with `Verification` entity or optional error
  public func startEmailVerification(_ email: Email, callback: @escaping Result<Verification, NSError>.Callback) {
    guard let apiKey = self.apiKey else {
      let error = BackendError(code: .invalidSession, reason: nil)
      callback(.failure(error))
      return
    }
    userStorage.startEmailVerification(apiKey, email: email, callback: callback)
  }
  
  /// Starts a new birth date verification
  /// - Parameters:
  ///   - birthDate: `BirthDate` entity with birth date
  ///   - callback: callback with `Verification` entity or optional error
  public func startBirthDateVerification(_ birthDate: BirthDate,
                                         callback: @escaping Result<Verification, NSError>.Callback) {
    guard let apiKey = self.apiKey else {
      let error = BackendError(code: .invalidSession, reason: nil)
      callback(.failure(error))
      return
    }
    userStorage.startBirthDateVerification(apiKey, birthDate: birthDate, callback: callback)
  }

  /// Starts document id verification
  /// - Parameters:
  ///   - documentImages: array of `UIImage` with document id
  ///   - selfie: `UIImage` with a selfie of the user to verify
  ///   - callback: callback with `Verification` entity or optional error
  public func startDocumentVerification(documentImages: [UIImage], selfie: UIImage?, livenessData: [String: AnyObject]?,
                                        associatedTo workflowObject: WorkflowObject?,
                                        callback: @escaping Result<Verification, NSError>.Callback) {
    guard let apiKey = self.apiKey, let accessToken = currentToken() else {
      let error = BackendError(code: .invalidSession, reason: nil)
      callback(.failure(error))
      return
    }
    userStorage.startDocumentVerification(apiKey, userToken: accessToken.token, documentImages: documentImages,
                                          selfie: selfie, livenessData: livenessData, associatedTo: workflowObject,
                                          callback: callback)
  }

  /// Fetch document verification status
  /// - Parameters:
  ///   - verification: `Verification` entity to check status
  ///   - callback: callback with `Verification` entity or optional error
  public func fetchDocumentVerificationStatus(_ verification: Verification,
                                              callback: @escaping Result<Verification, NSError>.Callback) {
    guard let apiKey = self.apiKey else {
      let error = BackendError(code: .invalidSession, reason: nil)
      callback(.failure(error))
      return
    }
    userStorage.documentVerificationStatus(apiKey, verificationId: verification.verificationId, callback: callback)
  }

  public func restartVerification(_ verification: Verification,
                                  callback: @escaping Result<Verification, NSError>.Callback) {
    guard let apiKey = self.apiKey else {
      let error = BackendError(code: .invalidSession, reason: nil)
      callback(.failure(error))
      return
    }
    userStorage.restartVerification(apiKey, verificationId: verification.verificationId, callback: callback)
  }

  public func completeVerification(_ verification: Verification,
                                   callback: @escaping Result<Verification, NSError>.Callback) {
    guard let apiKey = self.apiKey else {
      let error = BackendError(code: .invalidSession, reason: nil)
      callback(.failure(error))
      return
    }
    userStorage.completeVerification(apiKey, verificationId: verification.verificationId, secret: verification.secret,
                                     callback: callback)
  }

  public func fetchVerificationStatus(_ verification: Verification,
                                      callback: @escaping Result<Verification, NSError>.Callback) {
    guard let apiKey = self.apiKey else {
      let error = BackendError(code: .invalidSession, reason: nil)
      callback(.failure(error))
      return
    }
    userStorage.verificationStatus(apiKey, verificationId: verification.verificationId, callback: callback)
  }

    /// Performs a request order of a physical card with the same PAN of the current virtual card that will be sent by mail to the cardholder.
    /// - Parameters:
    ///   - cardId: the card identifier
    ///   - callback: callback block with a ``Card`` or an optional ``Error``
    public func orderPhysicalCard(_ cardId: String, callback: @escaping (Result<Card, NSError>) -> Void) {
        guard let apiKey = self.apiKey, let accessToken = currentToken() else {
            callback(.failure(BackendError(code: .invalidSession)))
            return
        }
        financialAccountsStorage.orderPhysicalCard(apiKey, userToken: accessToken.token, accountId: cardId, completion: callback)
    }
    
    /// Retrieves the configuration for an ordered physical card
    /// - Parameters:
    ///   - cardId: the card identifier
    ///   - callback: callback block with a ``PhysicalCardConfig`` or an optional ``Error``
    public func getOrderPhysicalCardConfig(_ cardId: String, callback: @escaping (Result<PhysicalCardConfig, NSError>) -> Void) {
        guard let apiKey = self.apiKey, let accessToken = currentToken() else {
            callback(.failure(BackendError(code: .invalidSession)))
            return
        }
        financialAccountsStorage.getOrderPhysicalCardConfig(apiKey, userToken: accessToken.token, accountId: cardId, completion: callback)
    }
    
  /// Retrieve a list of issued cards for current user
  /// - Parameters:
  ///   - page: index page
  ///   - rows: number of cards per page
  ///   - callback: callback block with an array of ``Card`` or an optional ``Error``
  public func fetchCards(page: Int, rows: Int, callback: @escaping Result<[Card], NSError>.Callback) {
    next(financialAccountsOfType: .card, page: page, rows: rows) { result in
      switch result {
      case .failure(let error):
        callback(.failure(error))
      case .success(let financialAccounts):
        let cards = financialAccounts.compactMap { $0 as? Card }
        callback(.success(cards))
      }
    }
  }

  private func next(financialAccountsOfType: FinancialAccountType, page: Int, rows: Int,
                    callback: @escaping Result<[FinancialAccount], NSError>.Callback) {
    guard let apiKey = self.apiKey, let accessToken = currentToken() else {
      callback(.failure(BackendError(code: .invalidSession)))
      return
    }
    financialAccountsStorage.get(financialAccountsOfType: financialAccountsOfType, apiKey: apiKey,
                                 userToken: accessToken.token, callback: callback)
  }

  public func fetchCard(_ cardId: String, forceRefresh: Bool = true, retrieveBalances: Bool = false,
                        callback: @escaping Result<Card, NSError>.Callback) {
    guard let apiKey = self.apiKey, let accessToken = currentToken() else {
      callback(.failure(BackendError(code: .invalidSession)))
      return
    }
    financialAccountsStorage.getFinancialAccount(
      apiKey, userToken: accessToken.token, accountId: cardId,
      forceRefresh: forceRefresh, retrieveBalances: retrieveBalances) { result in
      switch result {
      case .failure(let error):
        callback(.failure(error))
      case .success(let financialAccount):
        guard let card = financialAccount as? Card else {
          callback(.failure(BackendError(code: .cardNotFound)))
          return
        }
        callback(.success(card))
      }
    }
  }

  @available(*, deprecated, message: "Please use fetchCard instead.")
  public func fetchFinancialAccount(_ accountId: String, forceRefresh: Bool = true, retrieveBalances: Bool = false,
                                      callback: @escaping Result<FinancialAccount, NSError>.Callback) {
    fetchCard(accountId, forceRefresh: forceRefresh, retrieveBalances: retrieveBalances) { result in
      switch result {
      case .failure(let error):
        callback(.failure(error))
      case .success(let card):
        callback(.success(card))
      }
    }
  }
  @available(*, deprecated, message: "To show the card data to your users, please use the Apto PCI SDK.")
  public func fetchCardDetails(_ cardId: String, callback: @escaping Result<CardDetails, NSError>.Callback) {
    guard let apiKey = self.apiKey, let accessToken = currentToken() else {
      callback(.failure(BackendError(code: .invalidSession)))
      return
    }
    financialAccountsStorage.getCardDetails(apiKey, userToken: accessToken.token, accountId: cardId,
                                            callback: callback)
  }

  public func fetchNotificationPreferences(callback: @escaping Result<NotificationPreferences, NSError>.Callback) {
    guard let apiKey = self.apiKey, let accessToken = currentToken() else {
      callback(.failure(BackendError(code: .invalidSession)))
      return
    }
    notificationPreferencesStorage.fetchPreferences(apiKey, userToken: accessToken.token, callback: callback)
  }

  public func updateNotificationPreferences(_ preferences: NotificationPreferences,
                                            callback: @escaping Result<NotificationPreferences, NSError>.Callback) {
    guard let apiKey = self.apiKey, let accessToken = currentToken() else {
      callback(.failure(BackendError(code: .invalidSession)))
      return
    }
    notificationPreferencesStorage.updatePreferences(apiKey, userToken: accessToken.token, preferences: preferences,
                                                     callback: callback)
  }

  public func startOauthAuthentication(balanceType: AllowedBalanceType,
                                       callback: @escaping Result<OauthAttempt, NSError>.Callback) {
    guard let apiKey = self.apiKey, let accessToken = currentToken() else {
      callback(.failure(BackendError(code: .invalidSession)))
      return
    }
    oauthStorage.startOauthAuthentication(apiKey, userToken: accessToken.token, balanceType: balanceType,
                                          callback: callback)
  }

  public func verifyOauthAttemptStatus(_ attempt: OauthAttempt,
                                       callback: @escaping Result<OauthAttempt, NSError>.Callback) {
    guard let apiKey = self.apiKey, let accessToken = currentToken() else {
      callback(.failure(BackendError(code: .invalidSession)))
      return
    }
    oauthStorage.verifyOauthAttemptStatus(apiKey,
                                          userToken: accessToken.token,
                                          attempt: attempt,
                                          callback: callback)
  }

  public func saveOauthUserData(_ userData: DataPointList, custodian: Custodian,
                                callback: @escaping Result<OAuthSaveUserDataResult, NSError>.Callback) {
    guard let apiKey = self.apiKey, let accessToken = currentToken() else {
      return callback(.failure(BackendError(code: .invalidSession)))
    }
    userStorage.saveOauthData(apiKey, userToken: accessToken.token, userData: userData, custodian: custodian,
                              callback: callback)
  }

  public func fetchOAuthData(_ custodian: Custodian, callback: @escaping Result<OAuthUserData, NSError>.Callback) {
    guard let apiKey = self.apiKey else {
      return callback(.failure(BackendError(code: .invalidSession)))
    }
    userStorage.fetchOauthData(apiKey, custodian: custodian, callback: callback)
  }

  public func fetchVoIPToken(cardId: String, actionSource: VoIPActionSource,
                             callback: @escaping Result<VoIPToken, NSError>.Callback) {
    guard let apiKey = self.apiKey, let accessToken = currentToken() else {
      return callback(.failure(BackendError(code: .invalidSession)))
    }
    voIPStorage.fetchToken(apiKey, userToken: accessToken.token, cardId: cardId, actionSource: actionSource,
                           callback: callback)
  }

  public func activatePhysicalCard(_ cardId: String, code: String,
                                   callback: @escaping Result<PhysicalCardActivationResult, NSError>.Callback) {
    guard let apiKey = self.apiKey, let accessToken = currentToken() else {
      return callback(.failure(BackendError(code: .invalidSession)))
    }
    financialAccountsStorage.activatePhysical(apiKey, userToken: accessToken.token, accountId: cardId, code: code,
                                              callback: callback)
  }

  public func activateCard(_ cardId: String, callback: @escaping Result<Card, NSError>.Callback) {
    changeCardState(cardId, state: .created, callback: callback)
  }

  public func unlockCard(_ cardId: String, callback: @escaping Result<Card, NSError>.Callback) {
    changeCardState(cardId, state: .active, callback: callback)
  }

  public func lockCard(_ cardId: String, callback: @escaping Result<Card, NSError>.Callback) {
    changeCardState(cardId, state: .inactive, callback: callback)
  }

  private func changeCardState(_ cardId: String, state: FinancialAccountState,
                               callback: @escaping Result<Card, NSError>.Callback) {
    guard let projectKey = self.apiKey, let accessToken = currentToken() else {
      callback(.failure(BackendError(code: .invalidSession)))
      return
    }
    financialAccountsStorage.updateFinancialAccountState(projectKey, userToken: accessToken.token,
                                                         accountId: cardId, state: state) { result in
      callback(result.flatMap { financialAccount -> Result<Card, NSError> in
        guard let card = financialAccount as? Card else {
          return .failure(ServiceError(code: .jsonError))
        }
        return .success(card)
      })
    }
  }

  public func changeCardPIN(_ cardId: String, pin: String, callback: @escaping Result<Card, NSError>.Callback) {
    guard let projectKey = self.apiKey, let accessToken = currentToken() else {
      callback(.failure(BackendError(code: .invalidSession)))
      return
    }
    financialAccountsStorage.updateFinancialAccountPIN(projectKey, userToken: accessToken.token,
                                                       accountId: cardId, pin: pin) { result in
      callback(result.flatMap { financialAccount -> Result<Card, NSError> in
        guard let card = financialAccount as? Card else {
          return .failure(ServiceError(code: .jsonError))
        }
        return .success(card)
      })
    }
  }

  /// Sets a passcode to the card
  /// - Parameters:
  ///   - cardId: the id of the card
  ///   - passCode: the code to be set for this card
  ///   - verificationId (optional): If setting a passcode requires a passed primary credential verification, pass its id here.
  ///   - callback: this method will be called when the operation finished with a result.
  public func setCardPassCode(_ cardId: String, passCode: String, verificationId: String? = nil,
                              callback: @escaping Result<Void, NSError>.Callback) {
    guard let projectKey = self.apiKey, let accessToken = currentToken() else {
      callback(.failure(BackendError(code: .invalidSession)))
      return
    }
    financialAccountsStorage.setCardPassCode(projectKey, userToken: accessToken.token, cardId: cardId,
                                             passCode: passCode, verificationId: verificationId, callback: callback)
  }
  
  /// Retrieve a  list of transactions of a given card
  /// - Parameters:
  ///   - cardId: <#cardId description#>
  ///   - filters: <#filters description#>
  ///   - forceRefresh: <#forceRefresh description#>
  ///   - callback: <#callback description#>
  public func fetchCardTransactions(_ cardId: String, filters: TransactionListFilters, forceRefresh: Bool = true,
                                    callback: @escaping Result<[Transaction], NSError>.Callback) {
    guard let projectKey = self.apiKey, let accessToken = currentToken() else {
      callback(.failure(BackendError(code: .invalidSession)))
      return
    }
    financialAccountsStorage.getFinancialAccountTransactions(projectKey, userToken: accessToken.token,
                                                             accountId: cardId, filters: filters,
                                                             forceRefresh: forceRefresh, callback: callback)
  }

  public func fetchCardFundingSources(_ cardId: String, page: Int?, rows: Int?, forceRefresh: Bool = true,
                                      callback: @escaping Result<[FundingSource], NSError>.Callback) {
    guard let projectKey = self.apiKey, let accessToken = currentToken() else {
      callback(.failure(BackendError(code: .invalidSession)))
      return
    }
    financialAccountsStorage.financialAccountFundingSources(projectKey, userToken: accessToken.token,
                                                            accountId: cardId, page: page, rows: rows,
                                                            forceRefresh: forceRefresh, callback: callback)
  }

  public func fetchCardFundingSource(_ cardId: String, forceRefresh: Bool = true,
                                     callback: @escaping Result<FundingSource?, NSError>.Callback) {
    guard let projectKey = self.apiKey, let accessToken = currentToken() else {
      callback(.failure(BackendError(code: .invalidSession)))
      return
    }
    financialAccountsStorage.getFinancialAccountFundingSource(projectKey, userToken: accessToken.token,
                                                              accountId: cardId, forceRefresh: forceRefresh,
                                                              callback: callback)
  }

  public func setCardFundingSource(_ fundingSourceId: String, cardId: String,
                                   callback: @escaping Result<FundingSource, NSError>.Callback) {
    guard let projectKey = self.apiKey, let accessToken = currentToken() else {
      callback(.failure(BackendError(code: .invalidSession)))
      return
    }
    financialAccountsStorage.setFinancialAccountFundingSource(projectKey, userToken: accessToken.token,
                                                              accountId: cardId, fundingSourceId: fundingSourceId,
                                                              callback: callback)
  }

  public func addCardFundingSource(cardId: String, custodian: Custodian,
                                   callback: @escaping Result<FundingSource, NSError>.Callback) {
    guard let projectKey = self.apiKey, let accessToken = currentToken() else {
      callback(.failure(BackendError(code: .invalidSession)))
      return
    }
    financialAccountsStorage.addFinancialAccountFundingSource(projectKey, userToken: accessToken.token,
                                                              accountId: cardId, custodian: custodian,
                                                              callback: callback)
  }

  public func fetchCardProduct(cardProductId: String, forceRefresh: Bool = false,
                               callback: @escaping Result<CardProduct, NSError>.Callback) {
    guard let projectKey = self.apiKey, let accessToken = currentToken() else {
      callback(.failure(BackendError(code: .invalidSession)))
      return
    }
    configurationStorage.cardConfiguration(projectKey, userToken: accessToken.token, forceRefresh: forceRefresh,
                                           cardProductId: cardProductId, callback: callback)
  }

  public func nextCardApplications(page: Int, rows: Int,
                                   callback: @escaping Result<[CardApplication], NSError>.Callback) {
    guard let projectKey = self.apiKey, let accessToken = currentToken() else {
      callback(.failure(BackendError(code: .invalidSession)))
      return
    }
    cardApplicationsStorage.nextApplications(projectKey, userToken: accessToken.token, page: page, rows: rows,
                                             callback: callback)
  }

  public func applyToCard(cardProduct: CardProduct, callback: @escaping Result<CardApplication, NSError>.Callback) {
    guard let projectKey = self.apiKey, let accessToken = currentToken() else {
      callback(.failure(BackendError(code: .invalidSession)))
      return
    }
    cardApplicationsStorage.createApplication(projectKey, userToken: accessToken.token, cardProduct: cardProduct,
                                              callback: callback)
  }

  public func fetchCardApplicationStatus(_ applicationId: String,
                                         callback: @escaping Result<CardApplication, NSError>.Callback) {
    guard let projectKey = self.apiKey, let accessToken = currentToken() else {
      callback(.failure(BackendError(code: .invalidSession)))
      return
    }
    cardApplicationsStorage.applicationStatus(projectKey, userToken: accessToken.token, applicationId: applicationId,
                                              callback: callback)
  }

  public func setBalanceStore(applicationId: String, custodian: Custodian,
                              callback: @escaping Result<SelectBalanceStoreResult, NSError>.Callback) {
    guard let projectKey = self.apiKey, let accessToken = currentToken() else {
      callback(.failure(BackendError(code: .invalidSession)))
      return
    }
    cardApplicationsStorage.setBalanceStore(projectKey, userToken: accessToken.token, applicationId: applicationId,
                                            custodian: custodian, callback: callback)
  }

  public func acceptDisclaimer(workflowObject: WorkflowObject, workflowAction: WorkflowAction,
                               callback: @escaping Result<Void, NSError>.Callback) {
    guard let projectKey = self.apiKey, let accessToken = currentToken() else {
      callback(.failure(BackendError(code: .invalidSession)))
      return
    }
    cardApplicationsStorage.acceptDisclaimer(projectKey, userToken: accessToken.token, workflowObject: workflowObject,
                                             workflowAction: workflowAction, callback: callback)
  }

  public func cancelCardApplication(_ applicationId: String, callback: @escaping Result<Void, NSError>.Callback) {
    guard let apiKey = self.apiKey, let accessToken = currentToken() else {
      callback(.failure(BackendError(code: .invalidSession)))
      return
    }
    cardApplicationsStorage.cancelCardApplication(apiKey, userToken: accessToken.token, applicationId: applicationId,
                                                  callback: callback)
  }

    public func issueCard(applicationId: String,
                          additionalFields: [String: AnyObject]? = nil,
                          metadata: String? = nil,
                          design: IssueCardDesign? = nil,
                          callback: @escaping Result<Card, NSError>.Callback) {
        guard let projectKey = self.apiKey, let accessToken = currentToken() else {
            callback(.failure(BackendError(code: .invalidSession)))
            return
        }
        cardApplicationsStorage.issueCard(projectKey,
                                          userToken: accessToken.token,
                                          applicationId: applicationId,
                                          additionalFields: additionalFields,
                                          metadata: metadata,
                                          design: design,
                                          callback: callback)
    }

    @available(*, deprecated, message: "Please use issueCard with applicationId")
  public func issueCard(cardProduct: CardProduct, custodian: Custodian?, additionalFields: [String: AnyObject]? = nil,
                        initialFundingSourceId: String? = nil, callback: @escaping Result<Card, NSError>.Callback) {
    guard let apiKey = self.apiKey, let accessToken = currentToken() else {
      callback(.failure(BackendError(code: .invalidSession)))
      return
    }
    financialAccountsStorage.issueCard(apiKey, userToken: accessToken.token, cardProduct: cardProduct,
                                       custodian: custodian, additionalFields: additionalFields,
                                       initialFundingSourceId: initialFundingSourceId, callback: callback)
  }

  public func cardMonthlySpending(_ cardId: String, date: Date,
                                  callback: @escaping Result<MonthlySpending, NSError>.Callback) {
    fetchMonthlySpending(cardId: cardId, month: date.month, year: date.year, callback: callback)
  }

  public func fetchMonthlySpending(cardId: String, month: Int, year: Int,
                                   callback: @escaping Result<MonthlySpending, NSError>.Callback) {
    guard let apiKey = self.apiKey, let accessToken = currentToken() else {
      callback(.failure(BackendError(code: .invalidSession)))
      return
    }
    financialAccountsStorage.fetchMonthlySpending(apiKey, userToken: accessToken.token, accountId: cardId, month: month,
                                                  year: year, callback: callback)
  }

  public func fetchMonthlyStatementsPeriod(callback: @escaping Result<MonthlyStatementsPeriod, NSError>.Callback) {
    guard let apiKey = self.apiKey, let accessToken = currentToken() else {
      callback(.failure(BackendError(code: .invalidSession)))
      return
    }
    userStorage.fetchStatementsPeriod(apiKey, userToken: accessToken.token, callback: callback)
  }

  public func fetchMonthlyStatementReport(month: Int, year: Int,
                                          callback: @escaping Result<MonthlyStatementReport, NSError>.Callback) {
    guard let apiKey = self.apiKey, let accessToken = currentToken() else {
      callback(.failure(BackendError(code: .invalidSession)))
      return
    }
    userStorage.fetchStatement(apiKey, userToken: accessToken.token, month: month, year: year, callback: callback)
  }

  public func runPendingNetworkRequests() {
    serviceLocator.networkLocator.networkManager().runPendingRequests()
  }

  public func addPaymentSource(with request: PaymentSourceRequest, callback: @escaping Result<PaymentSource, NSError>.Callback) {
    guard let apiKey = self.apiKey, let accessToken = currentToken() else {
      callback(.failure(BackendError(code: .invalidSession)))
      return
    }
    paymentSourcesStorage.addPaymentSource(apiKey, userToken: accessToken.token, request, callback: callback)
  }
  
  public func getPaymentSources(_ request: PaginationQuery?, callback: @escaping Result<[PaymentSource], NSError>.Callback) {
    guard let apiKey = self.apiKey, let accessToken = currentToken() else {
      callback(.failure(BackendError(code: .invalidSession)))
      return
    }
    paymentSourcesStorage.getPaymentSources(apiKey, userToken: accessToken.token, request: request ?? .default, callback: callback)
  }
  
  public func deletePaymentSource(paymentSourceId: String, callback: @escaping Result<Void, NSError>.Callback) {
    guard let apiKey = self.apiKey, let accessToken = currentToken() else {
      callback(.failure(BackendError(code: .invalidSession)))
      return
    }
    paymentSourcesStorage.deletePaymentSource(apiKey, userToken: accessToken.token, paymentSourceId: paymentSourceId, callback: callback)
  }
  
  public func pushFunds(with request: PushFundsRequest, callback: @escaping Result<PaymentResult, NSError>.Callback) {
    guard let apiKey = self.apiKey, let accessToken = currentToken() else {
      callback(.failure(BackendError(code: .invalidSession)))
      return
    }
    paymentSourcesStorage.pushFunds(apiKey, userToken: accessToken.token, request: request, callback: callback)
  }
  
  // MARK: Private Attributes

  private func setUpNotificationObservers() {
    let notificator = serviceLocator.notificationHandler
    notificator.addObserver(self, selector: #selector(self.sdkDeprecated), name: .SDKDeprecatedNotification)
    notificator.addObserver(self, selector: #selector(self.didRestoreNetworkConnection),
                            name: .NetworkReachableNotification)
    notificator.addObserver(self, selector: #selector(self.didLoseNetworkConnection),
                            name: .NetworkNotReachableNotification)
    notificator.addObserver(self, selector: #selector(self.didLoseConnectionToServer),
                            name: .ServerMaintenanceNotification)
  }

  private func removeNotificationObservers() {
    serviceLocator.notificationHandler.removeObserver(self)
  }

  @objc private func sdkDeprecated() {
    delegate?.sdkDeprecated()
  }

  @objc private func didRestoreNetworkConnection() {
    delegate?.networkConnectionRestored?()
  }

  @objc private func didLoseNetworkConnection() {
    delegate?.networkConnectionError?()
  }

  @objc private func didLoseConnectionToServer() {
    delegate?.serverMaintenanceError?()
  }    
}

// MARK: - Push Notifications management

extension AptoPlatform {

  public func initializePushNotifications() {
    self.pushNotificationsManager.registerForPushNotifications()
  }

  public func handle(launchOptions: [UIApplication.LaunchOptionsKey: Any]?) {
    if let notification = launchOptions?[.remoteNotification] as? [String: AnyObject] {
      self.didReceiveRemoteNotificationWith(userInfo: notification) { _ in }
    }
  }

  public func didReceiveRemoteNotification(userInfo: [AnyHashable: Any],
                                           completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
    pushNotificationsManager.didReceiveRemoteNotificationWith(userInfo: userInfo, completionHandler: completionHandler)
  }

  public func didRegisterForRemoteNotificationsWithDeviceToken(deviceToken: Data) {
    let pushToken = self.pushNotificationsManager.newPushTokenReceived(deviceToken: deviceToken)
    self.pushTokenStorage.setCurrent(pushToken: pushToken)
    self.notifyPushTokenIfNeeded()
  }

  public func didFailToRegisterForRemoteNotificationsWithError(error: Error) {
    self.pushNotificationsManager.didFailToRegisterForRemoteNotificationsWithError(error: error)
  }

  public func didReceiveRemoteNotificationWith(userInfo: [AnyHashable: Any],
                                               completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
    pushNotificationsManager.didReceiveRemoteNotificationWith(userInfo: userInfo, completionHandler: completionHandler)
  }

  private func notifyPushTokenIfNeeded() {
    if let accessToken = self.currentToken(), let pushToken = self.currentPushToken() {
      pushTokenStorage.registerPushToken(apiKey, userToken: accessToken.token, pushToken: pushToken) { _ in }
    }
  }

  private func unregisterPushTokenIfNeeded() {
    if let accessToken = self.currentToken(), let pushToken = self.currentPushToken() {
      pushTokenStorage.unregisterPushToken(apiKey, userToken: accessToken.token, pushToken: pushToken) { _ in }
    }
  }
}
