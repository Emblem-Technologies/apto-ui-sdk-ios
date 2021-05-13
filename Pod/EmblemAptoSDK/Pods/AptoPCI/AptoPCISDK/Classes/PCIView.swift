//
// PCIView.swift
// AptoPCISDK
//
// Created by Ivan Oliver on 15/11/2018.
//

import UIKit
import WebKit

protocol PCIDataAction {
    func showPCIData()
    func hidePCIData()
}

public class PCIView: UIView, WKNavigationDelegate, WKUIDelegate, PCIDataAction {
  let webView = WKWebView(frame: .zero, configuration: WKWebViewConfiguration())
  var queue = OperationQueue()
  private let javascriptPrefix = "window.AptoPCISdk"
  @objc public var alertTexts: [String: String]?

    private(set) var isDialogShown = false
    
  override init(frame: CGRect) {
    super.init(frame: frame)
    initQueue()
    initWebView()
  }

  required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
    initQueue()
    initWebView()
  }

  @objc public func initialise(config: PCIConfig) {
    let jsonData = try! JSONEncoder().encode(config)
    let jsonString = String(data: jsonData, encoding: .utf8)!
    sendActionToJs(action: "\(javascriptPrefix).init(\(jsonString))")
  }

  @objc public func setTheme(theme: String) {
    sendActionToJs(action: "\(javascriptPrefix).setTheme('\(theme)')")
  }

  @objc public func setStyle(style: PCIConfigStyle) {
    sendActionToJs(action: "\(javascriptPrefix).setStyle(\(style.configString()))")
  }

  @objc public func showPCIData() {
    sendActionToJs(action: "\(javascriptPrefix).showPCIData()")
  }

  @objc public func hidePCIData() {
    if !isDialogShown {
        sendActionToJs(action: "\(javascriptPrefix).hidePCIData()")
    }
  }

  private func sendActionToJs(action: String) {
    queue.addOperation(WebViewOperation(
      webView: webView,
      javascript: action
    ))
  }
}

internal class WebViewOperation: Operation {
  let javascript: String
  let webView: WKWebView
  let dispatchQueue: DispatchQueue

  init(webView: WKWebView, javascript: String, on: DispatchQueue? = nil) {
    self.javascript = javascript
    self.webView = webView
    self.dispatchQueue = on ?? DispatchQueue.main
  }

  override func main() {
    dispatchQueue.async {
      self.webView.evaluateJavaScript(self.javascript)
    }
  }
}

extension PCIView: UIScrollViewDelegate {
  public func scrollViewWillBeginZooming(_ scrollView: UIScrollView, with view: UIView?) {
    scrollView.pinchGestureRecognizer?.isEnabled = false
  }
}

private extension PCIView {

  private func dictToString(dict: [String: Any]) -> String? {
    if let data = try? JSONSerialization.data(withJSONObject: dict, options: []) {
      return String(data: data, encoding: .utf8)
    }
    return nil
  }

  private func initQueue() {
    queue.name = "PCIView operations queue"
    queue.maxConcurrentOperationCount = 1
    queue.isSuspended = true
  }

  private func initWebView(){
    webView.translatesAutoresizingMaskIntoConstraints = false
    addSubview(webView)
    webView.isOpaque = false
    webView.backgroundColor = .clear
    webView.scrollView.backgroundColor = .clear
    webView.scrollView.isScrollEnabled = false
    webView.isUserInteractionEnabled = false
    NSLayoutConstraint.activate([
      webView.topAnchor.constraint(equalTo: self.topAnchor),
      webView.leftAnchor.constraint(equalTo: self.leftAnchor),
      webView.rightAnchor.constraint(equalTo: self.rightAnchor),
      webView.bottomAnchor.constraint(equalTo: self.bottomAnchor)
    ])
    webView.navigationDelegate = self
    webView.scrollView.delegate = self
    webView.uiDelegate = self
    let podBundle = Bundle(for: self.classForCoder)
    if let myURL = podBundle.url(forResource: "container", withExtension: "html") {
      webView.loadFileURL(myURL, allowingReadAccessTo: myURL.deletingLastPathComponent())
    }
  }
}

