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
#include "Skin.h"
#import "XORstring.h"
#include "ESP/mahoa.h"
#include "sys/mman.h"
#include "ESP/Tools.h"
#import <AVFoundation/AVFoundation.h>
#include <stdio.h>
#include <stdint.h>
#import <CoreTelephony/CTTelephonyNetworkInfo.h>
#include <string.h>
#include "ESP/Vector3.hpp"
#include "ESP/Vector2.hpp"
#import <Foundation/Foundation.h>
#include "ESP/tahoma.h"
#include "Helper/ini_rw.h"

#define ICON_FA_MEMORY ""
#define ICON_FA_GUN "\xef\x9b\xab"
#define ICON_FA_EYE "\uf06e"

#define kWidth  [UIScreen mainScreen].bounds.size.width
#define kHeight [UIScreen mainScreen].bounds.size.height
#define SCREEN_WIDTH [UIScreen mainScreen].bounds.size.width
#define SCREEN_HEIGHT [UIScreen mainScreen].bounds.size.height

// ============= GLOBAL VARIABLES =============
static bool isKeyAuthenticated = false; 
static bool 错误提示 = false;
static char keyInputText[128] = "";    
static char statusMessage[256] = "Lutfen Key Daxil Edin";
static bool show = true;
static bool streamerSecureMode = false; 
static bool handMode = false;            

// ESP Variables
bool ModSkinn = false;
bool KillMessage = false;
bool DeadBox = false;
JsonPreferences preferences;
bool Line = false;
bool Line2 = false;
bool Box = false;
bool Box2 = false;
bool 血条 = false;
bool 血条B = false;
bool Skeleton = false;
float skthick = 0.0f;
bool 信息 = false;
bool Weapon = false;
bool Weapon2 = false;
bool Alert = false;
bool GRWAR = false;
bool ESPON = false;
bool ESPNotBot = false;

// Aim Variables
bool AimBot = false;
bool Enable = false;
bool Enablev2 = false;
bool AutoFire = false;
int Cross = 0;
bool TPCAR = false;
bool IgnoreKnocked = false;
bool IgnoreBot = false;
bool VisCheck = false;
bool VisCheckBT = false;
bool AutoStandd = false;
float AimSpeed = 0.0f;
float Aimsmooth = 0.0f;
float g_disstance = 0.0f;
int AimF = 0;
int AimL = 0;

// Loot Variables
bool IsLootBox = false;
bool IsVehcle = false;
bool IsboxVechle = false;
bool IsCarFuel = false;
bool 步枪 = false;
bool 狙击 = false;
bool 地铁物资 = false;
bool 物资冲锋 = false;
bool 物资配件 = false;
bool 物资防具 = false;
bool 物资倍镜 = false;
bool IsSMG = false;
bool IsAR = false;
bool IsITM = false;
bool IsShotgun = false;

