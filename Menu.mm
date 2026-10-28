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
static bool isLogin = true;
static bool 错误提示 = false;
static char text[64];
static bool show = true;

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

// ============= HELPER FUNCTIONS =============
void TextGreen(const char* text) {
    ImGui::TextColored(Colors::Success, "%s", text);
}

void TextRed(const char* text) {
    ImGui::TextColored(Colors::Error, "%s", text);
}

void TextYellow(const char* text) {
    ImGui::TextColored(Colors::Warning, "%s", text);
}

void TextBlue(const char* text) {
    ImGui::TextColored(Colors::Info, "%s", text);
}

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
    colors[ImGuiCol_MenuBarBg] = ImVec4(0.0f, 0.0f, 0.0f, 0.80f);
    
    colors[ImGuiCol_Border] = ImVec4(1.00f, 1.00f, 1.00f, 0.90f);
    colors[ImGuiCol_BorderShadow] = ImVec4(0.00f, 0.00f, 0.00f, 0.00f);
    colors[ImGuiCol_Separator] = Colors::White;
    colors[ImGuiCol_SeparatorHovered] = Colors::LightGray;
    colors[ImGuiCol_SeparatorActive] = Colors::White;
    
    colors[ImGuiCol_Text] = Colors::White;
    colors[ImGuiCol_TextDisabled] = Colors::Gray;
    colors[ImGuiCol_TextSelectedBg] = ImVec4(1.0f, 1.0f, 1.0f, 0.35f);
    
    colors[ImGuiCol_Button] = Colors::MediumGray;
    colors[ImGuiCol_ButtonHovered] = ImVec4(0.3f, 0.3f, 0.3f, 1.00f);
    colors[ImGuiCol_ButtonActive] = Colors::White;
    
    colors[ImGuiCol_FrameBg] = ImVec4(0.08f, 0.08f, 0.08f, 1.00f);
    colors[ImGuiCol_FrameBgHovered] = ImVec4(0.18f, 0.18f, 0.18f, 1.00f);
    colors[ImGuiCol_FrameBgActive] = ImVec4(0.30f, 0.30f, 0.30f, 1.00f);
    colors[ImGuiCol_CheckMark] = Colors::White;    
    
    colors[ImGuiCol_SliderGrab] = Colors::White;
    colors[ImGuiCol_SliderGrabActive] = Colors::LightGray;
    
    colors[ImGuiCol_Tab] = Colors::Black;
    colors[ImGuiCol_TabHovered] = Colors::MediumGray;
    colors[ImGuiCol_TabActive] = Colors::MediumGray;
    colors[ImGuiCol_TabUnfocused] = Colors::Black;
    colors[ImGuiCol_TabUnfocusedActive] = Colors::DarkGray;
    
    colors[ImGuiCol_Header] = Colors::MediumGray;
    colors[ImGuiCol_HeaderHovered] = ImVec4(0.2f, 0.2f, 0.2f, 1.00f);
    colors[ImGuiCol_HeaderActive] = Colors::White;
    
    colors[ImGuiCol_TitleBg] = Colors::Black;
    colors[ImGuiCol_TitleBgActive] = Colors::Black;
    colors[ImGuiCol_TitleBgCollapsed] = Colors::Black;
    
    colors[ImGuiCol_ScrollbarBg] = Colors::Black;
    colors[ImGuiCol_ScrollbarGrab] = Colors::Gray;
    colors[ImGuiCol_ScrollbarGrabHovered] = Colors::LightGray;
    colors[ImGuiCol_ScrollbarGrabActive] = Colors::White;
    
    colors[ImGuiCol_ResizeGrip] = Colors::Gray;
    colors[ImGuiCol_ResizeGripHovered] = Colors::LightGray;
    colors[ImGuiCol_ResizeGripActive] = Colors::White;
    
    colors[ImGuiCol_NavHighlight] = Colors::White;
    
    style.WindowRounding = 8.0f;
    style.ChildRounding = 6.0f;
    style.FrameRounding = 4.0f;
    style.PopupRounding = 6.0f;
    style.ScrollbarRounding = 6.0f;
    style.GrabRounding = 4.0f;
    style.TabRounding = 4.0f;
    
    style.WindowPadding = ImVec2(15, 15);
    style.FramePadding = ImVec2(12, 8);
    style.ItemSpacing = ImVec2(10, 8);
    style.ItemInnerSpacing = ImVec2(8, 6);
    style.IndentSpacing = 21.0f;
    
    style.WindowBorderSize = 1.0f;
    style.ChildBorderSize = 1.0f;
    style.PopupBorderSize = 1.0f;
    style.FrameBorderSize = 0.0f;
}

