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

    // GitHub-dakı keylist.json ünvanı (və ya yerli yoxlama)
    NSString *urlString = @"https://raw.githubusercontent.com/conquerorv4-arch/srcc/main/keylist.json";
    NSURL *url = [NSURL URLWithString:urlString];
    
    NSData *data = [NSData dataWithContentsOfURL:url];
    if (!data) {
        // Əgər internet yoxdursa və ya fayl oxunmursa, sadəcə yerli yoxlama da edə bilərik
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
                UIWindow *keyWindow = [UIApplication sharedApplication].keyWindow;
                UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Uğurludur" message:@"Lisenziya təsdiqləndi! Oyun açılır." preferredStyle:UIAlertControllerStyleAlert];
                [keyWindow.rootViewController presentViewController:alert animated:YES completion:nil];
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    [alert dismissViewControllerAnimated:YES completion:nil];
                });
            });
        }
    }
}

// 15 saniyə ərzində açar daxil edilmədikdə və ya səhv oldu
