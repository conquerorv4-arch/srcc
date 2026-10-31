#import <UIKit/UIKit.h>
#include <string>
// ImGui Forward Declarations (Assuming ImGui headers are included in your project)
namespace ImGui {
bool Begin(const char* name, bool* p_open = NULL, int flags = 0);
void End();
bool BeginChild(const char* str_id, const ImVec2& size = ImVec2(0,0), bool border = false, int flags = 0);
void EndChild();
bool Selectable(const char* label, bool selected = false, int flags = 0, const ImVec2& size = ImVec2(0,0));
bool Button(const char* label, const ImVec2& size = ImVec2(0,0));
bool Checkbox(const char* label, bool* v);
void Text(const char* fmt, ...);
void Separator();
void Spacing();
void SetNextWindowSize(const ImVec2& size, int cond = 0);
}
struct ImVec2 {
float x, y;
ImVec2() : x(0.0f), y(0.0f) {}
ImVec2(float _x, float _y) : x(_x), y(_y) {}
};
#define ImGuiWindowFlags_NoCollapse 1 << 5
#define ImGuiWindowFlags_NoResize   1 << 4
#define ImGuiCond_FirstUseEver      1 << 2
// Global Menu State
namespace MenuState {
bool active = true;
int currentTab = 0;
bool activateBypass = false;
}
// API Client Interface & Implementation
@interface APIClient : NSObject
@property (nonatomic, strong) NSString *packageToken;
￼ (void)paid:(void(^)(BOOL success))completion;
￼ (NSString *)getKey;
@end
@implementation APIClient
￼ (void)paid:(void(^)(BOOL success))completion {
NSString *currentKey = [self getKey];
if (!currentKey || [currentKey length] == 0) {
if (completion) completion(NO);
return;
}
NSString *urlString = [NSString stringWithFormat:@"https://srcc-zoab.onrender.com/check?key=%@", currentKey];
NSURL *url = [NSURL URLWithString:urlString];
NSURLRequest *request = [NSURLRequest requestWithURL:url];
NSURLSessionDataTask *task = [[NSURLSession sharedSession] dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
if (error || !data) {
if (completion) completion(NO);
return;
}
NSError *jsonError;
NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:0 error:&jsonError];
if (json && [json[@"status"] isEqualToString:@"success"]) {
if (completion) completion(YES);
} else {
if (completion) completion(NO);
}
}];
[task resume];
}
￼ (NSString *)getKey {
return [[NSUserDefaults standardUserDefaults] stringForKey:@"UserCustomKey"] ?: @"";
}
￼ (void)setToken:(NSString *)token {
self.packageToken = token;
}
@end
// DARK IOS Menu Renderer Function
void RenderDarkIOSMenu() {
if (!MenuState::active) return;
ImGui::SetNextWindowSize(ImVec2(600, 400), ImGuiCond_FirstUseEver);
if (ImGui::Begin("DARK IOS v4.6", &MenuState::active, ImGuiWindowFlags_NoCollapse | ImGuiWindowFlags_NoResize)) {
// Sidebar (Tabs)
ImGui::BeginChild("Sidebar", ImVec2(120, 0), true);
ImGui::Text("MENU");
ImGui::Separator();
const char* tabs[] = { "Main", "ESP", "Loot", "Aim", "Skin", "Memory", "Movement", "Settings" };
for (int i = 0; i < 8; i++) {
if (ImGui::Selectable(tabs[i], MenuState::currentTab == i)) {
MenuState::currentTab = i;
}
}
ImGui::EndChild();
ImGui::SameLine();
// Content Area
ImGui::BeginChild("Content", ImVec2(0, 0), true);
switch (MenuState::currentTab) {
case 0: // Main
if (ImGui::Button("ACTIVATE BYPASS SYSTEM", ImVec2(-1, 30))) {
MenuState::activateBypass = !MenuState::activateBypass;
// Trigger API Check on Bypass Activation
APIClient *client = [[APIClient alloc] init];
[client paid:^(BOOL success) {
if (success) {
NSLog(@"Bypass & Key Verification Successful!");
} else {
NSLog(@"Key Verification Failed!");
}
}];
}
ImGui::Spacing();
ImGui::Separator();
ImGui::Spacing();
ImGui::Text("pwwzww & darkhxte :)");
ImGui::Text("CHANNEL @QTYG1");
ImGui::Text("OWNER @ZIRVEDEYIM0");
break;
case 1: // ESP
ImGui::Text("ESP Settings");
ImGui::Separator();
ImGui::Checkbox("Enable Box ESP", &MenuState::activateBypass);
break;
case 2: // Loot
ImGui::Text("Loot Filter Options");
ImGui::Separator();
break;
case 3: // Aim
ImGui::Text("Aimbot Settings");
ImGui::Separator();
break;
case 4: // Skin
ImGui::Text("Skinchanger Options");
ImGui::Separator();
break;
case 5: // Memory
ImGui::Text("Memory Hacks & Offsets");
ImGui::Separator();
break;
case 6: // Movement
ImGui::Text("Movement Tweaks (Bhop, etc.)");
ImGui::Separator();
break;
case 7: // Settings
ImGui::Text("Menu Configuration");
ImGui::Separator();
break;
}
ImGui::EndChild();
}
ImGui::End();
}