public extension PCIView {
  func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
    queue.isSuspended = false
  }

    func webView(_ webView: WKWebView, runJavaScriptAlertPanelWithMessage message: String,
                 initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping () -> Void) {
        let alertController = UIAlertController(title: nil, message: alertText(key: "wrongCode.message"), preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: alertText(key: "wrongCode.okAction"), style: .default, handler: { [weak self] action in
            completionHandler()
            self?.isDialogShown = false
        }))
        
        findViewController()?.present(alertController, animated: true, completion: { [weak self] in
            self?.isDialogShown = true
        })
    }
    
    func webView(_ webView: WKWebView, runJavaScriptTextInputPanelWithPrompt prompt: String, defaultText: String?,
                 initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping (String?) -> Void) {
        let alertController = UIAlertController(title: nil, message: alertText(key: "inputCode.message"), preferredStyle: .alert)
        alertController.addTextField(configurationHandler: { textField in
            textField.text = defaultText
            if #available(iOS 12.0, *) {
                textField.textContentType = .oneTimeCode
            }
        })
        
        alertController.addAction(UIAlertAction(title: alertText(key: "inputCode.okAction"), style: .default, handler: { [weak self] action in
            if let text = alertController.textFields?.first?.text {
                completionHandler(text)
            } else {
                completionHandler(defaultText)
            }
            self?.isDialogShown = false
        }))
        
        alertController.addAction(UIAlertAction(title: alertText(key: "inputCode.cancelAction"), style: .default, handler: { [weak self] action in
            completionHandler(nil)
            self?.isDialogShown = false
        }))
        
        findViewController()?.present(alertController, animated: true, completion: { [weak self] in
            self?.isDialogShown = true
        })
    }

  private func alertText(key: String) -> String {
    if let text = alertTexts?[key] {
      return text
    } else {
      return key.podLocalized()
    }
  }
}

private extension String {
  func podLocalized() -> String {
    return self.podLocalized(PCIView.classForCoder())
  }

  func podLocalized(_ bundleClass:AnyClass) -> String {
    return getBundleTranslation(Bundle(for:bundleClass))
  }

  func getBundleTranslation(_ bundle:Bundle) -> String {
    var language =  Locale.preferredLanguages[0].lowercased()
    let path = bundle.path(forResource: language, ofType: "lproj")
    if let path = path, let languageBundle = Bundle(path: path) {
      return NSLocalizedString(self, bundle: languageBundle, comment: "")
    }
    else {
      // Try with just the language without region
      language = language.prefixUntil("-")
      let path = bundle.path(forResource: language, ofType: "lproj")
      if let path = path, let languageBundle = Bundle(path: path) {
        return NSLocalizedString(self, bundle: languageBundle, comment: "")
      }
      else {
        // Fall back to the user's language
        return NSLocalizedString(self, bundle: bundle, comment: "")
      }
    }
  }

  func prefixUntil(_ string:String) -> String {
    if let range = self.range(of: string) {
      let intIndex: Int = self.distance(from: self.startIndex, to: range.lowerBound)
      return self.prefixOf(intIndex)!
    }
    return self
  }

  func prefixOf(_ size:Int) -> String? {
    return String(self.prefix(size))
  }
}

extension UIView {
  func findViewController() -> UIViewController? {
    if let nextResponder = self.next as? UIViewController {
      return nextResponder
    } else if let nextResponder = self.next as? UIView {
      return nextResponder.findViewController()
    } else {
      return nil
    }
  }
}

public class PCIConfig: NSObject, Codable {
  let configAuth: PCIConfigAuth
  let theme: String?
  let configCard: PCIConfigCard?
  public init(configAuth: PCIConfigAuth, configCard: PCIConfigCard?, theme: String? = nil) {
    self.configAuth = configAuth
    self.configCard = configCard
    self.theme = theme
  }
  enum CodingKeys: String, CodingKey {
    case configAuth = "auth"
    case theme
    case configCard = "values"
  }
}

public class PCIConfigAuth: NSObject, Codable {
  let cardId: String
  let apiKey: String
  let userToken: String
  let environment: PCIEnvironment
  public init(cardId: String, apiKey: String, userToken: String, environment: PCIEnvironment) {
    self.cardId = cardId
    self.apiKey = apiKey
    self.userToken = userToken
    self.environment = environment
  }
  enum CodingKeys: String, CodingKey {
    case cardId
    case apiKey
    case userToken
    case environment
  }
}

public enum PCIEnvironment: String, Codable {
  case stg
  case sbx
  case prd
}

public class PCIConfigCard: Codable {
  let lastFour: String?
  let labelPan: String?
  let labelCvv: String?
  let labelExp: String?
  let labelName: String?
  let nameOnCard: String?
  public init(lastFour: String? = nil, labelPan: String? = nil, labelCvv: String? = nil, labelExp: String? = nil, labelName: String? = nil, nameOnCard: String? = nil) {
    self.lastFour = lastFour
    self.labelPan = labelPan
    self.labelCvv = labelCvv
    self.labelExp = labelExp
    self.labelName = labelName
    self.nameOnCard = nameOnCard
  }
}

public class PCIConfigStyle: NSObject {
  let textColor: String?
  public init(textColor: String?) {
    self.textColor = textColor
  }
  public func configString() -> String {
    let styledParameters = StyleParameters(extends: "dark", container: StyleParameters.ContainerStyle(color: textColor))
    let jsonData = try! JSONEncoder().encode(styledParameters)
    return String(data: jsonData, encoding: .utf8)!
  }
  struct StyleParameters: Codable {
    let extends: String
    let container: ContainerStyle
    struct ContainerStyle: Codable {
      let color: String?
    }
  }
}
