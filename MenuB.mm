#import <Metal/Metal.h>
#import <MetalKit/MetalKit.h>
#import <Foundation/Foundation.h>
#import "MenuB.h"
#import "Project/ImGui/imgui.h"
#import "Project/ImGui/imgui_impl_metal.h"
#import "Project/Extra/ConfigMenu.h"
#include "Project/Extra/Obfuscate.h"
#import "ESP.hpp"
#import "Project/HideHack/HeeeNoScreenShotView.h"
#import "Project/Extra/fa-solid-900.ttf.h"
#import "Project/Extra/Font.h"
#include <dlfcn.h>
#include <arpa/inet.h>
#include <netdb.h>
#include <vector>
#include <string>
#include <unordered_set>
#include <mutex>
#include <thread>
#include <atomic>
#include <errno.h>

#define kWidth  [UIScreen mainScreen].bounds.size.width
#define kHeight [UIScreen mainScreen].bounds.size.height
#define kScale [UIScreen mainScreen].scale

@interface ImGuiDrawView () <MTKViewDelegate>
@property (nonatomic, strong) id <MTLDevice> device;
@property (nonatomic, strong) id <MTLCommandQueue> commandQueue;
@property (nonatomic, assign) BOOL canRunAgain;
@end

@implementation ImGuiDrawView

struct JsonPreferences {
int xsuit = 0;
int skinm4 = 0;
int skinakm = 0;
int para = 0;
int bag = 0;
int helmet = 0;
bool CoupeRB = false;
bool Dacia = false;
bool UAZ = false;
bool MiniBus = false;
bool BigFoot = false;
bool Boat = false;
bool Mirado = false;
bool Buggy = false;
bool RZR = false;
bool OMirado = false;
bool Moto = false;
bool Emote = false;
bool Helmett = false;
bool Bagg = false;
bool Fac= false;
bool Face= false;
bool Outfit = false;
bool Parachute = false;
bool Gloves = false;
bool Hieuungbay = false;
bool Comrade = false;
bool M416 = false;
bool AKM = false;
bool SCARL = false;
bool M762 = false;
bool MG3 = false;
bool Honey = false;
bool S12K = false;
bool DBS = false;
bool S1897 = false;
bool AWM = false;
bool Machete = false;
bool AMR = false;
bool MK14 = false;
bool MINI14 =false;
bool KAR98 = false;
bool M24 = false;
bool M16 = false;
bool M249 = false;
bool DP28 = false;
bool GROZA = false;
bool FAMAS = false;
bool AUG = false;
bool QBZ = false;
bool PAN = false;
bool UZI = false;
bool UMP = false;
bool TOMMY = false;
bool P90 = false;
bool BIZON = false;
bool ACE32 = false;
bool VECTOR = false;

    struct sConfig {
        struct sModSkin {
  bool Enable = 1;
  bool HitEffect = 0;
  bool KillMessage = 0;
  bool DeadBox = 0;
  int XSuits = 0;
  int AKM = 1;
  int M16A4 = 1;
  int Scar = 1;
  int M416 = 1;
  int Groza = 1;
  int Famas =1;
  int AUG = 1;
  int QBZ = 1;
  int M762 = 1;
  int MG3 = 1;
  int Honey = 1;
  int S12K = 1;
  int DBS = 1;
  int S1897 = 1;
  int ACE32 = 1;
  int Parachute = 1;
  int Gloves = 1;
  int Fac = 1;
  int Hieuungbay = 1;
  int Comrade = 1;
  int UZI = 1;
  int UMP = 1;
  int Vector = 1;
  int Thompson = 1;
  int P90 = 1;
  int Bizon = 1;
  int K98 = 1;
  int M24 = 1;
  int AWM = 1;
  int AMR = 1;
  int Machete = 1;
  int MK14 = 1;
  int MINI14 =1;
  int DP28 = 1;
  int M249 = 1;
  int Pan = 1;
  int Moto = 1;
  int CoupeRP = 1;
  int UAZ = 1;
  int Dacia = 1;
  int Bigfoot = 1;
  int Mirado = 1;
  int OMirado = 1;
  int Buggy = 1;
  int RZR = 1;
  int MiniBus = 1;
  int Boat = 1;
};
sModSkin Skin{false};
    };
    sConfig Config{false};
} extern preferences;

extern bool initkillmsgopen;
extern bool ModSkinn;
extern bool DeadBox;
extern bool hidename;
extern bool TeleportEnemy;
extern bool SilentGodView;
extern bool AutoFlashUPP;
extern bool FlashUPP;
extern float flashFuckk1;
extern bool FastScope;
extern bool IsAimlock;
extern bool IsFastSwitch;
extern bool IsBunnyJUMP;
extern bool FastReload;
extern bool IsOneShotKill;
extern bool goodview;
extern bool AttackTeammates;
extern bool GiveUp;
extern bool IsSpinCharacter;
extern bool IsSpinCharacters;
extern bool IsScaleWeapon;
extern bool IsScaleCharacter;
extern bool Unlock120FPS;
extern float spinspeed;
extern float spinspeeds;
extern bool tam7mau;
extern bool xoaytam;
extern bool autotap;
extern bool Snow;
extern bool Rain;
extern bool showdame;
extern bool IsHitXPL;
extern float WeaponScaleChanger;
extern float X1;
extern bool IsNorecoil;
extern bool IsNorecoil2;
extern bool IsNocamerashake;
extern bool tamnho;
extern bool NoGravity;
bool AllCarHacks = false;
extern bool CrazyCar;
extern bool WallHackCar;
extern bool infinitycar;
extern bool carspring;
extern bool CarSpin;
extern float SpinCar360;
extern bool ongngamzoom;
extern float SetZoom;
extern bool skinlobby;
extern bool BagGun;

