//
//  ProjectConfiguration.swift
//  AptoSDK
//
//  Created by Ivan Oliver Martínez on 13/01/2017.
//
//

import Foundation
import UIKit

open class ContextConfiguration {
  public let teamConfiguration: TeamConfiguration
  public let projectConfiguration: ProjectConfiguration

  init(teamConfiguration: TeamConfiguration, projectConfiguration: ProjectConfiguration) {
    self.teamConfiguration = teamConfiguration
    self.projectConfiguration = projectConfiguration
  }
}

open class TeamConfiguration {
  public let logoUrl: String?
  public let name: String

  init(logoUrl: String?, name: String) {
    self.logoUrl = logoUrl
    self.name = name
  }
}

public struct ProjectBranding: Codable {
  public let uiBackgroundPrimaryColor: String
  public let uiBackgroundSecondaryColor: String
  public let iconPrimaryColor: String
  public let iconSecondaryColor: String
  public let iconTertiaryColor: String
  public let textPrimaryColor: String
  public let textSecondaryColor: String
  public let textTertiaryColor: String
  public let textTopBarPrimaryColor: String
  public let textTopBarSecondaryColor: String
  public let textLinkColor: String
  public let textLinkUnderlined: Bool
  public let textButtonColor: String
  public let buttonCornerRadius: Float
  public let uiPrimaryColor: String
  public let uiSecondaryColor: String
  public let uiTertiaryColor: String
  public let uiErrorColor: String
  public let uiSuccessColor: String
  public let uiNavigationPrimaryColor: String
  public let uiNavigationSecondaryColor: String
  public let uiBackgroundOverlayColor: String
  public let textMessageColor: String
  public let badgeBackgroundPositiveColor: String
  public let badgeBackgroundNegativeColor: String
  public let showToastTitle: Bool
  public let transactionDetailsCollapsable: Bool
  public let disclaimerBackgroundColor: String
  public let uiStatusBarStyle: String
  public let logoUrl: String?
  public let uiTheme: String
}

public struct Branding: Codable {
  public let light: ProjectBranding
  public let dark: ProjectBranding
}

open class ProjectConfiguration {
  public let name: String
  public let summary: String?
  public let allowUserLogin: Bool
  public let skipSteps: Bool
  public let strictAddressValidation: Bool
  public let primaryAuthCredential: DataPointType
  public let secondaryAuthCredential: DataPointType
  public let supportEmailAddress: String?
  public let branding: Branding
  public let allowedCountries: [Country]
  public let welcomeScreenAction: WorkflowAction
  let defaultCountryCode: Int
  let products: [Product]
  let isTrackerActive: Bool?
  let trackerAccessToken: String?

  init(name: String = "Emblem",
       summary: String? = "Banking designed by Creators",
       allowUserLogin: Bool = true,
       primaryAuthCredential: DataPointType = .phoneNumber,
       secondaryAuthCredential: DataPointType = .email,
       skipSteps: Bool = false,
       strictAddressValidation: Bool = true,
       defaultCountryCode: Int = 1,
       products: [Product],
       welcomeScreenAction: WorkflowAction,
       supportEmailAddress: String? = "support@emblemcard.co",
       branding: Branding,
       allowedCountries: [Country]? = [Country(isoCode: "US")],
       isTrackerActive: Bool?,
       trackerAccessToken: String?) {
    self.name = name
    self.summary = summary
    self.allowUserLogin = allowUserLogin
    self.primaryAuthCredential = primaryAuthCredential
    self.secondaryAuthCredential = secondaryAuthCredential
    self.skipSteps = skipSteps
    self.strictAddressValidation = strictAddressValidation
    self.defaultCountryCode = defaultCountryCode
    self.products = products
    self.welcomeScreenAction = welcomeScreenAction
    self.supportEmailAddress = supportEmailAddress
    self.branding = branding
    self.isTrackerActive = isTrackerActive
    self.trackerAccessToken = trackerAccessToken
    if let allowedCountries = allowedCountries, !allowedCountries.isEmpty {
      self.allowedCountries = allowedCountries
    }
    else {
      self.allowedCountries = [Country.defaultCountry]
    }
  }
}

