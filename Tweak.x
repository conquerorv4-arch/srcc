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

@interface LoginManager : NSObject <UITextFieldDelegate>
+ (instancetype)sharedInstance;
- (void)loginTapped;
- (void)pasteTapped;
- (void)exitTapped;
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
                
                // Key uğurla keçildikdən sonra qara şəffaf yuvarlaq düyməni göstər
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
            floatingWindow = [[UIWindow alloc] initWithFrame:CGRectMake(50, 100, 55, 55)];
        }
    } else {
        floatingWindow = [[UIWindow alloc] initWithFrame:CGRectMake(50, 100, 55, 55)];
    }

    floatingWindow.windowLevel = UIWindowLevelAlert + 2000;
    floatingWindow.backgroundColor = [UIColor clearColor];
    
    UIViewController *vc = [[UIViewController alloc] init];
    floatingWindow.rootViewController = vc;
    [floatingWindow makeKeyAndVisible];

    UIButton *floatBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    floatBtn.frame = CGRectMake(0, 0, 55, 55);
    floatBtn.backgroundColor = [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.65]; // Qara şəffaf
    floatBtn.layer.cornerRadius = 27.5; // Yuvarlaq (Radius = width / 2)
    floatBtn.layer.borderWidth = 1.5;
    floatBtn.layer.borderColor = [UIColor colorWithWhite:1.0 alpha:0.4].CGColor;
    
    // Düymənin içərisinə ikon və ya kiçik simvol verə bilərsən
    [floatBtn setTitle:@"PUBG" forState:UIControlStateNormal];
    [floatBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    floatBtn.titleLabel.font = [UIFont boldSystemFontOfSize:11];
    
    [floatBtn addTarget:nil action:@selector(floatBtnTapped) forControlEvents:UIControlEventTouchUpInside];
    
    // Düyməni ekranda sürükləmək (Drag/Pan) üçün jest əlavə edirik
    UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:nil action:@selector(floatBtnDragged:)];
    [floatBtn addGestureRecognizer:pan];
    
    [vc.view addSubview:floatBtn];
}

// Düyməyə basıldıqda menyunu aç/bağla
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
    
    // Ekran sərhədlərindən çıxmasının qarşısını alaq
    CGFloat screenW = [UIScreen mainScreen].bounds.size.width;
    CGFloat screenH = [UIScreen mainScreen].bounds.size.height;
    center.x = MAX(30, MIN(screenW - 30, center.x));
    center.y = MAX(40, MIN(screenH - 40, center.y));
    
    btn.center = center;
    [pan setTranslation:CGPointZero inView:btn.superview];
}
@end

// Əsas Hiylə Menyusu (Cheat Menu Paneli)
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

    // Menyu qutusu
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

    // Bağlamaq (Close) düyməsi
    UIButton *closeBtn = [UIButton buttonWithType:UIButtonTypeSystem];
    closeBtn.frame = CGRectMake(menuPanel.frame.size.width - 50, 12, 35, 30);
    [closeBtn setTitle:@"X" forState:UIControlStateNormal];
    [closeBtn setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
    closeBtn.titleLabel.font = [UIFont boldSystemFontOfSize:16];
    [closeBtn addTarget:nil action:@selector(closeMenuTapped) forControlEvents:UIControlEventTouchUpInside];
    [menuPanel addSubview:closeBtn];
}

@interface MenuHelper : NSObject
@end
@implementation MenuHelper
+ (void)closeMenuTapped {
    cheatMenuWindow.hidden = YES;
}
@end

void showLoginMenu() {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
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

        UIView *panel = [[UIView alloc] initWithFrame:CGRectMake(25, 30, [UIScreen mainScreen].bounds.size.width - 50, 240)];
        panel.backgroundColor = [UIColor colorWithRed:0.07 green:0.07 blue:0.08 alpha:0.95];
        panel.layer.cornerRadius = 14;
        panel.layer.borderWidth = 1;
        panel.layer.borderColor = [UIColor colorWithWhite:0.2 alpha:1.0].CGColor;
        [vc.view addSubview:panel];

        UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 18, panel.frame.size.width - 40, 24)];
        titleLabel.text = @"Sign in";
        titleLabel.textColor = [UIColor whiteColor];
        titleLabel.font = [UIFont boldSystemFontOfSize:20];
        [panel addSubview:titleLabel];

        UILabel *subLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 44, panel.frame.size.width - 40, 18)];
        subLabel.text = @"Unlock advanced features through secure sign-in.";
        subLabel.textColor = [UIColor colorWithWhite:0.6 alpha:1.0];
        subLabel.font = [UIFont systemFontOfSize:11];
        [panel addSubview:subLabel];

        keyTextField = [[UITextField alloc] initWithFrame:CGRectMake(20, 75, panel.frame.size.width - 40, 42)];
        keyTextField.backgroundColor = [UIColor colorWithRed:0.12 green:0.12 blue:0.14 alpha:1.0];
        keyTextField.textColor = [UIColor whiteColor];
        keyTextField.font = [UIFont systemFontOfSize:14];
        keyTextField.borderStyle = UITextBorderStyleRoundedRect;
        keyTextField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"Password / Key" attributes:@{NSForegroundColorAttributeName: [UIColor colorWithWhite:0.4 alpha:1.0]}];
        keyTextField.delegate = [LoginManager sharedInstance];
        keyTextField.returnKeyType = UIReturnKeyDone;
        keyTextField.secureTextEntry = NO;
        [panel addSubview:keyTextField];

        UIButton *pasteBtn = [UIButton buttonWithType:UIButtonTypeSystem];
        pasteBtn.frame = CGRectMake(panel.frame.size.width - 90, 120, 70, 20);
        [pasteBtn setTitle:@"Paste" forState:UIControlStateNormal];
        [pasteBtn setTitleColor:[UIColor colorWithWhite:0.6 alpha:1.0] forState:UIControlStateNormal];
        pasteBtn.titleLabel.font = [UIFont systemFontOfSize:12];
        [pasteBtn addTarget:[LoginManager sharedInstance] action:@selector(pasteTapped) forControlEvents:UIControlEventTouchUpInside];
        [panel addSubview:pasteBtn];

        UIButton *loginBtn = [UIButton buttonWithType:UIButtonTypeSystem];
        loginBtn.frame = CGRectMake(20, 152, panel.frame.size.width - 40, 44);
        [loginBtn setTitle:@"Sign in" forState:UIControlStateNormal];
        [loginBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        loginBtn.backgroundColor = [UIColor colorWithRed:0.15 green:0.15 blue:0.18 alpha:1.0];
        loginBtn.layer.cornerRadius = 8;
        loginBtn.layer.borderWidth = 1;
        loginBtn.layer.borderColor = [UIColor colorWithWhite:0.3 alpha:1.0].CGColor;
        titleLabel.font = [UIFont boldSystemFontOfSize:15];
        [loginBtn addTarget:[LoginManager sharedInstance] action:@selector(loginTapped) forControlEvents:UIControlEventTouchUpInside];
        [panel addSubview:loginBtn];

        UIButton *exitBtn = [UIButton buttonWithType:UIButtonTypeSystem];
        exitBtn.frame = CGRectMake(20, 202, panel.frame.size.width - 40, 25);
        [exitBtn setTitle:@"Çıxış" forState:UIControlStateNormal];
        [exitBtn setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
        exitBtn.titleLabel.font = [UIFont systemFontOfSize:12];
        [exitBtn addTarget:[LoginManager sharedInstance] action:@selector(exitTapped) forControlEvents:UIControlEventTouchUpInside];
        [panel addSubview:exitBtn];

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
