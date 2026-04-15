//
//  Ext+NSScreen.swift
//  Nook
//
//  Extensions for NSScreen to detect notch and built-in display
//

import AppKit

extension NSScreen {
    /// Returns the size of the notch on this screen (pixel-perfect using macOS APIs)
    var notchSize: CGSize {
        guard safeAreaInsets.top > 0 else {
            // On non-notched displays, match this screen's actual menu bar height
            return CGSize(width: 224, height: menuBarHeight)
        }

        let notchHeight = safeAreaInsets.top
        let fullWidth = frame.width
        let leftPadding = auxiliaryTopLeftArea?.width ?? 0
        let rightPadding = auxiliaryTopRightArea?.width ?? 0

        guard leftPadding > 0, rightPadding > 0 else {
            // Fallback if auxiliary areas unavailable
            return CGSize(width: 180, height: notchHeight)
        }

        // +4 to match boring.notch's calculation for proper alignment
        let notchWidth = fullWidth - leftPadding - rightPadding + 4
        return CGSize(width: notchWidth, height: notchHeight)
    }

    /// Whether this is the built-in display
    var isBuiltinDisplay: Bool {
        guard let screenNumber = deviceDescription[NSDeviceDescriptionKey("NSScreenNumber")] as? CGDirectDisplayID else {
            return false
        }
        return CGDisplayIsBuiltin(screenNumber) != 0
    }

    /// The built-in display (with notch on newer MacBooks)
    static var builtin: NSScreen? {
        if let builtin = screens.first(where: { $0.isBuiltinDisplay }) {
            return builtin
        }
        return NSScreen.main
    }

    /// Whether this screen has a physical notch (camera housing)
    var hasPhysicalNotch: Bool {
        safeAreaInsets.top > 0
    }

    /// The menu bar height on this specific screen
    var menuBarHeight: CGFloat {
        let topInset = frame.maxY - visibleFrame.maxY
        return max(topInset, 24)
    }
}
