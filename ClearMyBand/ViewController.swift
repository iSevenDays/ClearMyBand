//
//  ViewController.swift
//  ClearMyBand
//
//  Created by Anton Sokolchenko on 10.01.17.
//  Copyright © 2017 Sokolchenko. All rights reserved.
//

import UIKit

let knownTiles: [String: String] = ["4076B009-0455-4AF7-A705-6D4ACD45A556": "Notifications",
                                    "823BA55A-7C98-4261-AD5E-929031289C6E": "Email",
                                    "69A39B4E-084B-4B53-9A1B-581826DF9E36": "Weather"]

class ViewController: UIViewController {

	var client: MSBClient?
	
	@IBOutlet weak var statusItem: UINavigationItem!
	@IBOutlet weak var activityIndicatorView: UIActivityIndicatorView!
	@IBOutlet weak var clearNotificationsBtn: UIButton!
	@IBOutlet weak var tableView: UITableView!
	
	let tileFabric = TileFabric()
	
	var strip: [StrappModel] = []
	
	let clearingNotificationsText = "Clearing notifications..."
	let clearedNotificationsText = "Notifications cleared"
	
	override func viewDidLoad() {
		super.viewDidLoad()
		tableView.delegate = self
		tableView.dataSource = self
		MSBClientManager.shared().delegate = self
		
		connectToBand()
		
		NotificationCenter.default.addObserver(self, selector: #selector(bluetoothStateChanged), name: NSNotification.Name.MSBClientManagerBluetoothPower, object: nil)
	}
	
	func bluetoothStateChanged(notification: Notification) {
		guard let enabled = notification.userInfo?[MSBClientManagerBluetoothPowerKey] as? NSNumber else { return }
		if enabled.boolValue {
			connectToBand()
		}
	}
	
	func connectToBand() {
		if let client = MSBClientManager.shared().attachedClients().first as? MSBClient {
			showConnectingStatus()
			self.client = client
			client.tileDelegate = self
			MSBClientManager.shared().connect(client)
		}
	}
	
	// MARK: - Connection status
	func showConnectingStatus() {
		activityIndicatorView.startAnimating()
		statusItem.title = "Connecting..."
	}
	
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
	
	// MARK: - Clear notifications tile adding to Microsoft Band 2 strip
	
	@IBAction func removeClearTile(_ sender: UIButton) {
		client?.tileManager.removeTile(with: UUID(uuidString: tileFabric.clearTileID), completionHandler: { [weak self] (error) in
			if error == nil {
				self?.show(notificationMessage: "Removed", withTitle: "Success")
			} else {
				self?.show(notificationMessage: "Can not remove the tile", withTitle: "Error")
			}
		})
	}
	
	@IBAction  func addClearTileToBand(_ sender: UIButton) {
		guard let clearTile = tileFabric.clearTile() else {
			show(notificationMessage: "Can not create a tile", withTitle: "Error")
			return
		}
		
		client?.tileManager.add(clearTile, completionHandler: { [weak self] (error) in
			guard let strongSelf = self else { return }
			
			if error == nil {
				strongSelf.updateClearTileWithText(text: strongSelf.clearingNotificationsText)
			} else if let error = error as? NSError {
				if error.code == MSBErrorType.tileAlreadyExist.rawValue {
					strongSelf.updateClearTileWithText(text: strongSelf.clearingNotificationsText)
				} else {
					strongSelf.show(notificationMessage: "Can not create a tile on Band", withTitle: "Error")
				}
			}
		})
	}
	
	func updateClearTileWithText(text: String) {
		NSLog("%@", "Updating clear tile")
		
		let textData = try! MSBPageTextBlockData(elementId: 1, text: text)
		
		let pageData = MSBPageData(id: UUID(uuidString: tileFabric.clearTilepageDataID), layoutIndex: 0, value: [textData])
		
		client?.tileManager.setPages([pageData as Any], tileId: UUID(uuidString: tileFabric.clearTileID), completionHandler: { [weak self] (error) in
			if error == nil {
				self?.show(notificationMessage: "Clear tile sent successfully", withTitle: "Success")
			} else {
				self?.show(notificationMessage: "Error sending tile information", withTitle: "Error")
			}
		})
	}
	
	// MARK: - Actions
	@IBAction func clearNotifications(_ sender: UIButton) {
		let enabledStrapps = strip.filter({$0.isOn})
		NSLog("%@%", enabledStrapps)
		
		guard let tileManager = client?.tileManager as? MSBTileManager else { return }
		
		for strapp in enabledStrapps {
			tileManager.utility.clearStrapp(strapp.appID, completion: nil)
		}
		updateClearTileWithText(text: clearedNotificationsText)
		show(notificationMessage: "Notifications cleared", withTitle: "Success")
	}
	
	func show(notificationMessage: String, withTitle title: String) {
		let controller = UIAlertController(title: title, message: notificationMessage, preferredStyle: .alert)
		let okAction = UIAlertAction(title: "Ok", style: .default, handler: nil)
		controller.addAction(okAction)
		present(controller, animated: true, completion: nil)
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
				var displayName = strap.strappDescriptor.displayName ?? "Unknown"
				if displayName == "(DEFAULT NAME)" {
					if let knowTileName = knownTiles[strapAppID.uuidString] {
						displayName = knowTileName
					}
				}
				let strapModel = StrappModel(name: displayName, appID: strapAppID, isOn: isOn)
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
		NSLog("%@", "clientDidConnect")
		showConnectedStatusFor(clientName: client.name)
		reloadTiles()
	}
	
	func clientManager(_ clientManager: MSBClientManager!, clientDidDisconnect client: MSBClient!) {
		NSLog("%@", "clientDidDisconnect")
		showDisconnectedStatusFor(clientName: client.name)
	}
	
	func clientManager(_ clientManager: MSBClientManager!, client: MSBClient!, didFailToConnectWithError error: Error!) {
		NSLog("%@", "didFailToConnectWithError")
		showFailedStatusFor(clientName: client.name)
	}
}

extension ViewController: MSBClientTileDelegate {
	func client(_ client: MSBClient!, tileDidOpen event: MSBTileEvent!) {
		NSLog("%@", "tileDidOpen \(event)")
		
		if event.tileId.uuidString == tileFabric.clearTileID {
			let emptySender = UIButton()
			clearNotifications(emptySender)
		}
	}
	
	func client(_ client: MSBClient!, tileDidClose event: MSBTileEvent!) {
		NSLog("%@", "tileDidClose \(event)")
		updateClearTileWithText(text: clearingNotificationsText)
	}
}
