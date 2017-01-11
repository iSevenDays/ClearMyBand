//
//  ClearTile.swift
//  ClearMyBand
//
//  Created by Anton Sokolchenko on 11.01.17.
//  Copyright © 2017 Sokolchenko. All rights reserved.
//

import Foundation

class TileFabric {
	
	var clearTileID: String {
		// Just unique UUID
		return "CABDBA9F-12FD-47A5-1453-E7270A43BB99"
	}
	
	var clearTilepageDataID: String {
		// Just unique UUID
		return "CABDBA9F-12FD-47A5-1453-E7270A43BB98"
	}
	
	func clearTile() -> MSBTile? {
		
		let tileName = "Clear tile"
		
		let tileIcon = try! MSBIcon(uiImage: UIImage(named: "clearIcon46"))
		
		let smallIcon = try! MSBIcon(uiImage: UIImage(named: "clearIcon24"))
		
		let tileID = UUID(uuidString: clearTileID)!
		
		guard let tile = try? MSBTile(id: tileID, name: tileName, tileIcon: tileIcon, smallIcon: smallIcon) else {
			NSLog("%@", "Error can not create tile")
			return nil
		}
		
		let pageTextBlockRect = MSBPageRect(x: 10, y: 0, width: 300, height: 40)
		
		// add the text block to contain the first message
		guard let pageTextBlock = MSBPageTextBlock(rect: pageTextBlockRect, font: MSBPageTextBlockFont.small) else {
			NSLog("%@", "Error can not create pageTextBlock")
			return nil
		}
		
		pageTextBlock.elementId = 1
		pageTextBlock.horizontalAlignment = .center
		pageTextBlock.autoWidth = true
		pageTextBlock.color = try! MSBColor(uiColor: UIColor.white)
		
		let flowPanelRect = MSBPageRect(x: 10, y: 44, width: 300, height: 105)
		guard let flowPanel = MSBPageFlowPanel(rect: flowPanelRect) else {
			NSLog("%@", "Error can not create flowPanel")
			return nil
		}
		
		flowPanel.addElement(pageTextBlock)
		
		let pageLayout = MSBPageLayout(root: flowPanel)
		tile.pageLayouts.addObjects(from: [pageLayout as Any])
		
		return tile
	}
	
	
}
