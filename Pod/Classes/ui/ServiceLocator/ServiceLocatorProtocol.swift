//
//  ServiceLocatorProtocol.swift
//  AptoSDK
//
//  Created by Takeichi Kanzaki on 07/06/2018.
//
//

import UIKit

protocol ServiceLocatorProtocol: class {
  var moduleLocator: ModuleLocatorProtocol { get }
  var presenterLocator: PresenterLocatorProtocol { get }
  var interactorLocator: InteractorLocatorProtocol { get }
  var viewLocator: ViewLocatorProtocol { get }
  var systemServicesLocator: SystemServicesLocatorProtocol { get }
  var storageLocator: StorageLocatorProtocol { get }
  var networkLocator: NetworkLocatorProtocol { get }


  var platform: AptoPlatformProtocol { get }
  var uiConfig: UIConfig! { get set } // swiftlint:disable:this implicitly_unwrapped_optional
  var analyticsManager: AnalyticsServiceProtocol { get }
  var notificationHandler: NotificationHandler { get }
}
