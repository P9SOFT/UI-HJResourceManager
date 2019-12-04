UI+HJResourceManager
============

Simple and easy category interface of UIImage/UIButton for downloading and caching images from the web, based on HJResourceManager.

# Installation

You can download the latest framework files from our Release page.
UI+HJResourceManager also available through CocoaPods. To install it simply add the following line to your Podfile.
pod ‘UI+HJResourceManager’

# Setup

UI+HJResourceManager is library based on HJResourceManager, and HJResourceManager is framework based on Hydra.
Prepare HJResourceManager first.

```swift
Hydra.default().addNormalWorker(forName: "hjrm")

let hjrmRepoPath = "\(NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0])/hjrm"
if HJResourceManager.default().standby(withRepositoryPath: hjrmRepoPath, localJobWorkerName: "hjrm", remoteJobWorkerName: "hjrm") {
    HJResourceManager.default().bind(toHydra: Hydra.default())
}

Hydra.default().startAllWorkers()
```

# Download and Display

Ue+HJResourceManager support extension for UIImageView and UIButton to downloading and display image.
Here is simple example to download and display image by give resource url to UIImageView and UIButton.

```swift
imageView.setImageUrl(imageUrlString)
imageButton.setBackgroundImageUrl(imageUrlString)
```

Basically, you do download and display image like above example.
But you can do more handling with it.

Using placeholder image when downloading.

```swift
imageView.setImageUrl(imageUrlString, placeholderImage: placeholderImage)
```

Imagine that, you call many many images at the same time and it take some time, like working on the tableview cells, and scrolling down.
It is ugly that you waiting to see the images for last visible cell until downloading done of previous upper images.
You can change the order downloading by using cutInLine flag to true.

```swift
imageView.setImageUrl(imageUrlString, placeholderImage: nil, cutInLine: true)
```

If you want to do your own business code after download images, use completion block.

```swift
imageView.setImageUrl(imageUrlString, placeholderImage: nil, cutInLine: true) { (image:UIImage?, urlStirng:String?, remakeName:String?, remakerParameter:Any?, cipherName:String?, targetChanged:Bool) in
    if let image = image {
        // do something you want.
    }
}
```

Here is parameters of completion means,
'image' is UIImage object from downloaded data.
'urlString' is url string of resource when it called.
'remakerName' is used remaker name when it called.
'remakerParameter' is used remaker parameter object when it called.
'cipherName' is used cipher name when it called.
'targetChanged' is check flag that setted resource currently is different with downloaded resource.

UI+HJResourceManager based on HJResourceManager, so you can use remaker and cipher mechanism of it.

```swift
imageView.setImageUrl(imageUrlString, placeholderImage: nil, cutInLine: true, remakerName: "resize", remakerParameter: ["width":300, "height":300]) { (image:UIImage?, urlStirng:String?, remakeName:String?, remakerParameter:Any?, cipherName:String?, targetChanged:Bool) in
    if let image = image {
        // do something you want.
    }
}
```

You can do same things to UIButton with handling control state, button image and button background image.

# Display Download Progress

Design any progress view as you wish, and confirm protocol HJProgressViewProtocol as below.

```objective-c
@protocol HJProgressViewProtocol
@optional
- (void)hjProgressViewConnected:(id)senderView contentLength:(NSUInteger)contentLength;
- (void)hjProgressViewTransfering:(id)senderView transferLength:(NSUInteger)transferLength contentLength:(NSUInteger)contentLength;
- (void)hjProgressViewTransferDone:(id)senderView;
- (void)hjProgressViewTransferFailed:(id)senderView;
- (void)hjProgressViewTransferCanceled:(id)senderView;
@end
```

Let's take a look around one by one.

hjProgressViewConnected function called after connection, it give you sender view and content length of file length to download.
You can update the display interface of amount range by referencing content length.

hjProgressViewTransfering function called when transfering every chunk, it give you sender view, transfer length and content length.
You can update the display interface of progressing by referencing transfer length and content length.

hjProgressViewTransferDone, hjProgressViewTransferFailed, hjProgressViewTransferCanceled function called after transfering done, failed and cancel for each case.

You can control your progress GUI by implement theses protocol to your own progress view.
After then, just set it to UIView or UIButton.
UI+HJResourceManager library will call protocol functions as their purpose, automatically.

```swift
imageView.hjImageProgressView = customProgressView
```

# License

MIT License, where applicable. http://en.wikipedia.org/wiki/MIT_License
