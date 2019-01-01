//
//  ShellProcess.swift
//  SwitchNetworkInstaller
//
//  Created by Dylan Elliott on 1/1/19.
//  Copyright © 2019 Dylan Elliott. All rights reserved.
//

import Foundation

class ShellProcess {
	let launchPath: String
	let args: [String]?
	let onOutput: ((String) -> Void)?
	
	init(launchPath: String, args: [String]? = [], onOutput: ((String) -> Void)?) {
		self.launchPath = launchPath
		self.args = args
		self.onOutput = onOutput
	}
	
	func launch(_ withArgs: [String]? = []) {
		let task = Process()
		task.launchPath = launchPath
		task.arguments = withArgs
		
		let outPipe = Pipe()
		task.standardOutput = outPipe
		
		let errorPipe = Pipe()
		task.standardError = errorPipe
		
		addOutputDataNotification(outPipe)
		addOutputDataNotification(errorPipe)
		
		task.launch()
	}
	
	private func addOutputDataNotification(_ pipe: Pipe) {
		let outHandle = pipe.fileHandleForReading
		outHandle.waitForDataInBackgroundAndNotify()
		
		NotificationCenter.default.addObserver(forName: NSNotification.Name.NSFileHandleDataAvailable, object: outHandle, queue: nil) {  notification -> Void in
			let data = outHandle.availableData
			if data.count > 0 {
				if let str = NSString(data: data, encoding: String.Encoding.utf8.rawValue) {
					print("Output: \(str)")
					self.onOutput?(str as String)
				}
				outHandle.waitForDataInBackgroundAndNotify()
			}
		}
	}
}
