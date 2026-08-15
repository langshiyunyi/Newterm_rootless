//
//  SettingsView.swift
//  NewTerm (iOS)
//
//  Created by Adam Demasi on 3/4/21.
//

import SwiftUI
import CoreHaptics
import NewTermCommon

fileprivate extension KeyboardArrowsStyle {
	var name: String {
		switch self {
		case .butterfly:   return .localize("ARROW_STYLE_BUTTERFLY")
		case .scissor:     return .localize("ARROW_STYLE_SCISSOR")
		case .classic:     return .localize("ARROW_STYLE_CLASSIC")
		case .vim:         return .localize("ARROW_STYLE_VIM")
		case .vimInverted: return .localize("ARROW_STYLE_VIM_INVERTED")
		}
	}
}

fileprivate extension KeyboardTrackpadSensitivity {
	var name: String {
		switch self {
		case .off:    return .localize("SENSITIVITY_OFF")
		case .low:    return .localize("SENSITIVITY_LOW")
		case .medium: return .localize("SENSITIVITY_MEDIUM")
		case .high:   return .localize("SENSITIVITY_HIGH")
		}
	}
}

struct SettingsView: View {

	@Environment(\.presentationMode)
	var presentationMode

	@ObservedObject var preferences = Preferences.shared

	var windowScene: UIWindowScene?

	@State private var keyboardToolbarState = KeyboardToolbarViewState()
	@ObservedObject private var keyboardShortcutPreferences = KeyboardShortcutPreferences.shared

	private func dismiss() {
		if let windowScene = windowScene {
			UIApplication.shared.requestSceneSessionDestruction(windowScene.session, options: nil, errorHandler: nil)
		} else {
			// TODO: presentationMode seems useless when UIKit is presenting
			// the view controller rather than SwiftUI? Ugh
//			presentationMode.wrappedValue.dismiss()
			NotificationCenter.default.post(name: RootViewController.settingsViewDoneNotification, object: nil)
		}
	}

	var body: some View {
		let list = List() {
			PreferencesGroup(header: Text("Terminal")) {
				NavigationLink(destination: SettingsFontView(),
											 label: { KeyValueView(title: Text("Font"),
																						 value: Text("\(preferences.fontName), \(Int(preferences.fontSize))")) })

				NavigationLink(destination: SettingsThemeView(),
											 label: { KeyValueView(title: Text("Theme"),
																						 value: Text(preferences.themeName)) })
			}

				PreferencesGroup(header: Text("Keyboard"),
										 footer: Text("Touch and hold the Space bar, then drag around the keyboard to move the cursor.")) {
					NavigationLink(destination: SettingsKeyboardShortcutsView(),
									 label: {
						KeyValueView(title: Text("Shortcut Keys"),
									 value: Text(keyboardShortcutPreferences.keys.map(\.keycapTitle).joined(separator: " · ")))
					})

					PreferencesPicker(selection: $preferences.keyboardArrowsStyle,
													label: Text("Arrow Keys"),
													valueLabel: Text(preferences.keyboardArrowsStyle.name),
													asLink: true) {
					ForEach(KeyboardArrowsStyle.allCases, id: \.self) { key in
						HStack(alignment: .center) {
							Text(key.name)
							Spacer()
							KeyboardToolbarKeyStack(toolbar: .padPrimaryTrailing,
																			arrowsStyle: key)
								.environmentObject(keyboardToolbarState)
								.disabled(true)
						}
							.height(44)
					}
				}

				PreferencesPicker(selection: $preferences.keyboardTrackpadSensitivity,
													label: Text("Trackpad Sensitivity"),
													valueLabel: Text(preferences.keyboardTrackpadSensitivity.name),
													asStepper: true)
			}

			PreferencesGroup(header: Text("Bell"),
											 footer: Text("When a terminal application needs to notify you of something, it rings the bell.")) {
				Toggle("Make beep sound", isOn: $preferences.bellSound)
				if CHHapticEngine.capabilitiesForHardware().supportsHaptics {
					Toggle("Make haptic vibration", isOn: $preferences.bellVibrate)
				}
				Toggle("Show heads-up display", isOn: $preferences.bellHUD)
			}

			PreferencesGroup {
				NavigationLink(destination: SettingsAdvancedView(),
											 label: { Text("Advanced") })
			}

			PreferencesGroup {
				NavigationLink(destination: SettingsAboutView(),
											 label: { Text("About") })
			}
		}
			.listStyle(InsetGroupedListStyle())
			.onChange(of: [preferences.bellVibrate, preferences.bellSound]) { _ in
				HapticController.playBell()
			}

		return NavigationView {
			list
				.navigationBarTitle("SETTINGS", displayMode: .large)
				.navigationBarItems(trailing: Button(action: { self.dismiss() },
																						 label: { Text(verbatim: .done).bold() }))
		}
			.navigationViewStyle(StackNavigationViewStyle())
	}
}

struct SettingsKeyboardShortcutsView: View {
	@ObservedObject private var preferences = KeyboardShortcutPreferences.shared

	var body: some View {
		PreferencesList {
			Section(header: Text("Toolbar Keys"),
						 footer: Text("Drag to reorder. Swipe left to remove. Arrow keys remain fixed on the right side of the toolbar.")) {
				ForEach(preferences.keys) { key in
					HStack {
						Text(key.title)
						Spacer()
						Text(key.keycapTitle)
							.font(.system(.body, design: .monospaced))
							.foregroundColor(.secondary)
					}
				}
				.onMove(perform: preferences.move)
				.onDelete(perform: preferences.remove)
			}

			if !preferences.availableKeys.isEmpty {
				Section(header: Text("Available Keys"),
							 footer: Text("Fn opens the F1–F12 row. Shift and Control stay active for the next key press.")) {
					ForEach(preferences.availableKeys) { key in
						Button(action: { preferences.add(key) }) {
							HStack {
								Text(key.title)
								Spacer()
								Image(systemName: "plus.circle")
							}
						}
					}
				}
			}

			Section {
				Button("Reset to Defaults", action: preferences.reset)
			}
		}
		.navigationBarTitle("Shortcut Keys")
		.navigationBarItems(trailing: EditButton())
	}
}

struct SettingsView_Previews: PreviewProvider {
	static var previews: some View {
		SettingsView()
	}
}
