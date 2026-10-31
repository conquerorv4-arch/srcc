#import <UIKit/UIKit.h>
#import <MetalKit/MetalKit.h>
#import "imgui.h"
#import "imgui_impl_metal.h"
#import "Settings.h"
// Menu state variables matching the requested layout
namespace MenuState {
bool active = true;
int currentTab = 0;
bool activateBypass = false;
}
// DARK IOS Menu Renderer Function
void RenderMenu() {
if (!MenuState::active) return;
// Set fixed window style and size matching DARK IOS v4.6
ImGui::SetNextWindowSize(ImVec2(600, 400), ImGuiCond_FirstUseEver);
if (ImGui::Begin("DARK IOS v4.6", &MenuState::active, ImGuiWindowFlags_NoCollapse | ImGuiWindowFlags_NoResize)) {
// Left side: Sidebar with classic tabs
ImGui::BeginChild("Sidebar", ImVec2(120, 0), true);
ImGui::Text("MENU");
ImGui::Separator();
const char* tabs[] = { "Main", "ESP", "Aim", "Loot", "Skin", "Memory", "Movement", "Settings" };
for (int i = 0; i < 8; i++) {
if (ImGui::Selectable(tabs[i], MenuState::currentTab == i)) {
MenuState::currentTab = i;
}
}
ImGui::EndChild();
ImGui::SameLine();
// Right side: Content container matching selected tab
ImGui::BeginChild("Content", ImVec2(0, 0), true);
switch (MenuState::currentTab) {
case 0: // Main Tab
if (ImGui::Button("ACTIVATE BYPASS SYSTEM", ImVec2(-1, 30))) {
MenuState::activateBypass = !MenuState::activateBypass;
}
ImGui::Spacing();
ImGui::Separator();
ImGui::Spacing();
ImGui::Text("pwwzww & darkhxte :)");
ImGui::Text("CHANNEL @QTYG1");
ImGui::Text("OWNER @ZIRVEDEYIM0");
break;
case 1: // ESP Tab (Linked with Settings.h variables)
ImGui::Text("ESP Settings");
ImGui::Separator();
ImGui::Checkbox("ESP Box", &Settings::ESP_Box);
ImGui::Checkbox("ESP Line", &Settings::ESP_Line);
ImGui::Checkbox("ESP Distance", &Settings::ESP_Distance);
ImGui::SliderFloat("Max Distance", &Settings::ESP_MaxDistance, 50.0f, 500.0f);
break;
case 2: // Aimbot Tab (Linked with Settings.h variables)
ImGui::Text("Aimbot Settings");
ImGui::Separator();
ImGui::Checkbox("Enable Aimbot", &Settings::Aimbot);
ImGui::SliderFloat("Aimbot FOV", &Settings::AimbotFOV, 10.0f, 300.0f);
break;
case 3: // Loot
ImGui::Text("Loot Filter Options");
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
ImGui::Text("Movement Tweaks");
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
