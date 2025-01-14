//
// TwilioVoIPImpl.swift
// AptoSDK
//
// Created by Takeichi Kanzaki on 17/06/2019.
//

import UIKit
import TwilioVoice

class TwilioVoIPClient: NSObject, VoIPCallProtocol {
  private var call: TVOCall?
  private var startedAt: Date?
  private var callback: Result<Void, NSError>.Callback?

  var isMuted: Bool {
    get {
      guard let call = self.call else { return false }
      return call.isMuted
    }
    set(newValue) {
      call?.isMuted = newValue
    }
  }

  var isOnHold: Bool {
    get {
      guard let call = self.call else { return false }
      return call.isOnHold
    }
    set(newValue) {
      call?.isOnHold = newValue
    }
  }

  var timeElapsed: TimeInterval {
    guard let date = startedAt else { return 0 }
    return Date().timeIntervalSince(date)
  }

  func call(_ destination: VoIPToken, callback: @escaping Result<Void, NSError>.Callback) {
    self.callback = callback
    let connectOptions = TVOConnectOptions(accessToken: destination.accessToken) { builder in
      builder.params = ["request_token": destination.requestToken]
    }
    call = TwilioVoice.connect(with: connectOptions, delegate: self)
  }

  func sendDigits(_ digits: VoIPDigits) {
    call?.sendDigits(digits.digits)
  }

  func disconnect() {
    call?.disconnect()
    call = nil
  }
}

extension TwilioVoIPClient: TVOCallDelegate {
  func callDidConnect(_ call: TVOCall) {
    self.call = call
    self.startedAt = Date()
    callback?(.success(Void()))
    self.callback = nil
  }

  func call(_ call: TVOCall, didFailToConnectWithError error: Error) {
    self.call = nil
    callback?(.failure(error as NSError))
    self.callback = nil
  }

  func call(_ call: TVOCall, didDisconnectWithError error: Error?) {
    self.call = nil
    if let error = error as NSError? {
      callback?(.failure(error))
      self.callback = nil
    }
  }
}
