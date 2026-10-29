#import <UIKit/UIKit.h>
#include "PUBG/core/MenuLoad/Includes.h"
#import <AVFoundation/AVFoundation.h>
#import "API/APIClient.h"
#include "PUBG/core/ue4/xor.h"

#define TOKEN ENCRYPT("wZ3Q/xYPjTIWo5gRdA5jLfamO6POk7SjBPQALRXHafuNi0nwolEDstMEOrlEsxHyiUUj4M/7hRwYD6VApIf9c3kkgQYy6dWE/B69+eT5F0g=")

extern bool menu_open;

void initAPI(){
    apiclient_set_token(TOKEN);
    apiclient_set_language(ENCRYPT("en"));
    apiclient_paid(^{
        [[ImGuiLoad share] performSelector:@selector(initMenu)];
    });
}

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
        initAPI();
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
