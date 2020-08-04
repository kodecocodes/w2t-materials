#  Flo/FloW
Chapter 13 CloudKit final app

The iPhone app sets up CloudKit container and private database zone. The first drink event creates the database's record type. If running on a device, the first drink event also creates the subscription from this device for change notifications.

The iPhone app sends data to the watch app via WatchConnectivity, whenever it fetches changes from the database.

The watch app sends new drink events directly to the iCloud database; if the iCloud account isn't available, it falls back on WatchConnectivity.

The watch simulator cannot "see" the iPhone simulator's iCloud login, so the watch app's use of CloudKit must be tested on the device.

Similarly, the iPhone simulator doesn't support remote notifications, so you must run the iPhone app on the device to see it update itself from a silent notification from the private database.

To install on devices: build and run the iPhone app: this also installs the watch app, which you can start manually.
