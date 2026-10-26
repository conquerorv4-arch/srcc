#import <UIKit/UIKit.h>
#include <dlfcn.h>
#include <sys/stat.h>

static UIWindow *overlayWindow = nil;
static UITextField *keyTextField = nil;
static NSTimer *authTimer = nil;
static BOOL isAuthorized = NO;

// Forward declarations
void verifyKey(NSString *inputKey);

@interface LoginManager : NSObject <UITextFieldDelegate>
+ (instancetype)sharedInstance;
- (void)loginTapped;
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

        // Paneli ekranın üst kısmına konumlandırıyoruz ki klavye kapatmasın
        UIView *panel = [[UIView alloc] initWithFrame:CGRectMake(30, 40, [UIScreen mainScreen].bounds.size.width - 60, 260)];
        panel.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.85];
        panel.layer.cornerRadius = 16;
        panel.layer.borderWidth = 1.5;
        panel.layer.borderColor = [UIColor cyanColor].CGColor;
        [vc.view addSubview:panel];

        UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 15, panel.frame.size.width - 20, 30)];
        titleLabel.text = @"PUBG Ultimate Login";
        titleLabel.textColor = [UIColor cyanColor];
        titleLabel.font = [UIFont boldSystemFontOfSize:18];
        titleLabel.textAlignment = NSTextAlignmentCenter;
        [panel addSubview:titleLabel];

        UILabel *subLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 50, panel.frame.size.width - 20, 20)];
        subLabel.text = @"Lütfen lisans anahtarını girin:";
        subLabel.textColor = [UIColor whiteColor];
        subLabel.font = [UIFont systemFontOfSize:13];
        subLabel.textAlignment = NSTextAlignmentCenter;
        [panel addSubview:subLabel];

        keyTextField = [[UITextField alloc] initWithFrame:CGRectMake(20, 80, panel.frame.size.width - 40, 40)];
        keyTextField.backgroundColor = [[UIColor darkGrayColor] colorWithAlphaComponent:0.6];
        keyTextField.textColor = [UIColor whiteColor];
        keyTextField.font = [UIFont systemFontOfSize:14];
        keyTextField.borderStyle = UITextBorderStyleRoundedRect;
        keyTextField.placeholder = @"Anahtarı buraya yazın...";
        keyTextField.delegate = [LoginManager sharedInstance];
        keyTextField.returnKeyType = UIReturnKeyDone;

        // Klavyenin üstüne Kapat ve Giriş Et butonları ekliyoruz
        UIToolbar *keyboardToolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, 44)];
        keyboardToolbar.barStyle = UIBarStyleDefault;
        UIBarButtonItem *flexSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
        UIBarButtonItem *doneBtn = [[UIBarButtonItem alloc] initWithTitle:@"Kapat" style:UIBarButtonItemStyleDone target:[LoginManager sharedInstance] action:@selector(doneTapped)];
        UIBarButtonItem *submitBtn = [[UIBarButtonItem alloc] initWithTitle:@"Giriş Et" style:UIBarButtonItemStylePlain target:[LoginManager sharedInstance] action:@selector(loginTapped)];
        keyboardToolbar.items = @[doneBtn, flexSpace, submitBtn];
        [keyboardToolbar sizeToFit];
        keyTextField.inputAccessoryView = keyboardToolbar;

        [panel addSubview:keyTextField];

        UIButton *loginBtn = [UIButton buttonWithType:UIButtonTypeSystem];
        loginBtn.frame = CGRectMake(25, 135, panel.frame.size.width - 50, 40);
        [loginBtn setTitle:@"GİRİŞ ET" forState:UIControlStateNormal];
        [loginBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        loginBtn.backgroundColor = [UIColor cyanColor];
        loginBtn.layer.cornerRadius = 8;
        loginBtn.titleLabel.font = [UIFont boldSystemFontOfSize:15];
        [loginBtn addTarget:[LoginManager sharedInstance] action:@selector(loginTapped) forControlEvents:UIControlEventTouchUpInside];
        [panel addSubview:loginBtn];

        UIButton *exitBtn = [UIButton buttonWithType:UIButtonTypeSystem];
        exitBtn.frame = CGRectMake(25, 185, panel.frame.size.width - 50, 35);
        [exitBtn setTitle:@"Çıkış" forState:UIControlStateNormal];
        [exitBtn setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
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
