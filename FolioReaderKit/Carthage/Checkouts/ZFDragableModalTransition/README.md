# ZFDragableModalTransition

[![Version](https://img.shields.io/cocoapods/v/ZFDragableModalTransition.svg?style=flat)](http://cocoadocs.org/docsets/ZFDragableModalTransition)
[![License](https://img.shields.io/cocoapods/l/ZFDragableModalTransition.svg?style=flat)](http://cocoadocs.org/docsets/ZFDragableModalTransition)
[![Platform](https://img.shields.io/cocoapods/p/ZFDragableModalTransition.svg?style=flat)](http://cocoadocs.org/docsets/ZFDragableModalTransition)

<p align="center"><img src="https://raw.githubusercontent.com/zoonooz/ZFDragableModalTransition/master/Screenshot/ss.gif"/></p>

## Usage

```objc
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    TaskDetailViewController *detailViewController = segue.destinationViewController;
    detailViewController.task = sender;

    // create animator object with instance of modal view controller
    // we need to keep it in property with strong reference so it will not get release
    self.animator = [[ZFModalTransitionAnimator alloc] initWithModalViewController:detailViewController];
    self.animator.dragable = YES;
    self.animator.direction = ZFModalTransitonDirectionBottom;
    [self.animator setContentScrollView:detailViewController.scrollview];

    // set transition delegate of modal view controller to our object
    detailViewController.transitioningDelegate = self.animator;

    // if you modal cover all behind view controller, use UIModalPresentationFullScreen
    detailViewController.modalPresentationStyle = UIModalPresentationCustom;
}
```
###ScrollView
If you have scrollview in the modal and you want to dismiss modal by drag it, you need to set scrollview to ZFModalTransitionAnimator instance.
```objc
[self.animator setContentScrollView:detailViewController.scrollview];
```

###Direction
You can set that which direction will our modal present. (default is ZFModalTransitonDirectionBottom)
```objc
self.animator.direction = ZFModalTransitonDirectionBottom;
```
P.S. Now you can set content scrollview only with ZFModalTransitonDirectionBottom

## Requirements
- iOS >= 7.1
- ARC

## Installation

ZFDragableModalTransition is available through [CocoaPods](http://cocoapods.org). To install
it, simply add the following line to your Podfile:

    pod "ZFDragableModalTransition"

## FAQ

### How can I show modal only part of view ?
The current ViewController's view still visible behind the modal, so you just set transparent color to background view.

## Author

Amornchai Kanokpullwad, [@zoonref](https://twitter.com/zoonref)

##  Swift Version

by @dimohamdy [ZFDragableModalTransitionSwift](https://github.com/dimohamdy/ZFDragableModalTransitionSwift)

## License

ZFDragableModalTransition is available under the MIT license. See the LICENSE file for more info.
