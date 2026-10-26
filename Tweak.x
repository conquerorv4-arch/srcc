#import <UIKit/UIKit.h>
#include <dlfcn.h>
#include <sys/stat.h>

// Global dəyişənlər
static UIWindow *overlayWindow = nil;
static UITextField *keyTextField = nil;
static NSTimer *authTimer = nil;
static BOOL isAuthorized = NO;

// Lisenziya yoxlama funksiyası
void verifyKey(NSString *inputKey) {
    if (isAuthorized) return;

    // GitHub-dakı keylist.json ünvanı
    NSString *urlString = @"https://raw.githubusercontent.com/conquerorv4-arch/srcc/main/keylist.json";
    NSURL *url = [NSURL URLWithString:urlString];
    
    NSData *data = [NSData dataWithContentsOfURL:url];
    if (!data) {
        return;
    }

    NSError *error = nil;
    NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
    
    if (json && [json[@"keys"] isKindOfClass:[NSArray class]]) {
        NSArray *validKeys = json[@"keys"];
        if ([validKeys containsObject:inputKey]) {
            isAuthorized = YES;
            [authTimer invalidate];
            authTimer = nil;
            
            // Doğrudursa menyunu gizlət və uğur mesajı göstər
            dispatch_async(dispatch_get_main_queue(), ^{
                [overlayWindow setHidden:YES];
                [overlayWindow removeFromSuperview];
                overlayWindow = nil;
                
                // Uğurlu giriş bildirişi
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
                UIWindow *keyWindow = [UIApplication sharedApplication].keyWindow;
#pragma clang diagnostic pop
                
                UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Uğurludur" message:@"Lisenziya təsdiqləndi! Oyun açılır." preferredStyle:UIAlertControllerStyleAlert];
                [keyWindow.rootViewController presentViewController:alert animated:YES completion:nil];
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    [alert dismissViewControllerAnimated:YES completion:nil];
                });
            });
        }
    }
}

// 15 saniyə ərzində açar daxil edilmədikdə tətbiqi bağlamaq (crash) üçün funksiya
void handleTimeout() {
    if (!isAuthorized) {
        abort();
    }
}

// UI Menyunu yaradan funksiya
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

        // Əsas menyu qutusu (Panel)
        UIView *panel = [[UIView alloc] initWithFrame:CGRectMake(30, 100, [UIScreen mainScreen].bounds.size.width - 60, 260)];
        panel.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.85];
        panel.layer.cornerRadius = 16;
        panel.layer.borderWidth = 1.5;
        panel.layer.borderColor = [UIColor cyanColor].CGColor;
        [vc.view addSubview:panel];

        // Başlıq
        UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 15, panel.frame.size.width - 20, 30)];
        titleLabel.text = @"PUBG Ultimate Login";
        titleLabel.textColor = [UIColor cyanColor];
        titleLabel.font = [UIFont boldSystemFontOfSize:18];
        titleLabel.textAlignment = NSTextAlignmentCenter;
        [panel addSubview:titleLabel];

        // Alt mətn / Status
        UILabel *subLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 50, panel.frame.size.width - 20, 20)];
        subLabel.text = @"Lütfən lisenziya açarını daxil edin:";
        subLabel.textColor = [UIColor whiteColor];
        subLabel.font = [UIFont systemFontOfSize:13];
        subLabel.textAlignment = NSTextAlignmentCenter;
        [panel addSubview:subLabel];

        // Açar yazılan xana
        keyTextField = [[UITextField alloc] initWithFrame:CGRectMake(20, 80, panel.frame.size.width - 40, 40)];
        keyTextField.backgroundColor = [[UIColor darkGrayColor] colorWithAlphaComponent:0.6];
        keyTextField.textColor = [UIColor whiteColor];
        keyTextField.font = [UIFont systemFontOfSize:14];
        keyTextField.borderStyle = UITextBorderStyleRoundedRect;
        keyTextField.placeholder = @"Açarı bura yazın...";
        [panel addSubview:keyTextField];

        // Giriş Düyməsi
        UIButton *loginBtn = [UIButton buttonWithType:UIButtonTypeSystem];
        loginBtn.frame = CGRectMake(25, 135, panel.frame.size.width - 50, 40);
        [loginBtn setTitle:@"GİRİŞ ET" forState:UIControlStateNormal];
        [loginBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        loginBtn.backgroundColor = [UIColor cyanColor];
        loginBtn.layer.cornerRadius = 8;
        loginBtn.titleLabel.font = [UIFont boldSystemFontOfSize:15];
        [loginBtn addTarget:nil action:@selector(loginTapped) forControlEvents:UIControlEventTouchUpInside];
        [panel addSubview:loginBtn];

        // Çıxış düyməsi
        UIButton *exitBtn = [UIButton buttonWithType:UIButtonTypeSystem];
        exitBtn.frame = CGRectMake(25, 185, panel.frame.size.width - 50, 35);
        [exitBtn setTitle:@"Çıxış" forState:UIControlStateNormal];
        [exitBtn setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
        [exitBtn addTarget:nil action:@selector(exitTapped) forControlEvents:UIControlEventTouchUpInside];
        [panel addSubview:exitBtn];

        // 15 saniyəlik taymer
        authTimer = [NSTimer scheduledTimerWithTimeInterval:15.0 target:[NSBlockOperation blockOperationWithBlock:^{
            handleTimeout();
        }] selector:@selector(main) userInfo:nil repeats:NO];
    });
}

// Düymə funksiyaları
@interface LoginManager : NSObject
+ (void)loginTapped;
+ (void)exitTapped;
@end

@implementation LoginManager
+ (void)loginTapped {
    NSString *inputKey = keyTextField.text;
    if (inputKey.length > 0) {
        verifyKey(inputKey);
    } else {
        #pragma clang diagnostic push
        #pragma clang diagnostic ignored "-Wdeprecated-declar