@implementation mi
OverlayView *overlayView;

- (instancetype)initWithFrame:(ModuleControl*)control {
    self.moduleControl = control;
    return [super init];
}

-(void)setOverlayView:(OverlayView*)ov{
    overlayView = ov;
    [self readIniConfig];
}

- (void)initializeImGui {
    ImGuiIO& io = ImGui::GetIO();
}

// ============= TAB DRAWING FUNCTIONS =============

void DrawMainTab() {
    static bool AntiBan = false;
    static float bypass_progress = 0.0f;
    static bool bypass_in_progress = false;
    static bool bypass_completed = false;
    static std::chrono::steady_clock::time_point bypass_start_time;
    static std::chrono::steady_clock::time_point last_message_time;
    static int current_message_index = 0;
    static float glow_effect = 0.0f;
    static bool glow_increasing = true;
    static float text_scale = 1.5f;
    static float window_alpha = 0.0f;
    static float success_glow = 0.0f;
    static bool success_glow_increasing = true;

    struct BypassMessage {
        const char* text;
        int color;
        float delay;
        bool bold;
    };

    static const BypassMessage messages[] = {
        {"[SYSTEM] Initializing Bypass Sequence...", 2, 0.2f, false},
        {"[SECURITY] Bypassing PUBG MOBILE Protection...", 2, 0.25f, false},
        {"[MODULE] Loading Anti-Cheat Modules...", 2, 0.3f, false},
        {"[安全系统] 正在初始化安全绕过协议...", 1, 0.25f, false},
        {"[检测引擎] 扫描游戏内存保护...", 1, 0.3f, false},
        {"[核心] 绕过完整性检查...", 1, 0.35f, true},
        {"[加密] 解密游戏安全协议...", 1, 0.25f, false},
        {"[注入] 注入安全补丁 v1.1.0...", 4, 0.4f, true},
        {"[网络] 建立安全连接通道...", 1, 0.3f, false},
        {"[验证] 验证绕过有效性...", 1, 0.35f, false},
        {"[虚拟化] 准备虚拟执行环境...", 1, 0.25f, false},
        {"[签名] 模拟官方签名验证...", 1, 0.4f, true},
        {"[内存] 应用内存补丁...", 1, 0.3f, false},
        {"[证书] 安全证书已伪造...", 1, 0.35f, true},
        {"[反调试] 反调试保护已禁用...", 1, 0.4f, false},
        {"[HOOK] 挂钩安全函数...", 3, 0.5f, true},
        {"[完成] 所有系统检查通过!", 0, 0.6f, true}
    };

    static const int total_messages = sizeof(messages) / sizeof(messages[0]);

    if (glow_increasing) {
        glow_effect += 0.01f;
        if (glow_effect >= 0.5f) glow_increasing = false;
    } else {
        glow_effect -= 0.01f;
        if (glow_effect <= 0.0f) glow_increasing = true;
    }

    if (success_glow_increasing) {
        success_glow += 0.005f;
        if (success_glow >= 0.3f) success_glow_increasing = false;
    } else {
        success_glow -= 0.005f;
        if (success_glow <= 0.0f) success_glow_increasing = true;
    }

    if ((bypass_in_progress || bypass_completed) && window_alpha < 1.0f) {
        window_alpha += 0.05f;
        if (window_alpha > 1.0f) window_alpha = 1.0f;
    } else if (!bypass_in_progress && !bypass_completed && window_alpha > 0.0f) {
        window_alpha -= 0.05f;
        if (window_alpha < 0.0f) window_alpha = 0.0f;
    }

    ImGui::PushStyleVar(ImGuiStyleVar_FramePadding, ImVec2(15, 15));
    ImGui::PushStyleVar(ImGuiStyleVar_FrameRounding, 5.0f);
    ImGui::PushStyleColor(ImGuiCol_Button, ImVec4(0.1f, 0.1f, 0.1f, 1.0f));
    ImGui::PushStyleColor(ImGuiCol_ButtonHovered, ImVec4(0.3f, 0.3f, 0.3f, 1.0f));
    ImGui::PushStyleColor(ImGuiCol_ButtonActive, ImVec4(0.5f, 0.5f, 0.5f, 1.0f));
    ImGui::PushStyleColor(ImGuiCol_Text, Colors::White);

    if (ImGui::Button("ACTIVATE BYPASS SYSTEM", ImVec2(-1, 60))) {
        if (!bypass_in_progress && !bypass_completed) {
            bypass_in_progress = true;
            bypass_completed = false;
            bypass_progress = 0.0f;
            bypass_start_time = std::chrono::steady_clock::now();
            last_message_time = bypass_start_time;
            current_message_index = 0;
            AntiBan = true;
        }
    }

    ImGui::PopStyleColor(4);
    ImGui::PopStyleVar(2);

    if (bypass_in_progress) {
        auto current_time = std::chrono::steady_clock::now();
        auto elapsed_time = std::chrono::duration_cast<std::chrono::milliseconds>(current_time - bypass_start_time).count();
        
        bypass_progress = static_cast<float>(elapsed_time) / 7000.0f;
        
        if (current_message_index < total_messages) {
            auto time_since_last_message = std::chrono::duration_cast<std::chrono::milliseconds>(current_time - last_message_time).count();
            if (time_since_last_message >= (messages[current_message_index].delay * 1000)) {
                current_message_index++;
                last_message_time = current_time;
            }
        }
        
        if (elapsed_time >= 7000) {
            bypass_in_progress = false;
            bypass_completed = true;
            bypass_progress = 1.0f;
        }
        
        ImGui::PushStyleVar(ImGuiStyleVar_Alpha, window_alpha);
        ImGui::PushStyleVar(ImGuiStyleVar_WindowPadding, ImVec2(15, 15));
        ImGui::PushStyleVar(ImGuiStyleVar_WindowRounding, 5.0f);
        ImGui::PushStyleColor(ImGuiCol_ChildBg, ImVec4(0.0f, 0.0f, 0.0f, 0.95f));
        ImGui::PushStyleColor(ImGuiCol_Border, ImVec4(1.0f, 1.0f, 1.0f, 1.0f));
        ImGui::PushStyleColor(ImGuiCol_BorderShadow, ImVec4(1.0f, 1.0f, 1.0f, glow_effect));
        
        ImGui::BeginChild("BypassConsole", ImVec2(0, ImGui::GetTextLineHeight() * 16 * text_scale), true, ImGuiWindowFlags_NoScrollbar);
        
        ImGui::TextColored(Colors::White, "PUBG MOBILE SECURITY BYPASS SYSTEM v1.1.0");
        ImGui::Separator();
        
        ImGui::BeginChild("ConsoleContent", ImVec2(0, ImGui::GetTextLineHeight() * 12 * text_scale), false, ImGuiWindowFlags_HorizontalScrollbar);
        
        for (int i = 0; i < current_message_index && i < total_messages; i++) {
            ImVec4 color = Colors::White;
            ImGui::TextColored(color, "[%02d:%02d:%03d] %s", 
                (int)(elapsed_time/60000), 
                (int)(elapsed_time/1000)%60, 
                (int)elapsed_time%1000, 
                messages[i].text);
        }
        
        if (ImGui::GetScrollY() >= ImGui::GetScrollMaxY()) {
            ImGui::SetScrollHereY(1.0f);
        }
        
        ImGui::EndChild();
        ImGui::Separator();
        
        ImGui::PushStyleColor(ImGuiCol_FrameBg, ImVec4(0.05f, 0.05f, 0.05f, 1.0f));
        ImGui::PushStyleColor(ImGuiCol_PlotHistogram, ImVec4(1.0f, 1.0f, 1.0f, 1.0f));
        ImGui::PushStyleVar(ImGuiStyleVar_FrameRounding, 3.0f);
        ImGui::ProgressBar(bypass_progress, ImVec2(-1, 30), "");
        ImGui::PopStyleVar();
        ImGui::PopStyleColor(2);
        
        ImGui::TextColored(Colors::White, "Status: %s", bypass_in_progress ? "IN PROGRESS" : "COMPLETED");
        ImGui::TextColored(Colors::White, "Progress: %.1f%%", bypass_progress * 100);
        
        ImGui::EndChild();
        ImGui::PopStyleColor(3);
        ImGui::PopStyleVar(3);
    }

    if (bypass_completed) {
        ImGui::PushStyleVar(ImGuiStyleVar_Alpha, window_alpha);
        ImGui::PushStyleVar(ImGuiStyleVar_WindowPadding, ImVec2(30, 30));
        ImGui::PushStyleVar(ImGuiStyleVar_WindowRounding, 10.0f);
        ImGui::PushStyleColor(ImGuiCol_ChildBg, ImVec4(0.0f, 0.0f, 0.0f, 0.95f));
        ImGui::PushStyleColor(ImGuiCol_Border, ImVec4(1.0f, 1.0f, 1.0f, 1.0f));
        ImGui::PushStyleColor(ImGuiCol_BorderShadow, ImVec4(1.0f, 1.0f, 1.0f, success_glow));
        ImGui::PushStyleColor(ImGuiCol_Text, Colors::White);
        
        ImGui::BeginChild("SuccessWindow", ImVec2(0, 200), true);
        
        ImGui::SetCursorPosX((ImGui::GetWindowWidth() - ImGui::CalcTextSize("BYPASS ACTIVATED SUCCESSFULLY!").x) * 0.5f);
        ImGui::TextColored(Colors::White, "BYPASS ACTIVATED SUCCESSFULLY!");
        
        ImGui::Dummy(ImVec2(0, 20));
        
        ImGui::SetCursorPosX((ImGui::GetWindowWidth() - 200) * 0.5f);
        ImGui::PushStyleVar(ImGuiStyleVar_FramePadding, ImVec2(20, 15));
        ImGui::PushStyleColor(ImGuiCol_Button, ImVec4(0.1f, 0.1f, 0.1f, 1.0f));
        ImGui::PushStyleColor(ImGuiCol_ButtonHovered, ImVec4(0.3f, 0.3f, 0.3f, 1.0f));
        ImGui::PushStyleColor(ImGuiCol_ButtonActive, ImVec4(0.5f, 0.5f, 0.5f, 1.0f));
        
        if (ImGui::Button("DONE", ImVec2(200, 60))) {
            bypass_completed = false;
            AntiBan = true;
        }
        
        ImGui::PopStyleColor(3);
        ImGui::PopStyleVar();
        
        ImGui::EndChild();
        ImGui::PopStyleColor(4);
        ImGui::PopStyleVar(3);
    }

    ImGui::Spacing();
    ImGui::Separator();
    ImGui::Spacing();

    ImGui::Text(ENCRYPT("pwwzww & darkhxte :)"));
    ImGui::Spacing();
    ImGui::Text("%s", make_string("CHANNEL @QTYG1").c_str());
    ImGui::Spacing();
    ImGui::Text("%s", make_string("OWNER @ZİRVEDEYİM0").c_str());
    ImGui::Spacing();

    ImGui::PushStyleColor(ImGuiCol_Button, Colors::Black);
    ImGui::PushStyleColor(ImGuiCol_ButtonHovered, ImVec4(0.2f, 0.2f, 0.2f, 1.0f));
    ImGui::PushStyleColor(ImGuiCol_ButtonActive, ImVec4(0.4f, 0.4f, 0.4f, 1.0f));
    ImGui::PushStyleColor(ImGuiCol_Text, Colors::White);

    ImGui::Spacing();
    std::string t1 = make_string("");
    std::wstring t2 = j2(m8(t1));
    std::string dCdTax(t2.begin(), t2.end());

    TextRed(dCdTax.c_str());
}

