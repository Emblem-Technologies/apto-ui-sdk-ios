//
//  String.swift
//  AptoSDK
//
//  Created by Ivan Oliver Martínez on 30/03/16.
//
//

import Foundation
import UIKit
import CommonCrypto

extension String {

  func urlsIn() -> [URL] {
    // swiftlint:disable:next force_try
    let detector = try! NSDataDetector(types: NSTextCheckingResult.CheckingType.link.rawValue)
    let matches = detector.matches(in: self, options: [], range: NSRange(location: 0, length: self.count))
    var retVal: [URL] = []
    for match in matches {
      let urlString = (self as NSString).substring(with: match.range)
      if let url = URL(string: urlString) {
        retVal.append(url)
      }
    }
    return retVal
  }

  func insert(_ string: String, ind: Int) -> String {
    return String(self.prefix(ind)) + string + String(self.suffix(self.count - ind))
  }

  public func formattedHtmlString(font: UIFont,
                                  color: UIColor,
                                  linkColor: UIColor,
                                  lineSpacing: CGFloat = 0) -> NSMutableAttributedString? {
    let htmlData = self.data(using: String.Encoding.utf8)
    guard let data = htmlData else {
      return nil
    }
    let options = [
      NSAttributedString.DocumentReadingOptionKey.documentType: NSAttributedString.DocumentType.html as Any
    ]
    do {
      let attrString = try NSAttributedString(data: data, options: options,
                                              documentAttributes: nil).mutableCopy() as? NSMutableAttributedString
      attrString?.replacePlainTextStyle(font: font, color: color, lineSpacing: lineSpacing)
      attrString?.replaceLinkStyle(font: font, color: linkColor, lineSpacing: lineSpacing)
      return attrString
    }
    catch {
      return nil
    }
  }

  public func localized() -> String {
    return getBundleTranslation(Bundle.main)
  }

  public func podLocalized() -> String {
    if let retVal = StringLocalizationStorage.shared.localizedString(for: self) {
      return retVal
    }
    return self.podLocalized(AptoPlatform.classForCoder())
  }

  func podLocalized(_ bundleClass: AnyClass) -> String {
    return getBundleTranslation(Bundle(for: bundleClass))
  }

  fileprivate func getBundleTranslation(_ bundle: Bundle) -> String {
    var language = LocalLanguage.language.lowercased()
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

  public func replace(_ occurrences: [String: String]) -> String {
    var retVal = self
    for (key, value) in occurrences {
      retVal = retVal.replacingOccurrences(of: key, with: value)
    }
    return retVal
  }

  public func prefixOf(_ size: Int) -> String? {
    return String(self.prefix(size))
  }

  func suffixOf(_ size: Int) -> String? {
    return String(self.suffix(size))
  }

  func prefixUntil(_ string: String) -> String {
    if let range = self.range(of: string) {
      let intIndex: Int = self.distance(from: self.startIndex, to: range.lowerBound)
      if let prefix = self.prefixOf(intIndex) {
        return prefix
      }
    }
    return self
  }

  func startsWith(_ string: String) -> Bool {
    return self.prefixOf(string.count) == string
  }

  public func endsWith(_ string: String) -> Bool {
    return self.suffixOf(string.count) == string
  }

  func countCharactersNotIn(characterSet: CharacterSet, untilIndex: Int) -> Int {
    var count = 0
    var currentIndex = 0
    for uni in unicodeScalars {
      if currentIndex > untilIndex {
        return count
      }
      if !(characterSet.contains(uni)) {
        count += 1
      }
      currentIndex += 1
    }
    return count
  }
}

extension String {
  var md5: String? {
    guard let data = self.data(using: .utf8) else { return nil }

    let hash = data.withUnsafeBytes { (bytes: UnsafePointer<Data>) -> [UInt8] in
      var hash: [UInt8] = [UInt8](repeating: 0, count: Int(CC_MD5_DIGEST_LENGTH))
      CC_MD5(bytes, CC_LONG(data.count), &hash)
      return hash
    }

    return hash.map { String(format: "%02x", $0) }.joined()
  }
}

public final class LocalLanguage {
  static var language = Locale.preferredLanguages[0]
}

extension String {
  static let dropDownCharacter = "▾"
}
