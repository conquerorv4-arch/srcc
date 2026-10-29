#import "菜单.h"
#import "XORstring.h"
#include "Image/Icon.h"
#import "View/OverlayView.h"
#include "IconsFontAwesome6.h"
#include <string>
#include <algorithm>
#include <chrono>
#include <dlfcn.h>
#include <iostream>
#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

// ============= GLOBAL VARIABLES =============
static bool isKeyAuthenticated = false; // Key təsdiqlənənə qədər false
static char keyInputText[128] = "";    // Key daxil etmək üçün xana
static char statusMessage[256] = "Lutfen Key Daxil Edin";
static bool show = true;
static bool streamerSecureMode = false;
static bool handMode = false;

// ============= HARDWARE ID & KEY CHECK FUNCTIONS =============
std::string getDeviceHWID() {
    NSUUID *uuid = [[UIDevice currentDevice] identifierForVendor];
    NSString *uuidString = [uuid UUIDString];
    return std::string([uuidString UTF8String]);
}

bool verifyKeyWithServer(std::string inputKey) {
    std::string hwid = getDeviceHWID();
    NSString *urlString = [NSString stringWithFormat:@"https://darkhxtekcu.site.je/check.php?key=%s&hwid=%s", inputKey.c_str(), hwid.c_str()];
    
    NSURL *url = [NSURL URLWithString:urlString];
    NSData *data = [NSData dataWithContentsOfURL:url];
    if (!data) return false;
    
    NSError *error;
    NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
    
    if (json && [json[@"status"] isEqualToString:@"success"]) {
        return true;
    }
    return false;
}

@implementation mi
OverlayView *overlayView;

- (instancetype)initWithFrame:(ModuleControl*)control {
    self.moduleControl = control;
    return [super init];
}

-(void)setOverlayView:(OverlayView*)ov{
    overlayView = ov;
}

- (void)initializeImGui {
    ImGuiIO& io = ImGui::GetIO();
}

