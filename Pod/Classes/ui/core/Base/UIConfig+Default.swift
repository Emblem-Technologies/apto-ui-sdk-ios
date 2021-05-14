import Foundation

extension UIConfig {
  public static let `default` = UIConfig(
    branding: Branding(light: projectBranding, dark: projectBranding)
  )
  
  private static let projectBranding = ProjectBranding(
    uiBackgroundPrimaryColor: "f2f3f4",
    uiBackgroundSecondaryColor: "f2f3f4",
    iconPrimaryColor: "e4eaf2",
    iconSecondaryColor: "8494a5",
    iconTertiaryColor: "3c4a5b",
    textPrimaryColor: "000000",
    textSecondaryColor: "8494a5",
    textTertiaryColor: "8494a5",
    textTopBarPrimaryColor: "000000",
    textTopBarSecondaryColor: "3c4a5b",
    textLinkColor: "0055FF",
    textLinkUnderlined: true,
    textButtonColor: "FFFFFF",
    buttonCornerRadius: 12.0,
    uiPrimaryColor: "641AFF",
    uiSecondaryColor: "ffffff",
    uiTertiaryColor: "e4eaf2",
    uiErrorColor: "ff673d",
    uiSuccessColor: "0055FF",
    uiNavigationPrimaryColor: "ffffff",
    uiNavigationSecondaryColor: "ffffff",
    uiBackgroundOverlayColor: "3c4a5b",
    textMessageColor: "ffffff",
    badgeBackgroundPositiveColor: "61ca00",
    badgeBackgroundNegativeColor: "326700",
    showToastTitle: true,
    transactionDetailsCollapsable: true,
    disclaimerBackgroundColor: "ffffff",
    uiStatusBarStyle: "light",
    logoUrl: nil,
    uiTheme: "theme_2"
  )
}
