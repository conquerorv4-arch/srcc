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

%ctor {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        if (checkLicense()) {
            NSLog(@"[Zirve] Key Təsdiqləndi!");
        } else {
            NSLog(@"[Zirve] Xəta: Yanlış və ya tapılmadı!");
        }
    });
}