//Global variables
@available(iOS 13.0, *)
struct GlobalVariables {
    static let blue = UIColor(red:0.17, green:0.52, blue:0.94, alpha:1.0) //2B84F0 For Icon Creation on Web
    static let purple = UIColor.rbg(r: 161, g: 114, b: 255)
    static let backmeGreen = UIColor.rbg(r: 37, g: 184, b: 137)
    static let messageBlue = UIColor.rbg(r: 39, g: 193, b: 256)
    static let buttonBlue = hexStringToUIColor(hex: "#00B3FE")
    static let blueText = UIColor.rbg(r: 85, g: 150, b: 189)
    static let redSignOff = UIColor.rbg(r: 242, g: 20, b: 84)
    static let greenApproval = UIColor.rbg(r: 30, g: 192, b: 124)
    static let purpleBackground = UIColor.rbg(r: 119, g: 97, b: 199)
    static let blueBackground = UIColor.rbg(r: 21, g: 152, b: 205)
    static let yellowBackground = UIColor.rbg(r: 255, g: 224, b: 41)
    static let redBackground = UIColor.rbg(r: 213, g: 95, b: 141)
    static let pinkishRed = UIColor.rbg(r: 235, g: 61, b: 154)
    static let redishRed = UIColor(red:0.91, green:0.24, blue:0.24, alpha:1.0)
    static let softRed = UIColor(red:0.99, green:0.67, blue:0.67, alpha:1.0)
    static let softPurple = UIColor(red:0.76, green:0.63, blue:1.00, alpha:1.0)
    static let softBlue = UIColor(red:0.47, green:0.69, blue:1.00, alpha:1.0)
    //    static let brightGreen = UIColor.rbg(r: 0, g: 215, b: 90)
//    #52cc00
//    #00D274
//    #47b300
//    #228B22
//    #4cbb17
//    00C954
//    00AE29
//    00C954
//    static let brightGreen = hexStringToUIColor(hex: "#00C954")
    static let brightGreen = UIColor(red:0.0, green:0.8, blue:0.2, alpha:1.0)
    static let brightGreenDeposit = UIColor(red:0.0, green:0.78, blue:0.2, alpha:1.0)
    static let featureColor = hexStringToUIColor(hex: "#00BDC7")
    static let darkerGreen = hexStringToUIColor(hex: "#56B900")
    static let backMeBlue = UIColor.rbg(r: 0, g: 155, b: 245)
    static let lightestGray = UIColor.init(white: 0.97, alpha: 1)
    static let lighterGray = UIColor.init(white: 0.75, alpha: 1)
    static let mediumBlack = UIColor(red:0.20, green:0.17, blue:0.17, alpha:1.0)
    static let mediumGray = UIColor(red:0.41, green:0.41, blue:0.41, alpha:1.0)
    static let softGreen = UIColor.rbg(r: 106, g: 205, b: 163)
    static let softPink = UIColor(red:0.99, green:0.51, blue:0.51, alpha:1.0)
    static let fortnitePurple = UIColor(red:0.33, green:0.00, blue:0.55, alpha:1.0)
    static let gold = UIColor.rbg(r: 237, g: 221, b: 0)
    static let silver = UIColor.rbg(r: 230, g: 232, b: 250)
    static let bronze = UIColor.rbg(r: 198, g: 129, b: 0)
    static let venmoColor = UIColor.rbg(r: 81, g: 164, b: 234)
    static let cashAppColor = UIColor.rbg(r: 91, g: 196, b: 67)
    //    static let lightPurple = UIColor.rbg(r: 100, g: 26, b: 255)
    static let lightPurple = purpleColorAdjust()
    static let backgroundColor = backgroundAdjust()
//    if let t = UIViewController.currentViewController() {
//        if t.trai
//    }
//    static var lightPurple = UIColor.systemIndigo
    static let mediumPurple = UIColor.rbg(r: 80, g: 76, b: 184)
    static let darkPurple = UIColor.rbg(r: 54, g: 52, b: 133)
    static let blackPurple = UIColor.rbg(r: 11, g: 10, b: 25)
    
    //    static let lightBlue = UIColor.rbg(r: 105, g: 195, b: 250)
    static let lightBlue = hexStringToUIColor(hex: "#0080FF")
    
    static let red = hexStringToUIColor(hex: "#FF0000")
//    static let black = hexStringToUIColor(hex: "#16161D")
//    1F2124
    static let black = hexStringToUIColor(hex: "#090909")
    
    //    static let lightPurple = UIColor.rbg(r: 125, g: 115, b: 238)
    //    static let orange = UIColor.rbg(r: 253, g: 157, b: 32)
    static let orange = UIColor.rbg(r: 255, g: 63, b: 0)
    static let purpleBlue = UIColor.rbg(r: 42, g: 127, b: 216)
    static let purpleBlue2 = UIColor.rbg(r: 41, g: 135, b: 221)
    static let darkRed = UIColor.rbg(r: 217, g: 0, b: 0)
    static let lightPurpleShimmer = UIColor.rbg(r: 158, g: 128, b: 231)
    static let mediumPurpleShimmer = UIColor.rbg(r: 92, g: 20, b: 221)
    static let twitchColor = UIColor.rbg(r: 100, g: 65, b: 165)
    static let level1 = UIColor.rbg(r: 0, g: 210, b: 210)
    
