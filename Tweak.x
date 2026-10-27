#import <UIKit/UIKit.h>
#include <dlfcn.h>
#include <sys/stat.h>

static UIWindow *overlayWindow = nil;
static UIWindow *floatingWindow = nil;
static UIWindow *cheatMenuWindow = nil;
static UITextField *keyTextField = nil;
static NSTimer *authTimer = nil;
static BOOL isAuthorized = NO;

void verifyKey(NSString *inputKey);
void showFloatingButton();
void toggleCheatMenu();

// KÖMƏKÇİ SİNİFLƏR
@interface FloatingHelper : NSObject
@end
@implementation FloatingHelper
+ (void)floatBtnTapped {
    toggleCheatMenu();
}
+ (void)floatBtnDragged:(UIPanGestureRecognizer *)pan {
    UIView *btn = pan.view;
    CGPoint translation = [pan translationInView:btn.superview];
    CGPoint center = CGPointMake(btn.center.x + translation.x, btn.center.y + translation.y);
    
    CGFloat screenW = [UIScreen mainScreen].bounds.size.width;
    CGFloat screenH = [UIScreen mainScreen].bounds.size.height;
    center.x = MAX(25, MIN(screenW - 25, center.x));
    center.y = MAX(25, MIN(screenH - 25, center.y));
    
    btn.center = center;
    [pan setTranslation:CGPointZero inView:btn.superview];
}
@end

@interface MenuHelper : NSObject
@end
@implementation MenuHelper
+ (void)closeMenuTapped {
    if (cheatMenuWindow) {
        cheatMenuWindow.hidden = YES;
    }
}
@end

@interface LoginManager : NSObject <UITextFieldDelegate>
+ (instancetype)sharedInstance;
- (void)loginTapped;
- (void)pasteTapped;
- (void)exitTapped;
- (void)supportTapped;
- (void)doneTapped;
@end

@implementation LoginManager
+ (instancetype)sharedInstance {
    static LoginManager *shared = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        shared = [[LoginManager alloc] init];
    });
    return shared;
}

- (void)loginTapped {
    NSString *inputKey = keyTextField.text;
    if (inputKey.length > 0) {
        verifyKey(inputKey);
    } else {
        UIViewController *topVC = [UIApplication sharedApplication].delegate.window.rootViewController;
        UIAlertController *errAlert = [UIAlertController alertControllerWithTitle:@"Hata" message:@"Anahtar boş olamaz!" preferredStyle:UIAlertControllerStyleAlert];
        [topVC presentViewController:errAlert animated:YES completion:nil];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [errAlert dismissViewControllerAnimated:YES completion:nil];
        });
    }
}

- (void)pasteTapped {
    UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
    if (pasteboard.string) {
        keyTextField.text = pasteboard.string;
    }
}

- (void)supportTapped {
    NSURL *supportURL = [NSURL URLWithString:@"https://t.me/@zirvedeyim0"];
    [[UIApplication sharedApplication] openURL:supportURL options:@{} completionHandler:nil];
}

- (void)exitTapped {
    abort();
}

- (void)doneTapped {
    [keyTextField resignFirstResponder];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    if (textField.text.length > 0) {
        verifyKey(textField.text);
    }
    return YES;
}
@end

void verifyKey(NSString *inputKey) {
    if (isAuthorized) return;

    NSString *urlString = @"https://raw.githubusercontent.com/conquerorv4-arch/srcc/main/keylist.json";
    NSURL *url = [NSURL URLWithString:urlString];
    
    NSData *data = [NSData dataWithContentsOfURL:url];
    if (!data) return;

    NSError *error = nil;
    NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
    
    if (json && [json[@"keys"] isKindOfClass:[NSArray class]]) {
        NSArray *validKeys = json[@"keys"];
        if ([validKeys containsObject:inputKey]) {
            isAuthorized = YES;
            [authTimer invalidate];
            authTimer = nil;
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [overlayWindow setHidden:YES];
                [overlayWindow removeFromSuperview];
                overlayWindow = nil;
                
                UIViewController *topVC = [UIApplication sharedApplication].delegate.window.rootViewController;
                UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Başarılı" message:@"Lisans onaylandı! Menü aktifleşti." preferredStyle:UIAlertControllerStyleAlert];
                [topVC presentViewController:alert animated:YES completion:nil];
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    [alert dismissViewControllerAnimated:YES completion:nil];
                });
                
                showFloatingButton();
            });
        }
    }
}

