//
//  ClaudeDirSelector.swift
//  Nook
//
//  Manages the expand/collapse state of the Claude directory picker row,
//  so NotchViewModel can grow the settings panel when the picker is open
//  (matching SoundSelector / ScreenSelector behavior).
//

import Combine
import Foundation

@MainActor
class ClaudeDirSelector: ObservableObject {
    static let shared = ClaudeDirSelector()

    @Published var isPickerExpanded: Bool = false

    /// Height of a single option row (matches SoundOptionRowInline style).
    private let rowHeight: CGFloat = 32

    /// Number of option rows the picker shows (Auto-detect + Choose folder…).
    private let optionCount: Int = 2

    private init() {}

    /// Extra height needed when the picker is expanded.
    var expandedPickerHeight: CGFloat {
        guard isPickerExpanded else { return 0 }
        return CGFloat(optionCount) * rowHeight + 8  // +8 for padding
    }
}
