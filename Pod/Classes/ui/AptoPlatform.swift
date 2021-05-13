//
//  AptoPlatform.swift
//  AptoSDK
//
//  Created by Takeichi Kanzaki on 18/01/16.
//

import Foundation
import AptoSDK

public extension AptoPlatform {
  @objc(initializeWith:environment:setupCertPinning:)
  func initializeWithApiKey(_ apiKey: String, environment: AptoPlatformEnvironment, setupCertPinning: Bool) {
    initializeWithApiKey(apiKey, environment: environment, setupCertPinning: setupCertPinning)
  }

  @objc(initializeWith:environment:)
  func initializeWithApiKey(_ apiKey: String, environment: AptoPlatformEnvironment) {
    initializeWithApiKey(apiKey, environment: environment)
  }

  @objc(initializeWith:)
  func initializeWithApiKey(_ apiKey: String) {
    initializeWithApiKey(apiKey)
  }

  @objc(startPhoneVerification:completion:)
  func startPhoneVerification(_ phone: PhoneNumber,
                              callback: @escaping (_ verification: Verification?, _ error: NSError?) -> Void) {
    startPhoneVerification(phone) { result in
      switch result {
      case .failure(let error):
        callback(nil, error)
      case .success(let verification):
        callback(verification, nil)
      }
    }
  }

  @objc(startEmailVerification:completion:)
  func startEmailVerification(_ email: Email,
                              callback: @escaping (_ verification: Verification?, _ error: NSError?) -> Void) {
    startEmailVerification(email) { result in
      switch result {
      case .failure(let error):
        callback(nil, error)
      case .success(let verification):
        callback(verification, nil)
      }
    }
  }

  @objc(startBirthDateVerification:completion:)
  func startBirthDateVerification(_ birthDate: BirthDate,
                                  callback: @escaping (_ verification: Verification?, _ error: NSError?) -> Void) {
    startBirthDateVerification(birthDate) { result in
      switch result {
      case .failure(let error):
        callback(nil, error)
      case .success(let verification):
        callback(verification, nil)
      }
    }
  }

  @objc(fetchVerificationStatus:completion:)
  func fetchVerificationStatus(_ verification: Verification,
                               callback: @escaping (_ verification: Verification?, _ error: NSError?) -> Void) {
    fetchVerificationStatus(verification) { result in
      switch result {
      case .failure(let error):
        callback(nil, error)
      case .success(let verification):
        callback(verification, nil)
      }
    }
  }

  @objc(restartVerification:completion:)
  func restartVerification(_ verification: Verification,
                           callback: @escaping (_ verification: Verification?, _ error: NSError?) -> Void) {
    restartVerification(verification) { result in
      switch result {
      case .failure(let error):
        callback(nil, error)
      case .success(let verification):
        callback(verification, nil)
      }
    }
  }

  @objc(completeVerification:completion:)
  func completeVerification(_ verification: Verification,
                            callback: @escaping (_ verification: Verification?, _ error: NSError?) -> Void) {
    completeVerification(verification) { result in
      switch result {
      case .failure(let error):
        callback(nil, error)
      case .success(let verification):
        callback(verification, nil)
      }
    }
  }

  @objc(createUserWithData:custodianUid:completion:)
  func createUser(userData: DataPointList, custodianUid: String?, callback: @escaping (_ user: ShiftUser?, _ error: NSError?) -> Void) {
    createUser(userData: userData, custodianUid: custodianUid) { result in
      switch result {
      case .failure(let error):
        callback(nil, error)
      case .success(let user):
        callback(user, nil)
      }
    }
  }

  @objc(issueCardWith:custodian:additionalFields:completion:)
  func issueCard(cardProduct: AptoCardProduct, custodian: Custodian?, additionalFields: [String: AnyObject]?,
                 callback: @escaping (_ card: Card?, _ error: NSError?) -> Void) {
    issueCard(cardProduct: cardProduct.swiftVersion, custodian: custodian,
              additionalFields: additionalFields) { result in
      switch result {
      case .failure(let error):
        callback(nil, error)
      case .success(let card):
        callback(card, nil)
      }
    }
  }

  @objc(updateUserInfoWith:completion:)
  func updateUserInfo(_ userData: DataPointList, callback: @escaping (_ user: ShiftUser?, _ error: NSError?) -> Void) {
    updateUserInfo(userData) { result in
      switch result {
      case .failure(let error):
        callback(nil, error)
      case .success(let user):
        callback(user, nil)
      }
    }
  }

  @objc(loginUserWith:completion:)
  func loginUserWith(verifications: [Verification],
                     callback: @escaping (_ user: ShiftUser?, _ error: NSError?) -> Void) {
    loginUserWith(verifications: verifications) { result in
      switch result {
      case .failure(let error):
        callback(nil, error)
      case .success(let user):
        callback(user, nil)
      }
    }
  }

