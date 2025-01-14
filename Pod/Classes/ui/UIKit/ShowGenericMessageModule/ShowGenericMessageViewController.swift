//
//  ShowGenericMessageViewController.swift
//  AptoSDK
//
//  Created by Ivan Oliver Martínez on 17/02/16.
//
//

import UIKit
import UIKit
import TTTAttributedLabel
import WebKit

protocol ShowGenericMessageEventHandler {
  func viewLoaded()
  func callToActionTapped()
  func secondaryCallToActionTapped()
  func closeTapped()
  func linkTapped(_ url: URL)
}

class ShowGenericMessageViewController: ShiftViewController, ShowGenericMessageViewProtocol {

  var eventHandler: ShowGenericMessageEventHandler
  fileprivate var logoImageView: UIImageView!
  fileprivate let webView = WKWebView()
  fileprivate var callToActionButton: UIButton! // swiftlint:disable:this implicitly_unwrapped_optional

  init(uiConfiguration: UIConfig, eventHandler: ShowGenericMessageEventHandler) {
    self.eventHandler = eventHandler
    super.init(uiConfiguration: uiConfiguration)
  }

  required init?(coder aDecoder: NSCoder) {
      fatalError("init(coder:) has not been implemented")
  }

  override func viewDidLoad() {
    super.viewDidLoad()
    self.view.backgroundColor = UIColor.white
    self.title = "disclaimer.title".podLocalized()
    self.showNavCancelButton(self.uiConfiguration.iconTertiaryColor)

    self.webView.isHidden = true
    self.webView.backgroundColor = UIColor.white
    view.addSubview(webView)
    self.webView.snp.makeConstraints { make in
      make.top.equalTo(view).offset(10)
      make.left.right.equalTo(view).inset(10)
    }

    self.callToActionButton = UIButton.roundedButtonWith(
      "disclaimer.button.find-loan".podLocalized(),
      backgroundColor: uiConfiguration.tintColor,
      accessibilityLabel: "Find a Loan Button") { self.eventHandler.callToActionTapped() }
    view.addSubview(callToActionButton)
    callToActionButton.snp.makeConstraints { make in
      make.top.equalTo(webView.snp.bottom).offset(20)
      make.left.right.equalTo(view).inset(20)
      make.height.equalTo(44)
      make.bottom.equalTo(view).offset(-20)
    }

    self.edgesForExtendedLayout = .top
    self.extendedLayoutIncludesOpaqueBars = true

    self.eventHandler.viewLoaded()
  }

  func set(title: String, logo: String?, content: Content?, callToAction: CallToAction?) {
    self.title = title

    if let text = content?.htmlString(font: self.uiConfiguration.fontProvider.timestampFont,
                                      color: self.uiConfiguration.noteTextColor,
                                      linkColor: self.uiConfiguration.tintColor) {
      let markdownStyle =
"""
body { font-family: '-apple-system','HelveticaNeue'; font-size:14; }
h1 { font-size:18; }
h2 { font-size:16; }
"""
      let htmlDoc =
"""
<html>
<head>
  <style>\(markdownStyle)</style>
</head>
<body>
  \(text)
</body>
</html>
"""
      webView.loadHTMLString(htmlDoc, baseURL: nil)
      webView.isHidden = false
    }
    else {
      webView.isHidden = true
    }

    if let callToAction = callToAction {
      callToActionButton.setTitle(callToAction.title, for: .normal)
      callToActionButton.isHidden = false
    }
    else {
      callToActionButton.isHidden = true
    }

  }

  override func closeTapped() {
    self.eventHandler.closeTapped()
  }
}

extension ShowGenericMessageViewController: TTTAttributedLabelDelegate {
  // swiftlint:disable:next implicitly_unwrapped_optional
  func attributedLabel(_ label: TTTAttributedLabel!, didSelectLinkWith url: URL!) {
    self.eventHandler.linkTapped(url)
  }
}
