#import <UIKit/UIKit.h>

extern void ShowMenuOverlayWindow();

__attribute__((constructor)) static void init() {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        ShowMenuOverlayWindow();
    });
}