void DrawESPTab() {
    SectionHeader("Player ESP");
    ImGui::Columns(2, nullptr, false);
    CheckboxGroup("Draw Line", &Line, "Draw Bone", &Skeleton);
    CheckboxGroup("Draw Info", &信息, "Draw Weapon", &Weapon);
    CheckboxGroup("Draw Box 4L", &Box, "Draw Box 3D", &Box2);
    ImGui::Checkbox("Draw Distance", &distancee);
    ImGui::NextColumn();
    CheckboxGroup("Draw Health", &血条B, "Draw Alert", &Alert);
    CheckboxGroup("Draw Vehicle", &IsVehcle, "Draw Loot Box", &IsLootBox);
    ImGui::Checkbox("Grenade Warning", &GRWAR);
    ImGui::Checkbox("Skip AI", &ESPNotBot);
    ImGui::Columns(1);
}

void DrawLootTab() {
    SectionHeader("Item ESP");
    ImGui::Columns(3, nullptr, false);
    ImGui::Checkbox("Rifle", &步枪);
    ImGui::Checkbox("Sniper", &狙击);
    ImGui::Checkbox("SMG", &物资冲锋);
    ImGui::NextColumn();
    ImGui::Checkbox("Scope", &物资倍镜);
    ImGui::Checkbox("Armor", &物资防具);
    ImGui::Checkbox("Accessories", &物资配件);
    ImGui::NextColumn();
    ImGui::Checkbox("Car Info", &IsCarFuel);
    ImGui::Checkbox("Box Vehicle", &IsboxVechle);
    ImGui::Checkbox("Airdrop", &地铁物资);
    ImGui::Columns(1);
}

