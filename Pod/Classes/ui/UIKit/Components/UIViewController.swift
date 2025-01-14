//
//  UIViewController.swift
//  AptoSDK
//
//  Created by Ivan Oliver Martínez on 13/02/16.
//
//

import Foundation
import UIKit
import SnapKit

public enum SubviewPosition {
  case topCenter
  case center
  case bottomCenter
  case custom(coordinates: CGPoint)
}

public protocol ViewControllerProtocol {
  func set(title: String)
  func showNavPreviousButton(_ tintColor: UIColor?)
  func showNavNextButton(title: String, tintColor: UIColor?)
  func showNavNextButton(icon: UIImage, tintColor: UIColor?)
  func showNavNextButton(tintColor: UIColor?)
  func hideNavNextButton()
  func showNavCancelButton(_ tintColor: UIColor?)
  func activateNavNextButton(_ tintColor: UIColor?)
  func deactivateNavNextButton(_ deactivatedTintColor: UIColor?)
  func show(error: Error, uiConfig: UIConfig?)
  func showNetworkNotReachableError(_ uiConfig: UIConfig?)
  func hideNetworkNotReachableError()
  func showServerMaintenanceError()
  func showMessage(_ message: String, uiConfig: UIConfig?)
  // swiftlint:disable:next function_parameter_count
  func show(message: String, title: String, animated: Bool, isError: Bool, uiConfig: UIConfig,
            tapHandler: (() -> Void)?)
  func showLoadingSpinner(tintColor: UIColor, position: SubviewPosition)
  func hideLoadingSpinner()
  func showLoadingView(uiConfig: UIConfig?)
  func hideLoadingView()
  func configureLeftNavButton(mode: UIViewControllerLeftButtonMode?, uiConfig: UIConfig?)
  var navigationController: UINavigationController? { get }
  func askPermissionToOpenExternalUrl(_ completion: @escaping Result<Bool, NSError>.Callback)
}

public extension ViewControllerProtocol {
  func showLoadingSpinner(tintColor: UIColor, position: SubviewPosition = .center) {
    showLoadingSpinner(tintColor: tintColor, position: position)
  }

  func showNavPreviousButton(_ tintColor: UIColor?) {
    showNavPreviousButton(tintColor)
  }

  func showNavCancelButton(_ tintColor: UIColor?) {
    showNavCancelButton(tintColor)
  }
}

extension ViewControllerProtocol where Self: ShiftViewController {
  func show(error: Error, uiConfig: UIConfig? = nil) {
    show(error: error, uiConfig: uiConfig ?? uiConfiguration)
  }

  func showMessage(_ message: String, uiConfig: UIConfig? = nil) {
    showMessage(message, uiConfig: uiConfig ?? uiConfiguration)
  }

  func show(message: String, title: String, animated: Bool = true, isError: Bool = false,
            tapHandler: (() -> Void)? = nil) {
    show(message: message, title: title, animated: animated, isError: isError, uiConfig: uiConfiguration,
         tapHandler: tapHandler)
  }
}

extension ShiftViewController {
  func show(error: Error) {
    show(error: error, uiConfig: uiConfiguration)
  }

  func showMessage(_ message: String) {
    showMessage(message, uiConfig: uiConfiguration)
  }

  func showLoadingView() {
    showLoadingView(uiConfig: uiConfiguration)
  }
}

extension UIViewController: ViewControllerProtocol {

