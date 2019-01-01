//
//  String+Extensions.swift
//  SwitchNetworkInstaller
//
//  Created by Dylan Elliott on 1/1/19.
//  Copyright © 2019 Dylan Elliott. All rights reserved.
//

import Foundation

extension String {
	var isValidIPAddress: Bool {
		let ipAddressRegex = try! NSRegularExpression(pattern: "\\d+\\.\\d+\\.\\d+\\.\\d+")
		let stringRange = NSRange(location: 0, length: self.utf16.count)
		let matchRange = ipAddressRegex.rangeOfFirstMatch(in: self, options: NSRegularExpression.MatchingOptions.anchored, range: stringRange)
		
		return matchRange == stringRange
	}
}
