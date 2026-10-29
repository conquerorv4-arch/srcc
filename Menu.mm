#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#include "PUBG/core/ue4/xor.h"

extern bool menu_open;

@interface ImGuiLoad : NSObject
+ (instancetype)share;
- (void)initMenu;
- (void)initTapGes;
- (void)toggleMenu;
- (void)handleTap:(UITapGestureRecognizer *)gesture;
@end

@implementation ImGuiLoad

+ (void)load { 
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{ 
        [[ImGuiLoad share] initMenu];
        [[ImGuiLoad share] initTapGes]; 
    }); 
}

+ (instancetype)share { 
    static ImGuiLoad *tool; 
    static dispatch_once_t onceToken; 
    dispatch_once(&onceToken, ^{ 
        tool = [[ImGuiLoad alloc] init]; 
    }); 
    return tool; 
}

- (void)initMenu { 
    // Overlay / DrawView idarəetməsi
}

- (void)toggleMenu { 
    menu_open = !menu_open; 
}

- (void)initTapGes { 
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTap:)]; 
    tap.numberOfTapsRequired = 2; 
    tap.numberOfTouchesRequired = 2; 
    UIWindowScene *windowScene = (UIWindowScene *)[UIApplication sharedApplication].connectedScenes.allObjects.firstObject; 
    UIWindow *keyWindow = windowScene.windows.firstObject; 
    [keyWindow.rootViewController.view addGestureRecognizer:tap]; 
}

- (void)handleTap:(UITapGestureRecognizer *)gesture { 
    if (gesture.state == UIGestureRecognizerStateEnded) { 
        [self toggleMenu]; 
    } 
}

@end
