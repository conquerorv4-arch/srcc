#import <UIKit/UIKit.h>

@interface OverlayManager : NSObject
@property (strong, nonatomic) UIWindow *menuWindow;
@property (strong, nonatomic) UIWindow *floatingWindow;
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
        [self setupFloatingButton];
    }
    return self;
}

- (void)setupFloatingButton {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        UIWindowScene *scene = nil;
        for (UIScene *s in [UIApplication sharedApplication].connectedScenes) {
            if (s.activationState == UISceneActivationStateForegroundActive && [s isKindOfClass:[UIWindowScene class]]) {
                scene = (UIWindowScene *)s;
                break;
            }
        }

        if (scene) {
            self.floatingWindow = [[UIWindow alloc] initWithWindowScene:scene];
        } else {
            self.floatingWindow = [[UIWindow alloc] initWithFrame:CGRectMake(20, 100, 50, 50)];
        }

        self.floatingWindow.windowLevel = UIWindowLevelAlert + 2;
        self.floatingWindow.backgroundColor = [UIColor clearColor];

        UIViewController *floatVc = [[UIViewController alloc] init];
        floatVc.view.backgroundColor = [UIColor clearColor];

        // Yumru qara düymə
        UIButton *floatBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        floatBtn.frame = CGRectMake(15, 100, 45, 45);
        floatBtn.backgroundColor = [UIColor blackColor];
        [floatBtn setTitle:@"PUBG" forState:UIControlStateNormal];
        [floatBtn setTitleColor:[UIColor systemGreenColor] forState:UIControlStateNormal];
        floatBtn.titleLabel.font = [UIFont boldSystemFontOfSize:11];
        floatBtn.layer.cornerRadius = 22.5;
        floatBtn.layer.borderWidth = 1.5;
        floatBtn.layer.borderColor = [UIColor systemGreenColor].CGColor;
        [floatBtn addTarget:self action:@selector(toggleMenu) forControlEvents:UIControlEventTouchUpInside];

        // Düyməni sürükləmək (hərəkət etdirmək) üçün pan jesti
        UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePan:)];
        [floatBtn addGestureRecognizer:pan];

        [floatVc.view addSubview:floatBtn];
        self.floatingWindow.rootViewController = floatVc;
        [self.floatingWindow makeKeyAndVisible];
    });
}

- (void)handlePan:(UIPanGestureRecognizer *)sender {
    UIView *btn = sender.view;
    CGPoint translation = [sender translationInView:btn.superview];
    CGPoint center = CGPointMake(btn.center.x + translation.x, btn.center.y + translation.y);
    
    // Ekran sərhədlərində qalması üçün
    CGFloat screenWidth = [UIScreen mainScreen].bounds.size.width;
    CGFloat screenHeight = [UIScreen mainScreen].bounds.size.height;
    
    center.x = MAX(25, MIN(screenWidth - 25, center.x));
    center.y = MAX(25, MIN(screenHeight - 25, center.y));
    
    btn.center = center;
    [sender setTranslation:CGPointZero inView:btn.superview];
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