void DrawAimTab() {
    SectionHeader("Aim Settings");
    ImGui::Columns(2, nullptr, false);
    CheckboxGroup("AimBot", &AimBot, "Bullet Track 360", &Enable);
    TextRed("Note: Bullet Track 360 works only in TDM (close to Enemy!)");
    CheckboxGroup("Bullet Track V2", &Enablev2, "Auto Fire", &AutoFire);
    ImGui::Columns(1);
    
    ImGui::Spacing();
    ImGui::Separator();
    SectionHeader("Cover Damage");
    TextRed("Note: Use V3 for best results with 180° BT");    
    ImGui::Columns(3, nullptr, false);
    ImGui::PushStyleColor(ImGuiCol_Text, Colors::White);
    ImGui::Checkbox("FAKE DAMAGE V1", &FAKEDAMAGE);
    ImGui::NextColumn();
    ImGui::Checkbox("FAKE DAMAGE V2", &FAKEDAMAGEV2);
    ImGui::NextColumn();
    ImGui::Checkbox("FAKE DAMAGE V3", &FAKEDAMAGEV3);
    ImGui::PopStyleColor();
    ImGui::Columns(1);
    
    ImGui::Spacing();
    ImGui::Separator();
    SectionHeader("Auto Stand");
    ImGui::PushStyleColor(ImGuiCol_Text, Colors::White);
    ImGui::Checkbox("Auto Stand V1", &AutoStandd);
    ImGui::PopStyleColor();
    
    ImGui::Spacing();
    ImGui::Separator();
    SectionHeader("Filters");
    CheckboxGroup("Ignore Knocked", &IgnoreKnocked, "Ignore AI", &IgnoreBot);
    CheckboxGroup("Vis Check", &VisCheck, "Vis Check BT", &VisCheckBT);
    
    ImGui::Spacing();
    ImGui::Separator();
    SectionHeader("Aim Target");
    ImGui::RadioButton("Head", &AimL, 1); ImGui::SameLine();
    ImGui::RadioButton("Neck", &AimL, 3); ImGui::SameLine();
    ImGui::RadioButton("Body", &AimL, 2);
    
    ImGui::Spacing();
    ImGui::Separator();
    SectionHeader("Aim Mode");
    ImGui::RadioButton("Fire", &AimF, 1); ImGui::SameLine();
    ImGui::RadioButton("Camera", &AimF, 2); ImGui::SameLine();
    ImGui::RadioButton("Fire & Camera", &AimF, 3);
    
    ImGui::Spacing();
    ImGui::Separator();
    SectionHeader("Advanced Settings");
    ImGui::SliderInt("Aim FOV", &Cross, 1, 1000);
    ImGui::SliderFloat("Distance", &g_disstance, 1.0f, 1000.0f);
    ImGui::SliderFloat("Aim Speed", &AimSpeed, 1.0f, 10.0f);
}