-(void)drawMenuWindow {
    ImGuiIO& io = ImGui::GetIO();
    
    // Əgər Key hələ təsdiqlənməyibsə, 30 saniyəlik geri sayım ilə Key Giriş Ekranı göstərilir
    if (!isKeyAuthenticated) {
        static float timeLeft = 30.0f; // 30 saniyəlik taymer
        
        // Hər frame-də taymeri azaldırıq
        timeLeft -= io.DeltaTime;
        
        ImGui::SetNextWindowSize(ImVec2(400, 240), ImGuiCond_Always);
        ImGui::SetNextWindowPos(ImVec2(io.DisplaySize.x * 0.5f, io.DisplaySize.y * 0.5f), ImGuiCond_Always, ImVec2(0.5f, 0.5f));
        
        ImGui::Begin("DARK IOS - Login", &show, ImGuiWindowFlags_NoCollapse | ImGuiWindowFlags_NoResize);
        
        ImGui::Text("Enter License Key:");
        ImGui::InputText("##key", keyInputText, IM_ARRAYSIZE(keyInputText));
        
        ImGui::Spacing();
        // Geri sayımı ekranda göstəririk
        ImGui::TextColored(ImVec4(1.0f, 0.5f, 0.0f, 1.0f), "Avtomatik cixis: %.0f saniye", timeLeft);
        
        // Vaxt 0 olduqda heç nə yazılmayıbsa oyun bağlanır (crash)
        if (timeLeft <= 0.0f) {
            exit(0);
        }
        
        ImGui::Spacing();
        if (ImGui::Button("LOGIN", ImVec2(150, 40))) {
            if (verifyKeyWithServer(keyInputText)) {
                isKeyAuthenticated = true;
                snprintf(statusMessage, sizeof(statusMessage), "Xos geldiniz!");
            } else {
                snprintf(statusMessage, sizeof(statusMessage), "Sehv Key veya Basqa Cihaza Bagli!");
            }
        }
        
        ImGui::Spacing();
        ImGui::TextColored(ImVec4(1.0f, 0.0f, 0.0f, 1.0f), "%s", statusMessage);
        ImGui::End();
        return;
    }

    // --- YENİ DARK IOS MENÜ DİZAYNI ---
    ImGui::SetNextWindowSize(ImVec2(1000, 600), ImGuiCond_Once);
    ImGui::SetNextWindowPos(ImVec2(io.DisplaySize.x * 0.5f, io.DisplaySize.y * 0.5f), ImGuiCond_FirstUseEver, ImVec2(0.5f, 0.5f));
    
    ImGui::PushStyleVar(ImGuiStyleVar_WindowPadding, ImVec2(0, 0));
    ImGui::PushStyleColor(ImGuiCol_WindowBg, ImVec4(0.05f, 0.06f, 0.08f, 1.0f)); // Tünd göy-qara fon
    ImGui::PushStyleColor(ImGuiCol_Border, ImVec4(0.1f, 0.1f, 0.1f, 1.0f));

    if (ImGui::Begin("DARK IOS", &self.moduleControl->menuStatus, ImGuiWindowFlags_NoTitleBar | ImGuiWindowFlags_NoResize)) {
        
        // --- SOL PANEL (SIDEBAR) ---
        ImGui::BeginChild("Sidebar", ImVec2(260, 600), true);
        
            ImGui::Spacing();
            ImGui::SetCursorPosX(20);
            ImGui::TextColored(ImVec4(1.0f, 1.0f, 1.0f, 1.0f), "DARK IOS");
            ImGui::Spacing(); ImGui::Spacing();

            // Aimbot Kateqoriyası
            ImGui::TextColored(ImVec4(0.4f, 0.4f, 0.4f, 1.0f), "  Aimbot");
            
            ImGui::PushStyleColor(ImGuiCol_Header, ImVec4(0.2f, 0.4f, 0.8f, 1.0f));
            ImGui::Selectable("  Aim Bot", true);
            ImGui::PopStyleColor();
            
            ImGui::Selectable("  Advanced");
            ImGui::Selectable("  Legit Bot");
            
            ImGui::Spacing(); ImGui::Spacing();

            // Visuals Kateqoriyası
            ImGui::TextColored(ImVec4(0.4f, 0.4f, 0.4f, 1.0f), "  Visuals");
            ImGui::Selectable("  Players");
            ImGui::Selectable("  World");

            ImGui::Spacing(); ImGui::Spacing();

            // Scripts Kateqoriyası
            ImGui::TextColored(ImVec4(0.4f, 0.4f, 0.4f, 1.0f), "  Scripts");
            ImGui::Selectable("  Scripts");

            ImGui::Spacing(); ImGui::Spacing();

            // Miscellaneous
            ImGui::TextColored(ImVec4(0.4f, 0.4f, 0.4f, 1.0f), "  Miscellaneous");
            ImGui::Selectable("  Main");

        ImGui::EndChild();
        
        ImGui::SameLine();

        // --- SAĞ PANEL (ƏSAS MƏZMUN) ---
        ImGui::BeginChild("MainContent", ImVec2(0, 0), false);
            
            ImGui::Spacing();
            ImGui::Text("  Save");
            ImGui::SameLine(700);
            ImGui::Text("🔍  ⚙️");
            ImGui::Separator();
            ImGui::Spacing();

            // 2 Sütunlu Grid
            ImGui::Columns(2, "SettingsGrid", true);

            // 1-ci Sütun
            ImGui::BeginChild("MovementBox", ImVec2(0, 250), true);
                ImGui::TextColored(ImVec4(0.6f, 0.6f, 0.6f, 1.0f), "Movement");
                ImGui::Separator();
                static bool p_speed = false; ImGui::Checkbox("player speed", &p_speed);
                static bool h_jump = true;   ImGui::Checkbox("high jump", &h_jump);
                static bool f_jump = false;  ImGui::Checkbox("frog jump", &f_jump);
                static bool c_fly = false;   ImGui::Checkbox("coord fly", &c_fly);
            ImGui::EndChild();

            ImGui::BeginChild("UtilityBox", ImVec2(0, 250), true);
                ImGui::TextColored(ImVec4(0.6f, 0.6f, 0.6f, 1.0f), "Utility");
                ImGui::Separator();
                static bool a_pick = false; ImGui::Checkbox("auto pickup", &a_pick);
                static bool d_punch = false;ImGui::Checkbox("door punch", &d_punch);
                static bool s_car = false;  ImGui::Checkbox("super car", &s_car);
                static bool noclip = true;  ImGui::Checkbox("noclip", &noclip);
            ImGui::EndChild();

            ImGui::NextColumn();

            // 2-ci Sütun
            ImGui::BeginChild("CombatBox", ImVec2(0, 250), true);
                ImGui::TextColored(ImVec4(0.6f, 0.6f, 0.6f, 1.0f), "Combat");
                ImGui::Separator();
                static bool n_recoil = true; ImGui::Checkbox("no recoil", &n_recoil);
                static bool f_shoot = true;  ImGui::Checkbox("fast shoot", &f_shoot);
                static bool a_punch = false; ImGui::Checkbox("anti flag punch", &a_punch);
                static bool m_accel = false; ImGui::Checkbox("mini accel", &m_accel);
            ImGui::EndChild();

            ImGui::BeginChild("ExploitsBox", ImVec2(0, 250), true);
                ImGui::TextColored(ImVec4(0.6f, 0.6f, 0.6f, 1.0f), "Exploits");
                ImGui::Separator();
                static bool c_scale = true; ImGui::Checkbox("character scale", &c_scale);
            ImGui::EndChild();

            ImGui::Columns(1);

        ImGui::EndChild();

        ImGui::End();
    }

    ImGui::PopStyleColor(2);
    ImGui::PopStyleVar(1);
}

