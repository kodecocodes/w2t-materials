#  TextMeMapMe

Chapter 25: Core Bluetooth starter app

## Notes for the editors

### Testing the app

Build and run on two iOS 11 devices, doing the usual dance to trust the developer.

If you don't have two devices running iOS 11, change the project iOS deployment target to 10.3, and uncheck Use Safe Area Layout Guides in the file inspector of one of the storyboard's view controllers.

On one device, select Peripheral Mode, and switch on Advertising. On the other device, select Central Mode. Bring the devices very close together; I often hold one above the other. The peripheral's text will appear in the central's text view, and the title of the central's bar button will change to Map Me.

Edit the peripheral text, and tap Done. The edited text should appear in the central's text view. Sometimes this works really well; other times, nothing happens.

Tap the Map Me button, and allow the app to use your location, then tap the button again. The peripheral will open Maps at your location. If you tap TextMeMapMe to return to the app, often (always?) Maps will reopen. I don't think the write request is being repeated, and I've stopped location updates. Stymied!

### Architecture

I tried to move the delegate methods into separate classes, like in Owen Brown's Arduino_Servo. But I couldn't see how to update the CentralViewController's UI without making it the peripheral delegate. And a CentralManager delegate method sets the peripheral's delegate, so I left those delegate methods in CentralViewController too.

### Queues

I tried specifying global queues for the central and peripheral managers, but got no transfer of data at all!

