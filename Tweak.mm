#import <UIKit/UIKit.h>

extern void ShowMenuOverlayWindow();

%ctor {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        ShowMenuOverlayWindow();
    });
}