namespace Settings
{
    static int Tab = 0;
}
ImFont *FontMenu;
HeeeNoScreenShotView *hideesp;
INI* config;
extern int èªçæ¨¡å¼,èªçåå,é·è¾¾å¤§å°,é·è¾¾X,é·è¾¾Y,èªçèå´,é¢è­¦èå´,ååæ¨¡å¼,åååºå®,IsPart,äººç©ç¾å,æªæ¢°ç¾å,IsMode,IsStyle;
extern float IsRadius, radiusalert, IsTPPValue, IsFPPValue, Health;
extern float IsRecoil;
extern float åæªéç,ç¸æºè§é,IsSpeed,å½ä¸­ç,IsDistanceAimbot,ç©èµè·ç¦»,IsDistancePlayer,IsThicknessBone,IsThicknessLine;
extern bool å±è½äººæº;
bool IsMatchInfomation = NO;
bool HideHack = YES;
bool drawOutline = YES;
bool IsDeveloperMode = NO;
bool IsView = NO;
bool IsIgnoreKnock = NO;
bool IsNumberPlayer = NO;
bool IsBox=NO;
bool IsFov=NO;
bool IsLine = NO;
bool IsLineAimbot = NO;
bool IsName = NO;
bool IsNation = NO;
bool IsUID = NO;
extern bool boquabots;
bool IsDistance = NO;
bool IsTeam = NO;
bool IsHealth = NO;
bool IsAlert360 = NO;
bool IsBone = NO;
bool IsWeapon = NO;
bool é·è¾¾å¼å³ = NO;
bool è¢«çå¼å³ = NO;
bool èææ¨¡å¼ = NO;
bool IsAimbot = NO;
bool IsBulletTrack = NO;
bool IsBulletTrack1=NO;
bool éé»å¼å³ = YES;
bool åå°å¼å³ = NO;
bool IsAR = NO;
bool IsSR = NO;
bool IsSMG = NO;
bool IsShotGun = NO;
bool IsBom = NO;
bool IsBullet = NO;
bool IsArmor = NO;
bool IsRecovery = NO;
bool IsVehicle = NO;
bool IsScope = NO;
bool ç¾åå¼å³ = NO;
bool æ åå¼å³ = NO;
bool é²æå¼å³ = NO;
bool ç¬å»å¼å³ = NO;
bool èç¹å¼å³ = NO;
bool IsWarningBom=NO;
bool IsDeadBox=NO;
bool IsAirDrop=NO;
bool MenDeal = false; // Menyunu əvvəlcə bağlayırıq ki, lisenziya təsdiqlənəndən sonra açısın
int Tab = 0;
int IsCheckAimbot = 0;
extern int AlivePlayerNum, AliveTeamNum, PlayerNum, minutes, seconds, Kill;
extern long NetDriver;
float IsFPSDraw = 30.0f;
extern bool AutoStand;
extern bool FAKEDAMAGE;
extern float muzzleOffsetZ;

extern ImVec4 ColorBoneVisible, ColorBoneInvisible, ColorLineVisible, ColorLineInvisible, ColorBoxVisible, ColorBoxInvisible, outlineColor;

static bool showBanner = false;
static std::string bannerMessage = "";
static double bannerStartTime = 0.0;
int IsEnglish = 0;

void ShowBannerNotification(const std::string& message) {
    showBanner = true;
    bannerMessage = message;
    bannerStartTime = ImGui::GetTime();
}

