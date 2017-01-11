# ClearMyBand
Clear My Band for iOS. Clears notifications on Microsoft Band 2


Simple View with available tiles.

For selected tiles there is an option to Clear Notifications.

Press the button and see that Microsoft Band 2 no more has notifications for the selected tile.



<center><img src="ClearMyBand/Screenshots/1.PNG?raw=true" alt="User Interface" width="250"></center>


**Details of implementation**

Project uses swizzling and private classes declaration to achieve the goal.

**Clear Tile**

Creates a tile on Microsoft Band 2.

Tapping on the tile will open the tile with text "Clearing notifications...".
If the event is successfully received by ClearMyBand app, then app will try to remove previously selected notifications.

If operation was successfly, "Notifications cleared" will appear on Microsoft Band 2.
