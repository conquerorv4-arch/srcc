#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>

#ifdef __cplusplus
extern "C" {
#endif
void ShowMenuOverlayWindow();
#ifdef __cplusplus
}
#endif

// 1. Serverdəki check.php ilə əlaqə yaradıb key yoxlayan funksiya
bool verifyKey(NSString *inputKey) {
    if (!inputKey || [inputKey length] == 0) return false;

    NSString *deviceHWID = [[[UIDevice currentDevice] identifierForVendor] UUIDString];
    NSString *urlString = [NSString stringWithFormat:@"https://zirvedeyim0.rf.gd/check.php?key=%@&hwid=%@", inputKey, deviceHWID];
    NSURL *url = [NSURL URLWithString:urlString];
    
    NSData *data = [NSData dataWithContentsOfURL:url];
    if (!data) return false;
    
    NSError *error;
    NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
    if (error) return false;
    
    NSString *status = json[@"status"];
    return [status isEqualToString:@"success"];
}

// 2. Key daxil etmək üçün pəncərə
void showKeyInputWindow() {
    dispatch_async(dispatch_get_main_queue(), ^{
        UIWindow *window = [[UIApplication sharedApplication] keyWindow];
        UIViewController *rootVC = window.rootViewController;
        if (!rootVC) return;

        // Əgər artıq bir pəncərə açıqdırsa iki dəfə açılmasının qarşısını alırıq
        if ([rootVC presentedViewController]) return;

        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"DARKIOS - Key Login"
                                                                       message:@"Lütfən admin paneldən aldığınız keyi daxil edin:"
                                                                preferredStyle:UIAlertControllerStyleAlert];

        [alert addTextFieldWithConfigurationHandler:^(UITextField *textField) {
            textField.placeholder = @"DARKIOS-1D-XXXXX";
            textField.clearButtonMode = UITextFieldViewModeWhileEditing;
        }];

        UIAlertAction *loginAction = [UIAlertAction actionWithTitle:@"Daxil Ol" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            UITextField *textField = alert.textFields.firstObject;
            NSString *enteredKey = textField.text;

            if (verifyKey(enteredKey)) {
                // Giriş uğurludur! İndi sənin orijinal menyunu ekrana gətirik
                ShowMenuOverlayWindow();
                
                // Toxunmaların işləməsi üçün UIWindow toxunma icazəsini tənzimləyirik
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    for (UIWindow *win in [[UIApplication sharedApplication] windows]) {
                        if (win != window) {
                            win.userInteractionEnabled = YES;
                        }
                    }
                });

            } else {
                // Xəta və ya yanlış key
                UIAlertController *errorAlert = [UIAlertController alertControllerWithTitle:@"Xəta" message:@"Yanlış key, vaxtı bitib və ya başqa cihaza bağlıdır!" preferredStyle:UIAlertControllerStyleAlert];
                [errorAlert addAction:[UIAlertAction actionWithTitle:@"Təkrar Cəhd Et" style:UIAlertActionStyleDestructive handler:^(UIAlertAction *action) {
                    showKeyInputWindow();
                }]];
                [rootVC presentViewController:errorAlert animated:YES completion:nil];
            }
        }];

        [alert addAction:loginAction];
        [rootVC presentViewController:alert animated:YES completion:nil];
    });
}

// 3. Oyun açılan kimi menyunun avtomatik açılmasını dayandırıb, yalnız key pəncərəsini çağırırıq
__attribute__((constructor)) static void init() {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        showKeyInputWindow();
    });
}
