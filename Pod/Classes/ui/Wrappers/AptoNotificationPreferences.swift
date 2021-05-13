//
//  AptoNotificationPreferences.swift
//  AptoSDK
//
//  Created by Takeichi Kanzaki on 24/07/2019.
//

import Foundation
import AptoSDK

@objc public enum AptoNotificationGroupId: Int {
  case paymentSuccessful
  case paymentDeclined
  case atmWithdrawal
  case incomingTransfer
  case cardStatus
  case legal

  init(from groupId: NotificationGroup.GroupId) {
    switch groupId {
    case .paymentSuccessful: self = .paymentSuccessful
    case .paymentDeclined: self = .paymentDeclined
    case .atmWithdrawal: self = .atmWithdrawal
    case .incomingTransfer: self = .incomingTransfer
    case .cardStatus: self = .cardStatus
    case .legal: self = .legal
    }
  }

  var swiftVersion: NotificationGroup.GroupId {
    switch self {
    case .paymentSuccessful: return .paymentSuccessful
    case .paymentDeclined: return .paymentDeclined
    case .atmWithdrawal: return .atmWithdrawal
    case .incomingTransfer: return .incomingTransfer
    case .cardStatus: return .cardStatus
    case .legal: return .legal
    }
  }
}

@objc public enum AptoNotificationGroupCategory: Int {
  case cardActivity
  case cardStatus
  case legal

  init(from category: NotificationGroup.Category) {
    switch category {
    case .cardActivity: self = .cardActivity
    case .cardStatus: self = .cardStatus
    case .legal: self = .legal
    }
  }

  var swiftVersion: NotificationGroup.Category {
    switch self {
    case .cardActivity: return .cardActivity
    case .cardStatus: return .cardStatus
    case .legal: return .legal
    }
  }
}

@objc public enum AptoNotificationGroupState: Int {
  case enabled
  case disabled

  init(from groupState: NotificationGroup.State) {
    switch groupState {
    case .enabled: self = .enabled
    case .disabled: self = .disabled
    }
  }

  var swiftVersion: NotificationGroup.State {
    switch self {
    case .enabled: return .enabled
    case .disabled: return .disabled
    }
  }
}

@objc public class AptoNotificationGroupChannel: NSObject {
  public var push: Bool?
  public var email: Bool?
  public var sms: Bool?

  init(from channel: NotificationGroup.Channel) {
    self.push = channel.push
    self.email = channel.email
    self.sms = channel.sms
  }

  var swiftVersion: NotificationGroup.Channel {
    return NotificationGroup.Channel(push: push, email: email, sms: sms)
  }
}

@objc public class AptoNotificationGroup: NSObject {
  public let groupId: AptoNotificationGroupId
  public let category: AptoNotificationGroupCategory
  public let state: AptoNotificationGroupState
  public let channel: AptoNotificationGroupChannel

  init(from group: NotificationGroup) {
    self.groupId = AptoNotificationGroupId(from: group.groupId)
    self.category = AptoNotificationGroupCategory(from: group.category)
    self.state = AptoNotificationGroupState(from: group.state)
    self.channel = AptoNotificationGroupChannel(from: group.channel)
  }

  var swiftVersion: NotificationGroup {
    return NotificationGroup(groupId: groupId.swiftVersion, category: category.swiftVersion, state: state.swiftVersion,
                             channel: channel.swiftVersion)
  }
}

@objc public class AptoNotificationPreferences: NSObject {
  public let preferences: [AptoNotificationGroup]

  init(from preferences: NotificationPreferences) {
    self.preferences = preferences.preferences.map { AptoNotificationGroup(from: $0) }
  }

  var swiftVersion: NotificationPreferences {
    return NotificationPreferences(preferences: preferences.map { $0.swiftVersion })
  }
}
