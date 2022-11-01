# MSGKS
## Modern Simple Graphical Krist Shop
THIS IS IN DEVELOPMENT USE AT OWN RISK

This is a graphical [Krist](https://www.krist.dev) shop for ComputerCraft:Tweaked. This uses [Basalt](https://basalt.madefor.cc/#/) for the GUI.
## Features
* Graphical interface
* Cart feature
  * Put together a cart of items to purchase with one transaction
  * Fine tune the amount of items you want to purchase
  * Get the most out of your krist
* Graphical config menu
  * Suggests items that are in the configured input chests
  * Shows price preview information
* Customization
  * Shop description
  * Per-item descriptions

## Setup
To install, place a computer and a chest within a claim where strangers have permission to interact with a computer and open storage. This chest will be your output chest, attach a modem to both, and connect as many other storage devices as you want on the network.

Run the installer with

`wget run https://raw.githubusercontent.com/MasonGulu/msgks/master/install.lua`

Once that finishes type `config` to edit the shop config and listings.

Once you've configured the shop add `shell.run("msgks.lua")` to your startup file.

## Configuration
### Config
* Shop Name - Name to display in banner of shop
* Contact info - Name to display as contact information
* Krist address - Address to listen to
* URL - Krist endpoint url
* Private key - Krist private key for refunds / api access
* Name - Optional, set if you want a name/metaname for your shop ex. "alt.kst" or "coolshop@alt.kst"
* Purchase timeout - Seconds to give a user to pay before wiping the cart
* Terminate password - password required to terminate the shop
* Terminate diskID - Optional, set to a diskID of a disk you have sole control of, you can later use this to terminate your shop.
* Shop Description - Longform field, will be displayed in info page
* Output inventory - chest to output paid for items to
* Input inventories - chests to pull items from

Don't forget to click save after making your changes.
### Listings

Use the add button to create a new listing, or select one and click edit.
* Name - Friendly name to display for this item
* Item ID - MC ID of the item 
* Price - Price in krist for the item
* Description - Text field that will be displayed to the user

Don't forget to click save.