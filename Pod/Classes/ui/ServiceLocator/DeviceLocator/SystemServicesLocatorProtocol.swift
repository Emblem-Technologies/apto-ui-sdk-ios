//
//  SystemServicesLocatorProtocol.swift
//  AptoUISDK
//
//  Created by Takeichi Kanzaki on 11/10/2019.
//

import Foundation

public protocol FileDownloaderProvider {
  func fileDownloader(url: URL, localFilename: String) -> FileDownloader
}

public protocol SystemServicesLocatorProtocol: FileDownloaderProvider {
  func fileManager(filename: String) -> FileManagerProtocol
  func dateProvider() -> DateProviderProtocol
  func authenticationManager() -> AuthenticationManagerProtocol
  func cardAdditionalFields() -> CardAdditionalFieldsProtocol
}
