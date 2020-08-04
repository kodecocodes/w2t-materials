#  Flo/FloW
Chapter 13 CloudKit starter app

The iPhone app sets up CloudKit container and private database zone. The first drink event creates the database's record type. If running on a device, the first drink event also creates the subscription from this device for change notifications.

The iPhone app sends data to the watch app via WatchConnectivity, whenever it fetches changes from the database.

The watch app sends new drink events to the iPhone app, via WatchConnectivity. The iPhone app then sends the record to the iCloud database.

The iPhone simulator doesn't support remote notifications, so you must run the iPhone app on the device to see it update itself from a silent notification from the private database.

To install on devices: build and run the iPhone app: this also installs the watch app, which you can start manually.
