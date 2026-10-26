#line 1 "Tweak.x"
#import <Foundation/Foundation.h>

BOOL checkLicense(NSString *userKey) {
    if ([userKey isEqualToString:@"ZIRVE-2026"]) {
        return YES;
    }
    return NO;
}

static __attribute__((constructor)) void _logosLocalCtor_03738126(int __unused argc, char __unused **argv, char __unused **envp) {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        NSString *savedKey = @"ZIRVE-2026";
        
        if (checkLicense(savedKey)) {
            NSLog(@"[Zirve] Key Təsdiqləndi!");
        } else {
            NSLog(@"[Zirve] Xəta: Yanlış key!");
        }
    });
}