void handleTimeout() {
    if (!isAuthorized) {
        abort();
    }
}

// Qara şəffaf yuvarlaq düymə (Floating Button)
void showFloatingButton() {
    if (floatingWindow) return;

    UIWindowScene *scene = nil;
    for (UIScene *s in [UIApplication sharedApplication].connectedScenes) {
        if ([s isKindOfClass:[UIWindowScene class]]) {
            scene = (UIWindowScene *)s;
            break;
        }
    }

    if (@available(iOS 13.0, *)) {
        if (scene) {
            floatingWindow = [[UIWindow alloc] initWithWindowScene:scene];
        } else {
            floatingWindow = [[UIWindow alloc] initWithFrame:CGRectMake(50, 100, 45, 45)];
        }
    } else {
        floatingWindow = [[UIWindow alloc] initWithFrame:CGRectMake(50, 100, 45, 45)];
    }

    floatingWindow.windowLevel = UIWindowLevelAlert + 2000;
    floatingWindow.backgroundColor = [UIColor clearColor];
    
    UIViewController *vc = [[UIViewController alloc] init];
    floatingWindow.rootViewController = vc;
    [floatingWindow makeKeyAndVisible];

    UIButton *floatBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    floatBtn.frame = CGRectMake(0, 0, 45, 45);
    floatBtn.backgroundColor = [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.6];
    floatBtn.layer.cornerRadius = 22.5;
    floatBtn.layer.borderWidth = 0.0;
    floatBtn.clipsToBounds = YES;
    
    [floatBtn setTitle:@"" forState:UIControlStateNormal];
    [floatBtn addTarget:[FloatingHelper class] action:@selector(floatBtnTapped) forControlEvents:UIControlEventTouchUpInside];
    
    UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:[FloatingHelper class] action:@selector(floatBtnDragged:)];
    [floatBtn addGestureRecognizer:pan];
    
    [vc.view addSubview:floatBtn];
}

