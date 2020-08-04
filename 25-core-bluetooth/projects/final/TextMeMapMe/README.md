#  TextMeMapMe

Chapter 25: Core Bluetooth final app

## Notes for the editors

### Testing the app

Build and run on Apple Watch Series 2 + iOS 11 device, doing the usual dance to trust the developer.

On the iOS device, select Peripheral Mode and, when you see the Watch app launching, switch on Advertising. After a while, the Watch app's button titles will change to Text Me and Map Me.

Tap the Text Me button, and wait ... the iOS device's text will appear on the watch.

Tap the Map Me button, and allow the app to use your location, then tap the button again. The peripheral will open Maps at your location. If you tap TextMeMapMe to return to the app, often (always?) Maps will reopen. I don't think the write request is being repeated, and I've stopped location updates. Stymied!



