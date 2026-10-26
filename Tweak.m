#line 1 "Tweak.x"
#import <Foundation/Foundation.h>

BOOL checkLicense() {
    NSString *keyPath = @"/var/mobile/Documents/key.txt";
    NSError *error = nil;
    NSString *savedKey = [NSString stringWithContentsOfFile:keyPath encoding:NSUTF8StringEncoding error:&error];
    
    savedKey = [savedKey stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    if ([savedKey isEqualToString:@"ZIRVE-2026"]) {
        return YES;
    }
    return NO;
}

static __attribute__((constructor)) void _logosLocalCtor_36cf86a9(int __unused argc, char __unused **argv, char __unused **envp) {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        if (checkLicense()) {
            NSLog(@"[Zirve] Key Təsdiqləndi!");
        } else {
            NSLog(@"[Zirve] Xəta: Yanlış və ya tapılmadı!");
        }
    });
}
