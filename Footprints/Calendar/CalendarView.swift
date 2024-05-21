//
//  CalendarView.swift
//  Footprints
//
//  Created by Collin Palmer on 5/9/24.
//

import SwiftUI

struct CalendarView: View {
    private let squareSide: CGFloat = 16
    let today: Date
    let daysInMonth: Int
    let daysInLastWeek: Int
    let selectedDates: [Int]
    private let dateMap: Set<Int>// = Set()
    
    
    // Assumption: all dates passed are within this month (maybe assert?)
    init(_ selectedDates: [Int]=[]) {
        self.today = Date.now
        self.daysInMonth = Calendar.current.range(of: .day, in: .month, for: self.today)!.upperBound
        self.daysInLastWeek = max(self.daysInMonth - 28, 0)
        self.selectedDates = selectedDates
        //self.dateMap.insert(1)
        
        /*
        let setDays = self.selectedDates.map {
            return Calendar.current.dateComponents([.day], from: $0).day!
        }
         */
        
        self.dateMap = Set(selectedDates)
        print("Date map: \(self.dateMap)")
    }
    
    var firstWeekdayOfMonth: Date.Weekday {
        // Compute the first day of the month
        //let day = Calendar.current.component(.day, from: self.today)
        let todayComponents = Calendar.current.dateComponents([.year, .month, .day], from: today)
        let firstOfMonthDate = Calendar.current.date(from: DateComponents(year: todayComponents.year, month: todayComponents.month, day: 1))
        
        // TODO: Some sort of exception if expected calendar is not used..?
        return firstOfMonthDate!.weekday
    }
    
    // TODO: Separate view where you can set color
    var calendarSquare: some View {
        RoundedRectangle(cornerRadius: 4)
            .fill(.accent)
            .heightEqualMaxWidth()
            //.frame(width: squareSide, height: squareSide)
    }
    
    var emptyCalendarSquare: some View {
        RoundedRectangle(cornerRadius: 4)
            //.stroke(.gray.opacity(0.6), lineWidth: 2)
            .fill(.gray.opacity(0.2))
            .heightEqualMaxWidth()
            //.frame(width: squareSide, height: squareSide)
    }
    
    var placeholderCalendarSquare: some View {
        Rectangle()
            .fill(.clear)
            .heightEqualMaxWidth()
            //.frame(width: squareSide, height: squareSide)
    }
    
    func dayOfMonth(week: Int, day: Int) -> Int {
        return week*7 + day
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            VStack(alignment: .leading) {
                Text(self.today.monthName.uppercased())
                    .font(.title.smallCaps())
                Text("\(self.dateMap.count)/\(self.daysInMonth-1) Days Ran")
                    .font(.caption2.weight(.light))
                    .opacity(0.8)
            }
            VStack {
                ForEach(0..<5, id: \.self) { (week: Int) in
                    HStack {
                        if week == 4 {
                            ForEach(0..<self.daysInLastWeek, id: \.self) { day in
                                // Check if a date with this day of the week exists
                                //if inMonth(calendarDate(week: week, day: day)) {
                                if self.dateMap.contains(dayOfMonth(week: week, day: day)) {
                                    calendarSquare
                                } else {
                                    emptyCalendarSquare
                                }
                            }
                            ForEach(0..<(7-self.daysInLastWeek), id: \.self) { _ in
                                // TODO: Should use background depending on dark mode or not
                                placeholderCalendarSquare
                            }
                        } else if week == 0 {
                            ForEach(0..<(self.firstWeekdayOfMonth.rawValue-1), id: \.self) { _ in
                                placeholderCalendarSquare
                            }
                            ForEach((self.firstWeekdayOfMonth.rawValue-1)..<7, id: \.self) { day in
                                if self.dateMap.contains(dayOfMonth(week: week, day: day)) {
                                    calendarSquare
                                } else {
                                    emptyCalendarSquare
                                }
                            }
                        } else {
                            ForEach(0..<7, id: \.self) { day in
                                if self.dateMap.contains(dayOfMonth(week: week, day: day)) {
                                    calendarSquare
                                } else {
                                    emptyCalendarSquare
                                }
                            }
                        }
                    }
                }
            }
            .padding()
            .background {
                Color.gray.opacity(0.1)
            }
            .clipShape(RoundedRectangle(cornerRadius: 10))
        }
    }
}

// TODO: View extension
private struct SizeReader: ViewModifier {
    @Binding var size: CGSize?
    
    func body(content: Content) -> some View {
        content
            .background {
                GeometryReader { reader in
                    Color.clear
                        .onAppear {
                            self.size = reader.size
                        }
                }
            }
    }
}

private struct Equalizer: ViewModifier {
    @State private var size: CGSize?
    
    func body(content: Content) -> some View {
        if let size {
            content
                .measure($size)
                .frame(height: size.width)
        } else {
            content
                .measure($size)
        }
    }
}

extension View {
    func heightEqualMaxWidth() -> some View {
        self.frame(maxWidth: .infinity)
            .modifier(Equalizer())
    }
    
    func measure(_ size: Binding<CGSize?>) -> some View {
        self.modifier(SizeReader(size: size))
    }
}

#Preview {
    CalendarView([1, 3, 5, 7, 18])
        .padding([.horizontal], 32)
}
