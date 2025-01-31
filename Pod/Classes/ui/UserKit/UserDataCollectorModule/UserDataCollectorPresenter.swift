//
//  DataCollectorInteractor.swift
//  AptoSDK
//
//  Created by Ivan Oliver Martínez on 30/01/16.
//
//

import UIKit
import Bond
import ReactiveKit

func <<T: RawRepresentable>(lhs: T, rhs: T) -> Bool where T.RawValue: Comparable {
  return lhs.rawValue < rhs.rawValue
}

protocol UserDataCollectorRouterProtocol: URLHandlerProtocol {
  func close()
  func presentPhoneVerification(verificationType: VerificationParams<PhoneNumber, Verification>,
                                modally: Bool?,
                                completion: (Result<Verification, NSError>.Callback)?)
  func presentEmailVerification(verificationType: VerificationParams<Email, Verification>,
                                modally: Bool?,
                                completion: (Result<Verification, NSError>.Callback)?)
  func presentBirthdateVerification(verificationType: VerificationParams<BirthDate, Verification>,
                                    modally: Bool?,
                                    completion: (Result<Verification, NSError>.Callback)?)
  func userDataCollected(_ user: ShiftUser)
}

protocol UserDataCollectorInteractorProtocol {
  func provideDataCollectorData()
  func nextStepTapped(fromStep: DataCollectorStep)
  func allUserDataCollected(_ userData: DataPointList, callback: @escaping Result<ShiftUser, NSError>.Callback)
}

protocol UserDataCollectorViewProtocol: ViewControllerProtocol {
  func show(fields: [FormRowView])
  func push(fields: [FormRowView])
  func pop(fields: [FormRowView])
  func update(progress: Float)
  func showLoadingView()
}

enum DataCollectorStep: Int {
  case info
  case address
  case birthDaySSN
}

class UserDataCollectorPresenter: UserDataCollectorDataReceiver, UserDataCollectorEventHandler {
  // swiftlint:disable implicitly_unwrapped_optional
  var viewController: UserDataCollectorViewProtocol!
  var interactor: UserDataCollectorInteractorProtocol!
  weak var router: UserDataCollectorRouterProtocol!
  // swiftlint:enable implicitly_unwrapped_optional

  private var stepVisibility = NSOrderedSet()
  private var step: Observable<DataCollectorStep> = Observable(.info)
  private var previousStep: DataCollectorStep = .info
  private let uiConfig: UIConfig
  private let config: UserDataCollectorConfig
  private var userData: DataPointList! // swiftlint:disable:this implicitly_unwrapped_optional

  init(config: UserDataCollectorConfig, uiConfig: UIConfig) {
    self.uiConfig = uiConfig
    self.config = config
  }

  func viewLoaded() {
    interactor.provideDataCollectorData()
  }

  // MARK: UserDataCollectorDataReceiver

  func set(_ userData: DataPointList,
           missingData: RequiredDataPointList,
           requiredData: RequiredDataPointList,
           skipSteps: Bool,
           mode: UserDataCollectorFinalStepMode,
           primaryCredentialType: DataPointType,
           secondaryCredentialType: DataPointType,
           googleGeocodingAPIKey: String?) {
    self.userData = userData
    stepVisibility = self.calculateStepVisibility(userData: userData,
                                                  mode: mode,
                                                  skipSteps: skipSteps,
                                                  requiredData: requiredData,
                                                  missingData: missingData)
    let stepFactory = UserDataCollectorStepFactory(requiredData: requiredData,
                                                   userData: userData,
                                                   mode: mode,
                                                   primaryCredentialType: primaryCredentialType,
                                                   secondaryCredentialType: secondaryCredentialType,
                                                   googleGeocodingAPIKey: googleGeocodingAPIKey,
                                                   uiConfig: uiConfig,
                                                   config: config,
                                                   router: router)
    // Setup steps
    setupSteps(stepVisibility, stepFactory: stepFactory)

    // Observe for step changes
    _ = step.observeNext { [weak self] newStep in
      guard let wself = self else {
        return
      }
      wself.show(step: newStep)
    }

    // Setup first screen
    let firstStep = stepVisibility[0] as! DataCollectorStep // swiftlint:disable:this force_cast
    previousStep = firstStep
    step.send(firstStep)
  }

  private func show(step: DataCollectorStep) {
    let stepIndex = stepVisibility.index(of: step)
    guard stepIndex != NSNotFound else {
      return
    }
    configureNavigationFor(step: step)
    let fields = fieldsFor(step: step)
    if stepVisibility.index(of: previousStep) < stepIndex {
      viewController.push(fields: fields)
    }
    else if previousStep == step {
      viewController.show(fields: fields)
    }
    else {
      viewController.pop(fields: fields)
    }
    viewController.update(progress: 100 * Float(stepIndex + 1) / Float(stepVisibility.count))
    previousStep = step
  }

  func setDataCollectorError(_ error: NSError) {
    viewController.show(error: error, uiConfig: uiConfig)
  }

  func show(error: NSError) {
    viewController.show(error: error, uiConfig: uiConfig)
  }

  func showNextStep() {
    let nextStep = firstNonCompleteStep(from: step.value)
    unbindNavigationFromCurrentStep()
    viewController.deactivateNavNextButton(uiConfig.disabledTextTopPrimaryBarColor)
    step.send(nextStep)
  }

  func showLoadingView() {
    viewController.showLoadingView()
  }

  func hideLoadingView() {
    viewController.hideLoadingView()
  }

  func userReady(_ user: ShiftUser) {
    router.userDataCollected(user)
  }

  // MARK: - DataCollectionEventHandler

  func nextStepTapped() {
    viewController.deactivateNavNextButton(uiConfig.disabledTextTopPrimaryBarColor)
    if step.value == lastStep {
      lastStepFinished()
    }
    else {
      interactor.nextStepTapped(fromStep: step.value)
    }
  }

