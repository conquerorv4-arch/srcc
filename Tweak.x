#import <UIKit/UIKit.h>
#include <dlfcn.h>
#include <sys/stat.h>

static UIWindow *overlayWindow = nil;
static UITextField *keyTextField = nil;
static NSTimer *authTimer = nil;
static BOOL isAuthorized = NO;

void verifyKey(NSString *inputKey);

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

// Panodakı (Clipboard) mətni avtomatik olaraq xanaya yapışdırır
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
                UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Başarılı" message:@"Lisans onaylandı! Oyun açılıyor." preferredStyle:UIAlertControllerStyleAlert];
                [topVC presentViewController:alert animated:YES completion:nil];
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    [alert dismissViewControllerAnimated:YES completion:nil];
                });
            });
        }
    }
}

void handleTimeout() {
    if (!isAuthorized) {
        abort();
    }
}

void showLoginMenu() {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        if (overlayWindow) return;

        UIWindowScene *scene = nil;
        for (UIScene *s in [UIApplication sharedApplication].connectedScenes) {
            if ([s.delegate respondsToSelector:@selector(window)]) {
                scene = (UIScene *)s;
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

        // Ekranın daha yuxarı hissəsində yerləşdirmək üçün koordinat
        UIView *panel = [[UIView alloc] initWithFrame:CGRectMake(25, 30, [UIScreen mainScreen].bounds.size.width - 50, 240)];
        panel.backgroundColor = [UIColor colorWithRed:0.07 green:0.07 blue:0.08 alpha:0.95];
        panel.layer.cornerRadius = 14;
        panel.layer.borderWidth = 1;
        panel.layer.borderColor = [UIColor colorWithWhite:0.2 alpha:1.0].CGColor;
        [vc.view addSubview:panel];

        // "Sign in" Başlığı
        UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 18, panel.frame.size.width - 40, 24)];
        titleLabel.text = @"Sign in";
        titleLabel.textColor = [UIColor whiteColor];
        titleLabel.font = [UIFont boldSystemFontOfSize:20];
        [panel addSubview:titleLabel];

        // Alt açıqlama mətni
        UILabel *subLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 44, panel.frame.size.width - 40, 18)];
        subLabel.text = @"Unlock advanced features through secure sign-in.";
        subLabel.textColor = [UIColor colorWithWhite:0.6 alpha:1.0];
        subLabel.font = [UIFont systemFontOfSize:11];
        [panel addSubview:subLabel];

        // Şifrə/Açar xanası (Password input)
        keyTextField = [[UITextField alloc] initWithFrame:CGRectMake(20, 75, panel.frame.size.width - 40, 42)];
        keyTextField.backgroundColor = [UIColor colorWithRed:0.12 green:0.12 blue:0.14 alpha:1.0];
        keyTextField.textColor = [UIColor whiteColor];
        keyTextField.font = [UIFont systemFontOfSize:14];
        keyTextField.borderStyle = UITextBorderStyleRoundedRect;
        keyTextField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"Password / Key" attributes:@{NSForegroundColorAttributeName: [UIColor colorWithWhite:0.4 alpha:1.0]}];
        keyTextField.delegate = [LoginManager sharedInstance];
        keyTextField.returnKeyType = UIReturnKeyDone;
        keyTextField.secureTextEntry = NO; // İstəsən YES edə bilərsən
        [panel addSubview:keyTextField];

        // "Forgot password?" yerinə "Paste" düyməsi
        UIButton *pasteBtn = [UIButton buttonWithType:UIButtonTypeSystem];
        pasteBtn.frame = CGRectMake(panel.frame.size.width - 90, 120, 70, 20);
        [pasteBtn setTitle:@"Paste" forState:UIControlStateNormal];
        [pasteBtn setTitleColor:[UIColor colorWithWhite:0.6 alpha:1.0] forState:UIControlStateNormal];
        pasteBtn.titleLabel.font = [UIFont systemFontOfSize:12];
        [pasteBtn addTarget:[LoginManager sharedInstance] action:@selector(pasteTapped) forControlEvents:UIControlEventTouchUpInside];
        [panel addSubview:pasteBtn];

        // "Sign in" Əsas düymə
        UIButton *loginBtn = [UIButton buttonWithType:UIButtonTypeSystem];
        loginBtn.frame = CGRectMake(20, 152, panel.frame.size.width - 40, 44);
        [loginBtn setTitle:@"Sign in" forState:UIControlStateNormal];
        [loginBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        loginBtn.backgroundColor = [UIColor colorWithRed:0.15 green:0.15 blue:0.18 alpha:1.0];
        loginBtn.layer.cornerRadius = 8;
        loginBtn.layer.borderWidth = 1;
        loginBtn.layer.borderColor = [UIColor colorWithWhite:0.3 alpha:1.0].CGColor;
        loginBtn.titleLabel.font = [UIFont boldSystemFontOfSize:15];
        [loginBtn addTarget:[LoginManager sharedInstance] action:@selector(loginTapped) forControlEvents:UIControlEventTouchUpInside];
        [panel addSubview:loginBtn];

        // Çıxış düyməsi (gizli və ya sadə formada)
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