// Memory/Hack Variables
bool Fps120 = false;
bool Fps90 = false;
bool Fps60 = false;
bool ipadview = false;
bool NoFog = false;
bool CrossHairSpin = false;
int WideValue = 0;
bool CrossHair = false;
bool CrossLong = false;
bool CrossHairR = false;
bool CrossHairR1 = false;
bool ReCo = false;
bool NoRecoil = false;
bool HitX = false;
bool AUOTJUMPAN = false;
bool Fullhack = false;
bool FastCrouch = false;
bool damage = false;
bool infinity = false;
bool bigscope = false;
bool MagicBullet = false;
float MagicBulletX = 0.0f;
float MagicBulletY = 0.0f;
float MagicBulletZ = 0.0f;
bool FastWeapon = false;
bool Fastshoot = false;
bool NoGravity = false;
float valueplayer = 0.0f;
bool BigPlayer = false;
bool NoSpreadBullet = false;
bool HighJump = false;
bool FastKnock = false;
bool HeadShoott = false;
bool FastBullet = false;
bool hidename = false;
bool NoCameraShake = false;
bool Peeking = false;
bool spinplayer = false;
bool weaponAbovePlayerHidden = false;
bool crazycar = false;
int carvalue = 0;
bool Rainbow = false;
bool Rainbow1 = false;
bool Flash2 = false;
bool SdkFlash2 = false;
int SpeedValue = 0;
bool Flash1 = false;
bool flashEnabled = false;
int FlashValue = 0;
bool SuperJump = false;
bool SdkSuper = false;
float SuperValue = 0.0f;
bool Swim = false;
bool Scope = false;
bool goodview = false;
bool good = false;
bool FAKEDAMAGEV2 = false;
bool FAKEDAMAGE = false;
bool FAKEDAMAGEV3 = false;
bool rest = false;
bool Silenttest = false;
bool bighit2 = false;
bool FastSwimV2 = false;
bool TeleportToPlayer = false;
bool TeleportToVehicle = false;
bool TeleportToLootBox = false;
bool DefaultSpeed = false;
bool AutoParachute = false;
float AutoParachuteScale = 0.0f;
bool AutoAGHA = false;
bool SlowMotion = false;
float SlowMotionFactor = 0.0f;
bool SlowMotion2 = false;
float SlowMotionFactor2 = 0.0f;
bool SniAR = false;
float FrameTimeValue = 0.0f;
bool WeaponSize = false;
float GunSize = 0.0f;
bool SilentGodview = false;
bool welapongod = false;
float gungody = 0.0f;
float gungodz = 0.0f;
float gungodx = 0.0f;
bool showdamage = false;
bool flly = false;
bool bunny = false;
bool ggxhit = false;
int carx = 0;
int cary = 0;
int carz = 0;
bool carfly = false;
bool dead = false;
bool distancee = false;
bool distancee2 = false;
bool RightLeft = false;
bool FuelVehicle = false;
bool flyy = false;
bool wall = false;
bool FlashSpeedd = false;
bool Speedknock = false;
bool Crazy = false;
bool IsBulletTracking360Enabled = false;
bool IsAutofire = false;
float HideEsp = 0.0f;
bool jumpee = false;
float jumped = 0.0f;
bool jumpeee = false;
bool jumpeeee = false;
bool LockStatus = false;
bool LockStatusoff = false;
bool SpeedPlayerV2 = false;
bool SpeedPlayer = false;
bool VIPJUMP = false;
float SPEEDJUMP = 0.0f;
float SPEEDAIR = 0.0f;
float GRAVITYSCALE = 0.0f;
float VIPHIGH = 0.0f;
float EnergyScale = 0.0f;
float JUMPANIMETION = 0.0f;
bool Tigerjump = false;
float TIGER = 0.0f;
bool Tp = false;
bool bPeekFly = false;
float TpSpeed = 0.0f;
bool AutoFly = false;
bool FlashV4 = false;
float FlashV4Value = 0.0f;
bool RemoveStuck = false;
bool inbta7 = false;
bool CRYENGINE = false;
bool AntiBan = false;
bool WallShoot = false;
bool GodViewV2 = false;
float jumpedd = 0.0f;
bool Fly = false;
bool opp = false;
bool ghostt = false;
bool snoww = false;
bool rainn = false;
bool AutoShoot = false;
bool AutoShootBT = false;
bool Ipad = false;
bool Telep = false;
bool flashparachute = false;
bool flashparachute2 = false;
bool flashparachute3 = false;
bool JAATSDK = false;
bool spdw = false;
bool SpeedScope = false;
bool ShowDamaze = false;
bool PREDICTION1 = false;
bool FixStuck = false;
bool bighitV4 = false;
bool bighitV5 = false;
int HITSIZE = 0;
bool Enable360 = false;
bool EnableShootIntervalSlider = false;
float SliderShootIntervalValue = 0.0f;
bool ScopeView = false;
float ScopeValue = 0.0f;
bool EnableDanceRotation = false;
float DancerValue = 0.0f;
float SliderSpeed = 0.0f;
bool 物资 = false;
bool 美化 = false;
int FlashSpeedSpeed = 0;
bool oneshoot = false;
int oneshootValue = 0;
int ShootValue = 0;
bool MenDeal = false;              
static uint8_t _md_key = 0xA5;

static inline void RainbowV1(bool v) {
    MenDeal = (v ^ _md_key);
}

static inline bool VSXM() {   
    return (MenDeal ^ _md_key);
}
bool thongtin = false;
int ModEmote1 = 0;

bool isActivated = false;
char offsetInput[20] = "";
char byteInput[20] = "";

const char *语言items[] = { "...", "English"};

namespace Settings {
    static int Tab = 0;
}

namespace Colors {
    const ImVec4 Black = ImVec4(0.00f, 0.00f, 0.00f, 1.00f);
    const ImVec4 DarkGray = ImVec4(0.04f, 0.04f, 0.04f, 1.00f);
    const ImVec4 MediumGray = ImVec4(0.12f, 0.12f, 0.12f, 1.00f);
    const ImVec4 LightGray = ImVec4(0.85f, 0.85f, 0.85f, 1.00f);
    const ImVec4 White = ImVec4(1.00f, 1.00f, 1.00f, 1.00f);
    const ImVec4 Gray = ImVec4(0.50f, 0.50f, 0.50f, 1.00f);
    