void RenderBannerNotification() {
    if (!showBanner) return;
    float currentTime = ImGui::GetTime();
    float elapsedTime = currentTime - bannerStartTime;
    const float displayDuration = 2.0f;
    const float animationDuration = 0.5f;

    if (elapsedTime > displayDuration + animationDuration) {
        showBanner = false;
        return;
    }

    float alpha = 1.0f;
    if (elapsedTime < animationDuration)
        alpha = elapsedTime / animationDuration;
    else if (elapsedTime > displayDuration)
        alpha = 1.0f - (elapsedTime - displayDuration) / animationDuration;

    ImVec4 bgColor = ImVec4(1, 1, 1, alpha);
    ImVec4 textColor = ImVec4(0, 0, 0, alpha);
    ImVec4 borderColor = ImVec4(0, 0, 0, alpha);

    ImVec2 windowSize = ImGui::GetIO().DisplaySize;
    ImVec2 textSize = ImGui::CalcTextSize(bannerMessage.c_str());
    ImVec2 bannerPadding = ImVec2(20.0f, 10.0f);
    ImVec2 bannerSize = ImVec2(textSize.x + 2 * bannerPadding.x, textSize.y + 2 * bannerPadding.y);
    ImVec2 bannerPos = ImVec2((windowSize.x - bannerSize.x) / 2.0f, 20);

    ImGui::SetNextWindowPos(bannerPos, ImGuiCond_Always);
    ImGui::SetNextWindowBgAlpha(alpha);

    ImGui::PushStyleColor(ImGuiCol_WindowBg, bgColor);
    ImGui::PushStyleColor(ImGuiCol_Text, textColor);
    ImGui::PushStyleColor(ImGuiCol_Border, borderColor);
    ImGui::PushStyleVar(ImGuiStyleVar_WindowRounding, 8.0f);
    ImGui::PushStyleVar(ImGuiStyleVar_WindowPadding, bannerPadding);

    ImGui::Begin("##BannerNotification", nullptr,
        ImGuiWindowFlags_NoDecoration |
        ImGuiWindowFlags_NoInputs |
        ImGuiWindowFlags_AlwaysAutoResize);

    ImGui::Text("%s", bannerMessage.c_str());

    ImGui::End();
    ImGui::PopStyleVar(2);
    ImGui::PopStyleColor(3);
}

- (instancetype)initWithNibName:(nullable NSString *)nibNameOrNil bundle:(nullable NSBundle *)nibBundleOrNil
{
    hideesp=[[HeeeNoScreenShotView alloc] initWithFrame:[UIScreen mainScreen].bounds];
    [[UIApplication sharedApplication].windows[0].rootViewController.view addSubview:hideesp];
    hideesp.userInteractionEnabled=false;  

    NSString *documentsDirectory = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *filePath = [documentsDirectory stringByAppendingPathComponent:@"Config.ini"];
    if(![fileManager fileExistsAtPath:filePath]){
        [fileManager createFileAtPath:filePath contents:[NSData data] attributes:nil];
    }
    config = ini_load((char*)filePath.UTF8String);

    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    _device = MTLCreateSystemDefaultDevice();
    _commandQueue = [_device newCommandQueue];

    if (!self.device) abort();

    IMGUI_CHECKVERSION();
    ImGui::CreateContext();
    ImGuiIO& io = ImGui::GetIO(); (void)io;

    ImGuiStyle& style = ImGui::GetStyle();
    style.Colors[ImGuiCol_WindowBg] = ImVec4(0.06f, 0.06f, 0.06f, 0.95f);
    style.Colors[ImGuiCol_ChildBg] = ImVec4(0.08f, 0.08f, 0.08f, 1.0f);
    style.Colors[ImGuiCol_Border] = ImVec4(0.85f, 0.85f, 0.85f, 0.8f);
    style.Colors[ImGuiCol_FrameBg] = ImVec4(0.15f, 0.15f, 0.15f, 1.0f);
    style.Colors[ImGuiCol_FrameBgHovered] = ImVec4(0.25f, 0.25f, 0.25f, 1.0f);
    style.Colors[ImGuiCol_FrameBgActive] = ImVec4(0.35f, 0.35f, 0.35f, 1.0f);
    style.Colors[ImGuiCol_Button] = ImVec4(0.12f, 0.12f, 0.12f, 1.0f);
    style.Colors[ImGuiCol_ButtonHovered] = ImVec4(0.25f, 0.25f, 0.25f, 1.0f);
    style.Colors[ImGuiCol_ButtonActive] = ImVec4(1.0f, 1.0f, 1.0f, 1.0f);
    style.Colors[ImGuiCol_CheckMark] = ImVec4(1.0f, 1.0f, 1.0f, 1.0f);
    style.Colors[ImGuiCol_SliderGrab] = ImVec4(1.0f, 1.0f, 1.0f, 1.0f);
    style.Colors[ImGuiCol_SliderGrabActive] = ImVec4(0.8f, 0.8f, 0.8f, 1.0f);
    style.Colors[ImGuiCol_Header] = ImVec4(0.2f, 0.2f, 0.2f, 1.0f);
    style.Colors[ImGuiCol_HeaderHovered] = ImVec4(0.3f, 0.3f, 0.3f, 1.0f);
    style.Colors[ImGuiCol_HeaderActive] = ImVec4(1.0f, 1.0f, 1.0f, 1.0f);
    style.Colors[ImGuiCol_Text] = ImVec4(1.0f, 1.0f, 1.0f, 1.0f);

    static const ImWchar ranges[] = { 0x0020, static_cast<ImWchar>(0x10FFFF), 0 };
    FontMenu = io.Fonts->AddFontFromMemoryTTF((void *) arial_data, arial_size , 22.5f, NULL, ranges);
    
    static const ImWchar icons_ranges[] = { 0xf000, 0xffff, 0 }; 
    ImFontConfig icons_config;      
    icons_config.MergeMode = true;

    io.Fonts->AddFontFromMemoryTTF(fa_solid_900_ttf, fa_solid_900_ttf_len, 17.5f, &icons_config, icons_ranges);
    ImGui_ImplMetal_Init(_device);

    return self;
}

