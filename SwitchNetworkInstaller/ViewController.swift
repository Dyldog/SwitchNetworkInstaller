//
//  ViewController.swift
//  SwitchNetworkInstaller
//
//  Created by Dylan Elliott on 30/12/18.
//  Copyright © 2018 Dylan Elliott. All rights reserved.
//

import Cocoa

class ViewController: NSViewController, NSControlTextEditingDelegate {
	
	
	@IBOutlet var filePathLabel: NSTextField!
	@IBOutlet var switchIPAddressField: NSTextField!
	@IBOutlet var installButton: NSButton!
	@IBOutlet var logView: NSTextView!
	
	var selectedFileURL: URL?
	var logLineStrings: [String] = []

	override func viewDidLoad() {
		super.viewDidLoad()
		
		updateInstallButton()
	}

	@IBAction func fileSelectButtonTapped(sender: NSButton) {
		let panel = NSOpenPanel()
		panel.allowedFileTypes = ["nsp"]
		panel.begin { response in
			if response == NSApplication.ModalResponse.OK {
				self.selectedFileURL = panel.url
				self.updateInstallButton()
			}
		}
	}
	
	func controlTextDidChange(_ obj: Notification) {
		updateInstallButton()
	}
	
	private func updateInstallButton() {
		filePathLabel.stringValue = (selectedFileURL as NSURL?)?.resourceSpecifier?.removingPercentEncoding ?? "No file selected..."
		
		let fileSelected = (selectedFileURL != nil)
		
		let ipAddressString = switchIPAddressField.stringValue
		let ipAddressRegex = try! NSRegularExpression(pattern: "\\d+\\.\\d+\\.\\d+\\.\\d+")
		let stringRange = NSRange(location: 0, length: ipAddressString.utf16.count)
		
		let matchRange = ipAddressRegex.rangeOfFirstMatch(in: switchIPAddressField.stringValue, options: NSRegularExpression.MatchingOptions.anchored, range: stringRange)
		
		let validIPAddressEntered = matchRange == stringRange
		
		installButton.isEnabled = (fileSelected && validIPAddressEntered)
	}
	
	@IBAction func installButtonTapped(sender: NSButton) {
		logLineStrings.removeAll()
		updateLogTextView()
		
		let urlString = (selectedFileURL! as NSURL).resourceSpecifier!.removingPercentEncoding!
		runNetworkInstall(filePath: urlString, ipAddress: switchIPAddressField.stringValue)
	}
	
	func runNetworkInstall(filePath: String, ipAddress: String) {
		print(filePath, ipAddress)
		let scriptPath = Bundle.main.path(forResource: "remote_install_pc", ofType: "py")!
		shell(launchPath: "/usr/local/bin/python3", args: scriptPath, ipAddress, filePath, onOutput: {
			self.logLineStrings.append($0)
			self.updateLogTextView()
		})
	}
	
	private func updateLogTextView() {
		logView.string = logLineStrings.joined(separator: "\n")
	}
}

extension ViewController {
	func shell(launchPath: String, args: String..., onOutput: @escaping (String) -> Void) {
		let task = Process()
		task.launchPath = launchPath
		task.arguments = args
		
		let pipe = Pipe()
		task.standardOutput = pipe
		task.standardError = pipe
		let outHandle = pipe.fileHandleForReading
		outHandle.waitForDataInBackgroundAndNotify()
		
		NotificationCenter.default.addObserver(
			forName: NSNotification.Name.NSFileHandleDataAvailable,
			object: outHandle, queue: nil) {  notification -> Void in
				let data = outHandle.availableData
				if data.count > 0 {
					if let str = NSString(data: data, encoding: String.Encoding.utf8.rawValue) {
						onOutput(str as String)
					}
					outHandle.waitForDataInBackgroundAndNotify()
				}
		}
		
		task.launch()
	}
}
