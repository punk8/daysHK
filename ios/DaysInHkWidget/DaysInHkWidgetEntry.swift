import WidgetKit

struct DaysInHkWidgetEntry: TimelineEntry {
  let date: Date
  let totalDays: Int
  let currentYearDays: Int
  let currentYear: Int
  let lastUpdatedAt: Date?
  let hasData: Bool
}

extension DaysInHkWidgetEntry {
  static let placeholder = DaysInHkWidgetEntry(
    date: Date(),
    totalDays: 658,
    currentYearDays: 128,
    currentYear: Calendar.current.component(.year, from: Date()),
    lastUpdatedAt: Date(),
    hasData: true
  )

  static let empty = DaysInHkWidgetEntry(
    date: Date(),
    totalDays: 0,
    currentYearDays: 0,
    currentYear: Calendar.current.component(.year, from: Date()),
    lastUpdatedAt: nil,
    hasData: false
  )
}
