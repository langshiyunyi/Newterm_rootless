//
//  TerminalConstants.swift
//  NewTerm Common
//
//  Created by Adam Demasi on 2/4/21.
//

import Foundation
import CoreGraphics

public struct ScreenSize: Hashable {
	public var cols: UInt16
	public var rows: UInt16
	public var pixelWidth: UInt16
	public var pixelHeight: UInt16

	public static let `default` = ScreenSize(cols: 80, rows: 25)

	public init(cols: UInt16, rows: UInt16, cellSize: CGSize = .zero) {
		self.cols = cols
		self.rows = rows
		self.pixelWidth = UInt16(cellSize.width)
		self.pixelHeight = UInt16(cellSize.height)
	}

	var windowSize: winsize {
		winsize(ws_row: rows,
						ws_col: cols,
						ws_xpixel: cols * pixelWidth,
						ws_ypixel: rows * pixelHeight)
	}
}

public struct EscapeSequences {

	// https://invisible-island.net/xterm/ctlseqs/ctlseqs.html#h2-PC-Style-Function-Keys

	public static let backspace = "\u{7f}".utf8Array
	public static let meta      = "\u{1b}".utf8Array
	public static let tab       = "\t".utf8Array
	public static let `return`  = "\r".utf8Array

	public static let up        = "\u{1b}[A".utf8Array
	public static let upApp     = "\u{1b}OA".utf8Array
	public static let down      = "\u{1b}[B".utf8Array
	public static let downApp   = "\u{1b}OB".utf8Array
	public static let left      = "\u{1b}[D".utf8Array
	public static let leftApp   = "\u{1b}OD".utf8Array
	public static let leftMeta  = "b".utf8Array // (removed \e)
	public static let right     = "\u{1b}[C".utf8Array
	public static let rightApp  = "\u{1b}OC".utf8Array
	public static let rightMeta = "f".utf8Array // (removed \e)

	public static let home      = "\u{1b}[H".utf8Array
	public static let homeApp   = "\u{1b}OH".utf8Array
	public static let end       = "\u{1b}[F".utf8Array
	public static let endApp    = "\u{1b}OF".utf8Array
	public static let pageUp    = "\u{1b}[5~".utf8Array
	public static let pageDown  = "\u{1b}[6~".utf8Array
	public static let delete    = "\u{1b}[3~".utf8Array
    public static let Delete    = "\u{1b}[3~".utf8Array

	public static let fn        = [
		"OP", "OQ", "OR", "OS", "[15~", "[17~", "[18~", "[19~", "[20~", "[21~", "[23~", "[24~"
	].map { "\u{1b}\($0)".utf8Array }
}

public extension UTF8Char {
	var controlCharacter: UTF8Char {
		switch self {
		case 0x3F:
			return 0x7F
		case 0x40...0x5F:
			return self - 0x40
		case 0x61...0x7A:
			return self - 0x60
		default:
			return self
		}
	}
}
