#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>

#ifdef __cplusplus
extern "C" {
#endif
void ShowMenuOverlayWindow();
#ifdef __cplusplus
}
#endif

// 1. Serverdəki check.php ilə əlaqə yaradıb key və HWID yoxlayan funksiya
bool verifyKey(NSString *inputKey) {
    if (!inputKey || [inputKey length] == 0) return false;

    // Cihazın unikal HWID-sini alırıq
    NSString *deviceHWID = [[[UIDevice currentDevice] identifierForVendor] UUIDString];
    
    // Sənin server linkini qururuq
    NSString *urlString = [NSString stringWithFormat:@"https://zirvedeyim0.rf.gd/check.php?key=%@&hwid=%@", inputKey, deviceHWID];
    NSURL *url = [NSURL URLWithString:urlString];
    
    // Serverə sorğu göndəririk
    NSData *data = [NSData dataWithContentsOfURL:url];
    if (!data) return false;
    
    NSError *error;
    NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
    if (error) return false;
    
    NSString *status = json[@"status"];
    
    // Əgər status "success" olarsa girişə icazə veririk
    if ([status isEqualToString:@"success"]) {
        return true;
    } 
    
    return false;
}

// 2. Key daxil etmək üçün pəncərənin (Alert) göstərilməsi
void showKeyInputWindow() {
    dispatch_async(dispatch_get_main_queue(), ^{
        UIWindow *window = [[UIApplication sharedApplication] keyWindow];
        UIViewController *rootVC = window.rootViewController;
        if (!rootVC) return;

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
                // Giriş uğurludur! Sənin orijinal hile menyunu çağırırıq
                ShowMenuOverlayWindow();
                
                // Uğur mesajı
                UIAlertController *successAlert = [UIAlertController alertControllerWithTitle:@"Uğurlu" message:@"Giriş təsdiqləndi! Hile aktivdir." preferredStyle:UIAlertControllerStyleAlert];
                [successAlert addAction:[UIAlertAction actionWithTitle:@"Tamam" style:UIAlertActionStyleDefault handler:nil]];
                [rootVC presentViewController:successAlert animated:YES completion:nil];
            } else {
                // Giriş uğursuzdur (Yanlış key, vaxtı bitib və ya başqa cihaz)
                UIAlertController *errorAlert = [UIAlertController alertControllerWithTitle:@"Xəta" message:@"Yanlış key, vaxtı bitib və ya başqa cihaza bağlıdır!" preferredStyle:UIAlertControllerStyleAlert];
                [errorAlert addAction:[UIAlertAction actionWithTitle:@"Təkrar Cəhd Et" style:UIAlertActionStyleDestructive handler:^(UIAlertAction *action) {
                    showKeyInputWindow(); // Xəta olarsa pəncərəni yenidən açır
                }]];
                [rootVC presentViewController:errorAlert animated:YES completion:nil];
            }
        }];

        [alert addAction:loginAction];
        [rootVC presentViewController:alert animated:YES completion:nil];
    });
}

// 3. Oyun yüklənəndə işə düşən əsas constructor
__attribute__((constructor)) static void init() {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        showKeyInputWindow();
    });
}
