#import "UIViewController+Additions.h"

@implementation UIViewController (TopMostViewController)

+ (UIViewController *)topMostController {
    
    UIWindow *topWndow = [UIApplication sharedApplication].keyWindow;
    UIViewController *topController = topWndow.rootViewController;
    
    if (topController == nil) {
        
        for (UIWindow *aWndow in [[UIApplication sharedApplication].windows reverseObjectEnumerator]) {
            topController = aWndow.rootViewController;
            if (topController)
                break;
        }
    }
    
    while (topController.presentedViewController) {
        topController = topController.presentedViewController;
    }
    
    return topController;
}

@end