void DrawSkinTab() {
    SectionHeader("Skin Changer");
    ImGui::Checkbox("Enable Skin Changer", &ModSkinn);
    
    if (ModSkinn) {
        preferences.Outfit = true;
        preferences.Face = true;
        preferences.Bagg = true;
        preferences.Helmett = true;
        preferences.Emote = true;
        preferences.Parachute = true;
        preferences.Fac = true;
        preferences.Hieuungbay = true;
        
        preferences.M416 = true;
        preferences.AKM = true;
        preferences.SCARL = true;
        preferences.M762 = true;
        preferences.GROZA = true;
        preferences.FAMAS = true;
        preferences.AUG = true;
        preferences.QBZ = true;
        preferences.Honey = true;
        preferences.M16 = true;
        preferences.ACE32 = true;
        preferences.KAR98 = true;
        preferences.M24 = true;
        preferences.AWM = true;
        preferences.AMR = true;
        preferences.MK14 = true;
        preferences.MINI14 = true;
        preferences.DP28 = true;
        preferences.MG3 = true;
        preferences.M249 = true;
        preferences.UZI = true;
        preferences.UMP = true;
        preferences.TOMMY = true;
        preferences.P90 = true;
        preferences.VECTOR = true;
        preferences.BIZON = true;
        preferences.S1897 = true;
        preferences.DBS = true;
        preferences.S12K = true;
        preferences.Machete = true;
        preferences.PAN = true;
        
        preferences.Dacia = true;
        preferences.UAZ = true;
        preferences.CoupeRB = true;
        preferences.Moto = true;
        preferences.BigFoot = true;
        preferences.Mirado = true;
        preferences.Buggy = true;
        preferences.RZR = true;
        preferences.MiniBus = true;
        preferences.Boat = true;
    }
    
    CheckboxGroup("Kill Message", &KillMessage, "Death Box", &DeadBox);
    ImGui::Spacing();
    ImGui::Separator();
    SectionHeader("Quick Presets");
    ImGui::Columns(3, nullptr, false);
    
    if (ImGui::Button("Preset 1", ImVec2(-1, 50))) {
        preferences.Config.Skin.XSuits = 8;
        preferences.Config.Skin.M416 = 10;
        preferences.Config.Skin.AKM = 10;
        preferences.bag = 3;
        preferences.helmet = 1;
    }
    ImGui::NextColumn();
    if (ImGui::Button("Preset 2", ImVec2(-1, 50))) {
        preferences.Config.Skin.XSuits = 35;
        preferences.Config.Skin.M416 = 9;
        preferences.Config.Skin.AKM = 11;
        preferences.bag = 13;
        preferences.helmet = 10;
    }
    ImGui::NextColumn();
    if (ImGui::Button("Preset 3", ImVec2(-1, 50))) {
        preferences.Config.Skin.XSuits = 15;
        preferences.Config.Skin.M416 = 8;
        preferences.Config.Skin.AKM = 10;
        preferences.bag = 12;
        preferences.helmet = 1;
    }
    ImGui::Columns(1);
}

