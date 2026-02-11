import SwiftUI

/// 30-day heatmap grid using DailyHistory data (green/red/gray squares).
struct MonthCalendarView: View {
    @StateObject private var historyManager = HistoryManager.shared

    private let columns = Array(repeating: GridItem(.flexible(), spacing: 4), count: 7)

    var body: some View {
        VStack(spacing: 12) {
            HStack {
                Text("30-Day Activity")
                    .font(.headline)
                    .foregroundColor(.white)
                Spacer()
                legendDots
            }

            // Day-of-week headers
            HStack(spacing: 4) {
                ForEach(["S", "M", "T", "W", "T", "F", "S"], id: \.self) { day in
                    Text(day)
                        .font(.system(size: 10, weight: .medium))
                        .foregroundColor(.gray)
                        .frame(maxWidth: .infinity)
                }
            }

            // Calendar grid
            LazyVGrid(columns: columns, spacing: 4) {
                // Leading spacer cells to align with weekday
                ForEach(0..<leadingSpacers, id: \.self) { _ in
                    Color.clear
                        .frame(height: 24)
                }

                ForEach(calendarDays, id: \.dateString) { day in
                    calendarCell(for: day)
                }
            }
        }
        .glassCard()
    }

    // MARK: - Data

    private var calendarDays: [CalendarDay] {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        var days: [CalendarDay] = []

        for offset in stride(from: -29, through: 0, by: 1) {
            guard let date = calendar.date(byAdding: .day, value: offset, to: today) else { continue }
            let state = historyManager.history.state(for: date)
            let isToday = offset == 0

            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd"

            days.append(CalendarDay(
                date: date,
                dateString: formatter.string(from: date),
                dayNumber: calendar.component(.day, from: date),
                steps: state?.steps ?? 0,
                goalMet: state?.isGoalMet ?? false,
                hasData: state != nil && (state?.steps ?? 0) > 0,
                isToday: isToday
            ))
        }

        return days
    }

    private var leadingSpacers: Int {
        guard let firstDay = calendarDays.first else { return 0 }
        let weekday = Calendar.current.component(.weekday, from: firstDay.date)
        return weekday - 1
    }

    // MARK: - Cell

    @ViewBuilder
    private func calendarCell(for day: CalendarDay) -> some View {
        ZStack {
            RoundedRectangle(cornerRadius: 4)
                .fill(cellColor(for: day))
                .frame(height: 24)

            if day.isToday {
                RoundedRectangle(cornerRadius: 4)
                    .stroke(Color.white.opacity(0.6), lineWidth: 1.5)
                    .frame(height: 24)
            }

            Text("\(day.dayNumber)")
                .font(.system(size: 9, weight: day.isToday ? .bold : .medium))
                .foregroundColor(day.hasData || day.isToday ? .white : .gray.opacity(0.6))
        }
    }

    private func cellColor(for day: CalendarDay) -> Color {
        guard day.hasData || day.isToday else {
            return Color.white.opacity(0.04)
        }

        if day.goalMet {
            return Color(hex: "#34C759").opacity(day.isToday ? 0.8 : 0.6)
        } else if day.steps > 0 {
            let intensity = min(Double(day.steps) / 7500.0, 1.0)
            if intensity > 0.5 {
                return Color.yellow.opacity(0.4)
            }
            return Color(hex: "#FF3B30").opacity(0.3)
        }

        return Color.white.opacity(0.04)
    }

    // MARK: - Legend

    private var legendDots: some View {
        HStack(spacing: 8) {
            legendItem(color: Color(hex: "#34C759"), label: "Met")
            legendItem(color: Color(hex: "#FF3B30").opacity(0.5), label: "Missed")
        }
    }

    private func legendItem(color: Color, label: String) -> some View {
        HStack(spacing: 3) {
            RoundedRectangle(cornerRadius: 2)
                .fill(color)
                .frame(width: 8, height: 8)
            Text(label)
                .font(.system(size: 9))
                .foregroundColor(.gray)
        }
    }
}

// MARK: - Model

private struct CalendarDay {
    let date: Date
    let dateString: String
    let dayNumber: Int
    let steps: Int
    let goalMet: Bool
    let hasData: Bool
    let isToday: Bool
}
