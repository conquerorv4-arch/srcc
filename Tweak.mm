#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>

#ifdef __cplusplus
extern "C" {
#endif
void ShowMenuOverlayWindow();
#ifdef __cplusplus
}
#endif

// Serveri yoxlayan və cavabı konsola yazdıran funksiya
bool verifyKey(NSString *inputKey) {
    if (!inputKey || [inputKey length] == 0) return false;

    inputKey = [inputKey stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];

    NSString *deviceHWID = [[[UIDevice currentDevice] identifierForVendor] UUIDString];
    NSString *urlString = [NSString stringWithFormat:@"https://srcc-zoab.onrender.com/check.php?key=%@&hwid=%@", inputKey, deviceHWID];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:urlString]];
    [request setValue:@"Mozilla/5.0 (iPhone; CPU iPhone OS 16_0 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Mobile/15E148" forHTTPHeaderField:@"User-Agent"];
    [request setTimeoutInterval:15.0];

    NSError *error = nil;
    NSURLResponse *response = nil;
    NSData *data = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
    
    if (error || !data) {
        NSLog(@"[DARKIOS] Bağlantı Hatası: %@", error.localizedDescription);
        return false;
    }
    
    NSString *rawResponse = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    NSLog(@"[DARKIOS] Server Yanıtı: %@", rawResponse);
    
    NSError *jsonError = nil;
    NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:0 error:&jsonError];
    if (jsonError || !json) {
        NSLog(@"[DARKIOS] JSON Çevirme Hatası: %@", jsonError.localizedDescription);
        return false;
    }
    
    NSString *status = json[@"status"];
    return [status isEqualToString:@"success"];
}

// Key daxiletmə pəncərəsi
void showKeyInputWindow() {
    dispatch_async(dispatch_get_main_queue(), ^{
        UIWindow *window = [[UIApplication sharedApplication] keyWindow];
        UIViewController *rootVC = window.rootViewController;
        if (!rootVC) return;

        if ([rootVC presentedViewController]) return;

        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"DARKIOS - Key Login"
                                                                       message:@"Admin paneldən aldığınız keyi daxil edin:"
                                                                preferredStyle:UIAlertControllerStyleAlert];

        [alert addTextFieldWithConfigurationHandler:^(UITextField *textField) {
            textField.placeholder = @"DARKIOS-1D-XXXXX";
            textField.clearButtonMode = UITextFieldViewModeWhileEditing;
        }];

        UIAlertAction *loginAction = [UIAlertAction actionWithTitle:@"Daxil Ol" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            UITextField *textField = alert.textFields.firstObject;
            NSString *enteredKey = textField.text;

            if (verifyKey(enteredKey)) {
                ShowMenuOverlayWindow();
                
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    for (UIWindow *win in [[UIApplication sharedApplication] windows]) {
                        if (win != window) {
                            win.userInteractionEnabled = YES;
                        }
                    }
                });

            } else {
                UIAlertController *errorAlert = [UIAlertController alertControllerWithTitle:@"Xəta" message:@"Yanlış key, vaxtı bitib və ya cihaz limiti dolub!" preferredStyle:UIAlertControllerStyleAlert];
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

__attribute__((constructor)) static void init() {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        showKeyInputWindow();
    });
}