void DrawMemoryTab() {
    SectionHeader("Memory Hacks");
    if (ImGui::BeginTabBar("##MemoryTabs")) {
        if (ImGui::BeginTabItem("Weapon")) {
            ImGui::Spacing();
            if (ImGui::CollapsingHeader("Basic Weapon Mods")) {
                ImGui::Columns(2, nullptr, false);
                CheckboxGroup("AR Sniper", &SniAR, "Full Gun", &Silenttest);
                CheckboxGroup("Gun God", &welapongod, "Gun UP", &good);
                CheckboxGroup("Gun UP V2", &SilentGodview, "No Recoil", &NoRecoil);
                CheckboxGroup("Fast Weapon", &FastWeapon, "Weapon Size", &WeaponSize);
                ImGui::Columns(1);
            }
            ImGui::EndTabItem();
        }
        if (ImGui::BeginTabItem("Player")) {
            ImGui::Spacing();
            if (ImGui::CollapsingHeader("Movement Mods")) {
                ImGui::Columns(2, nullptr, false);
                ImGui::Checkbox("Boost Jump", &SuperJump);
                ImGui::NextColumn();
                CheckboxGroup("Bunny Jump", &flly, "Fly Player", &HighJump);
                CheckboxGroup("Auto Jump", &AUOTJUMPAN, "Speed Knock", &Speedknock);
                ImGui::Columns(1);
            }
            ImGui::EndTabItem();
        }
        ImGui::EndTabBar();
    }
}

