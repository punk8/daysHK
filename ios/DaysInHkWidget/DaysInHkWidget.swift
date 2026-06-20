import SwiftUI
import WidgetKit

struct DaysInHkWidget: Widget {
  let kind = "DaysInHkWidget"

  var body: some WidgetConfiguration {
    StaticConfiguration(kind: kind, provider: DaysInHkWidgetProvider()) { entry in
      DaysInHkWidgetView(entry: entry)
    }
    .configurationDisplayName("在港日记")
    .description("查看总在港天数和今年在港天数。")
    .supportedFamilies([.systemSmall, .systemMedium])
  }
}

struct DaysInHkWidgetView: View {
  @Environment(\.widgetFamily) private var family
  let entry: DaysInHkWidgetEntry

  var body: some View {
    ZStack {
      background
      if entry.hasData {
        content
      } else {
        emptyState
      }
    }
    .widgetBackground(background)
  }

  @ViewBuilder
  private var content: some View {
    switch family {
    case .systemMedium:
      mediumContent
    default:
      smallContent
    }
  }

  private var smallContent: some View {
    VStack(alignment: .leading, spacing: 10) {
      header(showUpdateTime: false)
      Spacer(minLength: 2)
      numberText(value: entry.totalDays, color: .primaryNumber)
      Text("总在港天数")
        .font(.caption.weight(.semibold))
        .foregroundStyle(Color.primaryNumber)
      Spacer(minLength: 2)
      Text("今年 \(entry.currentYearDays) 天")
        .font(.headline.weight(.bold))
        .foregroundStyle(Color.secondaryNumber)
        .lineLimit(1)
        .minimumScaleFactor(0.75)
    }
    .padding(16)
  }

  private var mediumContent: some View {
    VStack(alignment: .leading, spacing: 18) {
      header(showUpdateTime: true)
      HStack(spacing: 22) {
        metricBlock(
          title: "总在港天数",
          value: entry.totalDays,
          footer: "累计记录",
          color: .primaryNumber
        )
        Divider()
          .overlay(Color.secondaryText.opacity(0.35))
        metricBlock(
          title: "今年在港天数",
          value: entry.currentYearDays,
          footer: "\(entry.currentYear) 年",
          color: .secondaryNumber
        )
      }
    }
    .padding(18)
  }

  private var emptyState: some View {
    VStack(alignment: .leading, spacing: 10) {
      header(showUpdateTime: false)
      Spacer()
      Text("暂无记录")
        .font(.title3.weight(.bold))
        .foregroundStyle(Color.primaryText)
      Text("打开 App 添加入离港记录")
        .font(.caption)
        .foregroundStyle(Color.secondaryText)
        .lineLimit(2)
      Spacer()
    }
    .frame(maxWidth: .infinity, alignment: .leading)
    .padding(16)
  }

  private func header(showUpdateTime: Bool) -> some View {
    HStack(spacing: 8) {
      BauhiniaIcon()
        .frame(width: 28, height: 28)
      Text("在港日记")
        .font(.headline.weight(.bold))
        .foregroundStyle(Color.primaryText)
      Spacer(minLength: 4)
      if showUpdateTime, let lastUpdatedAt = entry.lastUpdatedAt {
        Text("更新 \(lastUpdatedAt, format: .dateTime.hour().minute())")
          .font(.caption)
          .foregroundStyle(Color.secondaryText)
          .lineLimit(1)
          .minimumScaleFactor(0.75)
      }
    }
  }

  private func metricBlock(
    title: String,
    value: Int,
    footer: String,
    color: Color
  ) -> some View {
    VStack(alignment: .leading, spacing: 6) {
      Text(title)
        .font(.caption)
        .foregroundStyle(Color.secondaryText)
      numberText(value: value, color: color)
      HStack(spacing: 5) {
        Image(systemName: "calendar")
          .font(.caption)
        Text(footer)
          .font(.caption)
      }
      .foregroundStyle(Color.secondaryText)
    }
    .frame(maxWidth: .infinity, alignment: .leading)
  }

  private func numberText(value: Int, color: Color) -> some View {
    HStack(alignment: .firstTextBaseline, spacing: 4) {
      Text("\(value)")
        .font(.system(size: family == .systemMedium ? 42 : 44, weight: .bold, design: .rounded))
        .monospacedDigit()
      Text("天")
        .font(.headline.weight(.bold))
    }
    .foregroundStyle(color)
    .lineLimit(1)
    .minimumScaleFactor(0.7)
  }

  private var background: some View {
    Color.widgetBackground
  }
}

private extension View {
  @ViewBuilder
  func widgetBackground(_ background: some View) -> some View {
    if #available(iOSApplicationExtension 17.0, *) {
      containerBackground(for: .widget) {
        background
      }
    } else {
      self.background(background)
    }
  }
}

private struct BauhiniaIcon: View {
  var body: some View {
    ZStack {
      RoundedRectangle(cornerRadius: 7, style: .continuous)
        .fill(
          LinearGradient(
            colors: [.red, .red.opacity(0.78)],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
          )
        )
      Image(systemName: "sparkle")
        .font(.system(size: 15, weight: .bold))
        .foregroundStyle(.white)
    }
  }
}

private extension Color {
  static let widgetBackground = Color(uiColor: .systemBackground)
  static let primaryText = Color(uiColor: .label)
  static let secondaryText = Color(uiColor: .secondaryLabel)
  static let primaryNumber = Color(uiColor: .systemBlue)
  static let secondaryNumber = Color(uiColor: .systemGreen)
}
