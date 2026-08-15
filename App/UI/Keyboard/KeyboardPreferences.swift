//
//  KeyboardPreferences.swift
//  NewTerm (iOS)
//
//  Created by Adam Demasi on 27/12/2022.
//

import Foundation
import SwiftUI

enum KeyboardShortcutKey: String, CaseIterable, Identifiable, Hashable {
	case control
	case shift
	case escape
	case tab
	case functionKeys
	case more
	case deleteForward
	case home
	case end
	case pageUp
	case pageDown
	case f1
	case f2
	case f3
	case f4
	case f5
	case f6
	case f7
	case f8
	case f9
	case f10
	case f11
	case f12

	var id: String { rawValue }

	var title: String {
		switch self {
		case .control:      return "Control"
		case .shift:        return "Shift"
		case .escape:       return "Escape"
		case .tab:          return "Tab"
		case .functionKeys: return "Function Keys"
		case .more:         return "More"
		case .deleteForward:return "Delete Forward"
		case .home:         return "Home"
		case .end:          return "End"
		case .pageUp:       return "Page Up"
		case .pageDown:     return "Page Down"
		case .f1:           return "F1"
		case .f2:           return "F2"
		case .f3:           return "F3"
		case .f4:           return "F4"
		case .f5:           return "F5"
		case .f6:           return "F6"
		case .f7:           return "F7"
		case .f8:           return "F8"
		case .f9:           return "F9"
		case .f10:          return "F10"
		case .f11:          return "F11"
		case .f12:          return "F12"
		}
	}

	var keycapTitle: String {
		switch self {
		case .control:      return "Ctrl"
		case .escape:       return "Esc"
		case .functionKeys: return "Fn"
		case .deleteForward:return "Del"
		case .pageUp:       return "PgUp"
		case .pageDown:     return "PgDn"
		default:            return title
		}
	}

	var toolbarKey: ToolbarKey {
		switch self {
		case .control:       return .control
		case .shift:         return .shift
		case .escape:        return .escape
		case .tab:           return .tab
		case .functionKeys:  return .fnKeys
		case .more:          return .more
		case .deleteForward: return .Delete
		case .home:          return .home
		case .end:           return .end
		case .pageUp:        return .pageUp
		case .pageDown:      return .pageDown
		case .f1:            return .fnKey(index: 1)
		case .f2:            return .fnKey(index: 2)
		case .f3:            return .fnKey(index: 3)
		case .f4:            return .fnKey(index: 4)
		case .f5:            return .fnKey(index: 5)
		case .f6:            return .fnKey(index: 6)
		case .f7:            return .fnKey(index: 7)
		case .f8:            return .fnKey(index: 8)
		case .f9:            return .fnKey(index: 9)
		case .f10:           return .fnKey(index: 10)
		case .f11:           return .fnKey(index: 11)
		case .f12:           return .fnKey(index: 12)
		}
	}
}

final class KeyboardShortcutPreferences: ObservableObject {
	static let shared = KeyboardShortcutPreferences()
	static let defaultKeys: [KeyboardShortcutKey] = [.control, .shift, .escape, .tab, .more, .functionKeys]

	private static let defaultsKey = "keyboardToolbarShortcutKeys"
	private let defaults: UserDefaults

	@Published private(set) var keys: [KeyboardShortcutKey] {
		didSet {
			defaults.set(keys.map(\.rawValue), forKey: Self.defaultsKey)
		}
	}

	var availableKeys: [KeyboardShortcutKey] {
		KeyboardShortcutKey.allCases.filter { !keys.contains($0) }
	}

	private init(defaults: UserDefaults = .standard) {
		self.defaults = defaults
		if let storedKeys = defaults.stringArray(forKey: Self.defaultsKey) {
			var uniqueKeys = Set<KeyboardShortcutKey>()
			keys = storedKeys.compactMap(KeyboardShortcutKey.init(rawValue:)).filter { uniqueKeys.insert($0).inserted }
		} else {
			keys = Self.defaultKeys
		}
	}

	func add(_ key: KeyboardShortcutKey) {
		guard !keys.contains(key) else {
			return
		}
		keys.append(key)
	}

	func remove(at offsets: IndexSet) {
		keys.remove(atOffsets: offsets)
	}

	func move(from offsets: IndexSet, to destination: Int) {
		keys.move(fromOffsets: offsets, toOffset: destination)
	}

	func reset() {
		keys = Self.defaultKeys
	}
}

struct KeyboardPreferences {

	private static let defaults: UserDefaults = {
		#if targetEnvironment(macCatalyst)
		// If key repeat is disabled by the user, the initial repeat value will be set to a crazy
		// high sentinel number.
		.standard
		#else
		UserDefaults(suiteName: "com.apple.Accessibility") ?? .standard
		#endif
	}()

	static var isKeyRepeatEnabled: Bool {
		#if targetEnvironment(macCatalyst)
		// If key repeat is disabled by the user, the initial repeat value will be set to a crazy
		// high sentinel number.
		defaults.object(forKey: "InitialKeyRepeat") as? TimeInterval != 300000
		#else
		defaults.object(forKey: "KeyRepeatEnabled") as? Bool ?? true
		#endif
	}

	static var keyRepeatDelay: TimeInterval {
		#if targetEnvironment(macCatalyst)
		// No idea what these key repeat preference values are meant to calculate out to, but
		// this seems about right. Tested by counting frames in a screen recording.
		(defaults.object(forKey: "InitialKeyRepeat") as? TimeInterval ?? 84) * 0.012
		#else
		defaults.object(forKey: "KeyRepeatDelay") as? TimeInterval ?? 0.4
		#endif
	}

	static var keyRepeat: TimeInterval {
		#if targetEnvironment(macCatalyst)
		(defaults.object(forKey: "KeyRepeat") as? TimeInterval ?? 8) * 0.012
		#else
		defaults.object(forKey: "KeyRepeatInterval") as? TimeInterval ?? 0.1
		#endif
	}

	private init() {}

}
