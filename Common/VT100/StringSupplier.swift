//
//  StringSupplier.swift
//  NewTerm Common
//
//  Created by Adam Demasi on 2/4/21.
//

import Foundation
import SwiftTerm
import SwiftUI

fileprivate extension View {
	static func + (lhs: Self, rhs: some View) -> AnyView {
		AnyView(ViewBuilder.buildBlock(lhs, AnyView(rhs)))
	}
}

open class StringSupplier {

	open var terminal: Terminal!
	open var colorMap: ColorMap!
	open var fontMetrics: FontMetrics!
	open var cursorVisible = true

	public init() {}

    public func attributedString(forScrollInvariantRow row: Int) -> AnyView {
        guard let terminal = terminal else {
            fatalError()
        }

        //		guard let line = terminal.getScrollInvariantLine(row: row) else {
        //			return AnyView(EmptyView())
        //		}
        let line = terminal.buffer.lines[row]
        //        NSLog("NewTermLog: line[\(row)]=\(line)")

        let cursorPosition = terminal.getCursorLocation()
        let scrollbackRows = terminal.getTopVisibleRow()

        return attributedString(line: line, cursorX: row - scrollbackRows == cursorPosition.y ? cursorPosition.x : -1)
    }

    public func attributedString(line: BufferLine, cursorX: Int) -> AnyView {
		var lastAttribute = Attribute.empty
		var views = [AnyView]()
		var buffer = ""
		var bufferWidth = 0
		var skipContinuationCell = false

        for j in 0..<line.count {
			if skipContinuationCell {
				skipContinuationCell = false
				continue
			}

			let data = line[j]
			let isCursor = cursorVisible && j == cursorX

			if isCursor || lastAttribute != data.attribute {
				if !buffer.isEmpty || bufferWidth > 0 {
					views.append(text(buffer, width: bufferWidth, attribute: lastAttribute))
				}
				lastAttribute = data.attribute
				buffer.removeAll()
				bufferWidth = 0
			}

			let character = data.getCharacter()
			buffer.append(character == "\0" ? " " : character)
			bufferWidth += max(Int(data.width), 1)
			if data.width > 1 {
				skipContinuationCell = true
			}

			if isCursor {
				// We may need to insert a space for the cursor to show up.
				if buffer.isEmpty {
					buffer.append(" ")
				}

				views.append(text(buffer, width: bufferWidth, attribute: lastAttribute, isCursor: true))
				buffer.removeAll()
				bufferWidth = 0
			}
		}

		// Append the final run
		if !buffer.isEmpty || bufferWidth > 0 {
			views.append(text(buffer, width: bufferWidth, attribute: lastAttribute))
		}

		return AnyView(HStack(alignment: .firstTextBaseline, spacing: 0) {
			views.reduce(AnyView(EmptyView()), { $0 + $1 })
		}
//        .frame(maxWidth: .infinity, alignment: .leading)
        )
	}

	private func text(_ run: String, width: Int, attribute: Attribute, isCursor: Bool = false) -> AnyView {
		var fgColor = attribute.fg
		var bgColor = attribute.bg

		if attribute.style.contains(.inverse) {
			swap(&bgColor, &fgColor)
			if fgColor == .defaultColor {
				fgColor = .defaultInvertedColor
			}
			if bgColor == .defaultColor {
				bgColor = .defaultInvertedColor
			}
		}

		let foreground = colorMap?.color(for: fgColor,
																 isForeground: true,
																 isBold: attribute.style.contains(.bold),
																 isCursor: isCursor)
		let background = colorMap?.color(for: bgColor,
																 isForeground: false,
																 isCursor: isCursor)

		let font: UIFont?
		if attribute.style.contains(.bold) || attribute.style.contains(.blink) {
			font = attribute.style.contains(.italic) ? fontMetrics?.boldItalicFont : fontMetrics?.boldFont
		} else if attribute.style.contains(.dim) {
			font = attribute.style.contains(.italic) ? fontMetrics?.lightItalicFont : fontMetrics?.lightFont
		} else {
			font = attribute.style.contains(.italic) ? fontMetrics?.italicFont : fontMetrics?.regularFont
		}

		let width = CGFloat(width) * (fontMetrics?.width ?? 0)

		return AnyView(
			Text(run)
				// Text attributes
				.foregroundColor(Color(foreground ?? .white))
				.font(Font(font ?? .monospacedSystemFont(ofSize: 12, weight: .regular)))
				.underline(attribute.style.contains(.underline))
				.strikethrough(attribute.style.contains(.crossedOut))
				.tracking(0)
				// View attributes
				.allowsTightening(false)
				.lineLimit(1)
				.background(Color(background ?? .black))
				.frame(width: width)
				.fixedSize(horizontal: false, vertical: true)
		)
	}

}