  @objc func logout() {
    logout()
  }

  @objc(fetchCardsWithCompletion:)
  func fetchCards(callback: @escaping (_ cards: [Card]?, _ error: NSError?) -> Void) {
    fetchCards(page: 0, rows: 100) { result in
      switch result {
      case .failure(let error):
        callback(nil, error)
      case .success(let cards):
        callback(cards, nil)
      }
    }
  }

  @objc(activatePhysicalCard:code:completion:)
  func activatePhysicalCard(_ cardId: String, code: String,
                            callback: @escaping (_ result: AptoPhysicalCardActivationResult?, _ error: NSError?) -> Void) {
    activatePhysicalCard(cardId, code: code) { result in
      switch result {
      case .failure(let error):
        callback(nil, error)
      case .success(let activationResult):
        callback(AptoPhysicalCardActivationResult(from: activationResult), nil)
      }
    }
  }

  @objc(changeCard:pin:completion:)
  func changeCard(_ cardId: String, pin: String, callback: @escaping (_ card: Card?, _ error: NSError?) -> Void) {
    changeCardPIN(cardId, pin: pin) { result in
      switch result {
      case .failure(let error):
        callback(nil, error)
      case .success(let card):
        callback(card, nil)
      }
    }
  }

  @objc(lockCard:completion:)
  func lockCard(_ cardId: String, callback: @escaping (_ card: Card?, _ error: NSError?) -> Void) {
    lockCard(cardId) { result in
      switch result {
      case .failure(let error):
        callback(nil, error)
      case .success(let card):
        callback(card, nil)
      }
    }
  }

  @objc(unlockCard:completion:)
  func unlockCard(_ cardId: String, callback: @escaping (_ card: Card?, _ error: NSError?) -> Void) {
    unlockCard(cardId) { result in
      switch result {
      case .failure(let error):
        callback(nil, error)
      case .success(let card):
        callback(card, nil)
      }
    }
  }

  @objc(fetchCardFundingSources:forceRefresh:completion:)
  func fetchCardFundingSources(_ cardId: String, forceRefresh: Bool,
                               callback: @escaping (_ sources: [FundingSource]?, _ error: NSError?) -> Void) {
    fetchCardFundingSources(cardId, page: nil, rows: nil, forceRefresh: forceRefresh) { result in
      switch result {
      case .failure(let error):
        callback(nil, error)
      case .success(let fundingSources):
        callback(fundingSources, nil)
      }
    }
  }

  @objc(fetchCardFundingSource:forceRefresh:completion:)
  func fetchCardFundingSource(_ cardId: String, forceRefresh: Bool,
                              callback: @escaping (_ fundingSource: FundingSource?, _ error: NSError?) -> Void) {
    fetchCardFundingSource(cardId) { result in
      switch result {
      case .failure(let error):
        callback(nil, error)
      case .success(let fundingSource):
        callback(fundingSource, nil)
      }
    }
  }

  @objc(cardMonthlySpending:date:completion:)
  func cardMonthlySpending(_ cardId: String, date: Date,
                           callback: @escaping (_ spending: AptoMonthlySpending?, _ error: NSError?) -> Void) {
    cardMonthlySpending(cardId, date: date) { result in
      switch result {
      case .failure(let error):
        callback(nil, error)
      case .success(let spending):
        callback(AptoMonthlySpending(from: spending, date: date), nil)
      }
    }
  }

  @objc(fetchNotificationPreferencesWithCompletion:)
  func fetchNotificationPreferences(callback: @escaping (_ preferences: AptoNotificationPreferences?, _ error: NSError?) -> Void) {
    fetchNotificationPreferences { result in
      switch result {
      case .failure(let error):
        callback(nil, error)
      case .success(let preferences):
        callback(AptoNotificationPreferences(from: preferences), nil)
      }
    }
  }

  @objc(updateNotificationPreferences:completion:)
  func updateNotificationPreferences(_ preferences: AptoNotificationPreferences,
                                     callback: @escaping (_ preferences: AptoNotificationPreferences?, _ error: NSError?) -> Void) {
    updateNotificationPreferences(preferences.swiftVersion) { result in
      switch result {
      case .failure(let error):
        callback(nil, error)
      case .success(let preferences):
        callback(AptoNotificationPreferences(from: preferences), nil)
      }
    }
  }

  @objc(fetchCardTransactions:filters:forceRefresh:completion:)
  func fetchCardTransactions(_ cardId: String, filters: AptoTransactionListFilters, forceRefresh: Bool,
                             callback: @escaping (_ transactions: [Transaction]?, _ error: NSError?) -> Void) {
    fetchCardTransactions(cardId, filters: filters.swiftVersion, forceRefresh: forceRefresh) { result in
      switch result {
      case .failure(let error):
        callback(nil, error)
      case .success(let transactions):
        callback(transactions, nil)
      }
    }
  }
}
