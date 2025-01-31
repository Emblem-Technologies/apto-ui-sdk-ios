//
//  CardMonthlyStatsContract.swift
//  AptoSDK
//
//  Created by Takeichi Kanzaki on 07/01/2019.
//

import Bond
import UIKit

protocol CardMonthlyStatsModuleProtocol: UIModuleProtocol {
  func showTransactions(for categorySpending: CategorySpending, startDate: Date, endDate: Date)
  func showStatementReport(month: Month)
}

protocol CardMonthlyStatsInteractorProtocol {
  func fetchMonthlySpending(date: Date, callback: @escaping Result<MonthlySpending, NSError>.Callback)
  func isStatementsFeatureEnabled(callback: @escaping (_ isEnabled: Bool) -> Void)
  func fetchStatementsPeriod(callback: @escaping Result<MonthlyStatementsPeriod, NSError>.Callback)
}

class CardMonthlyStatsViewModel {
  let spentList: Observable<[CategorySpending]> = Observable([])
  let previousSpendingExists: Observable<Bool> = Observable(true)
  let nextSpendingExists: Observable<Bool> = Observable(true)
  let dataLoaded: Observable<Bool> = Observable(false)
  let monthlyStatementsAvailable: Observable<Bool> = Observable(false)
}

protocol CardMonthlyStatsPresenterProtocol: class {
  var router: CardMonthlyStatsModuleProtocol? { get set }
  var interactor: CardMonthlyStatsInteractorProtocol? { get set }
  var viewModel: CardMonthlyStatsViewModel { get }
  var analyticsManager: AnalyticsServiceProtocol? { get set }

  func viewLoaded()
  func closeTapped()
  func dateSelected(_ date: Date)
  func categorySpendingSelected(_ categorySpending: CategorySpending, date: Date)
  func monthlyStatementsTapped(date: Date)
}
