import UIKit

extension TransactionModule {
  public var component: TransactionComponentProvider {
    AptoTransactionComponentProvider()
  }
}