// Əsas Hiylə Menyusu
void toggleCheatMenu() {
    if (cheatMenuWindow) {
        cheatMenuWindow.hidden = !cheatMenuWindow.hidden;
        return;
    }

    UIWindowScene *scene = nil;
    for (UIScene *s in [UIApplication sharedApplication].connectedScenes) {
        if ([s isKindOfClass:[UIWindowScene class]]) {
            scene = (UIWindowScene *)s;
            break;
        }
    }

    if (@available(iOS 13.0, *)) {
        if (scene) {
            cheatMenuWindow = [[UIWindow alloc] initWithWindowScene:scene];
        } else {
            cheatMenuWindow = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
        }
    } else {
        cheatMenuWindow = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    }

    cheatMenuWindow.windowLevel = UIWindowLevelAlert + 1500;
    cheatMenuWindow.backgroundColor = [UIColor clearColor];
    
    UIViewController *vc = [[UIViewController alloc] init];
    cheatMenuWindow.rootViewController = vc;
    [cheatMenuWindow makeKeyAndVisible];

    UIView *menuPanel = [[UIView alloc] initWithFrame:CGRectMake(50, 80, [UIScreen mainScreen].bounds.size.width - 100, 300)];
    menuPanel.backgroundColor = [UIColor colorWithRed:0.08 green:0.08 blue:0.1 alpha:0.95];
    menuPanel.layer.cornerRadius = 16;
    menuPanel.layer.borderWidth = 1.2;
    menuPanel.layer.borderColor = [UIColor colorWithRed:0.2 green:0.6 blue:1.0 alpha:0.8].CGColor;
    [vc.view addSubview:menuPanel];

    UILabel *menuTitle = [[UILabel alloc] initWithFrame:CGRectMake(20, 15, menuPanel.frame.size.width - 40, 25)];
    menuTitle.text = @"PUBG Ultimate Menu";
    menuTitle.textColor = [UIColor whiteColor];
    menuTitle.font = [UIFont boldSystemFontOfSize:18];
    menuTitle.textAlignment = NSTextAlignmentCenter;
    [menuPanel addSubview:menuTitle];

    UIButton *closeBtn = [UIButton buttonWithType:UIButtonTypeSystem];
    closeBtn.frame = CGRectMake(menuPanel.frame.size.width - 50, 12, 35, 30);
    [closeBtn setTitle:@"X" forState:UIControlStateNormal];
    [closeBtn setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
    closeBtn.titleLabel.font = [UIFont boldSystemFontOfSize:16];
    [closeBtn addTarget:[MenuHelper class] action:@selector(closeMenuTapped) forControlEvents:UIControlEventTouchUpInside];
    [menuPanel addSubview:closeBtn];
}

void showLoginMenu() {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), FRAME:^{
        if (overlayWindow) return;

        UIWindowScene *scene = nil;
        for (UIScene *s in [UIApplication sharedApplication].connectedScenes) {
            if ([s isKindOfClass:[UIWindowScene class]]) {
                scene = (UIWindowScene *)s;
                break;
            }
        }

        if (@available(iOS 13.0, *)) {
            if (scene) {
                overlayWindow = [[UIWindow alloc] initWithWindowScene:scene];
            } else {
                overlayWindow = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
            }
        } else {
            overlayWindow = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
        }

        overlayWindow.windowLevel = UIWindowLevelAlert + 1000;
        overlayWindow.backgroundColor = [UIColor clearColor];
        
        UIViewController *vc = [[UIViewController alloc] init];
        overlayWindow.rootViewController = vc;
        [overlayWindow makeKeyAndVisible];

        // Panel eni daraldıldı və ekranda tənzimləndi (mərkəzləşdirildi)
        CGFloat screenW = [UIScreen mainScreen].bounds.size.width;
        CGFloat panelW = screenW - 200; // Yanlardan kifayət qədər alınaraq kiçildildi
        CGFloat panelX = (screenW - panelW) / 2;

        UIView *panel = [[UIView alloc] initWithFrame:CGRectMake(panelX, 40, panelW, 220)];
        // Arka plan tam siyah (şeffaf deyil)
        panel.backgroundColor = [UIColor blackColor];
        panel.layer.cornerRadius = 14;
        panel.layer.borderWidth = 1;
        panel.layer.borderColor = [UIColor colorWithWhite:0.2 alpha:1.0].CGColor;
        [vc.view addSubview:panel];

        UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 16, panelW - 40, 22)];
        titleLabel.text = @"DARK";
        titleLabel.textColor = [UIColor whiteColor];
        titleLabel.font = [UIFont boldSystemFontOfSize:20];
        titleLabel.textAlignment = NSTextAlignmentCenter;
        [panel addSubview:titleLabel];

        UILabel *subLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 38, panelW - 40, 16)];
        subLabel.text = @"LOGIN";
        subLabel.textColor = [UIColor colorWithWhite:0.7 alpha:1.0];
        subLabel.font = [UIFont boldSystemFontOfSize:11];
        subLabel.textAlignment = NSTextAlignmentCenter;
        [panel addSubview:subLabel];

        UILabel *keyLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 68, 100, 18)];
        keyLabel.text = @"License Key";
        keyLabel.textColor = [UIColor colorWithWhite:0.7 alpha:1.0];
        keyLabel.font = [UIFont systemFontOfSize:12];
        [panel addSubview:keyLabel];

        keyTextField = [[UITextField alloc] initWithFrame:CGRectMake(20, 90, panelW - 100, 40)];
        keyTextField.backgroundColor = [UIColor colorWithRed:0.12 green:0.12 blue:0.14 alpha:1.0];
        keyTextField.textColor = [UIColor whiteColor];
        keyTextField.font = [UIFont systemFontOfSize:14];
        keyTextField.borderStyle = UITextBorderStyleRoundedRect;
        keyTextField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"Key..." attributes:@{NSForegroundColorAttributeName: [UIColor colorWithWhite:0.4 alpha:1.0]}];
        keyTextField.delegate = [LoginManager sharedInstance];
        keyTextField.returnKeyType = UIReturnKeyDone;
        keyTextField.secureTextEntry = NO;
        [panel addSubview:keyTextField];

        UIButton *pasteBtn = [UIButton buttonWithType:UIButtonTypeSystem];
        pasteBtn.frame = CGRectMake(panelW - 75, 90, 55, 40);
        [pasteBtn setTitle:@"Paste" forState:UIControlStateNormal];
        [pasteBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        pasteBtn.backgroundColor = [UIColor colorWithRed:0.15 green:0.15 blue:0.18 alpha:1.0];
        pasteBtn.layer.cornerRadius = 6;
        pasteBtn.layer.borderWidth = 1;
        pasteBtn.layer.borderColor = [UIColor colorWithWhite:0.3 alpha:1.0].CGColor;
        pasteBtn.titleLabel.font = [UIFont boldSystemFontOfSize:12];
        [pasteBtn addTarget:[LoginManager sharedInstance] action:@selector(pasteTapped) forControlEvents:UIControlEventTouchUpInside];
        [panel addSubview:pasteBtn];

        UIButton *loginBtn = [UIButton buttonWithType:UIButtonTypeSystem];
        loginBtn.frame = CGRectMake(20, 138, panelW - 40, 38);
        [loginBtn setTitle:@"Verify" forState:UIControlStateNormal];
        [loginBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        loginBtn.backgroundColor = [UIColor colorWithRed:0.15 green:0.15 blue:0.18 alpha:1.0];
        loginBtn.layer.cornerRadius = 8;
        loginBtn.layer.borderWidth = 1;
        loginBtn.layer.borderColor = [UIColor colorWithWhite:0.3 alpha:1.0].CGColor;
        loginBtn.titleLabel.font = [UIFont boldSystemFontOfSize:14];
        [loginBtn addTarget:[LoginManager sharedInstance] action:@selector(loginTapped) forControlEvents:UIControlEventTouchUpInside];
        [panel addSubview:loginBtn];

        UIButton *supportBtn = [UIButton buttonWithType:UIButtonTypeSystem];
        supportBtn.frame = CGRectMake(25, 186, 80, 20);
        [supportBtn setTitle:@"Support" forState:UIControlStateNormal];
        [supportBtn setTitleColor:[UIColor colorWithWhite:0.6 alpha:1.0] forState:UIControlStateNormal];
        supportBtn.titleLabel.font = [UIFont systemFontOfSize:12];
        [supportBtn addTarget:[LoginManager sharedInstance] action:@selector(supportTapped) forControlEvents:UIControlEventTouchUpInside];
        [panel addSubview:supportBtn];

        UILabel *versionLbl = [[UILabel alloc] initWithFrame:CGRectMake(panelW - 105, 186, 80, 20)];
        versionLbl.text = @"v1";
        versionLbl.textColor = [UIColor colorWithWhite:0.6 alpha:1.0];
        versionLbl.font = [UIFont systemFontOfSize:12];
        versionLbl.textAlignment = NSTextAlignmentRight;
        [panel addSubview:versionLbl];

        authTimer = [NSTimer scheduledTimerWithTimeInterval:15.0 target:[NSBlockOperation blockOperationWithBlock:^{
            handleTimeout();
        }] selector:@selector(main) userInfo:nil repeats:NO];
    });
}

%ctor {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        showLoginMenu();
    });
}