    const ImVec4 Accent = ImVec4(1.00f, 1.00f, 1.00f, 1.00f);
    const ImVec4 AccentHover = ImVec4(0.80f, 0.80f, 0.80f, 1.00f);
    const ImVec4 AccentActive = ImVec4(1.00f, 1.00f, 1.00f, 1.00f);
    
    const ImVec4 Success = ImVec4(1.00f, 1.00f, 1.00f, 1.00f);
    const ImVec4 Warning = ImVec4(1.00f, 1.00f, 1.00f, 1.00f);
    const ImVec4 Error = ImVec4(1.00f, 1.00f, 1.00f, 1.00f);
    const ImVec4 Info = ImVec4(1.00f, 1.00f, 1.00f, 1.00f);
}

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

// ============= WATERMARK (AĞ-QARA DARK IOS YAZISI) =============
void DrawWatermark() {
    ImGuiIO& io = ImGui::GetIO();
    ImVec2 screenSize = io.DisplaySize;
    ImVec2 textPos = ImVec2((screenSize.x - ImGui::CalcTextSize("DARK IOS").x) * 0.5f, 15.0f);
    
    ImGuiWindowFlags flags = ImGuiWindowFlags_NoBackground | 
                             ImGuiWindowFlags_NoTitleBar | 
                             ImGuiWindowFlags_NoInputs | 
                             ImGuiWindowFlags_AlwaysAutoResize;
                             
    ImGui::SetNextWindowPos(textPos);
    ImGui::Begin("WatermarkOverlay", nullptr, flags);
    
    ImDrawList* drawList = ImGui::GetWindowDrawList();
    ImVec2 pos = ImGui::GetCursorScreenPos();
    
    drawList->AddText(ImVec2(pos.x + 1, pos.y + 1), IM_COL32(0, 0, 0, 255), "DARK IOS");
    drawList->AddText(pos, IM_COL32(255, 255, 255, 255), "DARK IOS");
    
    ImGui::End();
}

// ============= HELPER FUNCTIONS =============
void TextGreen(const char* text) { ImGui::TextColored(Colors::Success, "%s", text); }
void TextRed(const char* text) { ImGui::TextColored(Colors::Error, "%s", text); }
void TextYellow(const char* text) { ImGui::TextColored(Colors::Warning, "%s", text); }
void TextBlue(const char* text) { ImGui::TextColored(Colors::Info, "%s", text); }

void SectionHeader(const char* text) {
    ImGui::Spacing();
    ImGui::PushStyleColor(ImGuiCol_Text, Colors::White);
    ImGui::Text("%s", text);
    ImGui::PopStyleColor();
    ImGui::Separator();
    ImGui::Spacing();
}

void CheckboxGroup(const char* label1, bool* v1, const char* label2, bool* v2) {
    ImGui::Checkbox(label1, v1);
    ImGui::SameLine();
    ImGui::Checkbox(label2, v2);
}

