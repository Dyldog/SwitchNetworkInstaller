//
//  URL+Extensions.swift
//  SwitchNetworkInstaller
//
//  Created by Dylan Elliott on 1/1/19.
//  Copyright © 2019 Dylan Elliott. All rights reserved.
//

import Foundation

extension URL {
	var displayableString: String? {
		return (self as NSURL).resourceSpecifier?.removingPercentEncoding
	}
}
