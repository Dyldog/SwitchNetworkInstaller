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
	
	var selectedFileURL: URL?

	override func viewDidLoad() {
		super.viewDidLoad()

		// Do any additional setup after loading the view.
		updateView()
	}

	override var representedObject: Any? {
		didSet {
		// Update the view, if already loaded.
		}
	}
	
	@IBAction func fileSelectButtonTapped(sender: NSButton) {
		let panel = NSOpenPanel()
		panel.allowedFileTypes = ["nsp"]
		panel.begin { response in
			if response == NSApplication.ModalResponse.OK {
				self.selectedFileURL = panel.url
				self.updateView()
			}
		}
	}
	
	@IBAction func installButtonTapped(sender: NSButton) {
		let escapedURLString = (selectedFileURL! as NSURL).resourceSpecifier!
		let urlString = escapedURLString.removingPercentEncoding!
		runNetworkInstall(filePath: urlString, ipAddress: switchIPAddressField.stringValue)
	}
	
	func updateView() {
		filePathLabel.stringValue = selectedFileURL?.absoluteString ?? "No file selected..."

		let fileSelected = (selectedFileURL != nil)
		
		
		let ipAddressString = switchIPAddressField.stringValue
		let ipAddressRegex = try! NSRegularExpression(pattern: "\\d+\\.\\d+\\.\\d+\\.\\d+")
		let stringRange = NSRange(location: 0, length: ipAddressString.utf16.count)
		
		let matchRange = ipAddressRegex.rangeOfFirstMatch(in: switchIPAddressField.stringValue, options: NSRegularExpression.MatchingOptions.anchored, range: stringRange)
		
		let validIPAddressEntered = matchRange == stringRange
		
		installButton.isEnabled = (fileSelected && validIPAddressEntered)
	}

	func controlTextDidChange(_ obj: Notification) {
		updateView()
	}

}

extension ViewController {
	@discardableResult
	func shell(launchPath: String, args: String...) -> Int32 {
		let task = Process()
		task.launchPath = launchPath
		task.arguments = args
		task.launch()
		task.waitUntilExit()
		return task.terminationStatus
	}
	
	func runNetworkInstall(filePath: String, ipAddress: String) {
		print(filePath, ipAddress)
		let scriptPath = Bundle.main.path(forResource: "remote_install_pc", ofType: "py")!
		shell(launchPath: "/usr/local/bin/python3", args: scriptPath, ipAddress, filePath)
	}
}