void DrawMovementTab() {
    TextRed("Movement Cheats");
    ImGui::SameLine();
    ImGui::Text("| You Should Turn ON Lock Status First");
    ImGui::Separator();
    
    if (ImGui::Button("Lock Status ON", ImVec2(-1, 60))) {
        LockStatus = !LockStatus;
    }
}

void DrawSettingsTab() {
    TextRed("Cheat");
    ImGui::SameLine();
    ImGui::Text("Settings");
}

-(void)drawMenuWindow {
    ApplyModernDarkTheme();
    
    ImGuiIO& io = ImGui::GetIO();
    ImGui::SetNextWindowSize(ImVec2(1100, 750), ImGuiCond_FirstUseEver);
    ImGui::SetNextWindowPos(ImVec2(io.DisplaySize.x * 0.5f, io.DisplaySize.y * 0.5f), 0, ImVec2(0.5f, 0.5f));

    std::string w1 = make_string("NEXT PUBGM 4.6.0");
    std::wstring w2 = j2(m8(w1));
    std::string wnDtu(w2.begin(), w2.end());

    if (ImGui::Begin(wnDtu.c_str(), &self.moduleControl->menuStatus, ImGuiWindowFlags_NoCollapse)) {
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

-(void)readIniConfig {
    switch(self.moduleControl->fps) {
        case 0: overlayView.preferredFramesPerSecond = 60; break;
        case 1: overlayView.preferredFramesPerSecond = 90; break;
        case 2: overlayView.preferredFramesPerSecond = 120; break;
        default: overlayView.preferredFramesPerSecond = 60; break;
    }
}

-(void)saveIniConfig {}
- (void)dealloc {}

@end

// ============= FLOATING BLACK TRANSPARENT CIRCLE BUTTON (NO BORDER) =============
@interface FloatingMenuButton : UIButton
@property (nonatomic, assign) void* moduleControl;
@end

@implementation FloatingMenuButton {
    CGPoint touchLocation;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.5]; // Zil qara şəffaf
        self.layer.cornerRadius = frame.size.width / 2.0; // Yumru (dairəvi)
        self.clipsToBounds = YES;
        // Ağ kənar cizgisi (border) tamamilə silindi
        
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

// ============= LINKER FIX & OVERLAY INITIALIZER =============
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
            
            // Qara şəffaf yumru düymə (kənarsız)
            static FloatingMenuButton *floatBtn = nil;
            if (!floatBtn) {
                floatBtn = [[FloatingMenuButton alloc] initWithFrame:CGRectMake(100, 100, 50, 50)];
                floatBtn.moduleControl = modControl;
                
                [window addSubview:floatBtn];
                [window bringSubviewToFront:floatBtn];
            }
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
