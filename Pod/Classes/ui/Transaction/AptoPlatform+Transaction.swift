import UIKit
 
extension AptoPlatform {
  public var transaction: TransactionModule {
    AptoTransactionModule()
  }
}

internal struct AptoTransactionModule: TransactionModule {}
