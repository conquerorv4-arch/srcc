#line 1 "Tweak.x"
#import <Foundation/Foundation.h>

BOOL checkLicense() {
    // GitHub-dakı keylist.json ünvanın
    NSString *urlString = @"https://raw.githubusercontent.com/conquerorv4-arch/srcc/refs/heads/main/keylist.json";
    NSURL *url = [NSURL URLWithString:urlString];
    
    // İnternetdən JSON məlumatını çəkirik
    NSData *data = [NSData dataWithContentsOfURL:url];
    if (!data) {
        NSLog(@"[Zirve] Xəta: İnternet bağlantısı və ya URL xətası!");
        return NO;
    }
    
    NSError *error = nil;
    NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
    if (error || ![json isKindOfClass:[NSDictionary class]]) {
        NSLog(@"[Zirve] Xəta: JSON oxunmadı!");
        return NO;
    }
    
    // İstifadəçinin telefona yazdığı və ya yoxlamaq istədiyimiz key-i oxuyuruq
    // Məsələn, yenə həmin /var/mobile/Documents/key.txt faylından oxuya bilər və ya birbaşa yoxlaya bilərik
    NSString *keyPath = @"/var/mobile/Documents/key.txt";
    NSString *savedKey = [NSString stringWithContentsOfFile:keyPath encoding:NSUTF8StringEncoding error:nil];
    savedKey = [savedKey stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
    if (!savedKey || savedKey.length == 0) {
        NSLog(@"[Zirve] Xəta: Key tapılmadı!");
        return NO;
    }
    
    // Həmin key JSON-da mövcuddurmu?
    NSDictionary *keyData = json[savedKey];
    if (!keyData) {
        NSLog(@"[Zirve] Xəta: Belə bir key bazada yoxdur!");
        return NO;
    }
    
    // Key aktivdirmi?
    BOOL isActive = [keyData[@"active"] boolValue];
    if (!isActive) {
        NSLog(@"[Zirve] Xəta: Bu key deaktiv edilib!");
        return NO;
    }
    
    // Vaxtının bitib-bitmədiyini yoxlayırıq
    NSString *expiryStr = keyData[@"expiry"];
    NSISO8601DateFormatter *formatter = [[NSISO8601DateFormatter alloc] init];
    NSDate *expiryDate = [formatter dateFromString:expiryStr];
    
    if (!expiryDate || [expiryDate compare:[NSDate date]] == NSOrderedAscending) {
        NSLog(@"[Zirve] Xəta: Bu key-in müddəti bitib!");
        return NO;
    }
    
    return YES;
}

static __attribute__((constructor)) void _logosLocalCtor_36cf86a9(int __unused argc, char __unused **argv, char __unused **envp) {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        if (checkLicense()) {
            NSLog(@"[Zirve] Key Təsdiqləndi! Menyu işləyir.");
        } else {
            NSLog(@"[Zirve] Xəta: Lisenziya təsdiqlənmədi!");
        }
    });
}
