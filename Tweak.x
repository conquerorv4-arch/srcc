#import <UIKit/UIKit.h>

@interface OverlayManager : NSObject
@property (strong, nonatomic) UIWindow *menuWindow;
+ (instancetype)sharedInstance;
- (void)toggleMenu;
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

- (instancetype)init {
    self = [super init];
    if (self) {
        [self setupGesture];
    }
    return self;
}

- (void)setupGesture {
    // Oyun tam yüklendikten sonra jesti əlavə edirik
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        UIWindow *keyWindow = nil;
        for (UIWindow *window in [UIApplication sharedApplication].windows) {
            if (window.isKeyWindow) {
                keyWindow = window;
                break;
            }
        }
        if (!keyWindow) {
            keyWindow = [UIApplication sharedApplication].keyWindow;
        }
        
        if (keyWindow) {
            UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTripleTap:)];
            tap.numberOfTapsRequired = 3;
            tap.numberOfTouchesRequired = 3;
            [keyWindow addGestureRecognizer:tap];
        }
    });
}

- (void)handleTripleTap:(UITapGestureRecognizer *)sender {
    if (sender.state == UIGestureRecognizerStateEnded) {
        [self toggleMenu];
    }
}

- (void)toggleMenu {
    if (self.menuWindow) {
        [self.menuWindow setHidden:YES];
        self.menuWindow = nil;
        return;
    }

    UIWindowScene *scene = nil;
    for (UIScene *s in [UIApplication sharedApplication].connectedScenes) {
        if (s.activationState == UISceneActivationStateForegroundActive && [s isKindOfClass:[UIWindowScene class]]) {
            scene = (UIWindowScene *)s;
            break;
        }
    }

    if (scene) {
        self.menuWindow = [[UIWindow alloc] initWithWindowScene:scene];
    } else {
        self.menuWindow = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    }

    self.menuWindow.windowLevel = UIWindowLevelAlert + 1;
    self.menuWindow.backgroundColor = [UIColor clearColor];

    UIViewController *vc = [[UIViewController alloc] init];
    vc.view.backgroundColor = [UIColor clearColor];

    // Menyu pəncərəsi (Container)
    UIView *container = [[UIView alloc] initWithFrame:CGRectMake(50, 100, 280, 320)];
    container.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.85];
    container.layer.cornerRadius = 16;
    container.layer.borderWidth = 1.5;
    container.layer.borderColor = [UIColor systemGreenColor].CGColor;

    // Başlıq
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 15, 280, 30)];
    titleLabel.text = @"PUBG Ultimate Menu";
    titleLabel.textColor = [UIColor whiteColor];
    titleLabel.textAlignment = NSTextAlignmentCenter;
    titleLabel.font = [UIFont boldSystemFontOfSize:18];
    [container addSubview:titleLabel];

    // Bağlama düyməsi (X)
    UIButton *closeBtn = [UIButton buttonWithType:UIButtonTypeSystem];
    closeBtn.frame = CGRectMake(235, 10, 35, 35);
    [closeBtn setTitle:@"✕" forState:UIControlStateNormal];
    [closeBtn setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
    [closeBtn.titleLabel setFont:[UIFont boldSystemFontOfSize:18]];
    [closeBtn addTarget:self action:@selector(toggleMenu) forControlEvents:UIControlEventTouchUpInside];
    [container addSubview:closeBtn];

    // Funksiya / Switch nümunəsi
    UILabel *switchLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 70, 180, 30)];
    switchLabel.text = @"ESP Box / Line";
    switchLabel.textColor = [UIColor whiteColor];
    switchLabel.font = [UIFont systemFontOfSize:14];
    [container addSubview:switchLabel];

    UISwitch *sw = [[UISwitch alloc] initWithFrame:CGRectMake(210, 70, 50, 30)];
    [sw setOnTintColor:[UIColor systemGreenColor]];
    [container addSubview:sw];

    // Alt məlumat
    UILabel *infoLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 260, 240, 30)];
    infoLabel.text = @"Status: Active";
    infoLabel.textColor = [UIColor lightGrayColor];
    infoLabel.font = [UIFont systemFontOfSize:12];
    infoLabel.textAlignment = NSTextAlignmentCenter;
    [container addSubview:infoLabel];

    [vc.view addSubview:container];
    self.menuWindow.rootViewController = vc;
    [self.menuWindow makeKeyAndVisible];
}

@end

%ctor {
    [OverlayManager sharedInstance];
}