void ApplyModernDarkTheme() {
    ImGuiStyle& style = ImGui::GetStyle();
    ImVec4* colors = style.Colors;
    colors[ImGuiCol_WindowBg] = Colors::Black;
    colors[ImGuiCol_ChildBg] = Colors::DarkGray;
    colors[ImGuiCol_PopupBg] = Colors::DarkGray;
    colors[ImGuiCol_Border] = ImVec4(1.00f, 1.00f, 1.00f, 0.90f);
    colors[ImGuiCol_Text] = Colors::White;
    colors[ImGuiCol_Button] = Colors::MediumGray;
    colors[ImGuiCol_ButtonHovered] = ImVec4(0.3f, 0.3f, 0.3f, 1.00f);
    colors[ImGuiCol_FrameBg] = ImVec4(0.08f, 0.08f, 0.08f, 1.00f);
    style.WindowRounding = 8.0f;
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

// ============= TAB DRAWING FUNCTIONS =============
void DrawMainTab() {
    ImGui::Text("Main Settings & Bypass");
}

void DrawESPTab() {
    SectionHeader("Player ESP");
    CheckboxGroup("Draw Line", &Line, "Draw Bone", &Skeleton);
    CheckboxGroup("Draw Box 4L", &Box, "Draw Box 3D", &Box2);
}

void DrawLootTab() {
    SectionHeader("Item ESP");
    ImGui::Checkbox("Rifle", &步枪);
    ImGui::Checkbox("Sniper", &狙击);
}

void DrawAimTab() {
    SectionHeader("Aim Settings");
    CheckboxGroup("AimBot", &AimBot, "Bullet Track 360", &Enable);
}

// Xəta verən funksiyalar əlavə olundu:
void DrawSkinTab() {
    SectionHeader("Skin Changer");
    ImGui::Checkbox("Enable Skin Changer", &ModSkinn);
}

void DrawMemoryTab() {
    SectionHeader("Memory Hacks");
    ImGui::Checkbox("No Recoil", &NoRecoil);
}

void DrawMovementTab() {
    SectionHeader("Movement Cheats");
    ImGui::Checkbox("Super Jump", &SuperJump);
}

void DrawSettingsTab() {
    SectionHeader("Settings & Security");
    ImGui::Checkbox("Yayinci Modu", &streamerSecureMode);
}

-(void)drawMenuWindow {
    ApplyModernDarkTheme();
    
    if (isKeyAuthenticated) {
        DrawWatermark();
    }
    
    ImGuiIO& io = ImGui::GetIO();
    
    // Key Giriş Pəncərəsi və 30 Saniyəlik Geri Sayım
    if (!isKeyAuthenticated) {
        static float timeLeft = 30.0f; 
        timeLeft -= io.DeltaTime;
        
        ImGui::SetNextWindowSize(ImVec2(400, 240), ImGuiCond_Always);
        ImGui::SetNextWindowPos(ImVec2(io.DisplaySize.x * 0.5f, io.DisplaySize.y * 0.5f), ImGuiCond_Always, ImVec2(0.5f, 0.5f));
        
        ImGui::Begin("DARK IOS - Login", &show, ImGuiWindowFlags_NoCollapse | ImGuiWindowFlags_NoResize);
        
        ImGui::Text("Enter License Key:");
        ImGui::InputText("##key", keyInputText, IM_ARRAYSIZE(keyInputText));
        
        ImGui::Spacing();
        ImGui::TextColored(ImVec4(1.0f, 0.5f, 0.0f, 1.0f), "Avtomatik cixis: %.0f saniye", timeLeft);
        
        if (timeLeft <= 0.0f) {
            exit(0); 
        }
        
        ImGui::Spacing();
        if (ImGui::Button("LOGIN", ImVec2(150, 40))) {
            if (verifyKeyWithServer(keyInputText)) {
                isKeyAuthenticated = true;
                self.moduleControl->menuStatus = true;
            } else {
                snprintf(statusMessage, sizeof(statusMessage), "Sehv Key veya Basqa Cihaza Bagli!");
            }
        }
        
        ImGui::Spacing();
        ImGui::TextColored(Colors::Error, "%s", statusMessage);
        ImGui::End();
        return;
    }

    if (ImGui::Begin("DARK IOS", &self.moduleControl->menuStatus, ImGuiWindowFlags_NoCollapse)) {
        ImGui::SameLine(ImGui::GetWindowWidth() - 200);
        ImGui::Text("v4.6");
        ImGui::Separator();
        
        static int selected_tab = 0;
        const float sidebar_width = 180.0f;
        
        ImGui::BeginChild("Sidebar", ImVec2(sidebar_width, 0), true);
        {
            ImGui::PushStyleColor(ImGuiCol_Text, Colors::White);
            ImGui::SetCursorPosX((sidebar_width - ImGui::CalcTextSize("MENU").x) * 0.5f);
            ImGui::Text("MENU");
            ImGui::PopStyleColor();
            ImGui::Separator();
            ImGui::Spacing();
            
            const char* tabs[] = {"Main", "ESP", "Loot", "Aim", "Skin", "Memory", "Movement", "Settings"};
            
            for (int i = 0; i < 8; i++) {
                if (selected_tab == i) {
                    ImGui::PushStyleColor(ImGuiCol_Button, Colors::White);
                    ImGui::PushStyleColor(ImGuiCol_Text, Colors::Black);
                } else {
                    ImGui::PushStyleColor(ImGuiCol_Button, Colors::Black);
                    ImGui::PushStyleColor(ImGuiCol_Text, Colors::White);
                }
                
                if (ImGui::Button(tabs[i], ImVec2(-1, 50))) {
                    selected_tab = i;
                }
                ImGui::PopStyleColor(2);
            }
        }
        ImGui::EndChild();
        
        ImGui::SameLine();
        
        ImGui::BeginChild("Content", ImVec2(0, 0), true);
        {
            switch(selected_tab) {
                case 0: DrawMainTab(); break;
                case 1: DrawESPTab(); break;
                case 2: DrawLootTab(); break;
                case 3: DrawAimTab(); break;
                case 4: DrawSkinTab(); break;
                case 5: DrawMemoryTab(); break;
                case 6: DrawMovementTab(); break;
                case 7: DrawSettingsTab(); break;
            }
        }
        ImGui::EndChild();
    }
    ImGui::End();
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

// ============= FLOATING BUTTON =============
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
