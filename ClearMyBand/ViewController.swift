//
//  ViewController.swift
//  ClearMyBand
//
//  Created by Anton Sokolchenko on 10.01.17.
//  Copyright © 2017 Sokolchenko. All rights reserved.
//

import UIKit


class ViewController: UIViewController {

	var client: MSBClient?
	
	@IBOutlet weak var statusItem: UINavigationItem!
	@IBOutlet weak var activityIndicatorView: UIActivityIndicatorView!
	@IBOutlet weak var clearNotificationsBtn: UIButton!
	@IBOutlet weak var tableView: UITableView!
	
	var strip: [StrappModel] = []
	
	override func viewDidLoad() {
		super.viewDidLoad()
		tableView.delegate = self
		tableView.dataSource = self
		MSBClientManager.shared().delegate = self
		
		if let client = MSBClientManager.shared().attachedClients().first as? MSBClient {
			self.client = client
			client.tileDelegate = self
			MSBClientManager.shared().connect(client)
		}
	}
	
	// MARK: - Connection status
	func showConnectedStatusFor(clientName: String) {
		activityIndicatorView.stopAnimating()
		statusItem.title = "Connected to " + clientName
	}
	
	func showDisconnectedStatusFor(clientName: String) {
		activityIndicatorView.stopAnimating()
		statusItem.title = "Disconnected from " + clientName
	}
	
	func showFailedStatusFor(clientName: String) {
		activityIndicatorView.stopAnimating()
		statusItem.title = "Failed to connect to " + clientName
	}
	
	func showCannotRetrieveStatus() {
		activityIndicatorView.stopAnimating()
		statusItem.title = "Can not retrieve tiles"
	}
	
	// MARK: - Actions
	@IBAction func clearNotifications(_ sender: UIButton) {
		let enabledStraps = strip.filter({$0.isOn})
		print(enabledStraps)
		
		guard let sms = enabledStraps.filter({$0.name == "SMS"}).first else { return }
		
		guard let tileManager = client?.tileManager as? MSBTileManager else { return }
		
		var error: NSError? = nil
		
		tileManager.utility.clearStrapp(sms.appID) { (error) in
			if let error = error {
				NSLog("%@%", "tileManagerPrivate can not clear: \(sms)")
			}
		}
//		
//		tileManager.utility.notificationFacility.clear(sms.strap, errorRef: &error)
//		
//		if let error = error {
//			NSLog("%@%", "tileManagerPrivate can not clear: \(sms)")
//		}
		
	}


	func strapSwitchAction(sender: UISwitch) {
		var strap = strip[sender.tag]
		strap.isOn = sender.isOn
		strip[sender.tag] = strap
		UserDefaults.standard.set(strap.isOn, forKey: strap.appID.uuidString)
	}
	
	// MARK: - Tiles loading
	func reloadTiles() {
		client?.tileManager.tiles(completionHandler: { [weak self] (startStrip, error) in
			guard let strongSelf = self else { return }
			guard let strapps = startStrip as? [MSBStrapp] else {
				strongSelf.showCannotRetrieveStatus()
				return
			}
			strongSelf.strip.removeAll()
			for strap in strapps {
				let strapAppID = strap.strappDescriptor.appID!
				let isOn = UserDefaults.standard.bool(forKey: strapAppID.uuidString)
				let strapModel = StrappModel(name: strap.strappDescriptor.displayName, appID: strapAppID, isOn: isOn)
				strongSelf.strip.append(strapModel)
				strongSelf.tableView.reloadData()
			}
		})
	}
}

extension ViewController: UITableViewDelegate, UITableViewDataSource {
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: "tableViewCellIdentifier", for: indexPath) as! StrapTableViewCell
		let strap = strip[indexPath.row]
		cell.nameLabel.text = strap.name
		cell.switchControl.isOn = strap.isOn
		cell.switchControl.tag = indexPath.row
		cell.switchControl.addTarget(self, action: #selector(strapSwitchAction), for: .valueChanged)
		return cell
	}
	
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return strip.count
	}
}

extension ViewController: MSBClientManagerDelegate {
	func clientManager(_ clientManager: MSBClientManager!, clientDidConnect client: MSBClient!) {
		showConnectedStatusFor(clientName: client.name)
		reloadTiles()
	}
	
	func clientManager(_ clientManager: MSBClientManager!, clientDidDisconnect client: MSBClient!) {
		showDisconnectedStatusFor(clientName: client.name)
	}
	
	func clientManager(_ clientManager: MSBClientManager!, client: MSBClient!, didFailToConnectWithError error: Error!) {
		showFailedStatusFor(clientName: client.name)
	}
}

extension ViewController: MSBClientTileDelegate {
	func client(_ client: MSBClient!, tileDidOpen event: MSBTileEvent!) {
		
	}
	
	func client(_ client: MSBClient!, tileDidClose event: MSBTileEvent!) {
		
	}
}