- (UIWindow*)GetUIW {
    UIWindow *window = [UIApplication sharedApplication].keyWindow;
    if (window.windowLevel != UIWindowLevelNormal) {
        NSArray *arr = [UIApplication sharedApplication].windows;
        for (UIWindow *tmp in arr) {
            if (tmp.windowLevel == UIWindowLevelNormal) {
                window = tmp;
                break;
            }
        }
    }
    return window;
}

-(void)readIniConfig {}
-(void)saveIniConfig {}
- (void)dealloc {}

@end

// ============= FLOATING BUTTON & OVERLAY INITIALIZER =============
@interface FloatingMenuButton : UIButton
@property (nonatomic, assign) void* moduleControl;
@end

@implementation FloatingMenuButton {
    CGPoint touchLocation;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.5];
        self.layer.cornerRadius = frame.size.width / 2.0;
        self.clipsToBounds = YES;
        [self addTarget:self action:@selector(buttonTapped) forControlEvents:UIControlEventTouchUpInside];
    }
    return self;
}

- (void)buttonTapped {
    struct DummyControl {
        bool menuStatus;
    };
    if (self.moduleControl) {
        ((struct DummyControl*)self.moduleControl)->menuStatus = !((struct DummyControl*)self.moduleControl)->menuStatus;
    }
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [super touchesBegan:touches withEvent:event];
    UITouch *touch = [touches anyObject];
    touchLocation = [touch locationInView:self];
}

- (void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [super touchesMoved:touches withEvent:event];
    UITouch *touch = [touches anyObject];
    CGPoint currentLoc = [touch locationInView:self.superview];
    self.center = CGPointMake(currentLoc.x - touchLocation.x + self.frame.size.width/2,
                              currentLoc.y - touchLocation.y + self.frame.size.height/2);
}

@end

#ifdef __cplusplus
extern "C" {
#endif

__attribute__((visibility("default"))) void ShowMenuOverlayWindow() {
    dispatch_async(dispatch_get_main_queue(), ^{
        UIWindow *window = [UIApplication sharedApplication].keyWindow;
        if (!window) {
            window = [[UIApplication sharedApplication].windows firstObject];
        }
        
        if (window) {
            static ModuleControl *modControl = new ModuleControl();
            static mi *menuInstance = [[mi alloc] initWithFrame:modControl];
            
            CGRect frame = window.bounds;
            OverlayView *overlay = [[OverlayView alloc] initWithFrame:frame :modControl :menuInstance];
            [menuInstance setOverlayView:overlay];
            
            [window addSubview:overlay];
            [window bringSubviewToFront:overlay];
            
            static FloatingMenuButton *floatBtn = nil;
            if (!floatBtn) {
                floatBtn = [[FloatingMenuButton alloc] initWithFrame:CGRectMake(100, 100, 50, 50)];
                floatBtn.moduleControl = modControl;
                [window addSubview:floatBtn];
                [window bringSubviewToFront:floatBtn];
            }
            
            extern bool isKeyAuthenticated;
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                while(true) {
                    dispatch_sync(dispatch_get_main_queue(), ^{
                        floatBtn.hidden = !isKeyAuthenticated;
                    });
                    [NSThread sleepForTimeInterval:0.2];
                }
            });
            
        } else {
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                ShowMenuOverlayWindow();
            });
        }
    });
}

#ifdef __cplusplus
}
#endif