  func previousStepTapped() {
    unbindNavigationFromCurrentStep()
    if step.value == self.firstStep {
      router.close()
      return
    }
    step.send(lastNonCompleteStep(from: step.value))
  }

  // MARK: - Private Methods

  private var stepsDictionary: [DataCollectorStep: DataCollectorStepProtocol] = [:]
  private var firstStep: DataCollectorStep?
  private var lastStep: DataCollectorStep?

  private func setupSteps(_ stepVisibility: NSOrderedSet, stepFactory: UserDataCollectorStepFactory) {
    self.firstStep = nil
    self.lastStep = nil
    self.stepsDictionary.removeAll()
    stepVisibility.forEach {
      guard let step = $0 as? DataCollectorStep else { return }
      let handler = stepFactory.handler(for: step)
      store(step: step, handler: handler)
    }
  }

  private func lastStepFinished() {
    interactor.allUserDataCollected(userData) { [weak self] result in
      switch result {
      case .failure(let error):
        self?.viewController.show(error: error, uiConfig: self?.uiConfig)
      case .success(let user):
        self?.router.userDataCollected(user)
      }
    }
  }

  fileprivate func store(step: DataCollectorStep, handler: DataCollectorStepProtocol) {
    self.stepsDictionary[step] = handler
    if self.firstStep == nil { self.firstStep = step }
    self.lastStep = step
  }

  fileprivate func fieldsFor(step: DataCollectorStep) -> [FormRowView] {
    guard let handler = self.stepsDictionary[step] else {
      return []
    }
    return handler.rows
  }

  private func firstNonCompleteStep(from currentStep: DataCollectorStep) -> DataCollectorStep {
    let index = stepVisibility.index(of: currentStep)
    return stepVisibility[index + 1] as! DataCollectorStep // swiftlint:disable:this force_cast
  }

  fileprivate func lastNonCompleteStep(from currentStep: DataCollectorStep) -> DataCollectorStep {
    let index = stepVisibility.index(of: currentStep)
    return stepVisibility[index - 1] as! DataCollectorStep // swiftlint:disable:this force_cast
  }

  fileprivate func configureNavigationFor(step: DataCollectorStep) {
    guard let stepHandler = self.stepsDictionary[step] else {
      return
    }
    viewController.set(title: stepHandler.title)
    if step == self.firstStep {
      self.viewController.configureLeftNavButton(mode: config.backButtonMode, uiConfig: uiConfig)
      self.viewController.showNavNextButton(title: "user-data-collector.next-button.title".podLocalized(),
                                            tintColor: self.uiConfig.iconTertiaryColor)
    }
    else {
      self.viewController.showNavPreviousButton(uiConfig.iconTertiaryColor)
      self.viewController.showNavNextButton(title: "user-data-collector.next-button.title".podLocalized(),
                                            tintColor: self.uiConfig.iconTertiaryColor)
    }
    self.currentStepObserving = stepHandler.valid.removeDuplicates().observeNext { [weak self] validStep in
      if validStep {
        self?.viewController.showNavNextButton(title: "user-data-collector.next-button.title".podLocalized(),
                                               tintColor: self?.uiConfig.iconTertiaryColor)
      }
      else {
        self?.viewController.deactivateNavNextButton(self?.uiConfig.disabledTextTopPrimaryBarColor)
      }
    }
  }

  fileprivate var currentStepObserving: Disposable?

  fileprivate func unbindNavigationFromCurrentStep() {
    self.currentStepObserving?.dispose()
  }
}

private extension UserDataCollectorPresenter {

  // Step visibility calculations
  func calculateStepVisibility(userData: DataPointList,
                               mode: UserDataCollectorFinalStepMode,
                               skipSteps: Bool,
                               requiredData: RequiredDataPointList,
                               missingData: RequiredDataPointList) -> NSOrderedSet {
    let stepList: RequiredDataPointList
    if mode == .updateUser {
      // Show all the required steps
      stepList = requiredData
    }
    else {
      // Only show the missing data
      stepList = missingData
    }

    let retVal = NSMutableOrderedSet(capacity: stepList.count())
    stepList.forEach {
      for step in dataCollectorSteps(for: $0.type) {
        retVal.add(step)
      }
    }

    if skipSteps == true {
      removeCompletedSteps(from: retVal, userData: userData)
    }
    return retVal
  }

  func removeCompletedSteps(from retVal: NSMutableOrderedSet, userData: DataPointList) {
    if infoComplete(userData) {
      retVal.remove(DataCollectorStep.info)
    }
    if addressComplete(userData) {
      retVal.remove(DataCollectorStep.address)
    }
  }

  func dataCollectorSteps(for dataPointType: DataPointType) -> [DataCollectorStep] {
    switch dataPointType {
    case .personalName, .email, .phoneNumber:
      return [.info]
    case .address:
      return [.address]
    case .birthDate, .idDocument:
      return [.birthDaySSN]
    case .financialAccount:
      fatalError("Unsupported data point type financialAccount")
    }
  }

  func infoComplete(_ userData: DataPointList) -> Bool {
    return userData.nameDataPoint.complete() && userData.emailDataPoint.complete() && userData.phoneDataPoint.complete()
  }

  func addressComplete(_ userData: DataPointList) -> Bool {
    return userData.addressDataPoint.complete()
  }

  func birthdaySSNComplete(_ userData: DataPointList) -> Bool {
    return userData.birthDateDataPoint.complete() && userData.idDocumentDataPoint.complete()
  }

  func borrowerDataComplete(_ userData: DataPointList) -> Bool {
    return infoComplete(userData) && addressComplete(userData) && birthdaySSNComplete(userData)
  }
}
