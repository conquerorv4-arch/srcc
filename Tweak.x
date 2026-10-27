void showFloatingButton() {
    if (floatingWindow) return;

    UIWindowScene *scene = nil;
    for (UIScene *s in [UIApplication sharedApplication].connectedScenes) {
        if ([s isKindOfClass:[UIWindowScene class]]) {
            scene = (UIWindowScene *)s;
            break;
        }
    }

    if (@available(iOS 13.0, *)) {
        if (scene) {
            floatingWindow = [[UIWindow alloc] initWithWindowScene:scene];
        } else {
            floatingWindow = [[UIWindow alloc] initWithFrame:CGRectMake(50, 100, 50, 50)];
        }
    } else {
        floatingWindow = [[UIWindow alloc] initWithFrame:CGRectMake(50, 100, 50, 50)];
    }

    floatingWindow.windowLevel = UIWindowLevelAlert + 2000;
    floatingWindow.backgroundColor = [UIColor clearColor];
    
    UIViewController *vc = [[UIViewController alloc] init];
    floatingWindow.rootViewController = vc;
    [floatingWindow makeKeyAndVisible];

    // Şəkildəki kimi halqalı/q ۲۰۰atlı dizayn üçün əsas düymə
    UIButton *floatBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    floatBtn.frame = CGRectMake(0, 0, 50, 50);
    floatBtn.backgroundColor = [UIColor colorWithRed:0.15 green:0.18 blue:0.22 alpha:1.0];
    floatBtn.layer.cornerRadius = 25.0;
    floatBtn.layer.borderWidth = 3.0;
    floatBtn.layer.borderColor = [UIColor colorWithRed:0.35 green:0.40 blue:0.45 alpha:1.0].CGColor;
    floatBtn.clipsToBounds = YES;
    
    // İçindəki kiçik halqa effekti üçün alt görünüş (View)
    UIView *innerRing = [[UIView alloc] initWithFrame:CGRectMake(8, 8, 34, 34)];
    innerRing.backgroundColor = [UIColor colorWithRed:0.25 green:0.30 blue:0.35 alpha:1.0];
    innerRing.layer.cornerRadius = 17.0;
    innerRing.userInteractionEnabled = NO;
    [floatBtn addSubview:innerRing];
    
    // Ən içdəki ağ/açıq hissə
    UIView *coreCircle = [[UIView alloc] initWithFrame:CGRectMake(14, 14, 22, 22)];
    coreCircle.backgroundColor = [UIColor colorWithWhite:0.9f alpha:1.0f];
    coreCircle.layer.cornerRadius = 11.0;
    coreCircle.userInteractionEnabled = NO;
    [floatBtn addSubview:coreCircle];

    [floatBtn addTarget:[FloatingHelper class] action:@selector(floatBtnTapped) forControlEvents:UIControlEventTouchUpInside];
    
    UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:[FloatingHelper class] action:@selector(floatBtnDragged:)];
    [floatBtn addGestureRecognizer:pan];
    
    [vc.view addSubview:floatBtn];
}
