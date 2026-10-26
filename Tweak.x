#import <UIKit/UIKit.h>

// Menyunun vəziyyətini və jesti idarə etmək üçün sinif
@interface OverlayManager : NSObject
+ (instancetype)sharedInstance;
@property (nonatomic, assign) BOOL isMenuOpen;
@property (nonatomic, strong) UIView *menuView; // Menyuzun UI elementi (əgər varsa)
-setupGesture;
@end

@implementation OverlayManager

+ (instancetype)sharedInstance {
    static OverlayManager *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[OverlayManager alloc] init];
    });
    return sharedInstance;
}

- (void)setupGesture {
    // UIWindow tam yüklənəndən sonra jesti əlavə edirik
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(5.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        UIWindow *keyWindow = nil;
        for (UIWindow *window in [UIApplication sharedApplication].windows) {
            if ([window isKeyWindow]) {
                keyWindow = window;
                break;
            }
        }
        
        if (keyWindow) {
            UITapGestureRecognizer *tripleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTripleTap:)];
            tripleTap.numberOfTapsRequired = 3;     // 3 dəfə basma
            tripleTap.numberOfTouchesRequired = 3;  // 3 barmaq
            [keyWindow addGestureRecognizer:tripleTap];
            NSLog(@"[Zirve] 3 barmaq 3 dəfə toxunma jesti uğurla əlavə edildi!");
        }
    });
}

- (void)handleTripleTap:(UITapGestureRecognizer *)sender {
    if (sender.state == UIGestureRecognizerStateEnded) {
        self.isMenuOpen = !self.isMenuOpen;
        
        // Burada menyunun görünürlüğünü tənzimləyirik
        // Əgər menyu pəncərəniz/görünüşünüz varsa buraya əlavə edin:
        // self.menuView.hidden = !self.isMenuOpen;
        
        if (self.isMenuOpen) {
            NSLog(@"[Zirve] Menyу açıldı!");
        } else {
            NSLog(@"[Zirve] Menyу bağlandı!");
        }
    }
}

@end

// Lisizans yoxlaması
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
            [[OverlayManager sharedInstance] setupGesture];
        } else {
            NSLog(@"[Zirve] Xəta: Yanlış və ya tapılmadı!");
        }
    });
}
