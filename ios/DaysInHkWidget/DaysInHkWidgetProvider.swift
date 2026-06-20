import Foundation
import WidgetKit

struct DaysInHkWidgetProvider: TimelineProvider {
  private let appGroupIdentifier = "group.com.punk8.daysHK"
  private let totalDaysKey = "days_hk_total_days"
  private let currentYearDaysKey = "days_hk_current_year_days"
  private let currentYearKey = "days_hk_current_year"
  private let lastUpdatedAtKey = "days_hk_last_updated_at"

  func placeholder(in context: Context) -> DaysInHkWidgetEntry {
    DaysInHkWidgetEntry.placeholder
  }

  func getSnapshot(
    in context: Context,
    completion: @escaping (DaysInHkWidgetEntry) -> Void
  ) {
    completion(context.isPreview ? .placeholder : readEntry())
  }

  func getTimeline(
    in context: Context,
    completion: @escaping (Timeline<DaysInHkWidgetEntry>) -> Void
  ) {
    let entry = readEntry()
    let nextRefresh = Calendar.current.date(
      byAdding: .hour,
      value: 1,
      to: Date()
    ) ?? Date().addingTimeInterval(60 * 60)
    completion(Timeline(entries: [entry], policy: .after(nextRefresh)))
  }

  private func readEntry() -> DaysInHkWidgetEntry {
    guard let defaults = UserDefaults(suiteName: appGroupIdentifier) else {
      return .empty
    }

    let hasTotalDays = defaults.object(forKey: totalDaysKey) != nil
    guard hasTotalDays else {
      return .empty
    }

    let currentYear = defaults.object(forKey: currentYearKey) as? Int
      ?? Calendar.current.component(.year, from: Date())
    let lastUpdatedAt = defaults.string(forKey: lastUpdatedAtKey)
      .flatMap(Self.parseDate)

    return DaysInHkWidgetEntry(
      date: Date(),
      totalDays: defaults.integer(forKey: totalDaysKey),
      currentYearDays: defaults.integer(forKey: currentYearDaysKey),
      currentYear: currentYear,
      lastUpdatedAt: lastUpdatedAt,
      hasData: true
    )
  }

  private static func parseDate(_ value: String) -> Date? {
    let formatter = ISO8601DateFormatter()
    formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
    return formatter.date(from: value) ?? ISO8601DateFormatter().date(from: value)
  }
}
