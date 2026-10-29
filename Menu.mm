#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import "PUBG/core/MenuLoad/DrawView.h"
#include "PUBG/core/ue4/xor.h"

extern bool menu_open;

@interface ImGuiLoad()
@property (nonatomic, strong) ImGuiDrawView *vna;
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

- (void)show { 
    [self initMenu]; 
    _vna.view.hidden = NO; 
    menu_open = true; 
}

- (void)initMenu { 
    if (!_vna) { 
        _vna = [[ImGuiDrawView alloc] init]; 
        _vna.view.frame = [UIScreen mainScreen].bounds; 
        _vna.view.userInteractionEnabled = YES; 
        _vna.view.backgroundColor = [UIColor clearColor]; 
        UIWindowScene *windowScene = (UIWindowScene *)[UIApplication sharedApplication].connectedScenes.allObjects.firstObject; 
        UIWindow *keyWindow = windowScene.windows.firstObject; 
        [keyWindow.rootViewController.view addSubview:_vna.view]; 
        _vna.view.hidden = YES; 
        menu_open = false; 
    } 
}

- (void)toggleMenu { 
    _vna.view.hidden = !_vna.view.hidden; 
    menu_open = !_vna.view.hidden; 
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