    static let lighterPurple = hexStringToUIColor(hex: "#9C6EFF")
    static let lightPixelColor = hexStringToUIColor(hex: "#AB43CA")
    //    static let lighterPixelColor = hexStringToUIColor(hex: "#E746EC")
    //    E80091
    //    static let lighterPixelColor = hexStringToUIColor(hex: "#E80091")
    static let lighterPixelColor = hexStringToUIColor(hex: "#F1009C")
    //    F1009C
    //    static let lighterPixelColor = UIColor.rbg(r: 255, g: 52, b: 175)
    static let blue1 = hexStringToUIColor(hex: "#536DFE")
    static let blue2 = hexStringToUIColor(hex: "#627AFE")
    static let blue3 = hexStringToUIColor(hex: "#7287FE")
    static let darkMode = hexStringToUIColor(hex: "#161724")
//    static let darkModeLight = hexStringToUIColor(hex: "#2C2C3F")
    static let darkModeLight = UIColor.tertiaryLabel
    //    static let achieveOrange = hexStringToUIColor(hex: "#F26625")
    //255,144,0
    static let achieveOrange = hexStringToUIColor(hex: "#FF5D0B")
    static let darkBlue = hexStringToUIColor(hex: "#1D2671")
    //255,93,11
}

//Extensions
extension UIColor {
    class func rbg(r: CGFloat, g: CGFloat, b: CGFloat) -> UIColor {
        let color = UIColor.init(red: r/255, green: g/255, blue: b/255, alpha: 1)
        return color
    }
    static func shadowColor() -> UIColor {
        return UIColor(red: 0/255, green: 0/255, blue: 0/255, alpha: 0.41)
    }
    
}

@available(iOS 12.0, *)
@available(iOS 13.0, *)
func purpleColorAdjust() -> UIColor {
    if let topViewController = UIViewController.currentViewController() {
        if topViewController.traitCollection.userInterfaceStyle == .light {
            return hexStringToUIColor(hex: "#641AFF")
        } else {
            return UIColor.systemIndigo
//            return hexStringToUIColor(hex: "#8E1DFE")
        }
    } else {
        return hexStringToUIColor(hex: "#641AFF")
    }
}

@available(iOS 12.0, *)
@available(iOS 13.0, *)
func backgroundAdjust() -> UIColor {
    if let topViewController = UIViewController.currentViewController() {
        if topViewController.traitCollection.userInterfaceStyle == .light {
            return UIColor(named: "BACKGROUND")!
        } else {
            return UIColor.secondarySystemBackground
        }
    } else {
        return UIColor(named: "BACKGROUND")!
    }
}

func hexStringToUIColor (hex:String) -> UIColor {
    var cString:String = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
    
    if (cString.hasPrefix("#")) {
        cString.remove(at: cString.startIndex)
    }
    
    if (cString.hasPrefix("0x")) {
        cString = cString.replacingOccurrences(of: "0x", with: "")
        //        cString.remove(at: String.)
        //        cString.remove(at: 0)
    }
    
    if ((cString.count) != 6) {
        return UIColor.gray
    }
    
    var rgbValue:UInt64 = 0
    Scanner(string: cString).scanHexInt64(&rgbValue)
    
    return UIColor(
        red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
        green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
        blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
        alpha: CGFloat(1.0)
    )
}

extension UIViewController {
    public static func findBestViewController(_ vc: UIViewController) -> UIViewController {
        if let presentedViewController = vc.presentedViewController {
            // Return presented view controller
            return UIViewController.findBestViewController(presentedViewController)
        }
        else if let svc = vc as? UISplitViewController {
            // Return right hand side
            if svc.viewControllers.count > 0 {
                return UIViewController.findBestViewController(svc.viewControllers.last!)
            }
            else {
                return vc
            }
        }
        else if let svc = vc as? UINavigationController {
            // Return top view
            // TODO: Need to compare with ObjC ver.
            if let topViewController = svc.topViewController {
                return UIViewController.findBestViewController(topViewController)
            }
            else {
                return vc
            }
        }
        else if let svc = vc as? UITabBarController {
            // Return visible view
            if (svc.viewControllers?.count ?? 0) > 0 {
                return UIViewController.findBestViewController(svc.selectedViewController!)
            }
            else {
                return vc
            }
        }
        else {
            // Unknown view controller type, return last child view controller
            return vc
        }
    }
    
    public static func currentViewController() -> UIViewController? {
        guard let viewController = UIApplication.shared.keyWindow?.rootViewController else { return nil }
        return UIViewController.findBestViewController(viewController)
    }
}

