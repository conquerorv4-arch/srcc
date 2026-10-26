#import <UIKit/UIKit.h>

@interface LoginManager : NSObject
@property (strong, nonatomic) UIWindow *loginWindow;
@property (strong, nonatomic) UITextField *keyTextField;
@property (strong, nonatomic) UILabel *timerLabel;
@property (strong, nonatomic) NSTimer *countdownTimer;
@property (nonatomic) NSInteger remainingSeconds;
+ (instancetype)sharedInstance;
- (void)showLoginMenu;
@end

@implementation LoginManager

+ (instancetype)sharedInstance {
    static LoginManager *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[LoginManager alloc] init];
    });
    return sharedInstance;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        if ([self isKeyAlreadyValid]) {
            return;
        }
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self showLoginMenu];
        });
    }
    return self;
}

- (BOOL)isKeyAlreadyValid {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSDate *expirationDate = [defaults objectForKey:@"DarkKeyExpirationDate"];
    if (expirationDate) {
        if ([NSDate.date compare:expirationDate] == NSOrderedAscending) {
            return YES;
        }
    }
    return NO;
}

- (void)showLoginMenu {
    if (self.loginWindow) return;

    UIWindowScene *scene = nil;
    for (UIScene *s in [UIApplication sharedApplication].connectedScenes) {
        if (s.activationState == UISceneActivationStateForegroundActive && [s isKindOfClass:[UIScene class]]) {
            scene = (UIWindowScene *)s;
            break;
        }
    }

    if (scene) {
        self.loginWindow = [[UIWindow alloc] initWithWindowScene:scene];
    } else {
        self.loginWindow = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    }

    self.loginWindow.windowLevel = UIWindowLevelAlert + 10;
    self.loginWindow.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.6];

    UIViewController *vc = [[UIViewController alloc] init];
    vc.view.backgroundColor = [UIColor clearColor];

    // Mərkəzi qutu (Hündürlüyünü biraz artırdıq ki, timer sığışsın)
    UIView *container = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 300, 210)];
    container.center = vc.view.center;
    container.backgroundColor = [UIColor colorWithRed:0.12 green:0.12 blue:0.14 alpha:0.95];
    container.layer.cornerRadius = 14;
    container.layer.borderWidth = 1;
    container.layer.borderColor = [UIColor darkGrayColor].CGColor;

    // Geri sayım (Timer) yazısı
    self.remainingSeconds = 15;
    self.timerLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 15, 300, 25)];
    self.timerLabel.text = [NSString stringWithFormat:@"Kalan Süre: %lds", (long)self.remainingSeconds];
    self.timerLabel.textColor = [UIColor systemRedColor];
    self.timerLabel.textAlignment = NSTextAlignmentCenter;
    self.timerLabel.font = [UIFont boldSystemFontOfSize:14];
    [container addSubview:self.timerLabel];

    // Timeri işə salırıq
    self.countdownTimer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(updateTimer) userInfo:nil repeats:YES];

    // TextField: Paste Key
    self.keyTextField = [[UITextField alloc] initWithFrame:CGRectMake(25, 55, 250, 40)];
    self.keyTextField.backgroundColor = [UIColor colorWithRed:0.08 green:0.08 blue:0.10 alpha:1.0];
    self.keyTextField.textColor = [UIColor whiteColor];
    self.keyTextField.textAlignment = NSTextAlignmentCenter;
    self.keyTextField.font = [UIFont systemFontOfSize:14];
    self.keyTextField.layer.cornerRadius = 8;
    self.keyTextField.layer.borderWidth = 0.5;
    self.keyTextField.layer.borderColor = [UIColor grayColor].CGColor;
    
    [self.keyTextField setAttributedPlaceholder:[[NSAttributedString alloc] initWithString:@"Paste Key" attributes:@{NSForegroundColorAttributeName: [UIColor lightGrayColor]}]];
    [container addSubview:self.keyTextField];

    // Login Düyməsi
    UIButton *loginBtn = [UIButton buttonWithType:UIButtonTypeSystem];
    loginBtn.frame = CGRectMake(25, 120, 250, 40];
    [loginBtn setTitle:@"Login" forState:UIControlStateNormal];
    [loginBtn setTitleColor:[UIColor systemBlueColor] forState:UIControlStateNormal];
    loginBtn.titleLabel.font = [UIFont boldSystemFontOfSize:16];
    [loginBtn addTarget:self action:@selector(verifyKey) forControlEvents:UIControlEventTouchUpInside];
    [container addSubview:loginBtn];

    [vc.view addSubview:container];
    self.loginWindow.rootViewController = vc;
    [self.loginWindow makeKeyAndVisible];
}

- (void)updateTimer {
    self.remainingSeconds--;
    if (self.remainingSeconds > 0) {
        self.timerLabel.text = [NSString stringWithFormat:@"Kalan Süre: %lds", (long)self.remainingSeconds];
    } else {
        [self.countdownTimer invalidate];
        self.countdownTimer = nil;
        // 15 saniyə bitdi və key daxil edilmədi -> Çöküş (Crash)!
        abort();
    }
}

- (void)verifyKey {
    NSString *enteredKey = [self.keyTextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    if (enteredKey.length == 0) {
        abort();
    }

    // GİTHUB RAW LİNKİNİ BURA YAZ:
    NSString *urlString = @"https://raw.githubusercontent.com/ISTIFADE_ADIN/REPO_ADIN/main/keys.txt";
    NSURL *url = [NSURL URLWithString:urlString];
    
    NSError *error = nil;
    NSString *fileContent = [NSString stringWithContentsOfURL:url encoding:NSUTF8StringEncoding error:&error];
    
    if (error || !fileContent) {
        abort();
    }

    __block NSInteger foundDays = -1;
    NSArray *lines = [fileContent componentsSeparatedByString:@"\n"];
    
    [lines enumerateObjectsUsingBlock:^(NSString *line, NSUInteger idx, BOOL *stop) {
        NSArray *parts = [line componentsSeparatedByString:@":"];
        if (parts.count == 2) {
            NSString *keyInFile = [parts[0] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
            if ([keyInFile isEqualToString:enteredKey]) {
                foundDays = [parts[1] integerValue];
                *stop = YES;
            }
        }
    }];

    if (foundDays > 0) {
        // Doğrudursa timeri dayandırırıq
        [self.countdownTimer invalidate];
        self.countdownTimer = nil;

        NSTimeInterval seconds = foundDays * 24 * 60 * 60;
        NSDate *expirationDate = [NSDate dateWithTimeIntervalSinceNow:seconds];
        
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        [defaults setObject:expirationDate forKey:@"DarkKeyExpirationDate"];
        [defaults synchronize];

        [self.loginWindow setHidden:YES];
        self.loginWindow = nil;
    } else {
        // Yanlış key daxil edildikdə dərhal crash atır!
        abort();
    }
}

@end

%ctor {
    [LoginManager sharedInstance];
}
