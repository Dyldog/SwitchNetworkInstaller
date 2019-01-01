//
//  ViewController.swift
//  SwitchNetworkInstaller
//
//  Created by Dylan Elliott on 30/12/18.
//  Copyright © 2018 Dylan Elliott. All rights reserved.
//

import Cocoa

class ViewController: NSViewController, NSControlTextEditingDelegate {
	
	lazy var installProcess = NetworkInstallProcess(onOutput: { self.logLineStrings.append($0) })
	
	@IBOutlet var filePathLabel: NSTextField!
	@IBOutlet var switchIPAddressField: NSTextField!
	@IBOutlet var installButton: NSButton!
	@IBOutlet var logView: NSTextView!
	
	var selectedFileURL: URL? {
		didSet {
			filePathLabel.stringValue = selectedFileURL?.displayableString ?? "No file selected..."
		}
	}
	
	var logLineStrings: [String] = [] {
		didSet {
			logView.string = logLineStrings.joined(separator: "\n")
		}
	}

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
		let fileSelected = (selectedFileURL != nil)
		let validIPAddressEntered = switchIPAddressField.stringValue.isValidIPAddress
		
		installButton.isEnabled = (fileSelected && validIPAddressEntered)
	}
	
	@IBAction func installButtonTapped(sender: NSButton) {
		logLineStrings.removeAll()
		
		let urlString = (selectedFileURL! as NSURL).resourceSpecifier!.removingPercentEncoding!
		runNetworkInstall(filePath: urlString, ipAddress: switchIPAddressField.stringValue)
	}
	
	func runNetworkInstall(filePath: String, ipAddress: String) {
		installProcess.launch(withIPAddress: ipAddress, filePath: filePath)
	}
}

class NetworkInstallProcess: ShellProcess {
	override init(launchPath: String, args: [String]?, onOutput: ((String) -> Void)?) {
		fatalError("Use `init()`")
	}
	
	init(onOutput: ((String) -> Void)? = nil) {
		super.init(launchPath: "/usr/local/bin/python3", args: nil, onOutput: onOutput)
	}
	
	override func launch(_ withArgs: [String]?) {
		fatalError("Use `launch(withIPAddress ipAddress: String, filePath: String)`")
	}
	
	func launch(withIPAddress ipAddress: String, filePath: String) {
		let scriptPath = Bundle.main.path(forResource: "remote_install_pc", ofType: "py")!
		super.launch([scriptPath, ipAddress, filePath])
	}
}