  public func showNavPreviousButton(_ tintColor: UIColor? = nil) {
    self.installNavLeftButton(UIImage.imageFromPodBundle("top_back_default"),
                              tintColor: tintColor,
                              accessibilityLabel: "Navigation Previous Button",
                              target: self,
                              action: #selector(UIViewController.closeTapped))
  }

  public func showNavNextButton(title: String, tintColor: UIColor?) {
    self.installNavRightButton(nil,
                               tintColor: tintColor,
                               title: title,
                               accessibilityLabel: "Navigation Next Button",
                               target: self,
                               action: #selector(UIViewController.nextTapped))
  }

  public func showNavNextButton(icon: UIImage, tintColor: UIColor?) {
    self.installNavRightButton(icon,
                               tintColor: tintColor,
                               title: nil,
                               accessibilityLabel: "Navigation Next Button",
                               target: self,
                               action: #selector(UIViewController.nextTapped))
  }

  public func showNavNextButton(tintColor: UIColor?) {
    self.installNavRightButton(UIImage.imageFromPodBundle("top_next_default.png"),
                               tintColor: tintColor,
                               title: nil,
                               accessibilityLabel: "Navigation Next Button",
                               target: self,
                               action: #selector(UIViewController.nextTapped))
  }

  public func showNavCancelButton(_ tintColor: UIColor? = nil) {
    self.installNavLeftButton(UIImage.imageFromPodBundle("top_close_default"),
                              tintColor: tintColor,
                              accessibilityLabel: "Navigation Close Button",
                              target: self,
                              action: #selector(UIViewController.closeTapped))
  }

  public func showNavDummyNextButton() {
    self.installNavRightButton(nil,
                               tintColor: nil,
                               title: nil,
                               accessibilityLabel: nil,
                               target: nil,
                               action: #selector(UIViewController.nextTapped))
  }

  func installNavLeftButton(_ image: UIImage?,
                            tintColor: UIColor? = nil,
                            accessibilityLabel: String? = nil,
                            target: AnyObject?,
                            action: Selector) {
    let finalImage = tintColor != nil ? image?.asTemplate() : image
    var uiButtonItem: UIBarButtonItem
    uiButtonItem = UIBarButtonItem(
      image: finalImage,
      style: .plain,
      target: target,
      action: action)
    if let accessibilityLabel = accessibilityLabel {
      uiButtonItem.accessibilityLabel = accessibilityLabel
    }
    if tintColor != nil {
      uiButtonItem.tintColor = tintColor
    }
    navigationItem.leftBarButtonItem = uiButtonItem
  }

  func installNavRightButton(_ image: UIImage?,
                             tintColor: UIColor? = nil,
                             title: String? = nil,
                             accessibilityLabel: String? = nil,
                             target: AnyObject?,
                             action: Selector) {
    var uiButtonItem: UIBarButtonItem
    if let title = title {
      uiButtonItem = UIBarButtonItem(
        title: title,
        style: .plain,
        target: target,
        action: action)
    }
    else {
      let finalImage = tintColor != nil ? image?.asTemplate() : image
      uiButtonItem = UIBarButtonItem(
        image: finalImage,
        style: .plain,
        target: target,
        action: action)
    }
    if let accessibilityLabel = accessibilityLabel {
      uiButtonItem.accessibilityLabel = accessibilityLabel
    }
    if let tintColor = tintColor {
      uiButtonItem.tintColor = tintColor
      uiButtonItem.setTitleTextAttributes([NSAttributedString.Key.foregroundColor: tintColor.withAlphaComponent(0.4)],
                                          for: .disabled)
    }
    navigationItem.rightBarButtonItem = uiButtonItem
  }

  public func hideNavNextButton() {
    navigationItem.rightBarButtonItem = nil
  }

  func hideNavCancelButton() {
    navigationItem.leftBarButtonItem = nil
    navigationItem.hidesBackButton = true
  }

  func hideNavPreviousButton() {
    navigationItem.leftBarButtonItem = nil
    navigationItem.hidesBackButton = true
  }

  func hideNavBarBackButton() {
    self.navigationItem.leftBarButtonItem = nil
    navigationItem.hidesBackButton = true
  }

  func showNavBarBackButton() {
    self.navigationItem.hidesBackButton = false
  }

  public func deactivateNavNextButton(_ deactivatedTintColor: UIColor?) {
    navigationItem.rightBarButtonItem?.isEnabled = false
    if deactivatedTintColor != nil {
      navigationItem.rightBarButtonItem?.tintColor = deactivatedTintColor
    }
  }

  public func activateNavNextButton(_ tintColor: UIColor?) {
    navigationItem.rightBarButtonItem?.isEnabled = true
    if tintColor != nil {
      navigationItem.rightBarButtonItem?.tintColor = tintColor
    }
  }

  public func show(error: Error, uiConfig: UIConfig?) {
    self.hideLoadingSpinner()
    let backgroundColor = uiConfig?.uiErrorColor ?? UIColor.colorFromHex(0xDC4337)
    let font = uiConfig?.fontProvider.mainItemRegularFont
    let textColor = uiConfig?.textMessageColor
    let toast = Toast(text: error.localizedDescription, textAlignment: .left, backgroundColor: backgroundColor,
                      textColor: textColor, font: font, duration: 5, minimumHeight: 100, style: .bottomToTop)
    present(toast, animated: true)
  }

  public func showNetworkNotReachableError(_ uiConfig: UIConfig?) {
    let viewController = NetworkNotReachableErrorViewControllerTheme2(uiConfig: uiConfig)
    present(viewController, animated: true)
  }

  public func hideNetworkNotReachableError() {
    dismiss(animated: true)
  }

  public func showServerMaintenanceError() {
    let serviceLocator = ServiceLocator.shared
    let module = serviceLocator.moduleLocator.serverMaintenanceErrorModule()
    module.initialize { [weak self] result in
      guard let self = self else { return }
      switch result {
      case .failure(let error):
        self.show(error: error, uiConfig: serviceLocator.uiConfig )
      case .success(let viewController):
        self.present(viewController, animated: true)
      }
    }
    module.onClose = { _ in
      UIApplication.topViewController()?.dismiss(animated: false)
    }
  }

  public func showMessage(_ message: String, uiConfig: UIConfig?) {
    let backgroundColor = uiConfig?.uiSuccessColor ?? UIColor.colorFromHex(0xDC4337)
    let font = uiConfig?.fontProvider.mainItemRegularFont
    let textColor = uiConfig?.textMessageColor
    let toast = Toast(text: message, textAlignment: .left, backgroundColor: backgroundColor, textColor: textColor,
                      font: font, duration: 5, minimumHeight: 100, style: .bottomToTop)
    present(toast, animated: true)
  }

  public func show(message: String, title: String, animated: Bool = true, isError: Bool = false, uiConfig: UIConfig,
                   tapHandler: (() -> Void)?) {
    let toastView = TitleSubtitleToastView(uiConfig: uiConfig)
    let backgroundColor = isError ? uiConfig.uiErrorColor : uiConfig.uiPrimaryColor
    let toast = TitleSubtitleToast(title: uiConfig.showToastTitle ? title : nil, message: message,
                                   backgroundColor: backgroundColor, duration: tapHandler == nil ? 5 : nil,
                                   delegate: toastView)
    toastView.tapHandler = tapHandler
    present(toast, withCustomToastView: toastView, animated: animated)
  }

  public func showLoadingSpinner(tintColor: UIColor, position: SubviewPosition) {
    let activityIndicator = UIActivityIndicatorView(style: .white)
    activityIndicator.color = tintColor
    addSubview(activityIndicator, at: position)
    activityIndicator.startAnimating()
  }

  private func addSubview(_ subview: UIView, at position: SubviewPosition) {
    let container = UIView()
    container.backgroundColor = .clear
    view.addSubview(container)
    switch position {
    case .topCenter:
      container.snp.makeConstraints { make in
        make.left.top.right.equalToSuperview()
        make.height.equalToSuperview().dividedBy(3.0)
      }
    case .center:
      container.snp.makeConstraints { make in
        make.center.equalToSuperview()
      }
    case .bottomCenter:
      container.snp.makeConstraints { make in
        make.left.bottom.right.equalToSuperview()
        make.height.equalToSuperview().dividedBy(3.0)
      }
    case .custom(let coordinates):
      container.snp.makeConstraints { make in
        make.centerX.equalTo(coordinates.x)
        make.centerY.equalTo(coordinates.y)
      }
    }
    container.addSubview(subview)
    subview.snp.makeConstraints { make in
      make.center.equalToSuperview()
    }
  }

  public func hideLoadingSpinner() {
    for subview in view.subviews.reversed() {
      // The spinner is inside a container
      if subview.subviews.first is UIActivityIndicatorView { // swiftlint:disable:this for_where
        subview.removeFromSuperview()
        return
      }
    }
  }
 
  public func showLoadingView(uiConfig: UIConfig?) {
    let tag = 2020
    let loadingViewAlreadyShowing = UIApplication.shared.keyWindow?.subviews.first(where: { $0.tag == tag }) != nil
    guard !loadingViewAlreadyShowing else { return }
    
    if let window = UIApplication.shared.keyWindow {
      let loadingView = UIView(frame: .zero)
      loadingView.tag = tag
      loadingView.backgroundColor = view.backgroundColor?.withAlphaComponent(0.9)
      let activityIndicator = UIActivityIndicatorView(style: .white)
      activityIndicator.color = uiConfig?.uiPrimaryColor ?? .gray
      loadingView.addSubview(activityIndicator)
      loadingView.alpha = 0
      
      activityIndicator.snp.makeConstraints { make in
        make.center.equalToSuperview()
      }
      window.addSubview(loadingView)
      loadingView.snp.makeConstraints { make in
        make.edges.equalToSuperview()
      }
      
      UIView.animate(withDuration: 0.3) {
        activityIndicator.startAnimating()
        loadingView.alpha = 1
      }
    }
  }

  public func hideLoadingView() {
    if let window = UIApplication.shared.keyWindow {
      for subview in window.subviews.reversed() {
        // The spinner is inside a container
        if subview.subviews.first is UIActivityIndicatorView { // swiftlint:disable:this for_where

          UIView.animate(withDuration: 0.3, animations: {
            subview.alpha = 0
          }) { _ in
            subview.removeFromSuperview()
          }
          return
        }
      }
    }
  }

  public func set(title: String) {
    self.title = title
  }

  @objc func nextTapped() {
    // To be overriden in child classes
  }

  @objc func closeTapped() {
    // To be overriden in child classes
  }

  func setNavigationBar(tintColor: UIColor) {
    guard let navigationController = self.navigationController else {
      return
    }
    let textAttributes = [NSAttributedString.Key.foregroundColor: tintColor]
    navigationController.navigationBar.titleTextAttributes = textAttributes
    navigationController.navigationBar.tintColor = tintColor
  }

  public func askPermissionToOpenExternalUrl(_ completion: @escaping Result<Bool, NSError>.Callback) {
    let optionMenu = UIAlertController(title: nil,
                                       message: "offer-list.continue-application-in-web-browser".podLocalized(),
                                       preferredStyle: .alert)
    let okAction = UIAlertAction(title: "alert-controller.button.yes".podLocalized(),
                                 style: .default) { _ in
      completion(.success(true))
    }
    optionMenu.addAction(okAction)
    let cancelAction = UIAlertAction(title: "alert-controller.button.no".podLocalized(),
                                     style: .cancel) { _ in
      completion(.success(false))
    }
    optionMenu.addAction(cancelAction)
    present(optionMenu, animated: true, completion: nil)
  }

  public var edgesConstraint: ConstraintItem {
    if #available(iOS 11, *) {
      return view.safeAreaLayoutGuide.snp.edges
    }
    return view.snp.edges
  }
}

public enum UIViewControllerLeftButtonMode {
  case none
  case back
  case close
}

enum UIViewControllerPresentationMode {
  case push
  case modal
}