- (MTKView *)mtkView { return (MTKView *)self.view; }

- (void)loadView
{
    CGFloat w = [UIApplication sharedApplication].windows[0].rootViewController.view.frame.size.width;
    CGFloat h = [UIApplication sharedApplication].windows[0].rootViewController.view.frame.size.height;
    self.view = [[MTKView alloc] initWithFrame:CGRectMake(0, 0, w, h)];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.mtkView.device = self.device;
    self.mtkView.delegate = self;
    self.mtkView.clearColor = MTLClearColorMake(0, 0, 0, 0);
    self.mtkView.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0];
    self.mtkView.clipsToBounds = YES;
    self.canRunAgain = YES;
}

- (void)updateIOWithTouchEvent:(UIEvent *)event
{
    UITouch *anyTouch = event.allTouches.anyObject;
    CGPoint touchLocation = [anyTouch locationInView:self.view];
    ImGuiIO &io = ImGui::GetIO();
    io.MousePos = ImVec2(touchLocation.x, touchLocation.y);

    BOOL hasActiveTouch = NO;
    for (UITouch *touch in event.allTouches)
    {
        if (touch.phase != UITouchPhaseEnded && touch.phase != UITouchPhaseCancelled)
        {
            hasActiveTouch = YES;
            break;
        }
    }
    io.MouseDown[0] = hasActiveTouch;
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event { [self updateIOWithTouchEvent:event]; }
- (void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event { [self updateIOWithTouchEvent:event]; }
- (void)touchesCancelled:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event { [self updateIOWithTouchEvent:event]; }
- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event { [self updateIOWithTouchEvent:event]; }

- (void)drawInMTKView:(MTKView*)view
{   
    switch(IsCheckAimbot){
        case 0: IsAimbot = NO; IsBulletTrack = NO; IsBulletTrack1 = NO; break;
        case 1: IsAimbot = YES; IsBulletTrack = NO; IsBulletTrack1 = NO; break;
        case 2: IsAimbot = NO; IsBulletTrack = YES; IsBulletTrack1 = NO; break;
        case 3: IsAimbot = NO; IsBulletTrack = NO; IsBulletTrack1 = YES; break;
    }

    if (HideHack) {
        [hideesp addSubview:view];
    } else {
        [[UIApplication sharedApplication].keyWindow addSubview:view];
    }
    if (MenDeal) {
        if (hideesp.userInteractionEnabled !=true) hideesp.userInteractionEnabled =true;
    } else {
        if (hideesp.userInteractionEnabled !=false) hideesp.userInteractionEnabled =false; 
    }

    ImGuiIO& io = ImGui::GetIO();
    io.DisplaySize.x = view.bounds.size.width;
    io.DisplaySize.y = view.bounds.size.height;
    
    CGFloat framebufferScale = view.window.screen.nativeScale ?: UIScreen.mainScreen.nativeScale;
    io.DisplayFramebufferScale = ImVec2(framebufferScale, framebufferScale);
    io.DeltaTime = 1 / float(view.preferredFramesPerSecond ?: 60);
    view.preferredFramesPerSecond = IsFPSDraw;
    
    id<MTLCommandBuffer> commandBuffer = [self.commandQueue commandBuffer];
        
    if (MenDeal == true) {
        [self.mtkView setUserInteractionEnabled:YES];
    } else if (MenDeal == false) {
        [self.mtkView setUserInteractionEnabled:NO];
    }

    MTLRenderPassDescriptor* renderPassDescriptor = view.currentRenderPassDescriptor;
    if (renderPassDescriptor != nil)
    {
        id <MTLRenderCommandEncoder> renderEncoder = [commandBuffer renderCommandEncoderWithDescriptor:renderPassDescriptor];
        [renderEncoder pushDebugGroup:@"ImGui Jane"];

            ImGui_ImplMetal_NewFrame(renderPassDescriptor);
            ImGui::NewFrame();
            
            ImFont* font = ImGui::GetFont();
            font->Scale = 14.0f / font->FontSize;

            RenderBannerNotification();
            
            CGSize screenSize = [UIScreen mainScreen].bounds.size;

            ImGui::SetNextWindowSize(ImVec2(screenSize.width, screenSize.height));
            ImGui::SetNextWindowPos(ImVec2(0, 0));
            if (ImGui::Begin("alpha", nullptr, ImGuiWindowFlags_NoBackground | ImGuiWindowFlags_NoTitleBar | ImGuiWindowFlags_NoCollapse | ImGuiWindowFlags_NoResize | ImGuiWindowFlags_NoInputs | ImGuiWindowFlags_NoMove)) {
            GetActors(ImGui::GetBackgroundDrawList());
            }
            ImGui::End();

NSString *aliasKey = @"DARK IOS";
const char* ServerName = [aliasKey cStringUsingEncoding:NSUTF8StringEncoding];
std::string str = ServerName;

float fontSize = IsFontDraw * 1.5f;
float totalWidth = 0.0f;

for (char c : str) {
    std::string s(1, c);
    totalWidth += FontMenu->CalcTextSizeA(fontSize, FLT_MAX, 0.0f, s.c_str()).x;
}

float startX = screenSize.width / 2 - totalWidth / 2;
float x = startX;
float y = 75;
float time = ImGui::GetTime();

for (int i = 0; i < str.length(); ++i) {
    char c = str[i];
    std::string ch(1, c);
    float hue = fmodf((time * 0.3f + i * 0.1f), 1.0f);
    ImColor charColor = ImColor::HSV(hue, 0.0f, 1.0f);

    DrawTextWithOutlineX(
        ImGui::GetBackgroundDrawList(),
        ImVec2(x, y),
        ch,
        fontSize,
        charColor,
        outlineColor,
        drawOutline,
        FontMenu
    );

    x += FontMenu->CalcTextSizeA(fontSize, FLT_MAX, 0.0f, ch.c_str()).x;
}
            
            ImGuiIO& Io = ImGui::GetIO();
            ImGui::SetNextWindowPos(ImVec2(Io.DisplaySize.x * 0.5f, Io.DisplaySize.y * 0.5f), ImGuiCond_FirstUseEver, ImVec2(0.5f, 0.5f));
            ImGui::SetNextWindowSize({500, 300}, ImGuiCond_FirstUseEver);
            
            if (MenDeal == true)
            {            
                ImGui::Begin("DARK IOS", &MenDeal, ImGuiWindowFlags_NoCollapse | ImGuiWindowFlags_NoResize);
                ImVec2 windowSize = ImGui::GetContentRegionAvail();
                float leftColumnWidth = windowSize.x / 4;
                float rightColumnWidth = windowSize.x * 3 / 4 - 4.1;  
                
                ImGui::BeginChild("LeftColumn", ImVec2(leftColumnWidth, 0), true);
                int totalButtons = 7;
                float childHeight = ImGui::GetContentRegionAvail().y;
                float spacing = ImGui::GetStyle().ItemSpacing.y;
                float totalSpacing = spacing * (totalButtons - 1);
                float buttonHeight = (childHeight - totalSpacing) / totalButtons;
                float buttonWidth = ImGui::GetContentRegionAvail().x;

                if (ImGui::Button(IsEnglish == 0 ? "\uf015 Home" : "\uf015 Trang Chủ", ImVec2(buttonWidth, buttonHeight))) { Tab = 0; }
                if (ImGui::Button(IsEnglish == 0 ? "\uf007 Player" : "\uf007 Người Chơi", ImVec2(buttonWidth, buttonHeight))) { Tab = 1; }
                if (ImGui::Button(IsEnglish == 0 ? "\uf0e8 Item" : "\uf0e8 Vật Phẩm", ImVec2(buttonWidth, buttonHeight))) { Tab = 2; }
                if (ImGui::Button("\uf05b Aimbot", ImVec2(buttonWidth, buttonHeight))) { Tab = 3; }
                if (ImGui::Button("\uf044 Mod", ImVec2(buttonWidth, buttonHeight))) { Tab = 4; }
                if (ImGui::Button("\uf538 Memory", ImVec2(buttonWidth, buttonHeight))) { Tab = 5; }
                if (ImGui::Button(IsEnglish == 0 ? "\uf013 Setting" : "\uf013 Cài Đặt", ImVec2(buttonWidth, buttonHeight))) { Tab = 6; }
                ImGui::EndChild();
                ImGui::SameLine();
                
                float windowWidth = ImGui::GetContentRegionAvail().x;
                float checkboxWidth = windowWidth / 3.0f;
                ImGui::BeginChild("TabView", ImVec2(0, 0), true);
                
                if (Tab == 0) {}
                if (Tab == 1) {
                    ImGui::Checkbox(IsEnglish == 0 ? "Number Enemy" : "Số Địch", &IsNumberPlayer);
                    ImGui::SameLine(checkboxWidth);
                    ImGui::Checkbox(IsEnglish == 0 ? "Bone" : "Xương", &IsBone);
                    ImGui::SameLine(checkboxWidth * 2);
                    ImGui::Checkbox(IsEnglish == 0 ? "Box" : "Hộp", &IsBox);
                    ImGui::Checkbox(IsEnglish == 0 ? "Line" : "Đường Kẻ", &IsLine);
                    ImGui::SameLine(checkboxWidth);
                    ImGui::Checkbox(IsEnglish == 0 ? "Health" : "Máu", &IsHealth);
                    ImGui::SameLine(checkboxWidth * 2);
                    ImGui::Checkbox(IsEnglish == 0 ? "Name" : "Tên", &IsName);
                    ImGui::Checkbox(IsEnglish == 0 ? "Team" : "Đội", &IsTeam);
                    ImGui::SameLine(checkboxWidth);
                    ImGui::Checkbox(IsEnglish == 0 ? "Distance" : "Khoảng Cách", &IsDistance);
                    ImGui::SameLine(checkboxWidth * 2);
                    ImGui::Checkbox(IsEnglish == 0 ? "Weapon" : "Vũ Khí", &IsWeapon);
                    ImGui::Checkbox(IsEnglish == 0 ? "Nation" : "Quốc Gia", &IsNation);
                    ImGui::SameLine(checkboxWidth);
                    ImGui::Checkbox(IsEnglish == 0 ? "UID" : "UID", &IsUID);
                    ImGui::SameLine(checkboxWidth * 2);
                    ImGui::Checkbox(IsEnglish == 0 ? "Ignore Bot" : "Bỏ Qua Bot", &å±è½äººæº);
                    if (IsAlert360) {
                        ImGui::Checkbox("##456", &IsAlert360);
                        ImGui::SameLine();
                        ImGui::SliderFloat(IsEnglish == 0 ? "Warning 360" : "Cảnh Báo 360", &radiusalert, 0.0f, screenSize.height / 2, "%.0f");
                    } else {
                        ImGui::Checkbox(IsEnglish == 0 ? "Warning 360" : "Cảnh Báo 360", &IsAlert360);
                    }
                    ImGui::Separator();
                    ImGui::Combo(IsEnglish == 0 ? "Style ESP" : "Phong Cách ESP", &IsStyle, IsEnglish == 0 ? "iOS\0VN Hax\0" : "iOS\0VN Hax\0");
                    ImGui::Separator();
                    ImGui::SliderFloat(IsEnglish == 0 ? "Distance " : "Khoảng Cách ", &IsDistancePlayer, 0.0f, 750.0f, "%.0fM");
                    ImGui::Separator();
                    ImGui::SliderFloat(IsEnglish == 0 ? "Thickness Bone" : "Độ Dày Xương", &IsThicknessBone, 1.0f, 5.0f, "%.1f");
                    ImGui::SliderFloat(IsEnglish == 0 ? "Thickness Line" : "Độ Dày Đường Kẻ", &IsThicknessLine, 1.0f, 5.0f, "%.1f");
                    ImGui::Separator();
                    ImGui::Text(IsEnglish == 0 ? "Color Bone:" : "Màu Xương:");
                    ImGui::SameLine(checkboxWidth);
                    ImGui::ColorEdit3(IsEnglish == 0 ? "Visible" : "Nhìn Thấy", (float*)&ColorBoneVisible, ImGuiColorEditFlags_NoInputs);
                    ImGui::SameLine(checkboxWidth * 2);
                    ImGui::ColorEdit3(IsEnglish == 0 ? "Invisible" : "Bị Khuất", (float*)&ColorBoneInvisible, ImGuiColorEditFlags_NoInputs);
                    ImGui::Text(IsEnglish == 0 ? "Color Line:" : "Màu Đường Kẻ:");
                    ImGui::SameLine(checkboxWidth);
                    ImGui::ColorEdit3(IsEnglish == 0 ? "Visible " : "Nhìn Thấy ", (float*)&ColorLineVisible, ImGuiColorEditFlags_NoInputs);
                    ImGui::SameLine(checkboxWidth * 2);
                    ImGui::ColorEdit3(IsEnglish == 0 ? "Invisible " : "Bị Khuất ", (float*)&ColorLineInvisible, ImGuiColorEditFlags_NoInputs);
                    ImGui::Text(IsEnglish == 0 ? "Color Box:" : "Màu Hộp:");
                    ImGui::SameLine(checkboxWidth);
                    ImGui::ColorEdit3(IsEnglish == 0 ? "Visible  " : "Nhìn Thấy  ", (float*)&ColorBoxVisible, ImGuiColorEditFlags_NoInputs);
                    ImGui::SameLine(checkboxWidth * 2);
                    ImGui::ColorEdit3(IsEnglish == 0 ? "Invisible  " : "Bị Khuất  ", (float*)&ColorBoxInvisible, ImGuiColorEditFlags_NoInputs);
                }
                if (Tab == 2) {
                    ImGui::Checkbox(IsEnglish == 0 ? "Warning Bom" : "Cảnh Báo Bom", &IsWarningBom);
                    ImGui::SameLine(checkboxWidth);
                    ImGui::Checkbox("AR", &IsAR);
                    ImGui::SameLine(checkboxWidth * 2);
                    ImGui::Checkbox("SMG", &IsSMG);
                    ImGui::Checkbox("SR", &IsSR);
                    ImGui::SameLine(checkboxWidth);
                    ImGui::Checkbox("ShotGun", &IsShotGun);
                    ImGui::SameLine(checkboxWidth * 2);
                    ImGui::Checkbox("Bom", &IsBom);
                    ImGui::Checkbox(IsEnglish == 0 ? "Bullet" : "Đạn", &IsBullet);
                    ImGui::SameLine(checkboxWidth);
                    ImGui::Checkbox(IsEnglish == 0 ? "Recovery" : "Hồi Phục", &IsRecovery);
                    ImGui::SameLine(checkboxWidth * 2);
                    ImGui::Checkbox(IsEnglish == 0 ? "Vehicle" : "Phương Tiện", &IsVehicle);
                    ImGui::Checkbox(IsEnglish == 0 ? "Scope" : "Ống Ngắm", &IsScope);
                    ImGui::SameLine(checkboxWidth);
                    ImGui::Checkbox(IsEnglish == 0 ? "Dead Box" : "Hòm Xác", &IsDeadBox);
                    ImGui::SameLine(checkboxWidth * 2);
                    ImGui::Checkbox(IsEnglish == 0 ? "Air Drop" : "Hòm Thính", &IsAirDrop);
                    ImGui::Checkbox(IsEnglish == 0 ? "Armor & Helmet & Bag" : "Giáp & Mũ & Balo", &IsArmor);
                }
                if (Tab == 3) {
                    ImGui::RadioButton(IsEnglish == 0 ? "Off" : "Tắt", &IsCheckAimbot, 0);
                    ImGui::SameLine(checkboxWidth);
                    ImGui::RadioButton("Aimbot", &IsCheckAimbot, 1);
                    ImGui::Checkbox("Fov", &IsFov);
                    ImGui::SameLine(checkboxWidth);
                    ImGui::Checkbox(IsEnglish == 0 ? "Line" : "Đường Kẻ", &IsLineAimbot);
                    ImGui::SameLine(checkboxWidth * 2);
                    ImGui::Checkbox(IsEnglish == 0 ? "Ignore Knock" : "Bỏ Qua Gục", &IsIgnoreKnock);
                    ImGui::Checkbox(IsEnglish == 0 ? "Ignore Bot" : "Bỏ Qua Bot", &boquabots);
                    ImGui::SliderFloat(IsEnglish == 0 ? "Radius" : "Bán Kính", &IsRadius, 0.0f, screenSize.height / 2, "%.0f");
                    ImGui::SliderFloat(IsEnglish == 0 ? "Speed" : "Tốc Độ", &IsSpeed, 0.0f, 1.0f, "%.1f");
                    ImGui::SliderFloat(IsEnglish == 0 ? "Less Recoil" : "Giảm Giật", &IsRecoil, 0.0f, 5.0f, "%.1f");
                    ImGui::SliderFloat(IsEnglish == 0 ? "Distance" : "Khoảng Cách", &IsDistanceAimbot, 0.0f, 500.0f, "%.0fM");
                    ImGui::Combo(IsEnglish == 0 ? "Mode" : "Chế Độ", &IsMode, IsEnglish == 0 ? "Auto\0Fire\0Scope\0Fire & Scope\0Lock\0" : "Tự Động\0Bắn\0Ống Ngắm\0Bắn & Ống Ngắm\0Khóa\0");
                    ImGui::Combo(IsEnglish == 0 ? "Part" : "Vị Trí", &IsPart, IsEnglish == 0 ? "Random\0Head\0Body\0" : "Ngẫu Nhiên\0Đầu\0Thân\0");
                }
                if (Tab == 4) {
                    ImGui::Checkbox("Skin", &ModSkinn);
                    ImGui::SameLine(checkboxWidth);
                    ImGui::Checkbox(IsEnglish == 0 ? "Kill Message" : "Thông Báo Diệt", &initkillmsgopen);
                    ImGui::SameLine(checkboxWidth * 2);
                    ImGui::Checkbox(IsEnglish == 0 ? "Dead Box" : "Hòm Xác", &DeadBox);
                    ImGui::Checkbox(IsEnglish == 0 ? "Skin Lobby" : "Skin Sảnh", &skinlobby);

                    ImGui::Separator();
                    ImVec2 childSize = ImGui::GetWindowSize();
                    float buttonWidthMod = (childSize.x - ImGui::GetStyle().ItemSpacing.x * 2) / 3.0f - 3.0f;
                    if(ImGui::Button(IsEnglish == 0 ? "Player" : "Nhân Vật", ImVec2(buttonWidthMod, 0))) Settings::Tab = 0;
                    ImGui::SameLine();
                    if(ImGui::Button(IsEnglish == 0 ? "Weapon" : "Vũ Khí", ImVec2(buttonWidthMod, 0))) Settings::Tab = 1;
                    ImGui::SameLine();
                    if(ImGui::Button(IsEnglish == 0 ? "Vehicle" : "Phương Tiện", ImVec2(buttonWidthMod, 0))) Settings::Tab = 2;
                    ImGui::Separator();
                    
                    if (ModSkinn||initkillmsgopen||DeadBox||skinlobby||BagGun){
                        ImGui::BeginChild("ScrollableTabContent", ImVec2(0, 0), true, ImGuiWindowFlags_AlwaysVerticalScrollbar);
                        if (Settings::Tab == 0) {
                            ImGui::Checkbox("##Trang Phục", &preferences.Outfit);
                            ImGui::SameLine();
                            ImGui::Combo(IsEnglish == 0 ? "Outfit" : "Trang Phục", &preferences.Config.Skin.XSuits, "Default\0Golden Pharaoh X-Suit\0");
                            ImGui::Checkbox("##Balo", &preferences.Bagg);
                            ImGui::SameLine();
                            ImGui::Combo(IsEnglish == 0 ? "Bag" : "Balo", &preferences.bag, "Default\0Pharaoh\0");
                            ImGui::Checkbox("##Mũ", &preferences.Helmett);
                            ImGui::SameLine();
                            ImGui::Combo(IsEnglish == 0 ? "Helmet" : "Mũ", &preferences.helmet, "Default\0Inferno Rider\0");
                        }
                        if (Settings::Tab == 1) {
                            ImGui::Checkbox("##M416", &preferences.M416);
                            ImGui::SameLine();
                            ImGui::Combo("M416", &preferences.Config.Skin.M416, "Default\0Glacier\0");
                        }
                        if (Settings::Tab == 2) {
                            ImGui::Checkbox("##Dacia", &preferences.Dacia);
                            ImGui::SameLine();
                            ImGui::Combo("Dacia", &preferences.Config.Skin.Dacia, "Default\0Bentley\0");
                        }
                        ImGui::EndChild();
                    }
                }
                if (Tab == 5) {
                    ImGui::Checkbox(IsEnglish == 0 ? "Hide Name" : "Ẩn Tên", &hidename);
                    ImGui::Checkbox(IsEnglish == 0 ? "Unlock 120FPS & Ultra HD" : "Mở Khóa 120FPS & Ultra HD", &Unlock120FPS);
                    ImGui::Checkbox(IsEnglish == 0 ? "Custom View" : "Tùy Chỉnh Góc Nhìn", &IsView);
                    if (IsView) {
                        ImGui::SliderFloat("TPP", &IsTPPValue, 50.0f, 150.0f, "%.0f");
                        ImGui::SliderFloat("FPP", &IsFPPValue, 50.0f, 150.0f, "%.0f");
                    } 
                    ImGui::Checkbox(IsEnglish == 0 ? "Spin Player" : "Xoay Nhân Vật", &IsSpinCharacter);
                    if (IsSpinCharacter) {
                        ImGui::SliderFloat(IsEnglish == 0 ? "Speed" : "Tốc Độ", &spinspeed, 0.0f, 25.0f, "%.0f");
                    }
                    ImGui::Checkbox("Aimlock", &IsAimlock);
                }
                if (Tab == 6) {
                    float childWidth = ImGui::GetContentRegionAvail().x;
                    float buttonWidthAction = (childWidth - ImGui::GetStyle().ItemSpacing.x) * 0.5f;

                    if (ImGui::Button(IsEnglish == 0 ? "Save Config" : "Lưu Cấu Hình", ImVec2(buttonWidthAction, 0))) {
                        [self SaveSetting];
                        ShowBannerNotification(IsEnglish == 0 ? "Save Config Done" : "Đã Lưu Cấu Hình");
                    }
                    ImGui::SameLine();
                    if (ImGui::Button(IsEnglish == 0 ? "Use Config" : "Sử Dụng Cấu Hình", ImVec2(buttonWidthAction, 0))) {
                        [self UseSetting];
                        ShowBannerNotification(IsEnglish == 0 ? "Use Config Done" : "Đã Sử Dụng Cấu Hình");
                    }

                    if (ImGui::Button(IsEnglish == 0 ? "Reset Config" : "Đặt Lại Cấu Hình", ImVec2(childWidth, 0))) {
                        [self ResetSetting];
                        ShowBannerNotification(IsEnglish == 0 ? "Reset Config Done" : "Đã Đặt Lại Cấu Hình");
                    }
                    ImGui::Combo(IsEnglish == 0 ? "Language" : "Ngôn Ngữ", &IsEnglish, "English\0Tiếng Việt\0");
                    ImGui::SliderFloat(IsEnglish == 0 ? "Frame Rate" : "Tốc Độ Khung Hình", &IsFPSDraw, 30.0f, 120.0f, "%.0fFPS");
                    ImGui::Checkbox(IsEnglish == 0 ? "Border Text || Border Color" : "Viền Chữ || Màu Viền", &drawOutline);
                    ImGui::SameLine();
                    ImGui::ColorEdit3("##4343", (float*)&outlineColor, ImGuiColorEditFlags_NoInputs);
                    ImGui::Checkbox(IsEnglish == 0 ? "Hide Hack" : "Ẩn Hack", &HideHack);
                }
                ImGui::EndChild();
                ImGui::End();  
            }
        
        ImGui::Render();
        ImDrawData* draw_data = ImGui::GetDrawData();
        ImGui_ImplMetal_RenderDrawData(draw_data, commandBuffer, renderEncoder);
        
        [renderEncoder popDebugGroup];
        [renderEncoder endEncoding];
        
        [commandBuffer presentDrawable:view.currentDrawable];
        }
    [commandBuffer commit];
}

-(void)SaveSetting{ configManager::putBoolean(config,"Player", "NumberPlayer", IsNumberPlayer); }
-(void)UseSetting{ IsNumberPlayer = configManager::readBoolean(config,"Player", "NumberPlayer", false); }
-(void)ResetSetting{ IsNumberPlayer = false; }

- (void)mtkView:(MTKView*)view drawableSizeWillChange:(CGSize)size {}

@end
